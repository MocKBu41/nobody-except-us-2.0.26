-- NEU BOT v1.4
-- Independent assault groups.
-- Each infantry transport / detached infantry / assigned tank keeps its own target.
-- Opening target tries real geometry from available BotApi object fields; safe fallback spreads by flag numbers.

require([[/script/multiplayer/bot.data]])

local C={
    Units={},Candidates={},SpawnIntents={},SpawnTickets={},AwaitingArrival=nil,
    SquadRole={},DeadSquads={},SquadGroup={},DeferredOrders={},
    Groups={},NextGroupId=1,PendingInfantryGroups={},
    Time=0,Timer=nil,TimerGeneration=0,
    State="OPENING",NextAttackAt=nil,NextTankReinforcementAt=0,NextPatrolAt=0,NextInfantryOrderAt=0,
    ReconSquad=nil,ReconTarget=nil,ReconVisited={},
    SpawnAnchor=nil,PositionProbeLogged=false,
    EnemySignals={aatSeenAt=nil,aatDestroyedAt=nil,aatStage=0,aircraftSeenAt=nil,aircraftDestroyedAt=nil,aircraftResponseAt=nil}
}

local function log(m) print("[NEU-BOT] "..tostring(m)) end
local function lower(s) return string.lower(tostring(s or "")) end

local function splitTags(tags)
    local out={}
    for t in string.gmatch(tags or "","%S+") do out[lower(t)]=true end
    return out
end
local function hasTag(r,t) return r and r.tagset and r.tagset[lower(t)]==true end
local function isDuelTank(r)
    return hasTag(r,"duel_tanks70") or hasTag(r,"duel_tanks80") or hasTag(r,"duel_tanks90")
end
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

local function detectSide(line)
    return line:match('%f[%w]side%s*%(%s*([^%)%s]+)%s*%)') or line:match('%f[%w]s%s*%(%s*([^%)%s]+)%s*%)')
end

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
                local expected=(ch==")") and "(" or "{"
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
                        units[units.count]=rec units.count=units.count+1 units.seen[id]=true added=added+1
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
    for _,r in ipairs(roles) do C.Candidates[r]={} end
    for _,rec in ipairs(C.Units) do
        if type(rec)=="table" then
            for _,r in ipairs(roles) do if roleMatches(rec,r) then C.Candidates[r][#C.Candidates[r]+1]=rec end end
        end
    end
    for _,r in ipairs(roles) do log("ROLE "..r.." candidates="..#C.Candidates[r]) end
end

local function enqueueSpawn(role,reason,delaySec,target,groupId)
    local due=C.Time+(delaySec or 0)
    C.SpawnIntents[#C.SpawnIntents+1]={role=role,reason=reason or "",due=due,target=target,groupId=groupId,attempts=0,tried={}}
    log("QUEUE role="..role.." due="..due.." group="..tostring(groupId).." target="..tostring(target).." reason="..tostring(reason))
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
    local idx=nil
    for i,x in ipairs(C.SpawnIntents) do if x.due<=C.Time then idx=i break end end
    if not idx then return end
    local intent=table.remove(C.SpawnIntents,idx)
    local rec=chooseUntried(intent)
    if not rec then log("NO UNIT role="..intent.role) return end
    intent.attempts=intent.attempts+1
    local ticket={role=intent.role,reason=intent.reason,target=intent.target,groupId=intent.groupId,unit=rec.unit}
    C.SpawnTickets[#C.SpawnTickets+1]=ticket
    local ok=BotApi.Commands:Spawn(rec.unit,MaxSquadSize)
    if ok then
        C.AwaitingArrival=ticket
        log("SPAWN OK role="..intent.role.." unit="..rec.unit.." group="..tostring(intent.groupId))
    else
        table.remove(C.SpawnTickets,#C.SpawnTickets)
        if intent.attempts < #(C.Candidates[intent.role] or {}) then
            intent.due=C.Time+NEU_BOT.SpawnRetrySec
            C.SpawnIntents[#C.SpawnIntents+1]=intent
        else log("SPAWN FAILED role="..intent.role) end
    end
end

local function flags()
    local my=BotApi.Instance.team
    local enemy=BotApi.Instance.enemyTeam
    local f={mine={},enemy={},neutral={},all={},mineCount=0,enemyCount=0,neutralCount=0}
    for _,flag in pairs(BotApi.Scene.Flags) do
        f.all[#f.all+1]=flag
        if flag.occupant==my then f.mine[#f.mine+1]=flag.name f.mineCount=f.mineCount+1
        elseif flag.occupant==enemy then f.enemy[#f.enemy+1]=flag.name f.enemyCount=f.enemyCount+1
        else f.neutral[#f.neutral+1]=flag.name f.neutralCount=f.neutralCount+1 end
    end
    return f
end

local function flagObj(name)
    for _,f in pairs(BotApi.Scene.Flags) do if f.name==name then return f end end
    return nil
end
local function flagOccupant(name)
    local f=flagObj(name) return f and f.occupant or nil
end
local function flagNumber(name)
    return type(name)=="string" and tonumber(name:match("(%d+)$")) or nil
end

local function safeField(obj,key)
    local ok,val=pcall(function() return obj[key] end)
    if ok then return val end
    return nil
end
local function vecFrom(v)
    if not v then return nil end
    local x=safeField(v,"x") or safeField(v,1)
    local y=safeField(v,"y") or safeField(v,2)
    local z=safeField(v,"z") or safeField(v,3)
    if type(x)=="number" and type(y)=="number" then return {x=x,y=y,z=(type(z)=="number" and z or 0)} end
    return nil
end
local function objectPos(obj)
    if not obj then return nil end
    local p=vecFrom(safeField(obj,"position")) or vecFrom(safeField(obj,"pos")) or vecFrom(safeField(obj,"point"))
    if p then return p end
    local x=safeField(obj,"x") local y=safeField(obj,"y") local z=safeField(obj,"z")
    if type(x)=="number" and type(y)=="number" then return {x=x,y=y,z=(type(z)=="number" and z or 0)} end
    return nil
end
local function d2(a,b)
    if not a or not b then return nil end
    local dx=a.x-b.x local dy=a.y-b.y local dz=(a.z or 0)-(b.z or 0)
    return dx*dx+dy*dy+dz*dz
end

local function chooseNearestByAnchor(anchor,used)
    if not anchor then return nil end
    local best,bestD=nil,nil
    for _,f in pairs(BotApi.Scene.Flags) do
        if f.occupant~=BotApi.Instance.team and not (used and used[f.name]) then
            local p=objectPos(f)
            local dist=d2(anchor,p)
            if dist and (not bestD or dist<bestD) then best=f.name bestD=dist end
        end
    end
    if best then log("TARGET GEOMETRY flag="..best.." d2="..tostring(bestD)) end
    return best
end

local function sortedTargets()
    local f=flags()
    local list={}
    for _,n in ipairs(f.neutral) do list[#list+1]=n end
    for _,n in ipairs(f.enemy) do list[#list+1]=n end
    table.sort(list,function(a,b)
        local na,nb=flagNumber(a),flagNumber(b)
        if na and nb then return na<nb end
        return tostring(a)<tostring(b)
    end)
    return list
end

local function chooseSpreadTarget(index,used)
    local list=sortedTargets()
    local free={}
    for _,n in ipairs(list) do if not (used and used[n]) then free[#free+1]=n end end
    if #free==0 then return nil end
    if index<=1 then return free[1] end
    if index==2 then return free[#free] end
    local pos=1+((index-1)%#free)
    return free[pos]
end

local function newGroup(target)
    local id=C.NextGroupId C.NextGroupId=C.NextGroupId+1
    C.Groups[id]={id=id,target=target,infantry={},tanks={},detached={},captured=false}
    log("GROUP CREATE id="..id.." target="..tostring(target))
    return id
end
local function groupOf(id)
    local gid=C.SquadGroup[id] return gid and C.Groups[gid] or nil
end
local function setGroup(id,gid)
    if id and gid then C.SquadGroup[id]=gid end
end

local function squadAlive(id) return id and BotApi.Scene:IsSquadExists(id) end
local function capture(id,flag)
    if id and flag and squadAlive(id) then
        log("ORDER squad="..tostring(id).." group="..tostring(C.SquadGroup[id]).." flag="..tostring(flag).." role="..tostring(C.SquadRole[id]))
        BotApi.Commands:CaptureFlag(id,flag)
    end
end
local function deferCapture(id,flag,delay)
    C.DeferredOrders[#C.DeferredOrders+1]={squad=id,flag=flag,due=C.Time+(delay or 0)}
end
local function processDeferredOrders()
    for i=#C.DeferredOrders,1,-1 do
        local o=C.DeferredOrders[i]
        if o.due<=C.Time then capture(o.squad,o.flag) table.remove(C.DeferredOrders,i) end
    end
end

local function chooseOwnFlag()
    local f=flags() return f.mine[1]
end

local function assignTankGroup()
    local best=nil local bestCount=nil
    for gid,g in pairs(C.Groups) do
        if g.target and flagOccupant(g.target)~=BotApi.Instance.team then
            local c=#g.tanks
            if bestCount==nil or c<bestCount then best=gid bestCount=c end
        end
    end
    if not best then for gid,_ in pairs(C.Groups) do best=gid break end end
    return best
end

local function discoverDetachedSquads()
    local activeGroups={}
    for gid,g in pairs(C.Groups) do if g.target then activeGroups[#activeGroups+1]=gid end end
    table.sort(activeGroups)
    if #activeGroups==0 then return end
    local cursor=1
    for _,sid in pairs(BotApi.Scene.Squads) do
        if sid and not C.SquadRole[sid] and squadAlive(sid) then
            local gid=activeGroups[cursor]
            cursor=cursor+1 if cursor>#activeGroups then cursor=1 end
            C.SquadRole[sid]="infantry_detached"
            C.DeadSquads[sid]=false
            setGroup(sid,gid)
            C.Groups[gid].detached[#C.Groups[gid].detached+1]=sid
            log("DETACHED squad="..tostring(sid).." group="..gid.." target="..tostring(C.Groups[gid].target))
            capture(sid,C.Groups[gid].target)
        end
    end
end

local function processGroupOrders()
    if C.Time<C.NextInfantryOrderAt then return end
    C.NextInfantryOrderAt=C.Time+NEU_BOT.InfantryReissueSec
    discoverDetachedSquads()
    for gid,g in pairs(C.Groups) do
        local target=g.target
        if target and flagOccupant(target)==BotApi.Instance.team then g.captured=true end
        if target and not g.captured then
            for _,sid in ipairs(g.infantry) do if squadAlive(sid) then log("GROUP PUSH id="..gid.." squad="..sid.." flag="..target) capture(sid,target) end end
            for _,sid in ipairs(g.detached) do if squadAlive(sid) then capture(sid,target) end end
            for _,sid in ipairs(g.tanks) do if squadAlive(sid) then capture(sid,target) end end
        end
    end
end

local function chooseNextGroupTarget(gid)
    local used={}
    for id,g in pairs(C.Groups) do if id~=gid and g.target and not g.captured then used[g.target]=true end end
    local t=chooseNearestByAnchor(C.SpawnAnchor,used)
    if not t then t=chooseSpreadTarget(gid,used) end
    return t
end

local function advanceGroups()
    for gid,g in pairs(C.Groups) do
        if g.target and flagOccupant(g.target)==BotApi.Instance.team then
            if not g.captured then log("GROUP CAPTURE id="..gid.." flag="..g.target) end
            g.captured=true
            local nextTarget=chooseNextGroupTarget(gid)
            if nextTarget and nextTarget~=g.target then
                g.target=nextTarget g.captured=false
                log("GROUP NEXT id="..gid.." flag="..nextTarget)
            end
        end
    end
end

local function processRecon()
    if not C.ReconSquad or not squadAlive(C.ReconSquad) then return end
    if C.ReconTarget and flagOccupant(C.ReconTarget)~=BotApi.Instance.team then return end
    local used={}
    for _,g in pairs(C.Groups) do if g.target then used[g.target]=true end end
    local t=chooseNearestByAnchor(C.SpawnAnchor,used) or chooseSpreadTarget(3,used)
    C.ReconTarget=t
    if t then log("RECON NEXT flag="..t) capture(C.ReconSquad,t) end
end

local function processAA()
    if C.Time<C.NextPatrolAt then return end
    C.NextPatrolAt=C.Time+NEU_BOT.AntiAirPatrolSec
    local own=chooseOwnFlag()
    if own then
        for sid,role in pairs(C.SquadRole) do if squadAlive(sid) and (role=="antiair" or role=="aat") then capture(sid,own) end end
    end
end

local function processTankReinforcement()
    if C.Time<C.NextTankReinforcementAt then return end
    C.NextTankReinforcementAt=C.Time+NEU_BOT.TankReinforcementSec
    local gid=assignTankGroup()
    local target=gid and C.Groups[gid] and C.Groups[gid].target or nil
    enqueueSpawn("tank","5 minute reinforcement",0,target,gid)
end

local function detectLosses()
    for sid,role in pairs(C.SquadRole) do
        if not C.DeadSquads[sid] and not squadAlive(sid) then
            C.DeadSquads[sid]=true
            local gid=C.SquadGroup[sid]
            log("LOST squad="..tostring(sid).." role="..tostring(role).." group="..tostring(gid))
            if role=="tank" then
                local target=gid and C.Groups[gid] and C.Groups[gid].target or nil
                enqueueSpawn("tank","replace destroyed tank",0,target,gid)
                enqueueSpawn("infantry","tank loss support",0,target,gid)
            end
        end
    end
end

local function processEnemyRules()
    local s=C.EnemySignals
    if s.aatSeenAt and s.aatStage==1 and C.Time>=s.aatSeenAt+NEU_BOT.AntiRadDelaySec then
        enqueueSpawn("antirad","enemy aat response",0,nil,nil) s.aatStage=2 s.aatCheckAt=C.Time+NEU_BOT.EnemyResponseCheckSec
    elseif s.aatStage==2 and s.aatCheckAt and C.Time>=s.aatCheckAt then
        if s.aatDestroyedAt and s.aatDestroyedAt>=s.aatSeenAt then enqueueSpawn("duel_heli","aat destroyed",0,nil,nil) s.aatStage=0
        else enqueueSpawn("antirad","aat survived",0,nil,nil) enqueueSpawn("strike","aat survived",0,nil,nil) s.aatCheckAt=C.Time+NEU_BOT.EnemyResponseCheckSec end
    end
    if s.aircraftSeenAt and s.aircraftResponseAt and C.Time>=s.aircraftResponseAt then
        if s.aircraftDestroyedAt and s.aircraftDestroyedAt>=s.aircraftSeenAt then
            local gid=assignTankGroup() local target=gid and C.Groups[gid] and C.Groups[gid].target or nil
            enqueueSpawn("tank","aircraft destroyed reward",0,target,gid)
            enqueueSpawn("infantry","aircraft destroyed reward",0,target,gid)
        else enqueueSpawn("duel_fighter","aircraft alive",0,nil,nil) end
        s.aircraftResponseAt=nil
    end
end

function NEU_BOT_EnemyTagSeen(tag)
    tag=lower(tag)
    if tag=="aat" then C.EnemySignals.aatSeenAt=C.Time C.EnemySignals.aatDestroyedAt=nil C.EnemySignals.aatStage=1
    elseif tag=="aircraft" then
        C.EnemySignals.aircraftSeenAt=C.Time C.EnemySignals.aircraftDestroyedAt=nil C.EnemySignals.aircraftResponseAt=C.Time+NEU_BOT.EnemyResponseCheckSec
        if math.random(2)==1 then enqueueSpawn("duel_fighter","aircraft response",0,nil,nil) else enqueueSpawn("aat","aircraft response",0,chooseOwnFlag(),nil) end
    end
end
function NEU_BOT_EnemyTagDestroyed(tag)
    tag=lower(tag)
    if tag=="aat" then C.EnemySignals.aatDestroyedAt=C.Time elseif tag=="aircraft" then C.EnemySignals.aircraftDestroyedAt=C.Time end
end

local function onSecond()
    C.Time=C.Time+1
    detectLosses()
    processDeferredOrders()
    processEnemyRules()
    advanceGroups()
    processGroupOrders()
    processRecon()
    processAA()
    processTankReinforcement()
    processSpawn()
    if C.Time%30==0 then
        local parts={}
        for gid,g in pairs(C.Groups) do parts[#parts+1]="G"..gid.."="..tostring(g.target) end
        log("TIME="..C.Time.." GROUPS "..table.concat(parts," "))
    end
end

local function stopClock()
    C.TimerGeneration=C.TimerGeneration+1
    if C.Timer then BotApi.Events:KillQuantTimer(C.Timer) C.Timer=nil end
end
local function startClock()
    stopClock()
    local gen=C.TimerGeneration
    local function pulse()
        if gen~=C.TimerGeneration then return end
        C.Timer=nil onSecond()
        if gen==C.TimerGeneration then C.Timer=BotApi.Events:SetQuantTimer(pulse,NEU_BOT.TickMs) end
    end
    C.Timer=BotApi.Events:SetQuantTimer(pulse,NEU_BOT.TickMs)
end

local function makeOpeningGroups()
    local used={}
    for i=1,NEU_BOT.AssaultGroups do
        local target=chooseNearestByAnchor(C.SpawnAnchor,used)
        if not target then target=chooseSpreadTarget(i,used) end
        if target then used[target]=true end
        local gid=newGroup(target)
        C.PendingInfantryGroups[#C.PendingInfantryGroups+1]=gid
        enqueueSpawn("infantry","opening group infantry",0,target,gid)
    end
    local firstGid=1
    local tankTarget=C.Groups[firstGid] and C.Groups[firstGid].target or nil
    enqueueSpawn("tank","opening tank",NEU_BOT.OpeningTankDelaySec,tankTarget,firstGid)
end

function onGameStart()
    math.randomseed(os.time()*BotApi.Instance.hostId)
    C.Units={} C.Units.count=1
    readAllUnits(nil,C.Units,BotApi.Instance.army)
    buildCandidates()
    C.SpawnIntents={} C.SpawnTickets={} C.AwaitingArrival=nil
    C.SquadRole={} C.DeadSquads={} C.SquadGroup={} C.DeferredOrders={}
    C.Groups={} C.NextGroupId=1 C.PendingInfantryGroups={}
    C.Time=0 C.NextTankReinforcementAt=NEU_BOT.TankReinforcementSec C.NextPatrolAt=0 C.NextInfantryOrderAt=0
    C.ReconSquad=nil C.ReconTarget=nil C.ReconVisited={} C.SpawnAnchor=nil
    C.EnemySignals={aatSeenAt=nil,aatDestroyedAt=nil,aatStage=0,aircraftSeenAt=nil,aircraftDestroyedAt=nil,aircraftResponseAt=nil}

    -- Recon is spawned first. On its arrival we probe its squad object/scene value for a spawn position.
    enqueueSpawn("recon","opening recon",0,nil,nil)
    enqueueSpawn("antiair","opening aa",0,nil,nil)
    log("START v1.4 army="..tostring(BotApi.Instance.army).." units="..tostring(C.Units.count-1))
    startClock()
    processSpawn()
end

function onGameStop() stopClock() collectgarbage("collect") end
function onGameQuant() processSpawn() end

function onGameSpawn(args)
    local ticket=nil
    if #C.SpawnTickets>0 then ticket=table.remove(C.SpawnTickets,1) end
    if not ticket then log("UNMATCHED SPAWN squad="..tostring(args.squadId)) return end
    if C.AwaitingArrival==ticket then C.AwaitingArrival=nil end
    local sid=args.squadId
    C.SquadRole[sid]=ticket.role C.DeadSquads[sid]=false
    if ticket.groupId then setGroup(sid,ticket.groupId) end
    log("ARRIVED squad="..tostring(sid).." role="..ticket.role.." group="..tostring(ticket.groupId).." target="..tostring(ticket.target))

    -- Safe position probes. Some game builds expose position fields, some do not.
    if not C.SpawnAnchor then
        C.SpawnAnchor=objectPos(args) or objectPos(safeField(args,"squad"))
        if C.SpawnAnchor then log("SPAWN POSITION x="..C.SpawnAnchor.x.." y="..C.SpawnAnchor.y.." z="..C.SpawnAnchor.z)
        else log("SPAWN POSITION unavailable -> fallback target spread") end
    end

    if ticket.role=="recon" then
        C.ReconSquad=sid
        if #C.Groups==0 then makeOpeningGroups() end
        local used={}
        for _,g in pairs(C.Groups) do if g.target then used[g.target]=true end end
        C.ReconTarget=chooseNearestByAnchor(C.SpawnAnchor,used) or chooseSpreadTarget(3,used)
        if C.ReconTarget then capture(sid,C.ReconTarget) end
    elseif ticket.role=="infantry" then
        local gid=ticket.groupId
        if gid and C.Groups[gid] then C.Groups[gid].infantry[#C.Groups[gid].infantry+1]=sid end
        if ticket.target then capture(sid,ticket.target) end
    elseif ticket.role=="tank" then
        local gid=ticket.groupId or assignTankGroup()
        if gid then setGroup(sid,gid) C.Groups[gid].tanks[#C.Groups[gid].tanks+1]=sid end
        local t=(gid and C.Groups[gid] and C.Groups[gid].target) or ticket.target
        if t then deferCapture(sid,t,NEU_BOT.VehicleFollowDelaySec) end
    elseif ticket.role=="antiair" or ticket.role=="aat" then
        local own=chooseOwnFlag() if own then capture(sid,own) end
    elseif ticket.target then capture(sid,ticket.target) end
    processSpawn()
end

BotApi.Events:Subscribe(BotApi.Events.GameStart,onGameStart)
BotApi.Events:Subscribe(BotApi.Events.GameEnd,onGameStop)
BotApi.Events:Subscribe(BotApi.Events.Quant,onGameQuant)
BotApi.Events:Subscribe(BotApi.Events.GameSpawn,onGameSpawn)
