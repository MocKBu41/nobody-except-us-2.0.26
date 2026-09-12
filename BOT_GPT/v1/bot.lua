-- NEU BOT v1
-- Logic source: user bot-logic.json + stable BotApi patterns from the stock/COLDWAR bot.
-- Important: enemy unit TAG detection is not exposed by the verified BotApi used here.
-- The response branches for aat/aircraft are implemented and can be triggered through
-- NEU_BOT_EnemyTagSeen(tag) / NEU_BOT_EnemyTagDestroyed(tag) once a verified sensor hook is found.

require([[/script/multiplayer/bot.data]])

local C = {
    Units = {},
    Candidates = {},
    RoleCursor = {},
    SpawnIntents = {},
    SpawnRequest = nil,
    SpawnTickets = {},
    AwaitingArrival = nil,
    SquadRole = {},
    SquadTarget = {},
    DeadSquads = {},
    DeferredOrders = {},
    Time = 0,
    Timer = nil,
    TimerGeneration = 0,
    State = "OPENING",
    CurrentAttackFlag = nil,
    AttackStartedAt = nil,
    AttackCheckAt = nil,
    NextAttackAt = nil,
    FlagCursor = 0,
    EnemySignals = {
        aatSeenAt = nil,
        aatDestroyedAt = nil,
        aatStage = 0,
        aircraftSeenAt = nil,
        aircraftDestroyedAt = nil,
        aircraftResponseAt = nil
    },
    WarningPrinted = false
}

local function log(msg)
    print("[NEU-BOT] " .. tostring(msg))
end

local function lower(s)
    return string.lower(tostring(s or ""))
end

local function splitTags(tags)
    local out = {}
    for t in string.gmatch(tags or "", "%S+") do out[lower(t)] = true end
    return out
end

local function hasTag(rec, tag)
    return rec and rec.tagset and rec.tagset[lower(tag)] == true
end

local function roleMatches(rec, role)
    if role == "recon" then return hasTag(rec,"all") and hasTag(rec,"recon") end
    if role == "infantry" then return hasTag(rec,"all") and hasTag(rec,"infantry") end
    if role == "antiair" then return hasTag(rec,"all") and hasTag(rec,"antiair") end
    if role == "tank_usa" then return hasTag(rec,"tank_usa") end
    if role == "aircraftlight" then return hasTag(rec,"aircraftlight") end
    if role == "aat" then return hasTag(rec,"aat") end
    if role == "antirad" then return hasTag(rec,"antirad") end
    if role == "strike" then return hasTag(rec,"strike") end
    if role == "duel_heli" then return hasTag(rec,"duel_heli") end
    if role == "duel_fighter" then return hasTag(rec,"duel_fighter") end
    return false
end

local function detectSide(line)
    return line:match('%f[%w]side%s*%(%s*([^%)%s]+)%s*%)')
        or line:match('%f[%w]s%s*%(%s*([^%)%s]+)%s*%)')
end

local function parseRecords(raw)
    local records, buffer, stack = {}, {}, {}
    local quoted, escaped, comment = false, false, false
    for i=1,#raw do
        local ch=raw:sub(i,i)
        if comment then
            if ch=="\n" then
                comment=false
                if #stack>0 then buffer[#buffer+1]=" " end
            end
        elseif quoted then
            buffer[#buffer+1]=ch
            if escaped then escaped=false
            elseif ch=="\\" then escaped=true
            elseif ch=='"' then quoted=false end
        elseif ch==";" then
            comment=true
        elseif ch=='"' then
            if #stack>0 then buffer[#buffer+1]=ch; quoted=true end
        elseif ch=="(" or ch=="{" then
            stack[#stack+1]=ch
            buffer[#buffer+1]=ch
        elseif ch==")" or ch=="}" then
            if #stack>0 then
                local expected = ch==")" and "(" or "{"
                if stack[#stack] ~= expected then return records end
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

function readUnitsRaw(fname, units, army)
    local f=io.open(fname,"r")
    if not f then
        log("FILE MISSING "..fname)
        return
    end
    local raw=f:read("*a")
    f:close()
    local records=parseRecords(raw)
    units.count=units.count or 1
    units.seen=units.seen or {}
    local added=0

    for _,line in ipairs(records) do
        local side=detectSide(line)
        if side and lower(side)==lower(army) then
            local tagParts={}
            for tags in line:gmatch('%f[%w]t%s*%(([^)]*)%)') do
                tagParts[#tagParts+1]=tags
            end
            local tags=table.concat(tagParts," ")
            local vehicle=line:match('^%s*{%s*"([^"]+)"')
            local name=vehicle or line:match('%f[%w]name%s*%(([^)]+)%)')
            if name and not name:find("mp/",1,true) then
                local id=vehicle or (name.."("..army..")")
                if not units.seen[id] then
                    local count=0
                    for n in line:gmatch('%f[%w]c%d+%s*%([^)]*:(%d+)') do count=count+tonumber(n) end
                    if count<1 then count=1 end
                    local rec={
                        unit=id,
                        tags=tags,
                        tagset=splitTags(tags),
                        count=count,
                        raw=line,
                        side=side,
                        nobot=(line:find("nobot",1,true)~=nil)
                    }
                    -- Keep original bot safety: do not buy nobot units.
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
    C.Candidates={}
    local roles={"recon","infantry","antiair","tank_usa","aircraftlight","aat","antirad","strike","duel_heli","duel_fighter"}
    for _,r in ipairs(roles) do C.Candidates[r]={} end
    for _,rec in ipairs(C.Units) do
        if type(rec)=="table" then
            for _,r in ipairs(roles) do
                if roleMatches(rec,r) then C.Candidates[r][#C.Candidates[r]+1]=rec end
            end
        end
    end
    for _,r in ipairs(roles) do
        log("ROLE "..r.." candidates="..#C.Candidates[r])
    end
end

local function nextCandidate(role)
    local list=C.Candidates[role] or {}
    if #list==0 then return nil end
    local i=(C.RoleCursor[role] or 0)+1
    if i>#list then i=1 end
    C.RoleCursor[role]=i
    return list[i]
end

local function enqueueSpawn(role, reason, delaySec, target)
    local due=C.Time+(delaySec or 0)
    C.SpawnIntents[#C.SpawnIntents+1]={role=role,reason=reason or "",due=due,target=target,attempts=0}
    log("QUEUE role="..role.." due="..due.." reason="..tostring(reason))
end

local function processSpawn()
    if C.SpawnRequest or C.AwaitingArrival then return end
    local index=nil
    for i,intent in ipairs(C.SpawnIntents) do
        if intent.due<=C.Time then index=i; break end
    end
    if not index then return end

    local intent=table.remove(C.SpawnIntents,index)
    local rec=nextCandidate(intent.role)
    if not rec then
        log("NO UNIT role="..intent.role)
        return
    end

    intent.rec=rec
    intent.attempts=(intent.attempts or 0)+1
    C.SpawnRequest=intent

    local ticket={role=intent.role,reason=intent.reason,target=intent.target,unit=rec.unit}
    C.SpawnTickets[#C.SpawnTickets+1]=ticket
    local ok=BotApi.Commands:Spawn(rec.unit,MaxSquadSize)

    if ok then
        C.AwaitingArrival=ticket
        C.SpawnRequest=nil
        log("SPAWN OK role="..intent.role.." unit="..rec.unit)
    else
        for i=#C.SpawnTickets,1,-1 do
            if C.SpawnTickets[i]==ticket then table.remove(C.SpawnTickets,i); break end
        end
        C.SpawnRequest=nil
        if intent.attempts < math.max(1,#(C.Candidates[intent.role] or {})) then
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
        if flag.occupant==my then f.mine[#f.mine+1]=flag.name; f.mineCount=f.mineCount+1
        elseif flag.occupant==enemy then f.enemy[#f.enemy+1]=flag.name; f.enemyCount=f.enemyCount+1
        else f.neutral[#f.neutral+1]=flag.name; f.neutralCount=f.neutralCount+1 end
    end
    table.sort(f.mine)
    table.sort(f.enemy)
    table.sort(f.neutral)
    return f
end

local function flagOccupant(name)
    for _,flag in pairs(BotApi.Scene.Flags) do
        if flag.name==name then return flag.occupant end
    end
    return nil
end

local function chooseAttackFlag()
    local f=flags()
    local list=#f.neutral>0 and f.neutral or f.enemy
    if #list==0 then return nil end
    C.FlagCursor=C.FlagCursor+1
    if C.FlagCursor>#list then C.FlagCursor=1 end
    return list[C.FlagCursor]
end

local function chooseOwnFlag()
    local f=flags()
    if #f.mine==0 then return nil end
    C.FlagCursor=C.FlagCursor+1
    if C.FlagCursor>#f.mine then C.FlagCursor=1 end
    return f.mine[C.FlagCursor]
end

local function squadAlive(id)
    return id and BotApi.Scene:IsSquadExists(id)
end

local function capture(id,flag)
    if id and flag and squadAlive(id) then
        BotApi.Commands:CaptureFlag(id,flag)
    end
end

local function deferCapture(id,flag,delay)
    C.DeferredOrders[#C.DeferredOrders+1]={squad=id,flag=flag,due=C.Time+(delay or 0)}
end

local function processDeferredOrders()
    for i=#C.DeferredOrders,1,-1 do
        local x=C.DeferredOrders[i]
        if x.due<=C.Time then
            capture(x.squad,x.flag)
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
    if role=="tank_usa" then
        if target then deferCapture(id,target,NEU_BOT.VehicleFollowDelaySec) end
        return
    end
    if target then capture(id,target) end
end

local function orderAllAttack(target)
    -- Infantry/recon first. Tank follows after five seconds.
    for id,role in pairs(C.SquadRole) do
        if squadAlive(id) and (role=="infantry" or role=="recon") then giveRoleOrder(id,role,target) end
    end
    for id,role in pairs(C.SquadRole) do
        if squadAlive(id) and role~="infantry" and role~="recon" then giveRoleOrder(id,role,target) end
    end
end

local function orderDefense()
    for id,role in pairs(C.SquadRole) do
        if squadAlive(id) then giveRoleOrder(id,role,chooseOwnFlag()) end
    end
end

local function startAttack()
    local target=chooseAttackFlag()
    if not target then
        C.State="DEFEND"
        orderDefense()
        return
    end
    C.State="ATTACK"
    C.CurrentAttackFlag=target
    C.AttackStartedAt=C.Time
    C.AttackCheckAt=C.Time+NEU_BOT.AttackResultCheckSec
    C.NextAttackAt=nil
    log("ATTACK flag="..target)
    orderAllAttack(target)
end

local function resolveAttack()
    if C.State~="ATTACK" or not C.CurrentAttackFlag then return end
    if C.Time<C.AttackCheckAt then return end

    local my=BotApi.Instance.team
    local captured=(flagOccupant(C.CurrentAttackFlag)==my)
    if captured then
        log("ATTACK SUCCESS flag="..C.CurrentAttackFlag)
        enqueueSpawn("infantry","defend captured flag",0,C.CurrentAttackFlag)
    else
        log("ATTACK STALLED flag="..C.CurrentAttackFlag)
        enqueueSpawn("aircraftlight","support stalled attack",0,C.CurrentAttackFlag)
        enqueueSpawn("infantry","defend line before attack",0,chooseOwnFlag())
    end

    local f=flags()
    if f.mineCount>f.enemyCount then
        C.State="WAIT"
        C.NextAttackAt=C.Time+NEU_BOT.AttackWaitSec
        orderDefense()
        log("STATE WAIT advantage="..f.mineCount..":"..f.enemyCount)
    else
        C.State="WAIT"
        C.NextAttackAt=C.Time+5
        log("STATE WAIT short; no flag advantage")
    end
    C.CurrentAttackFlag=nil
end

local function detectOwnLosses()
    for id,role in pairs(C.SquadRole) do
        if not C.DeadSquads[id] and not squadAlive(id) then
            C.DeadSquads[id]=true
            log("LOST squad="..tostring(id).." role="..tostring(role))
            if role=="tank_usa" then
                enqueueSpawn("tank_usa","replace destroyed tank",0,C.CurrentAttackFlag)
                enqueueSpawn("infantry","tank loss infantry support",0,C.CurrentAttackFlag)
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
        -- User rule: attack after 5 minutes OR earlier if the player owns more flags.
        if f.enemyCount>f.mineCount or (C.NextAttackAt and C.Time>=C.NextAttackAt) then
            startAttack()
        end
    elseif C.State=="ATTACK" then
        resolveAttack()
    elseif C.State=="DEFEND" then
        local f=flags()
        if f.enemyCount>=f.mineCount then
            C.State="WAIT"
            C.NextAttackAt=C.Time+5
        end
    end
end

local function processEnemyRules()
    local s=C.EnemySignals

    if s.aatSeenAt and s.aatStage==1 and C.Time>=s.aatSeenAt+NEU_BOT.AntiRadDelaySec then
        enqueueSpawn("antirad","enemy aat response",0,C.CurrentAttackFlag)
        s.aatStage=2
        s.aatCheckAt=C.Time+NEU_BOT.EnemyResponseCheckSec
        log("AAT response stage 2: antirad")
    elseif s.aatStage==2 and s.aatCheckAt and C.Time>=s.aatCheckAt then
        if s.aatDestroyedAt and s.aatDestroyedAt>=s.aatSeenAt then
            enqueueSpawn("duel_heli","aat destroyed",0,C.CurrentAttackFlag)
            s.aatStage=0
            log("AAT destroyed -> duel_heli")
        else
            enqueueSpawn("antirad","aat survived first suppression",0,C.CurrentAttackFlag)
            enqueueSpawn("strike","aat survived first suppression",0,C.CurrentAttackFlag)
            s.aatStage=3
            s.aatCheckAt=C.Time+NEU_BOT.EnemyResponseCheckSec
            log("AAT survived -> antirad + strike")
        end
    elseif s.aatStage==3 and s.aatCheckAt and C.Time>=s.aatCheckAt then
        if s.aatDestroyedAt and s.aatDestroyedAt>=s.aatSeenAt then
            enqueueSpawn("duel_heli","aat destroyed after strike",0,C.CurrentAttackFlag)
            s.aatStage=0
            log("AAT destroyed after strike -> duel_heli")
        else
            enqueueSpawn("antirad","repeat aat suppression",0,C.CurrentAttackFlag)
            enqueueSpawn("strike","repeat aat suppression",0,C.CurrentAttackFlag)
            s.aatCheckAt=C.Time+NEU_BOT.EnemyResponseCheckSec
        end
    end

    if s.aircraftSeenAt and s.aircraftResponseAt and C.Time>=s.aircraftResponseAt then
        if s.aircraftDestroyedAt and s.aircraftDestroyedAt>=s.aircraftSeenAt then
            enqueueSpawn("tank_usa","aircraft destroyed reward",0,C.CurrentAttackFlag)
            enqueueSpawn("infantry","aircraft destroyed reward",0,C.CurrentAttackFlag)
        else
            enqueueSpawn("duel_fighter","aircraft still alive",0,C.CurrentAttackFlag)
        end
        s.aircraftResponseAt=nil
    end
end

-- External bridge for a future verified enemy-spawn sensor.
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
        log("ENEMY TAG aat destroyed")
    elseif tag=="aircraft" then
        C.EnemySignals.aircraftDestroyedAt=C.Time
        log("ENEMY TAG aircraft destroyed")
    end
end

local function onSecond()
    C.Time=C.Time+1
    detectOwnLosses()
    processDeferredOrders()
    processEnemyRules()
    processStrategicLoop()
    processSpawn()

    if not C.WarningPrinted and C.Time>=2 then
        log("NOTE enemy aat/aircraft tag sensor is not verified; response branches await a sensor hook")
        C.WarningPrinted=true
    end
    if C.Time%30==0 then log("TIME="..C.Time.." STATE="..C.State) end
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
    C.Units={}; C.Units.count=1
    readAllUnits(nil,C.Units,BotApi.Instance.army)
    buildCandidates()

    C.RoleCursor={}
    C.SpawnIntents={}
    C.SpawnRequest=nil
    C.SpawnTickets={}
    C.AwaitingArrival=nil
    C.SquadRole={}
    C.SquadTarget={}
    C.DeadSquads={}
    C.DeferredOrders={}
    C.Time=0
    C.State="OPENING"
    C.CurrentAttackFlag=nil
    C.AttackStartedAt=nil
    C.AttackCheckAt=nil
    C.NextAttackAt=nil
    C.FlagCursor=0
    C.WarningPrinted=false
    C.EnemySignals={aatSeenAt=nil,aatDestroyedAt=nil,aatStage=0,aircraftSeenAt=nil,aircraftDestroyedAt=nil,aircraftResponseAt=nil}

    -- User opening sequence.
    enqueueSpawn("recon","opening",0,nil)
    enqueueSpawn("infantry","opening",0,nil)
    enqueueSpawn("antiair","opening",0,nil)
    enqueueSpawn("tank_usa","opening",NEU_BOT.OpeningTankDelaySec,nil)

    log("START army="..tostring(BotApi.Instance.army).." units="..tostring(C.Units.count-1))
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
        return
    end

    if C.AwaitingArrival==ticket then C.AwaitingArrival=nil end
    C.SquadRole[args.squadId]=ticket.role
    C.DeadSquads[args.squadId]=false
    log("ARRIVED squad="..tostring(args.squadId).." role="..ticket.role.." unit="..ticket.unit)

    local target=ticket.target or C.CurrentAttackFlag
    if ticket.reason=="defend captured flag" and ticket.target then
        capture(args.squadId,ticket.target)
    elseif ticket.reason=="defend line before attack" and ticket.target then
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
