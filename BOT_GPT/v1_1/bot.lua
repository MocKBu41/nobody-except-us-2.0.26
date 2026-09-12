-- NEU BOT v1.1
-- Random duel_tanks70/80/90 tank selection + immediate next flag attack.
require([[/script/multiplayer/bot.data]])

local C={Units={},Candidates={},SpawnIntents={},SpawnTickets={},AwaitingArrival=nil,SquadRole={},DeadSquads={},DeferredOrders={},Time=0,Timer=nil,TimerGeneration=0,State="OPENING",CurrentAttackFlag=nil,AttackCheckAt=nil,NextAttackAt=nil,FlagCursor=0,WarningPrinted=false,EnemySignals={aatSeenAt=nil,aatDestroyedAt=nil,aatStage=0,aircraftSeenAt=nil,aircraftDestroyedAt=nil,aircraftResponseAt=nil}}

local function log(m) print("[NEU-BOT] "..tostring(m)) end
local function lower(s) return string.lower(tostring(s or "")) end
local function splitTags(tags) local o={} for t in string.gmatch(tags or "","%S+") do o[lower(t)]=true end return o end
local function hasTag(r,t) return r and r.tagset and r.tagset[lower(t)]==true end
local function isDuelTank(r) return hasTag(r,"duel_tanks70") or hasTag(r,"duel_tanks80") or hasTag(r,"duel_tanks90") end

local function roleMatches(r,role)
    if role=="recon" then return hasTag(r,"all") and hasTag(r,"recon") end
    if role=="infantry" then return hasTag(r,"all") and hasTag(r,"infantry") end
    if role=="antiair" then return hasTag(r,"all") and hasTag(r,"antiair") end
    if role=="tank" then return isDuelTank(r) end
    if role=="aircraftlight" then return hasTag(r,"aircraftlight") end
    if role=="aat" then return hasTag(r,"aat") end
    if role=="antirad" then return hasTag(r,"antirad") end
    if role=="strike" then return hasTag(r,"strike") end
    if role=="duel_heli" then return hasTag(r,"duel_heli") end
    if role=="duel_fighter" then return hasTag(r,"duel_fighter") end
    return false
end

local function detectSide(line) return line:match('%f[%w]side%s*%(%s*([^%)%s]+)%s*%)') or line:match('%f[%w]s%s*%(%s*([^%)%s]+)%s*%)') end

local function parseRecords(raw)
    local records,buffer,stack={},{},{}
    local quoted,escaped,comment=false,false,false
    for i=1,#raw do
        local ch=raw:sub(i,i)
        if comment then
            if ch=="\n" then comment=false if #stack>0 then buffer[#buffer+1]=" " end end
        elseif quoted then
            buffer[#buffer+1]=ch
            if escaped then escaped=false elseif ch=="\\" then escaped=true elseif ch=='"' then quoted=false end
        elseif ch==";" then comment=true
        elseif ch=='"' then if #stack>0 then buffer[#buffer+1]=ch quoted=true end
        elseif ch=="(" or ch=="{" then stack[#stack+1]=ch buffer[#buffer+1]=ch
        elseif ch==")" or ch=="}" then
            if #stack>0 then
                local expected=ch==")" and "(" or "{"
                if stack[#stack]~=expected then return records end
                buffer[#buffer+1]=ch stack[#stack]=nil
                if #stack==0 then records[#records+1]=table.concat(buffer) buffer={} end
            end
        elseif #stack>0 then buffer[#buffer+1]=ch end
    end
    return records
end

function readUnitsRaw(fname,units,army)
    local f=io.open(fname,"r")
    if not f then log("FILE MISSING "..fname) return end
    local raw=f:read("*a") f:close()
    units.count=units.count or 1 units.seen=units.seen or {}
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
                    if not rec.nobot then units[units.count]=rec units.count=units.count+1 units.seen[id]=true added=added+1 end
                end
            end
        end
    end
    log("READ "..fname.." added="..added)
end

local function buildCandidates()
    local roles={"recon","infantry","antiair","tank","aircraftlight","aat","antirad","strike","duel_heli","duel_fighter"}
    C.Candidates={}
    for _,r in ipairs(roles) do C.Candidates[r]={} end
    for _,rec in ipairs(C.Units) do
        if type(rec)=="table" then
            for _,r in ipairs(roles) do if roleMatches(rec,r) then C.Candidates[r][#C.Candidates[r]+1]=rec end end
        end
    end
    for _,r in ipairs(roles) do log("ROLE "..r.." candidates="..#C.Candidates[r]) end
end

local function enqueueSpawn(role,reason,delaySec,target)
    local due=C.Time+(delaySec or 0)
    C.SpawnIntents[#C.SpawnIntents+1]={role=role,reason=reason or "",due=due,target=target,attempts=0,tried={}}
    log("QUEUE role="..role.." due="..due.." reason="..tostring(reason))
end

local function chooseUntried(intent)
    local list=C.Candidates[intent.role] or {}
    local available={}
    for _,rec in ipairs(list) do if not intent.tried[rec.unit] then available[#available+1]=rec end end
    if #available==0 then return nil end
    local rec=available[math.random(1,#available)]
    intent.tried[rec.unit]=true
    if intent.role=="tank" then log("TANK RANDOM unit="..tostring(rec.unit).." tags="..tostring(rec.tags)) end
    return rec
end

local function processSpawn()
    if C.AwaitingArrival then return end
    local index=nil
    for i,intent in ipairs(C.SpawnIntents) do if intent.due<=C.Time then index=i break end end
    if not index then return end
    local intent=table.remove(C.SpawnIntents,index)
    local rec=chooseUntried(intent)
    if not rec then log("NO UNIT role="..intent.role) return end
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
            intent.due=C.Time+NEU_BOT.SpawnRetrySec C.SpawnIntents[#C.SpawnIntents+1]=intent log("SPAWN REJECTED role="..intent.role.." retry")
        else log("SPAWN FAILED role="..intent.role.." all candidates tried") end
    end
end

local function flags()
    local my=BotApi.Instance.team local enemy=BotApi.Instance.enemyTeam
    local f={mine={},enemy={},neutral={},mineCount=0,enemyCount=0,neutralCount=0}
    for _,flag in pairs(BotApi.Scene.Flags) do
        if flag.occupant==my then f.mine[#f.mine+1]=flag.name f.mineCount=f.mineCount+1
        elseif flag.occupant==enemy then f.enemy[#f.enemy+1]=flag.name f.enemyCount=f.enemyCount+1
        else f.neutral[#f.neutral+1]=flag.name f.neutralCount=f.neutralCount+1 end
    end
    table.sort(f.mine) table.sort(f.enemy) table.sort(f.neutral)
    return f
end

local function flagOccupant(name) for _,flag in pairs(BotApi.Scene.Flags) do if flag.name==name then return flag.occupant end end return nil end
local function chooseAttackFlag()
    local f=flags() local list=#f.neutral>0 and f.neutral or f.enemy
    if #list==0 then return nil end
    C.FlagCursor=C.FlagCursor+1 if C.FlagCursor>#list then C.FlagCursor=1 end
    return list[C.FlagCursor]
end
local function chooseOwnFlag()
    local f=flags() if #f.mine==0 then return nil end
    C.FlagCursor=C.FlagCursor+1 if C.FlagCursor>#f.mine then C.FlagCursor=1 end
    return f.mine[C.FlagCursor]
end

local function squadAlive(id) return id and BotApi.Scene:IsSquadExists(id) end
local function capture(id,flag)
    if id and flag and squadAlive(id) then
        log("ORDER squad="..tostring(id).." flag="..tostring(flag).." role="..tostring(C.SquadRole[id]))
        BotApi.Commands:CaptureFlag(id,flag)
    end
end
local function deferCapture(id,flag,delay) C.DeferredOrders[#C.DeferredOrders+1]={squad=id,flag=flag,due=C.Time+(delay or 0)} end
local function processDeferredOrders()
    for i=#C.DeferredOrders,1,-1 do local x=C.DeferredOrders[i] if x.due<=C.Time then capture(x.squad,x.flag) table.remove(C.DeferredOrders,i) end end
end

local function giveRoleOrder(id,role,target)
    if not squadAlive(id) then return end
    if role=="antiair" or role=="aat" then capture(id,chooseOwnFlag()) return end
    if role=="tank" then if target then deferCapture(id,target,NEU_BOT.VehicleFollowDelaySec) end return end
    if target then capture(id,target) end
end

local function orderAllAttack(target)
    C.DeferredOrders={}
    for id,role in pairs(C.SquadRole) do if squadAlive(id) and (role=="infantry" or role=="recon") then giveRoleOrder(id,role,target) end end
    for id,role in pairs(C.SquadRole) do if squadAlive(id) and role~="infantry" and role~="recon" then giveRoleOrder(id,role,target) end end
end
local function orderDefense()
    C.DeferredOrders={}
    for id,role in pairs(C.SquadRole) do if squadAlive(id) then giveRoleOrder(id,role,chooseOwnFlag()) end end
end

local function startAttack()
    local target=chooseAttackFlag()
    if not target then C.State="DEFEND" C.CurrentAttackFlag=nil orderDefense() log("STATE -> DEFEND no attack flags") return end
    C.State="ATTACK" C.CurrentAttackFlag=target C.AttackCheckAt=C.Time+NEU_BOT.AttackResultCheckSec C.NextAttackAt=nil
    log("ATTACK flag="..target)
    orderAllAttack(target)
end

local function processAttack()
    if C.State~="ATTACK" or not C.CurrentAttackFlag then return end
    if flagOccupant(C.CurrentAttackFlag)==BotApi.Instance.team then
        local capturedFlag=C.CurrentAttackFlag
        log("ATTACK SUCCESS flag="..capturedFlag.." -> NEXT FLAG")
        C.CurrentAttackFlag=nil
        enqueueSpawn("infantry","defend captured flag",0,capturedFlag)
        startAttack()
        return
    end
    if C.Time < (C.AttackCheckAt or 999999) then return end
    log("ATTACK STALLED flag="..tostring(C.CurrentAttackFlag))
    enqueueSpawn("aircraftlight","support stalled attack",0,C.CurrentAttackFlag)
    enqueueSpawn("infantry","defend line before attack",0,chooseOwnFlag())
    C.State="WAIT" C.NextAttackAt=C.Time+5 C.CurrentAttackFlag=nil
end

local function detectOwnLosses()
    for id,role in pairs(C.SquadRole) do
        if not C.DeadSquads[id] and not squadAlive(id) then
            C.DeadSquads[id]=true log("LOST squad="..tostring(id).." role="..tostring(role))
            if role=="tank" then enqueueSpawn("tank","replace destroyed tank",0,C.CurrentAttackFlag) enqueueSpawn("infantry","tank loss infantry support",0,C.CurrentAttackFlag) end
        end
    end
end

local function processStrategicLoop()
    if C.State=="OPENING" then
        if C.Time>=6 then C.State="WAIT" C.NextAttackAt=NEU_BOT.AttackWaitSec log("OPENING COMPLETE -> WAIT") end
        return
    end
    if C.State=="WAIT" then
        local f=flags()
        if f.enemyCount>f.mineCount or (C.NextAttackAt and C.Time>=C.NextAttackAt) then startAttack() end
    elseif C.State=="ATTACK" then processAttack()
    elseif C.State=="DEFEND" then local f=flags() if f.enemyCount>=f.mineCount then C.State="WAIT" C.NextAttackAt=C.Time+5 end end
end

local function processEnemyRules()
    local s=C.EnemySignals
    if s.aatSeenAt and s.aatStage==1 and C.Time>=s.aatSeenAt+NEU_BOT.AntiRadDelaySec then
        enqueueSpawn("antirad","enemy aat response",0,C.CurrentAttackFlag) s.aatStage=2 s.aatCheckAt=C.Time+NEU_BOT.EnemyResponseCheckSec
    elseif s.aatStage==2 and s.aatCheckAt and C.Time>=s.aatCheckAt then
        if s.aatDestroyedAt and s.aatDestroyedAt>=s.aatSeenAt then enqueueSpawn("duel_heli","aat destroyed",0,C.CurrentAttackFlag) s.aatStage=0
        else enqueueSpawn("antirad","aat survived",0,C.CurrentAttackFlag) enqueueSpawn("strike","aat survived",0,C.CurrentAttackFlag) s.aatStage=3 s.aatCheckAt=C.Time+NEU_BOT.EnemyResponseCheckSec end
    elseif s.aatStage==3 and s.aatCheckAt and C.Time>=s.aatCheckAt then
        if s.aatDestroyedAt and s.aatDestroyedAt>=s.aatSeenAt then enqueueSpawn("duel_heli","aat destroyed after strike",0,C.CurrentAttackFlag) s.aatStage=0
        else enqueueSpawn("antirad","repeat aat suppression",0,C.CurrentAttackFlag) enqueueSpawn("strike","repeat aat suppression",0,C.CurrentAttackFlag) s.aatCheckAt=C.Time+NEU_BOT.EnemyResponseCheckSec end
    end
    if s.aircraftSeenAt and s.aircraftResponseAt and C.Time>=s.aircraftResponseAt then
        if s.aircraftDestroyedAt and s.aircraftDestroyedAt>=s.aircraftSeenAt then enqueueSpawn("tank","aircraft destroyed reward",0,C.CurrentAttackFlag) enqueueSpawn("infantry","aircraft destroyed reward",0,C.CurrentAttackFlag)
        else enqueueSpawn("duel_fighter","aircraft still alive",0,C.CurrentAttackFlag) end
        s.aircraftResponseAt=nil
    end
end

function NEU_BOT_EnemyTagSeen(tag)
    tag=lower(tag)
    if tag=="aat" then C.EnemySignals.aatSeenAt=C.Time C.EnemySignals.aatDestroyedAt=nil C.EnemySignals.aatStage=1
    elseif tag=="aircraft" then
        C.EnemySignals.aircraftSeenAt=C.Time C.EnemySignals.aircraftDestroyedAt=nil C.EnemySignals.aircraftResponseAt=C.Time+NEU_BOT.EnemyResponseCheckSec
        if math.random(2)==1 then enqueueSpawn("duel_fighter","enemy aircraft 50/50 response",0,C.CurrentAttackFlag) else enqueueSpawn("aat","enemy aircraft 50/50 response",0,chooseOwnFlag()) end
    end
end
function NEU_BOT_EnemyTagDestroyed(tag) tag=lower(tag) if tag=="aat" then C.EnemySignals.aatDestroyedAt=C.Time elseif tag=="aircraft" then C.EnemySignals.aircraftDestroyedAt=C.Time end end

local function onSecond()
    C.Time=C.Time+1 detectOwnLosses() processDeferredOrders() processEnemyRules() processStrategicLoop() processSpawn()
    if not C.WarningPrinted and C.Time>=2 then log("NOTE enemy aat/aircraft tag sensor is not verified; response branches await a sensor hook") C.WarningPrinted=true end
    if C.Time%30==0 then log("TIME="..C.Time.." STATE="..C.State.." TARGET="..tostring(C.CurrentAttackFlag)) end
end
local function stopClock() C.TimerGeneration=C.TimerGeneration+1 if C.Timer then BotApi.Events:KillQuantTimer(C.Timer) C.Timer=nil end end
local function startClock()
    stopClock() local generation=C.TimerGeneration
    local function pulse() if generation~=C.TimerGeneration then return end C.Timer=nil onSecond() if generation==C.TimerGeneration then C.Timer=BotApi.Events:SetQuantTimer(pulse,NEU_BOT.TickMs) end end
    C.Timer=BotApi.Events:SetQuantTimer(pulse,NEU_BOT.TickMs)
end

function onGameStart()
    math.randomseed(os.time()*BotApi.Instance.hostId)
    C.Units={} C.Units.count=1 readAllUnits(nil,C.Units,BotApi.Instance.army) buildCandidates()
    C.SpawnIntents={} C.SpawnTickets={} C.AwaitingArrival=nil C.SquadRole={} C.DeadSquads={} C.DeferredOrders={}
    C.Time=0 C.State="OPENING" C.CurrentAttackFlag=nil C.AttackCheckAt=nil C.NextAttackAt=nil C.FlagCursor=0 C.WarningPrinted=false
    C.EnemySignals={aatSeenAt=nil,aatDestroyedAt=nil,aatStage=0,aircraftSeenAt=nil,aircraftDestroyedAt=nil,aircraftResponseAt=nil}
    enqueueSpawn("recon","opening",0,nil)
    enqueueSpawn("infantry","opening",0,nil)
    enqueueSpawn("antiair","opening",0,nil)
    enqueueSpawn("tank","opening",NEU_BOT.OpeningTankDelaySec,nil)
    log("START v1.1 army="..tostring(BotApi.Instance.army).." units="..tostring(C.Units.count-1))
    startClock() processSpawn()
end
function onGameStop() stopClock() collectgarbage("collect") end
function onGameQuant() processSpawn() end
function onGameSpawn(args)
    local ticket=nil if #C.SpawnTickets>0 then ticket=table.remove(C.SpawnTickets,1) end
    if not ticket then log("UNMATCHED SPAWN squad="..tostring(args.squadId)) return end
    if C.AwaitingArrival==ticket then C.AwaitingArrival=nil end
    C.SquadRole[args.squadId]=ticket.role C.DeadSquads[args.squadId]=false
    log("ARRIVED squad="..tostring(args.squadId).." role="..ticket.role.." unit="..ticket.unit)
    local target=ticket.target or C.CurrentAttackFlag
    if ticket.reason=="defend captured flag" and ticket.target then capture(args.squadId,ticket.target)
    elseif ticket.reason=="defend line before attack" and ticket.target then capture(args.squadId,ticket.target)
    else giveRoleOrder(args.squadId,ticket.role,target) end
    processSpawn()
end

BotApi.Events:Subscribe(BotApi.Events.GameStart,onGameStart)
BotApi.Events:Subscribe(BotApi.Events.GameEnd,onGameStop)
BotApi.Events:Subscribe(BotApi.Events.Quant,onGameQuant)
BotApi.Events:Subscribe(BotApi.Events.GameSpawn,onGameSpawn)
