-- NEU BOT v1.16
-- Based on v1.15. Restores sustained v1.13-style pressure, keeps passengers in transports,
-- and actively calls aircraftlight + artsupport on every assault direction.
-- Verified BotApi commands only: Spawn, CaptureFlag, Income, EnemyHasTanks.

require([[/script/multiplayer/bot.data]])
require([[/script/multiplayer/bot.mapdata]])
local MAP = NEU_MAPDATA

local C = {
    Units={}, Candidates={}, SpawnIntents={}, SpawnTickets={}, AwaitingArrival=nil,
    SquadRole={}, DeadSquads={}, SquadGroup={}, DefendTarget={}, Groups={}, LastOrder={},
    Time=0, Timer=nil, TimerGeneration=0, AttackUnlocked=false, AttackUnlockReason=nil,
    NeutralsCleared=false, PointStartTarget={}, PointStartPending={}, PointStartDone={},
    HostileNeutral={}, PointStartQueued=false, PatrolHeliSquad=nil,
    AirSupport={}, ArtSupport={}, BalanceDefenseActive=false,
    NextTankReinforcementAt=0, NextInfantryReinforcementAt=0,
    NextPatrolAt=0, NextOrderAt=0, NextPointStartCheckAt=0,
    NextHeliPatrolAt=0, NextSupportPatrolAt=0,
    FlagSnapshot=nil, FlagIndex=nil
}

local function log(m) print("[NEU-BOT] " .. tostring(m)) end
local function lower(s) return string.lower(tostring(s or "")) end
local function splitTags(tags)
    local o={}
    for t in string.gmatch(tags or "", "%S+") do o[lower(t)] = true end
    return o
end
local function hasTag(r,t) return r and r.tagset and r.tagset[lower(t)] == true end
local function recText(r) return lower((r and r.unit or "") .. " " .. (r and r.raw or "")) end

local function roleMatches(r,role)
    local text=recText(r)
    if role=="pointstart" then return hasTag(r,"pointstart") end
    if role=="patrol_heli" then return hasTag(r,"duel_heli") or hasTag(r,"duel_heli2") end
    if role=="aircraftlight" then return hasTag(r,"aircraftlight") or text:find("support_light",1,true)~=nil end
    if role=="artsupport" then return hasTag(r,"artsupport") end
    if role=="antirad" then return hasTag(r,"antirad") or text:find("antirad",1,true)~=nil end
    if role=="strike" then return hasTag(r,"strike") or text:find("_strike",1,true)~=nil end
    if role=="duel_heli" then return hasTag(r,"duel_heli") or hasTag(r,"duel_heli2") end
    if role=="duel_fighter" then return hasTag(r,"duel_fighter") end
    if r and r.nobot then return false end
    if role=="recon" then return hasTag(r,"all") and hasTag(r,"recon") end
    if role=="infantry" or role=="defense_infantry" then return hasTag(r,"all") and hasTag(r,"infantry") end
    if role=="antiair" then return hasTag(r,"all") and hasTag(r,"antiair") end
    if role=="tank" then return hasTag(r,"duel_tanks70") or hasTag(r,"duel_tanks80") or hasTag(r,"duel_tanks90") end
    if role=="tank80plus" then return hasTag(r,"duel_tanks80") or hasTag(r,"duel_tanks90") end
    if role=="aat" then return hasTag(r,"aat") end
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
                buffer[#buffer+1]=ch
                stack[#stack]=nil
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
            local parts={}
            for tags in line:gmatch('%f[%w]t%s*%(([^)]*)%)') do parts[#parts+1]=tags end
            local tags=table.concat(parts," ")
            local vehicle=line:match('^%s*{%s*"([^"]+)"')
            local name=vehicle or line:match('%f[%w]name%s*%(([^)]+)%)')
            if name and not name:find("mp/",1,true) then
                local id=vehicle or (name.."("..army..")")
                if not units.seen[id] then
                    local rec={unit=id,tags=tags,tagset=splitTags(tags),raw=line,side=side,nobot=(line:find("nobot",1,true)~=nil)}
                    units[units.count]=rec
                    units.count=units.count+1
                    units.seen[id]=true
                    added=added+1
                end
            end
        end
    end
    log("READ "..fname.." added="..added)
end

local function buildCandidates()
    local roles={"pointstart","patrol_heli","recon","infantry","defense_infantry","antiair","tank","tank80plus","aircraftlight","artsupport","aat","antirad","strike","duel_heli","duel_fighter"}
    C.Candidates={}
    for _,r in ipairs(roles) do C.Candidates[r]={} end
    for _,rec in ipairs(C.Units) do
        if type(rec)=="table" then
            for _,r in ipairs(roles) do
                if roleMatches(rec,r) then C.Candidates[r][#C.Candidates[r]+1]=rec end
            end
        end
    end
    for _,r in ipairs(roles) do log("ROLE "..r.." candidates="..#C.Candidates[r]) end
end

local function flags()
    if C.FlagSnapshot then return C.FlagSnapshot end
    local my,enemy=BotApi.Instance.team,BotApi.Instance.enemyTeam
    local f={mine={},enemy={},neutral={},mineCount=0,enemyCount=0,neutralCount=0}
    for _,x in pairs(BotApi.Scene.Flags) do
        if x.occupant==my then f.mine[#f.mine+1]=x.name f.mineCount=f.mineCount+1
        elseif x.occupant==enemy then f.enemy[#f.enemy+1]=x.name f.enemyCount=f.enemyCount+1
        else f.neutral[#f.neutral+1]=x.name f.neutralCount=f.neutralCount+1 end
    end
    return f
end

local function flagObj(name)
    if C.FlagIndex then return C.FlagIndex[name] end
    for _,f in pairs(BotApi.Scene.Flags) do if f.name==name then return f end end
end
local function flagOccupant(name) local f=flagObj(name) return f and f.occupant or nil end
local function isNeutral(name) local o=flagOccupant(name) return o~=BotApi.Instance.team and o~=BotApi.Instance.enemyTeam end
local function flagNumber(name) return type(name)=="string" and tonumber(name:match("(%d+)$")) or nil end
local function numericSort(list)
    table.sort(list,function(a,b)
        local na,nb=flagNumber(a),flagNumber(b)
        if na and nb and na~=nb then return na<nb end
        return tostring(a)<tostring(b)
    end)
end
local function geoSortSpawn(list)
    if MAP and MAP.loaded and MAP.spawn then MAP:sortFromSpawn(list) else numericSort(list) end
end
local function geoSortFromFlag(list,from)
    if MAP and MAP.loaded and from and MAP:point(from) then MAP:sortFromFlag(list,from) else geoSortSpawn(list) end
end

local function hostileNeutralActiveCount()
    local n=0
    for name,v in pairs(C.HostileNeutral) do if v and isNeutral(name) then n=n+1 end end
    return n
end
local function strategicNeutralList()
    local f=flags() local out={}
    for _,n in ipairs(f.neutral) do if not C.HostileNeutral[n] then out[#out+1]=n end end
    return out
end
local function strategicNeutralCount() return #strategicNeutralList() end
local function effectiveEnemyCount() local f=flags() return f.enemyCount+hostileNeutralActiveCount() end
local function isStrategicEnemy(name)
    return flagOccupant(name)==BotApi.Instance.enemyTeam or (C.HostileNeutral[name]==true and isNeutral(name))
end

local function frontOwnList()
    local f=flags() local enemy={}
    for _,n in ipairs(f.enemy) do enemy[#enemy+1]=n end
    for n,v in pairs(C.HostileNeutral) do if v and isNeutral(n) then enemy[#enemy+1]=n end end
    if MAP and MAP.loaded then return MAP:frontOwnFlags(f.mine,enemy) end
    numericSort(f.mine)
    return f.mine
end
local function chooseFrontOwnFlag(used)
    local list=frontOwnList()
    for _,n in ipairs(list) do if not(used and used[n]) then return n end end
    return list[1]
end
local function chooseOwnFlagBefore(target)
    local f=flags() if #f.mine==0 then return nil end
    if MAP and MAP.loaded and target and MAP:point(target) then
        local best,bd=nil,nil
        for _,name in ipairs(f.mine) do
            local d=MAP:distanceNames(name,target)
            if d and (not bd or d<bd) then best,bd=name,d end
        end
        if best then return best end
    end
    return chooseFrontOwnFlag(nil)
end
local function chooseSafeOwnFlag(target)
    local f=flags() if #f.mine==0 then return nil end
    local front={}
    for _,n in ipairs(frontOwnList()) do front[n]=true end
    local pool={}
    for _,n in ipairs(f.mine) do if not front[n] then pool[#pool+1]=n end end
    if #pool==0 then pool=f.mine end
    if MAP and MAP.loaded and target then
        local best=MAP:nearestToFlag(pool,target,nil)
        if best then return best end
    end
    numericSort(pool)
    return pool[1]
end

local function squadAlive(id) return id and BotApi.Scene:IsSquadExists(id) end
local function aliveCount(list)
    local n=0
    for _,sid in ipairs(list or {}) do if squadAlive(sid) then n=n+1 end end
    return n
end

local function capture(id,flag,force)
    if not(id and flag and flagObj(flag) and squadAlive(id)) then return end
    local role=C.SquadRole[id]
    local occ=flagOccupant(flag)
    local neutral=(occ~=BotApi.Instance.team and occ~=BotApi.Instance.enemyTeam)
    if neutral and role~="pointstart" and not C.HostileNeutral[flag] then return end
    local last=C.LastOrder[id]
    if not force and last and last.flag==flag and C.Time-(last.time or 0)<(NEU_BOT.OrderCooldownSec or 12) then return end
    C.LastOrder[id]={flag=flag,time=C.Time}
    log("ORDER squad="..tostring(id).." group="..tostring(C.SquadGroup[id]).." flag="..tostring(flag).." role="..tostring(role))
    BotApi.Commands:CaptureFlag(id,flag)
end

local function enqueueSpawn(role,reason,delay,target,gid,mode)
    C.SpawnIntents[#C.SpawnIntents+1]={role=role,reason=reason or "",due=C.Time+(delay or 0),target=target,groupId=gid,mode=mode,attempts=0,cycles=0,tried={}}
    if role=="pointstart" and target then C.PointStartPending[target]=true end
    log("QUEUE role="..role.." group="..tostring(gid).." target="..tostring(target).." reason="..tostring(reason))
end
local function pendingForGroup(role,gid)
    for _,x in ipairs(C.SpawnIntents) do if x.role==role and x.groupId==gid then return true end end
    return C.AwaitingArrival and C.AwaitingArrival.role==role and C.AwaitingArrival.groupId==gid
end
local function chooseUntried(intent)
    local list=C.Candidates[intent.role] or {} local a={}
    for _,r in ipairs(list) do if not intent.tried[r.unit] then a[#a+1]=r end end
    if #a==0 then return nil end
    local r=a[math.random(1,#a)] intent.tried[r.unit]=true return r
end
local function criticalRole(role)
    return role=="tank" or role=="tank80plus" or role=="infantry" or role=="patrol_heli" or role=="aircraftlight" or role=="artsupport"
end
local function maxRetryCycles(role)
    if role=="aircraftlight" or role=="artsupport" then return NEU_BOT.SupportSpawnRetryCycles or 8 end
    return NEU_BOT.CriticalSpawnRetryCycles or 3
end

local function processSpawn()
    if C.Spawning or C.AwaitingArrival then return end
    local idx=nil
    for i,x in ipairs(C.SpawnIntents) do if x.due<=C.Time then idx=i break end end
    if not idx then return end
    local intent=table.remove(C.SpawnIntents,idx)
    if intent.role=="pointstart" and intent.target and not isNeutral(intent.target) then
        C.PointStartPending[intent.target]=nil
        return processSpawn()
    end
    local rec=chooseUntried(intent)
    if not rec then log("NO UNIT role="..intent.role) return end
    intent.attempts=intent.attempts+1
    local ticket={role=intent.role,target=intent.target,groupId=intent.groupId,mode=intent.mode,unit=rec.unit}
    C.SpawnTickets[#C.SpawnTickets+1]=ticket
    C.AwaitingArrival=ticket
    C.Spawning=true
    local ok=BotApi.Commands:Spawn(rec.unit,(intent.role=="pointstart") and (NEU_BOT.PointStartSquadSize or MaxSquadSize) or MaxSquadSize)
    C.Spawning=false
    if ok or C.AwaitingArrival~=ticket then
        log("SPAWN OK role="..intent.role.." unit="..rec.unit)
    else
        C.AwaitingArrival=nil
        table.remove(C.SpawnTickets,#C.SpawnTickets)
        local total=#(C.Candidates[intent.role] or {})
        if intent.attempts<total then
            intent.due=C.Time+(NEU_BOT.SpawnRetrySec or 2)
            C.SpawnIntents[#C.SpawnIntents+1]=intent
        elseif intent.role=="pointstart" or (criticalRole(intent.role) and (intent.cycles or 0)<maxRetryCycles(intent.role)) then
            intent.cycles=(intent.cycles or 0)+1
            intent.attempts=0 intent.tried={}
            local retry=(intent.role=="aircraftlight" or intent.role=="artsupport") and (NEU_BOT.SupportSpawnRetrySec or 15) or ((intent.role=="pointstart") and (NEU_BOT.PointStartSpawnRetrySec or 5) or (NEU_BOT.CriticalSpawnRetrySec or 10))
            intent.due=C.Time+retry
            C.SpawnIntents[#C.SpawnIntents+1]=intent
            log("SPAWN RETRY CYCLE role="..intent.role.." cycle="..intent.cycles.." group="..tostring(intent.groupId))
        else
            log("SPAWN FAILED role="..intent.role.." group="..tostring(intent.groupId).." target="..tostring(intent.target))
        end
    end
end

local function newGroup(id)
    C.Groups[id]={id=id,target=nil,phase="opening",stopped=false,failedTarget=nil,infantry={},detached={},tanks={},defenders={},resultCheckAt=nil,nextAttackAt=nil}
end
local function activeGroups()
    local a={}
    for id,g in pairs(C.Groups) do if not g.stopped then a[#a+1]=id end end
    table.sort(a) return a
end
local function groupInfCount(g) return aliveCount(g.infantry)+aliveCount(g.detached) end
local function chooseLeastInfantryGroup()
    local best,bn=nil,nil
    for _,id in ipairs(activeGroups()) do
        local n=groupInfCount(C.Groups[id])
        if bn==nil or n<bn then best,bn=id,n end
    end
    return best
end

local function adoptPointStart(sid,reason)
    local id=chooseLeastInfantryGroup()
    local g=id and C.Groups[id]
    if not g then return false end
    if groupInfCount(g)>=(NEU_BOT.MaxAssaultInfantrySquads or 4) then
        local hold=chooseFrontOwnFlag(nil)
        C.SquadRole[sid]="defense_infantry"
        C.SquadGroup[sid]=id
        C.DefendTarget[sid]=hold
        g.defenders[#g.defenders+1]=sid
        log("POINTSTART -> DEFENSE squad="..sid.." group="..id.." flag="..tostring(hold))
        if hold then capture(sid,hold,true) end
        return true
    end
    C.SquadRole[sid]="infantry_detached"
    C.SquadGroup[sid]=id
    g.detached[#g.detached+1]=sid
    log("POINTSTART -> ASSAULT squad="..sid.." group="..id.." reason="..tostring(reason))
    if g.phase=="attack" and g.target then capture(sid,g.target,true) end
    return true
end

local function usedEnemyTargets(except)
    local u={}
    for id,g in pairs(C.Groups) do if id~=except and not g.stopped and g.target and isStrategicEnemy(g.target) then u[g.target]=true end end
    return u
end
local function chooseEnemyTarget(gid)
    local f=flags() local used=usedEnemyTargets(gid) local g=C.Groups[gid] local c={}
    for _,n in ipairs(f.enemy) do if not used[n] then c[#c+1]=n end end
    for n,v in pairs(C.HostileNeutral) do if v and isNeutral(n) and not used[n] then c[#c+1]=n end end
    if #c==0 then return nil end
    if MAP and MAP.loaded then
        local front=MAP:frontOwnFlags(f.mine,c)
        if front[1] then geoSortFromFlag(c,front[1]) else geoSortSpawn(c) end
    else numericSort(c) end
    for _,n in ipairs(c) do if n~=g.failedTarget then return n end end
    return c[1]
end

local function ensureInfantry(id,reason,minCount)
    local g=C.Groups[id] if not g or g.stopped then return end
    minCount=minCount or 1
    local have=groupInfCount(g)
    if have<minCount and not pendingForGroup("infantry",id) then enqueueSpawn("infantry",reason,0,g.target,id,g.phase) end
end
local function ensureTank(id,reason)
    local g=C.Groups[id] if g and not g.stopped and aliveCount(g.tanks)==0 and not pendingForGroup("tank",id) and not pendingForGroup("tank80plus",id) then
        enqueueSpawn("tank80plus",reason,0,g.target,id,g.phase)
    end
end
local function hasSupportForGroup(tbl,gid)
    for sid,s in pairs(tbl) do if squadAlive(sid) and s.groupId==gid then return true end end
    return false
end
local function ensureAirSupport(id,target)
    if #(C.Candidates.aircraftlight or {})==0 then log("AIR SUPPORT UNAVAILABLE candidates=0") return end
    if not hasSupportForGroup(C.AirSupport,id) and not pendingForGroup("aircraftlight",id) then
        enqueueSpawn("aircraftlight","assault air support",0,target,id,"support")
    end
end
local function ensureArtSupport(id,target)
    if #(C.Candidates.artsupport or {})==0 then log("ART SUPPORT UNAVAILABLE candidates=0") return end
    if not hasSupportForGroup(C.ArtSupport,id) and not pendingForGroup("artsupport",id) then
        enqueueSpawn("artsupport","assault artillery support",0,target,id,"support")
    end
end

local function makeOpeningGroups()
    if C.Groups[1] then return end
    for i=1,NEU_BOT.AssaultGroups do
        newGroup(i)
        enqueueSpawn("infantry","opening infantry",0,nil,i,"opening")
        enqueueSpawn("tank","opening tank",NEU_BOT.OpeningTankDelaySec,nil,i,"opening")
    end
end
local function queuePointStartTargets()
    if C.PointStartQueued then return end
    C.PointStartQueued=true
    local f=flags() local list={}
    for _,t in ipairs(f.neutral) do list[#list+1]=t end
    geoSortSpawn(list)
    for _,t in ipairs(list) do enqueueSpawn("pointstart","opening point",0,t,nil,"pointstart") end
end
local function processPointStartCapture()
    if C.Time<C.NextPointStartCheckAt then return end
    C.NextPointStartCheckAt=C.Time+(NEU_BOT.PointStartCheckSec or 3)
    for sid,target in pairs(C.PointStartTarget) do
        if squadAlive(sid) and target then
            if flagOccupant(target)==BotApi.Instance.team then
                C.PointStartTarget[sid]=nil C.PointStartPending[target]=nil C.PointStartDone[target]=true
                log("POINTSTART RECYCLE squad="..sid.." flag="..target)
                adoptPointStart(sid,"pointstart-captured")
            else capture(sid,target) end
        end
    end
end

local function unlockAttack()
    if C.AttackUnlocked then return end
    local f=flags()
    if C.Time>=NEU_BOT.AttackWaitSec then C.AttackUnlocked=true C.AttackUnlockReason="5 minutes"
    elseif effectiveEnemyCount()>f.mineCount then C.AttackUnlocked=true C.AttackUnlockReason="enemy flag advantage" end
    if C.AttackUnlocked then log("ATTACK UNLOCK reason="..tostring(C.AttackUnlockReason)) end
end
local function neutralTransition()
    local strategic=strategicNeutralCount()
    if strategic==0 then
        if not C.NeutralsCleared then
            C.NeutralsCleared=true
            for _,g in pairs(C.Groups) do if not g.stopped then g.phase="ready" g.target=nil g.nextAttackAt=C.Time end end
            log("NEUTRALS CLEARED")
        end
    elseif C.NeutralsCleared then C.NeutralsCleared=false end
end
local function completeCapturedTargets()
    for id,g in pairs(C.Groups) do
        if not g.stopped and g.phase=="attack" and g.target and flagOccupant(g.target)==BotApi.Instance.team then
            local captured=g.target
            C.HostileNeutral[captured]=nil
            log("TARGET CAPTURED -> NEXT ATTACK group="..id.." flag="..captured)
            g.failedTarget=nil g.target=nil g.phase="ready" g.resultCheckAt=nil
            g.nextAttackAt=C.Time+(NEU_BOT.CaptureNextAttackDelaySec or 3)
        end
    end
end

local function startAttack(id)
    local g=C.Groups[id]
    if not g or g.stopped or not C.AttackUnlocked or strategicNeutralCount()>0 then return end
    local target=chooseEnemyTarget(id)
    if not target then g.phase="ready" g.nextAttackAt=C.Time+3 return end
    g.target=target g.phase="attack" g.resultCheckAt=C.Time+(NEU_BOT.AttackResultCheckSec or 90) g.nextAttackAt=nil
    log("ATTACK START group="..id.." flag="..target.." I="..groupInfCount(g).." T="..aliveCount(g.tanks))
    ensureInfantry(id,"attack infantry",NEU_BOT.MinAssaultInfantrySquads or 2)
    ensureTank(id,"attack tank")
    ensureAirSupport(id,target)
    ensureArtSupport(id,target)
    for _,sid in ipairs(g.infantry) do if squadAlive(sid) then capture(sid,target,true) end end
    for _,sid in ipairs(g.detached) do if squadAlive(sid) then capture(sid,target,true) end end
    for _,sid in ipairs(g.tanks) do if squadAlive(sid) then capture(sid,target,true) end end
end
local function startReadyGroups()
    if not C.AttackUnlocked or not C.NeutralsCleared then return end
    for _,id in ipairs(activeGroups()) do
        local g=C.Groups[id]
        if (g.phase=="ready" or g.phase=="opening") and (not g.nextAttackAt or C.Time>=g.nextAttackAt) then startAttack(id) end
    end
end

local function resolveAttackResults()
    for id,g in pairs(C.Groups) do
        if not g.stopped and g.phase=="attack" and g.resultCheckAt and C.Time>=g.resultCheckAt then
            if g.target and flagOccupant(g.target)==BotApi.Instance.team then
                completeCapturedTargets()
            else
                log("ATTACK PRESSURE group="..id.." flag="..tostring(g.target).." I="..groupInfCount(g).." T="..aliveCount(g.tanks))
                ensureInfantry(id,"stalled attack infantry",NEU_BOT.MinAssaultInfantrySquads or 2)
                ensureTank(id,"stalled attack tank")
                ensureAirSupport(id,g.target)
                ensureArtSupport(id,g.target)
                g.resultCheckAt=C.Time+(NEU_BOT.AttackResultCheckSec or 90)
            end
        end
    end
end

local function processAssaultMaintenance()
    for id,g in pairs(C.Groups) do
        if not g.stopped and g.phase=="attack" and g.target then
            ensureInfantry(id,"assault maintenance infantry",NEU_BOT.MinAssaultInfantrySquads or 2)
            ensureTank(id,"assault maintenance tank")
            ensureAirSupport(id,g.target)
            ensureArtSupport(id,g.target)
        end
    end
end

local function processOrders()
    if C.Time<C.NextOrderAt then return end
    C.NextOrderAt=C.Time+(NEU_BOT.InfantryReissueSec or 5)
    for _,g in pairs(C.Groups) do
        if not g.stopped and g.phase=="attack" and g.target and isStrategicEnemy(g.target) then
            for _,sid in ipairs(g.infantry) do if squadAlive(sid) then capture(sid,g.target) end end
            for _,sid in ipairs(g.detached) do if squadAlive(sid) then capture(sid,g.target) end end
            for _,sid in ipairs(g.tanks) do if squadAlive(sid) then capture(sid,g.target) end end
        end
        for _,sid in ipairs(g.defenders) do
            if squadAlive(sid) then local t=C.DefendTarget[sid] if t then capture(sid,t) end end
        end
    end
end

local function defenderCountAt(t)
    local n=0
    for sid,x in pairs(C.DefendTarget) do if x==t and squadAlive(sid) then n=n+1 end end
    return n
end
local function processBalanceDefense()
    local f=flags() local should=(f.mineCount>effectiveEnemyCount())
    if should and not C.BalanceDefenseActive then
        C.BalanceDefenseActive=true
        local used={}
        for _,id in ipairs(activeGroups()) do
            local t=chooseFrontOwnFlag(used)
            if t then
                used[t]=true
                if defenderCountAt(t)<(NEU_BOT.MaxDefenseSquadsPerFlag or 1) then enqueueSpawn("defense_infantry","frontline defense",0,t,id,"defense") end
            end
        end
    elseif not should and C.BalanceDefenseActive then C.BalanceDefenseActive=false end
end
local function processReinforcements()
    if C.Time>=C.NextTankReinforcementAt then
        C.NextTankReinforcementAt=C.Time+(NEU_BOT.TankReinforcementSec or 300)
        for _,id in ipairs(activeGroups()) do ensureTank(id,"periodic tank") end
    end
    if C.Time>=C.NextInfantryReinforcementAt then
        C.NextInfantryReinforcementAt=C.Time+(NEU_BOT.InfantryReinforcementSec or 180)
        for _,id in ipairs(activeGroups()) do ensureInfantry(id,"periodic infantry",NEU_BOT.MinAssaultInfantrySquads or 2) end
    end
end
local function processAA()
    if C.Time<C.NextPatrolAt then return end
    C.NextPatrolAt=C.Time+(NEU_BOT.AntiAirPatrolSec or 20)
    local t=chooseFrontOwnFlag(nil)
    if t then for sid,r in pairs(C.SquadRole) do if squadAlive(sid) and (r=="antiair" or r=="aat") then capture(sid,t) end end end
end
local function processHeliPatrol()
    local sid=C.PatrolHeliSquad
    if not squadAlive(sid) or C.Time<C.NextHeliPatrolAt then return end
    C.NextHeliPatrolAt=C.Time+(NEU_BOT.HeliPatrolSec or 20)
    local f=flags() if #f.enemy>0 then geoSortSpawn(f.enemy) capture(sid,f.enemy[1],true) end
end
local function processSupportPatrols()
    if C.Time<C.NextSupportPatrolAt then return end
    C.NextSupportPatrolAt=C.Time+(NEU_BOT.SupportPatrolSec or 20)
    for sid,s in pairs(C.AirSupport) do
        if squadAlive(sid) then
            local g=s.groupId and C.Groups[s.groupId]
            if g and g.phase=="attack" and g.target then
                s.target=g.target
                s.home=chooseOwnFlagBefore(g.target)
                local dest=(s.leg=="home") and s.home or s.target
                if dest then
                    log("AIR CORRIDOR squad="..sid.." group="..tostring(s.groupId).." dest="..tostring(dest))
                    capture(sid,dest,true)
                end
                s.leg=(s.leg=="home") and "target" or "home"
            end
        else C.AirSupport[sid]=nil end
    end
    for sid,s in pairs(C.ArtSupport) do
        if squadAlive(sid) then
            local g=s.groupId and C.Groups[s.groupId]
            local target=(g and g.target) or s.target
            local home=chooseSafeOwnFlag(target)
            if home then
                s.home=home s.target=target
                log("ART SUPPORT squad="..sid.." group="..tostring(s.groupId).." hold="..home.." target="..tostring(target))
                capture(sid,home,true)
            end
        else C.ArtSupport[sid]=nil end
    end
end

local function detectLosses()
    for sid,role in pairs(C.SquadRole) do
        if not C.DeadSquads[sid] and not squadAlive(sid) then
            C.DeadSquads[sid]=true
            local id=C.SquadGroup[sid] local g=id and C.Groups[id]
            log("LOST squad="..sid.." role="..tostring(role).." group="..tostring(id))
            if role=="tank" or role=="tank80plus" then if id and g then ensureTank(id,"tank replacement") end end
            if (role=="infantry" or role=="infantry_detached") and id and g and g.phase=="attack" then ensureInfantry(id,"infantry replacement",NEU_BOT.MinAssaultInfantrySquads or 2) end
            if role=="aircraftlight" then C.AirSupport[sid]=nil if id and g and g.phase=="attack" then ensureAirSupport(id,g.target) end end
            if role=="artsupport" then C.ArtSupport[sid]=nil if id and g and g.phase=="attack" then ensureArtSupport(id,g.target) end end
            if role=="patrol_heli" then C.PatrolHeliSquad=nil end
            if role=="pointstart" then
                local t=C.PointStartTarget[sid]
                C.PointStartTarget[sid]=nil
                if t and flagOccupant(t)~=BotApi.Instance.team then C.HostileNeutral[t]=true end
            end
        end
    end
end

local function onSecond()
    C.Time=C.Time+1
    C.FlagSnapshot=nil C.FlagIndex={}
    C.FlagSnapshot=flags()
    for _,flag in pairs(BotApi.Scene.Flags) do C.FlagIndex[flag.name]=flag end
    detectLosses()
    unlockAttack()
    processPointStartCapture()
    neutralTransition()
    completeCapturedTargets()
    startReadyGroups()
    resolveAttackResults()
    processAssaultMaintenance()
    processOrders()
    processHeliPatrol()
    processSupportPatrols()
    processAA()
    processBalanceDefense()
    processReinforcements()
    processSpawn()
    if C.Time%30==0 then
        local f=flags() local p={}
        for id,g in pairs(C.Groups) do p[#p+1]="G"..id.."="..tostring(g.target)..":"..g.phase..":I"..groupInfCount(g)..":T"..aliveCount(g.tanks) end
        log("TIME="..C.Time.." FLAGS="..f.mineCount.."/"..f.enemyCount.." N="..strategicNeutralCount().." AIR="..tostring(next(C.AirSupport)~=nil).." ART="..tostring(next(C.ArtSupport)~=nil).." "..table.concat(p," "))
    end
    C.FlagSnapshot=nil C.FlagIndex=nil
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

function onGameStart()
    C.Spawning=false C.FlagSnapshot=nil C.FlagIndex=nil
    local host=tonumber(BotApi.Instance.hostId) or 1 math.randomseed(os.time()*host)
    C.Units={count=1,seen={}} readAllUnits(nil,C.Units,BotApi.Instance.army) buildCandidates()
    C.SpawnIntents={} C.SpawnTickets={} C.AwaitingArrival=nil C.SquadRole={} C.DeadSquads={} C.SquadGroup={} C.DefendTarget={} C.Groups={} C.LastOrder={}
    C.Time=0 C.AttackUnlocked=false C.AttackUnlockReason=nil C.NeutralsCleared=false
    C.PointStartTarget={} C.PointStartPending={} C.PointStartDone={} C.HostileNeutral={} C.PointStartQueued=false
    C.PatrolHeliSquad=nil C.AirSupport={} C.ArtSupport={} C.BalanceDefenseActive=false
    C.NextTankReinforcementAt=NEU_BOT.TankReinforcementSec or 300
    C.NextInfantryReinforcementAt=NEU_BOT.InfantryReinforcementSec or 180
    C.NextPatrolAt=0 C.NextOrderAt=0 C.NextPointStartCheckAt=0 C.NextHeliPatrolAt=0 C.NextSupportPatrolAt=0
    local mapOk=MAP and MAP:load() or false
    queuePointStartTargets()
    makeOpeningGroups()
    enqueueSpawn("recon","opening recon",0,nil,nil,"opening")
    enqueueSpawn("antiair","opening aa",0,nil,nil,"opening")
    enqueueSpawn("patrol_heli","opening heli",0,nil,nil,"patrol")
    log("START v1.16 map="..tostring(mapOk))
    log("RULE assault-pressure=v1.13-style NO-timeout-retreat minInf="..tostring(NEU_BOT.MinAssaultInfantrySquads or 2))
    log("RULE unmatched-spawn=IGNORE to keep transport passengers mounted")
    log("RULE aircraftlight=CALL-ON-ATTACK artsupport=CALL-ON-ATTACK")
    startClock()
    processSpawn()
end
function onGameStop() stopClock() collectgarbage("collect") end
function onGameQuant() processSpawn() end

function onGameSpawn(args)
    local sid=args and args.squadId
    if not sid or C.SquadRole[sid] then return end
    local ticket=#C.SpawnTickets>0 and table.remove(C.SpawnTickets,1) or nil
    if not ticket then
        log("UNMATCHED SPAWN squad="..tostring(sid).." policy=ignore-passenger")
        return
    end
    if C.AwaitingArrival==ticket then C.AwaitingArrival=nil end
    C.SquadRole[sid]=ticket.role C.DeadSquads[sid]=false
    if ticket.groupId then C.SquadGroup[sid]=ticket.groupId end
    log("ARRIVED squad="..sid.." role="..ticket.role.." group="..tostring(ticket.groupId).." target="..tostring(ticket.target))
    if ticket.role=="pointstart" then
        C.PointStartPending[ticket.target]=nil C.PointStartTarget[sid]=ticket.target
        if ticket.target then capture(sid,ticket.target,true) end
    elseif ticket.role=="patrol_heli" then
        C.PatrolHeliSquad=sid
    elseif ticket.role=="infantry" then
        local g=ticket.groupId and C.Groups[ticket.groupId]
        if g then g.infantry[#g.infantry+1]=sid if g.phase=="attack" and g.target then capture(sid,g.target,true) end end
    elseif ticket.role=="defense_infantry" then
        local g=ticket.groupId and C.Groups[ticket.groupId]
        if g then g.defenders[#g.defenders+1]=sid end
        C.DefendTarget[sid]=ticket.target
        if ticket.target then capture(sid,ticket.target,true) end
    elseif ticket.role=="tank" or ticket.role=="tank80plus" then
        local g=ticket.groupId and C.Groups[ticket.groupId]
        if g then g.tanks[#g.tanks+1]=sid if g.phase=="attack" and g.target then capture(sid,g.target,true) end end
    elseif ticket.role=="aircraftlight" then
        local g=ticket.groupId and C.Groups[ticket.groupId]
        local target=(g and g.target) or ticket.target
        C.AirSupport[sid]={groupId=ticket.groupId,target=target,home=chooseOwnFlagBefore(target),leg="target"}
        log("AIR SUPPORT READY squad="..sid.." group="..tostring(ticket.groupId).." target="..tostring(target))
        if target then capture(sid,target,true) end
    elseif ticket.role=="artsupport" then
        local g=ticket.groupId and C.Groups[ticket.groupId]
        local target=(g and g.target) or ticket.target
        local home=chooseSafeOwnFlag(target)
        C.ArtSupport[sid]={groupId=ticket.groupId,target=target,home=home}
        log("ART SUPPORT READY squad="..sid.." group="..tostring(ticket.groupId).." hold="..tostring(home).." target="..tostring(target))
        if home then capture(sid,home,true) end
    elseif ticket.role=="antiair" or ticket.role=="aat" then
        local t=ticket.target or chooseFrontOwnFlag(nil)
        if t then capture(sid,t,true) end
    elseif ticket.target then
        capture(sid,ticket.target,true)
    end
    processSpawn()
end

BotApi.Events:Subscribe(BotApi.Events.GameStart,onGameStart)
BotApi.Events:Subscribe(BotApi.Events.GameEnd,onGameStop)
BotApi.Events:Subscribe(BotApi.Events.Quant,onGameQuant)
BotApi.Events:Subscribe(BotApi.Events.GameSpawn,onGameSpawn)
