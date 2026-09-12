-- NEU BOT v1.3
-- Based on v1.2. Fixes:
-- 1) opening squads immediately receive an opening flag;
-- 2) flag selection no longer uses lexicographic f1,f10,f11,f2 sorting;
-- 3) next target prefers the closest numbered frontier flag to already owned flags;
-- 4) infantry orders are reissued so dismounted infantry keeps moving/attacking;
-- 5) detached/new squad ids found in BotApi.Scene.Squads receive the current infantry objective.

require([[/script/multiplayer/bot.data]])

local C = {
    Units={}, Candidates={}, SpawnIntents={}, SpawnTickets={}, AwaitingArrival=nil,
    SquadRole={}, DeadSquads={}, DeferredOrders={}, InfantryTarget={},
    Time=0, Timer=nil, TimerGeneration=0,
    State="OPENING", CurrentAttackFlag=nil, AttackCheckAt=nil, NextAttackAt=nil,
    OpeningFlag=nil, PatrolCursor=0, NextPatrolAt=0, NextTankReinforcementAt=0,
    NextInfantryOrderAt=0,
    ReconSquad=nil, ReconTarget=nil, ReconVisited={}, WarningPrinted=false,
    EnemySignals={aatSeenAt=nil,aatDestroyedAt=nil,aatStage=0,aircraftSeenAt=nil,aircraftDestroyedAt=nil,aircraftResponseAt=nil}
}

local function log(m) print("[NEU-BOT] "..tostring(m)) end
local function lower(s) return string.lower(tostring(s or "")) end

local function splitTags(tags)
    local out={}
    for t in string.gmatch(tags or "","%S+") do out[lower(t)]=true end
    return out
end

local function hasTag(rec,tag)
    return rec and rec.tagset and rec.tagset[lower(tag)]==true
end

local function isDuelTank(rec)
    return hasTag(rec,"duel_tanks70") or hasTag(rec,"duel_tanks80") or hasTag(rec,"duel_tanks90")
end

local function roleMatches(rec,role)
    if role=="recon" then return hasTag(rec,"all") and hasTag(rec,"recon") end
    if role=="infantry" then return hasTag(rec,"all") and hasTag(rec,"infantry") end
    if role=="antiair" then return hasTag(rec,"all") and hasTag(rec,"antiair") end
    if role=="tank" then return isDuelTank(rec) end
    if role=="aircraftlight" then return hasTag(rec,"aircraftlight") end
    if role=="aat" then return hasTag(rec,"aat") end
    if role=="antirad" then return hasTag(rec,"antirad") end
    if role=="strike" then return hasTag(rec,"strike") end
    if role=="duel_heli" then return hasTag(rec,"duel_heli") end
    if role=="duel_fighter" then return hasTag(rec,"duel_fighter") end
    return false
end

local function detectSide(line)
    return line:match('%f[%w]side%s*%(%s*([^%)%s]+)%s*%)') or line:match('%f[%w]s%s*%(%s*([^%)%s]+)%s*%)')
end

local function parseRecords(raw)
    local records,buffer,stack={},{},{}
    local quoted,escaped,comment=false,false,false
    for i=1,#raw do
        local ch=raw:sub(i,i)
        if comment then
            if ch=="\n" then
                comment=false
                if #stack>0 then buffer[#buffer+1]=" " end
            end
        elseif quoted then
            buffer[#buffer+1]=ch
            if escaped then
                escaped=false
            elseif ch=="\\" then
                escaped=true
            elseif ch=='"' then
                quoted=false
            end
        elseif ch==";" then
            comment=true
        elseif ch=='"' then
            if #stack>0 then
                buffer[#buffer+1]=ch
                quoted=true
            end
        elseif ch=="(" or ch=="{" then
            stack[#stack+1]=ch
            buffer[#buffer+1]=ch
        elseif ch==")" or ch=="}" then
            if #stack>0 then
                local expected=(ch==")") and "(" or "{"
                if stack[#stack]~=expected then return records end
                buffer[#buffer+1]=ch
                stack[#stack]=nil
                if #stack==0 then
                    records[#records+1]=table.concat(buffer)
                    buffer={}
                end
            end
        elseif #stack>0 then
            buffer[#buffer+1]=ch
        end
    end
    return records
end

function readUnitsRaw(fname,units,army)
    local f=io.open(fname,"r")
    if not f then
        log("FILE MISSING "..fname)
        return
    end
    local raw=f:read("*a")
    f:close()
    units.count=units.count or 1
    units.seen=units.seen or {}
    local added=0
    for _,line in ipairs(parseRecords(raw)) do
        local side=detectSide(line)
        if side and lower(side)==lower(army) then
            local tagParts={}
            for tags in line:gmatch('%f[%w]t%s*%(([^)]*)%)') do tagParts[#tagParts+1]=tags end
            local tags=table.concat(tagParts," ")
            local vehicle=line:match('^%s*{%s*"([^"]+)"')
            local name=vehicle or line:match('%f[%w]name%s*%(([^)]+)%)')
            if name and not name:find("mp/",1,true) then
                local id=vehicle or (name.."("..army..")")
                if not units.seen[id] then
                    local rec={unit=id,tags=tags,tagset=splitTags(tags),raw=line,side=side,nobot=(line:find("nobot",1,true)~=nil)}
                    if not rec.nobot then
                        units[units.count]=rec
                        units.count=units.count+1
                        units.seen[id]=true
                        added=added+1
                    end
                end
            end
        end
    end
    log("READ "..fname.." added="..added)
end

local function buildCandidates()
    local roles={"recon","infantry","antiair","tank","aircraftlight","aat","antirad","strike","duel_heli","duel_fighter"}
    C.Candidates={}
    for _,role in ipairs(roles) do C.Candidates[role]={} end
    for _,rec in ipairs(C.Units) do
        if type(rec)=="table" then
            for _,role in ipairs(roles) do
                if roleMatches(rec,role) then C.Candidates[role][#C.Candidates[role]+1]=rec end
            end
        end
    end
    for _,role in ipairs(roles) do log("ROLE "..role.." candidates="..#C.Candidates[role]) end
end

local function enqueueSpawn(role,reason,delaySec,target)
    local due=C.Time+(delaySec or 0)
    C.SpawnIntents[#C.SpawnIntents+1]={role=role,reason=reason or "",due=due,target=target,attempts=0,tried={}}
    log("QUEUE role="..role.." due="..due.." reason="..tostring(reason).." target="..tostring(target))
end

local function chooseUntried(intent)
    local list=C.Candidates[intent.role] or {}
    local available={}
    for _,rec in ipairs(list) do
        if not intent.tried[rec.unit] then available[#available+1]=rec end
    end
    if #available==0 then return nil end
    local rec=available[math.random(1,#available)]
    intent.tried[rec.unit]=true
    if intent.role=="tank" then log("TANK RANDOM unit="..tostring(rec.unit).." tags="..tostring(rec.tags)) end
    return rec
end

local function processSpawn()
    if C.AwaitingArrival then return end
    local index=nil
    for i,intent in ipairs(C.SpawnIntents) do
        if intent.due<=C.Time then index=i break end
    end
    if not index then return end
    local intent=table.remove(C.SpawnIntents,index)
    local rec=chooseUntried(intent)
    if not rec then
        log("NO UNIT role="..intent.role)
        return
    end
    intent.attempts=intent.attempts+1
    local ticket={role=intent.role,reason=intent.reason,target=intent.target,unit=rec.unit}
    C.SpawnTickets[#C.SpawnTickets+1]=ticket
    local ok=BotApi.Commands:Spawn(rec.unit,MaxSquadSize)
    if ok then
        C.AwaitingArrival=ticket
        log("SPAWN OK role="..intent.role.." unit="..rec.unit)
    else
        table.remove(C.SpawnTickets,#C.SpawnTickets)
        if intent.attempts < #(C.Candidates[intent.role] or {}) then
            intent.due=C.Time+NEU_BOT.SpawnRetrySec
            C.SpawnIntents[#C.SpawnIntents+1]=intent
            log("SPAWN REJECTED role="..intent.role.." retry")
        else
            log("SPAWN FAILED role="..intent.role.." all candidates tried")
        end
    end
end

local function flags()
    local my=BotApi.Instance.team
    local enemy=BotApi.Instance.enemyTeam
    local f={mine={},enemy={},neutral={},mineCount=0,enemyCount=0,neutralCount=0}
    for _,flag in pairs(BotApi.Scene.Flags) do
        if flag.occupant==my then
            f.mine[#f.mine+1]=flag.name
            f.mineCount=f.mineCount+1
        elseif flag.occupant==enemy then
            f.enemy[#f.enemy+1]=flag.name
            f.enemyCount=f.enemyCount+1
        else
            f.neutral[#f.neutral+1]=flag.name
            f.neutralCount=f.neutralCount+1
        end
    end
    return f
end

local function flagOccupant(name)
    for _,flag in pairs(BotApi.Scene.Flags) do
        if flag.name==name then return flag.occupant end
    end
    return nil
end

local function flagNumber(name)
    if type(name)~="string" then return nil end
    return tonumber(name:match("(%d+)$"))
end

local function chooseOpeningFlag()
    local my=BotApi.Instance.team
    for _,flag in pairs(BotApi.Scene.Flags) do
        if flag.occupant~=my then
            log("OPENING FLAG="..tostring(flag.name))
            return flag.name
        end
    end
    return nil
end

local function numericFrontierDistance(candidate,mine)
    local cn=flagNumber(candidate)
    if not cn then return nil end
    local best=nil
    for _,owned in ipairs(mine) do
        local on=flagNumber(owned)
        if on then
            local d=math.abs(cn-on)
            if not best or d<best then best=d end
        end
    end
    return best
end

local function chooseAttackFlag()
    local f=flags()
    local list=(#f.neutral>0) and f.neutral or f.enemy
    if #list==0 then return nil end

    if #f.mine>0 then
        local bestName=nil
        local bestDistance=nil
        for _,name in ipairs(list) do
            local d=numericFrontierDistance(name,f.mine)
            if d and (not bestDistance or d<bestDistance) then
                bestName=name
                bestDistance=d
            end
        end
        if bestName then
            log("TARGET FRONTIER flag="..bestName.." numericDistance="..bestDistance)
            return bestName
        end
    end

    log("TARGET FIRST flag="..tostring(list[1]))
    return list[1]
end

local function chooseOwnFlag()
    local f=flags()
    if #f.mine==0 then return nil end
    C.PatrolCursor=C.PatrolCursor+1
    if C.PatrolCursor>#f.mine then C.PatrolCursor=1 end
    return f.mine[C.PatrolCursor]
end

local function chooseReconFlag()
    local target=chooseAttackFlag()
    if not target then return nil end
    if not C.ReconVisited[target] then
        C.ReconVisited[target]=true
        return target
    end

    local f=flags()
    local list=(#f.neutral>0) and f.neutral or f.enemy
    for _,name in ipairs(list) do
        if not C.ReconVisited[name] then
            C.ReconVisited[name]=true
            return name
        end
    end
    C.ReconVisited={}
    C.ReconVisited[target]=true
    return target
end

local function squadAlive(id)
    return id and BotApi.Scene:IsSquadExists(id)
end

local function capture(id,flag)
    if id and flag and squadAlive(id) then
        log("ORDER squad="..tostring(id).." flag="..tostring(flag).." role="..tostring(C.SquadRole[id]))
        BotApi.Commands:CaptureFlag(id,flag)
    end
end

local function setInfantryTarget(id,target)
    if id and target then C.InfantryTarget[id]=target end
end

local function deferCapture(id,flag,delay)
    C.DeferredOrders[#C.DeferredOrders+1]={squad=id,flag=flag,due=C.Time+(delay or 0)}
end

local function processDeferredOrders()
    for i=#C.DeferredOrders,1,-1 do
        local order=C.DeferredOrders[i]
        if order.due<=C.Time then
            capture(order.squad,order.flag)
            table.remove(C.DeferredOrders,i)
        end
    end
end

local function giveRoleOrder(id,role,target)
    if not squadAlive(id) then return end
    if role=="antiair" or role=="aat" then
        capture(id,chooseOwnFlag())
        return
    end
    if role=="tank" then
        if target then deferCapture(id,target,NEU_BOT.VehicleFollowDelaySec) end
        return
    end
    if role=="infantry" or role=="infantry_detached" then
        if target then
            setInfantryTarget(id,target)
            capture(id,target)
        end
        return
    end
    if target then capture(id,target) end
end

local function discoverDetachedSquads()
    for _,squad in pairs(BotApi.Scene.Squads) do
        if squad and not C.SquadRole[squad] and squadAlive(squad) then
            C.SquadRole[squad]="infantry_detached"
            C.DeadSquads[squad]=false
            local target=C.CurrentAttackFlag or C.OpeningFlag or chooseOwnFlag()
            if target then
                C.InfantryTarget[squad]=target
                log("DETACHED squad="..tostring(squad).." -> flag="..tostring(target))
                capture(squad,target)
            else
                log("DETACHED squad="..tostring(squad).." no target")
            end
        end
    end
end

local function processInfantryOrders()
    if C.Time<C.NextInfantryOrderAt then return end
    C.NextInfantryOrderAt=C.Time+NEU_BOT.InfantryReissueSec

    discoverDetachedSquads()

    for id,role in pairs(C.SquadRole) do
        if squadAlive(id) and (role=="infantry" or role=="infantry_detached") then
            local target=C.InfantryTarget[id]
            if C.State=="ATTACK" and C.CurrentAttackFlag then
                target=C.CurrentAttackFlag
                C.InfantryTarget[id]=target
            end
            if target then
                log("INFANTRY PUSH squad="..tostring(id).." flag="..tostring(target))
                capture(id,target)
            end
        end
    end
end

local function orderAllAttack(target)
    C.DeferredOrders={}
    for id,role in pairs(C.SquadRole) do
        if squadAlive(id) and (role=="infantry" or role=="infantry_detached" or role=="recon") then
            giveRoleOrder(id,role,target)
        end
    end
    for id,role in pairs(C.SquadRole) do
        if squadAlive(id) and role=="tank" then giveRoleOrder(id,role,target) end
    end
end

local function orderDefense()
    C.DeferredOrders={}
    for id,role in pairs(C.SquadRole) do
        if squadAlive(id) then
            if role=="infantry" or role=="infantry_detached" then
                local target=chooseOwnFlag()
                if target then setInfantryTarget(id,target) capture(id,target) end
            elseif role=="antiair" or role=="aat" then
                capture(id,chooseOwnFlag())
            end
        end
    end
end

local function startAttack()
    local target=chooseAttackFlag()
    if not target then
        C.State="DEFEND"
        C.CurrentAttackFlag=nil
        orderDefense()
        log("STATE -> DEFEND no attack flags")
        return
    end
    C.State="ATTACK"
    C.CurrentAttackFlag=target
    C.AttackCheckAt=C.Time+NEU_BOT.AttackResultCheckSec
    C.NextAttackAt=nil
    log("ATTACK flag="..target)
    orderAllAttack(target)
end

local function afterAttackResult()
    local f=flags()
    C.CurrentAttackFlag=nil
    if f.mineCount>f.enemyCount then
        C.State="WAIT"
        C.NextAttackAt=C.Time+NEU_BOT.AttackWaitSec
        orderDefense()
        log("BALANCE advantage="..f.mineCount..":"..f.enemyCount.." -> WAIT 5m")
    else
        C.State="WAIT"
        C.NextAttackAt=C.Time+NEU_BOT.NextAttackDelaySec
        log("BALANCE no advantage="..f.mineCount..":"..f.enemyCount.." -> NEXT ATTACK")
    end
end

local function processAttack()
    if C.State~="ATTACK" or not C.CurrentAttackFlag then return end
    if flagOccupant(C.CurrentAttackFlag)==BotApi.Instance.team then
        local captured=C.CurrentAttackFlag
        log("ATTACK SUCCESS flag="..captured)
        enqueueSpawn("infantry","defend captured flag",0,captured)
        afterAttackResult()
        return
    end
    if C.Time < (C.AttackCheckAt or 999999) then return end
    local stalled=C.CurrentAttackFlag
    log("ATTACK STALLED flag="..tostring(stalled))
    enqueueSpawn("aircraftlight","support stalled attack",0,stalled)
    enqueueSpawn("infantry","defend line before attack",0,chooseOwnFlag())
    afterAttackResult()
end

local function processRecon()
    if not C.ReconSquad or not squadAlive(C.ReconSquad) then return end
    if C.ReconTarget and flagOccupant(C.ReconTarget)~=BotApi.Instance.team then return end
    if C.ReconTarget then log("RECON CAPTURED flag="..C.ReconTarget) end
    C.ReconTarget=chooseReconFlag()
    if C.ReconTarget then
        log("RECON NEXT flag="..C.ReconTarget)
        capture(C.ReconSquad,C.ReconTarget)
    end
end

local function processAntiAirPatrol()
    if C.Time<C.NextPatrolAt then return end
    C.NextPatrolAt=C.Time+NEU_BOT.AntiAirPatrolSec
    for id,role in pairs(C.SquadRole) do
        if squadAlive(id) and (role=="antiair" or role=="aat") then
            local target=chooseOwnFlag()
            if target then
                log("AA PATROL squad="..tostring(id).." flag="..target)
                capture(id,target)
            end
        end
    end
end

local function processTankReinforcement()
    if C.Time<C.NextTankReinforcementAt then return end
    C.NextTankReinforcementAt=C.Time+NEU_BOT.TankReinforcementSec
    enqueueSpawn("tank","5 minute tank reinforcement",0,C.CurrentAttackFlag or C.OpeningFlag)
    log("TANK 5M reinforcement queued")
end

local function detectOwnLosses()
    for id,role in pairs(C.SquadRole) do
        if not C.DeadSquads[id] and not squadAlive(id) then
            C.DeadSquads[id]=true
            C.InfantryTarget[id]=nil
            log("LOST squad="..tostring(id).." role="..tostring(role))
            if role=="tank" then
                enqueueSpawn("tank","replace destroyed tank",0,C.CurrentAttackFlag or C.OpeningFlag)
                enqueueSpawn("infantry","tank loss infantry support",0,C.CurrentAttackFlag or C.OpeningFlag)
            elseif role=="recon" and C.ReconSquad==id then
                C.ReconSquad=nil
                C.ReconTarget=nil
            end
        end
    end
end

local function processStrategicLoop()
    if C.State=="OPENING" then
        if C.Time>=6 then
            C.State="WAIT"
            C.NextAttackAt=NEU_BOT.AttackWaitSec
            log("OPENING COMPLETE -> WAIT")
        end
        return
    end

    if C.State=="WAIT" then
        local f=flags()
        if f.enemyCount>f.mineCount or (C.NextAttackAt and C.Time>=C.NextAttackAt) then startAttack() end
    elseif C.State=="ATTACK" then
        processAttack()
    elseif C.State=="DEFEND" then
        local f=flags()
        if f.enemyCount>=f.mineCount then
            C.State="WAIT"
            C.NextAttackAt=C.Time+NEU_BOT.NextAttackDelaySec
        end
    end
end

local function processEnemyRules()
    local s=C.EnemySignals
    if s.aatSeenAt and s.aatStage==1 and C.Time>=s.aatSeenAt+NEU_BOT.AntiRadDelaySec then
        enqueueSpawn("antirad","enemy aat response",0,C.CurrentAttackFlag)
        s.aatStage=2
        s.aatCheckAt=C.Time+NEU_BOT.EnemyResponseCheckSec
    elseif s.aatStage==2 and s.aatCheckAt and C.Time>=s.aatCheckAt then
        if s.aatDestroyedAt and s.aatDestroyedAt>=s.aatSeenAt then
            enqueueSpawn("duel_heli","aat destroyed",0,C.CurrentAttackFlag)
            s.aatStage=0
        else
            enqueueSpawn("antirad","aat survived",0,C.CurrentAttackFlag)
            enqueueSpawn("strike","aat survived",0,C.CurrentAttackFlag)
            s.aatStage=3
            s.aatCheckAt=C.Time+NEU_BOT.EnemyResponseCheckSec
        end
    elseif s.aatStage==3 and s.aatCheckAt and C.Time>=s.aatCheckAt then
        if s.aatDestroyedAt and s.aatDestroyedAt>=s.aatSeenAt then
            enqueueSpawn("duel_heli","aat destroyed after strike",0,C.CurrentAttackFlag)
            s.aatStage=0
        else
            enqueueSpawn("antirad","repeat aat suppression",0,C.CurrentAttackFlag)
            enqueueSpawn("strike","repeat aat suppression",0,C.CurrentAttackFlag)
            s.aatCheckAt=C.Time+NEU_BOT.EnemyResponseCheckSec
        end
    end

    if s.aircraftSeenAt and s.aircraftResponseAt and C.Time>=s.aircraftResponseAt then
        if s.aircraftDestroyedAt and s.aircraftDestroyedAt>=s.aircraftSeenAt then
            enqueueSpawn("tank","aircraft destroyed reward",0,C.CurrentAttackFlag)
            enqueueSpawn("infantry","aircraft destroyed reward",0,C.CurrentAttackFlag)
        else
            enqueueSpawn("duel_fighter","aircraft still alive",0,C.CurrentAttackFlag)
        end
        s.aircraftResponseAt=nil
    end
end

function NEU_BOT_EnemyTagSeen(tag)
    tag=lower(tag)
    if tag=="aat" then
        C.EnemySignals.aatSeenAt=C.Time
        C.EnemySignals.aatDestroyedAt=nil
        C.EnemySignals.aatStage=1
        log("ENEMY TAG aat seen")
    elseif tag=="aircraft" then
        C.EnemySignals.aircraftSeenAt=C.Time
        C.EnemySignals.aircraftDestroyedAt=nil
        C.EnemySignals.aircraftResponseAt=C.Time+NEU_BOT.EnemyResponseCheckSec
        if math.random(2)==1 then
            enqueueSpawn("duel_fighter","enemy aircraft 50/50 response",0,C.CurrentAttackFlag)
        else
            enqueueSpawn("aat","enemy aircraft 50/50 response",0,chooseOwnFlag())
        end
        log("ENEMY TAG aircraft seen")
    end
end

function NEU_BOT_EnemyTagDestroyed(tag)
    tag=lower(tag)
    if tag=="aat" then
        C.EnemySignals.aatDestroyedAt=C.Time
    elseif tag=="aircraft" then
        C.EnemySignals.aircraftDestroyedAt=C.Time
    end
end

local function onSecond()
    C.Time=C.Time+1
    detectOwnLosses()
    processDeferredOrders()
    processEnemyRules()
    processStrategicLoop()
    processAntiAirPatrol()
    processTankReinforcement()
    processRecon()
    processInfantryOrders()
    processSpawn()

    if not C.WarningPrinted and C.Time>=2 then
        log("NOTE v1.3 uses repeated CaptureFlag + detached squad discovery for dismounted infantry")
        C.WarningPrinted=true
    end
    if C.Time%30==0 then
        log("TIME="..C.Time.." STATE="..C.State.." TARGET="..tostring(C.CurrentAttackFlag).." OPENING="..tostring(C.OpeningFlag).." RECON="..tostring(C.ReconTarget))
    end
end

local function stopClock()
    C.TimerGeneration=C.TimerGeneration+1
    if C.Timer then
        BotApi.Events:KillQuantTimer(C.Timer)
        C.Timer=nil
    end
end

local function startClock()
    stopClock()
    local generation=C.TimerGeneration
    local function pulse()
        if generation~=C.TimerGeneration then return end
        C.Timer=nil
        onSecond()
        if generation==C.TimerGeneration then
            C.Timer=BotApi.Events:SetQuantTimer(pulse,NEU_BOT.TickMs)
        end
    end
    C.Timer=BotApi.Events:SetQuantTimer(pulse,NEU_BOT.TickMs)
end

function onGameStart()
    math.randomseed(os.time()*BotApi.Instance.hostId)
    C.Units={}
    C.Units.count=1
    readAllUnits(nil,C.Units,BotApi.Instance.army)
    buildCandidates()

    C.SpawnIntents={}
    C.SpawnTickets={}
    C.AwaitingArrival=nil
    C.SquadRole={}
    C.DeadSquads={}
    C.DeferredOrders={}
    C.InfantryTarget={}
    C.Time=0
    C.State="OPENING"
    C.CurrentAttackFlag=nil
    C.AttackCheckAt=nil
    C.NextAttackAt=nil
    C.OpeningFlag=chooseOpeningFlag()
    C.PatrolCursor=0
    C.NextPatrolAt=0
    C.NextTankReinforcementAt=NEU_BOT.TankReinforcementSec
    C.NextInfantryOrderAt=0
    C.ReconSquad=nil
    C.ReconTarget=nil
    C.ReconVisited={}
    C.WarningPrinted=false
    C.EnemySignals={aatSeenAt=nil,aatDestroyedAt=nil,aatStage=0,aircraftSeenAt=nil,aircraftDestroyedAt=nil,aircraftResponseAt=nil}

    enqueueSpawn("recon","opening recon",0,C.OpeningFlag)
    enqueueSpawn("infantry","opening infantry 1",0,C.OpeningFlag)
    enqueueSpawn("infantry","opening infantry 2",0,C.OpeningFlag)
    enqueueSpawn("antiair","opening aa",0,nil)
    enqueueSpawn("tank","opening tank",NEU_BOT.OpeningTankDelaySec,C.OpeningFlag)

    log("START v1.3 army="..tostring(BotApi.Instance.army).." units="..tostring(C.Units.count-1).." opening="..tostring(C.OpeningFlag))
    startClock()
    processSpawn()
end

function onGameStop()
    stopClock()
    collectgarbage("collect")
end

function onGameQuant()
    processSpawn()
end

function onGameSpawn(args)
    local ticket=nil
    if #C.SpawnTickets>0 then ticket=table.remove(C.SpawnTickets,1) end
    if not ticket then
        log("UNMATCHED SPAWN squad="..tostring(args.squadId))
        C.SquadRole[args.squadId]="infantry_detached"
        C.DeadSquads[args.squadId]=false
        local target=C.CurrentAttackFlag or C.OpeningFlag or chooseOwnFlag()
        if target then
            C.InfantryTarget[args.squadId]=target
            capture(args.squadId,target)
        end
        return
    end

    if C.AwaitingArrival==ticket then C.AwaitingArrival=nil end
    C.SquadRole[args.squadId]=ticket.role
    C.DeadSquads[args.squadId]=false
    log("ARRIVED squad="..tostring(args.squadId).." role="..ticket.role.." unit="..ticket.unit.." target="..tostring(ticket.target))

    local target=ticket.target or C.CurrentAttackFlag or C.OpeningFlag

    if ticket.role=="recon" and not C.ReconSquad then
        C.ReconSquad=args.squadId
        C.ReconTarget=target or chooseReconFlag()
        if C.ReconTarget then capture(args.squadId,C.ReconTarget) end
    elseif ticket.reason=="defend captured flag" and ticket.target then
        setInfantryTarget(args.squadId,ticket.target)
        capture(args.squadId,ticket.target)
    elseif ticket.reason=="defend line before attack" and ticket.target then
        setInfantryTarget(args.squadId,ticket.target)
        capture(args.squadId,ticket.target)
    else
        giveRoleOrder(args.squadId,ticket.role,target)
    end

    processSpawn()
end

BotApi.Events:Subscribe(BotApi.Events.GameStart,onGameStart)
BotApi.Events:Subscribe(BotApi.Events.GameEnd,onGameStop)
BotApi.Events:Subscribe(BotApi.Events.Quant,onGameQuant)
BotApi.Events:Subscribe(BotApi.Events.GameSpawn,onGameSpawn)
