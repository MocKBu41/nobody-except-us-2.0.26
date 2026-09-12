-- NEU BOT v1.7
-- Integrated version built from working v1.5/v1.5.2 behavior.
-- No v1.6 guard/probe overlays.
-- Verified BotApi commands only: Spawn, CaptureFlag, Income, EnemyHasTanks.

require([[/script/multiplayer/bot.data]])

local C={
    Units={},Candidates={},SpawnIntents={},SpawnTickets={},AwaitingArrival=nil,
    SquadRole={},DeadSquads={},SquadGroup={},DeferredOrders={},DetachedTarget={},TankReadyAt={},
    Groups={},NextGroupId=1,
    Time=0,Timer=nil,TimerGeneration=0,
    TeamEdge=nil,TeamEdgeLogged=false,
    AttackUnlocked=false,AttackUnlockReason=nil,
    NeutralsCleared=false,
    NextTankReinforcementAt=0,NextInfantryReinforcementAt=0,
    NextPatrolAt=0,NextInfantryOrderAt=0,NextNeutralCaptureAt=0,
    NeutralCaptureTarget={},NeutralPending={},CaptureSource="all infantry fallback",
    BalanceDefenseActive=false,
    ReconSquad=nil,
    EnemySignals={aatSeenAt=nil,aatDestroyedAt=nil,aatStage=0,aatCheckAt=nil,
                  aircraftSeenAt=nil,aircraftDestroyedAt=nil,aircraftResponseAt=nil}
}

local function log(m) print("[NEU-BOT] "..tostring(m)) end
local function lower(s) return string.lower(tostring(s or "")) end

local function splitTags(tags)
    local out={}
    for t in string.gmatch(tags or "","%S+") do out[lower(t)]=true end
    return out
end

local function hasTag(r,t)
    return r and r.tagset and r.tagset[lower(t)]==true
end

local function isDuelTank(r)
    return hasTag(r,"duel_tanks70") or hasTag(r,"duel_tanks80") or hasTag(r,"duel_tanks90")
end

local function isTank80Plus(r)
    return hasTag(r,"duel_tanks80") or hasTag(r,"duel_tanks90")
end

local function roleMatches(r,role)
    if role=="recon" then return hasTag(r,"all") and hasTag(r,"recon") end
    if role=="infantry" or role=="defense_infantry" or role=="capture_infantry" then
        return hasTag(r,"all") and hasTag(r,"infantry")
    end
    if role=="antiair" then return hasTag(r,"all") and hasTag(r,"antiair") end
    if role=="tank" then return isDuelTank(r) end
    if role=="tank80plus" then return isTank80Plus(r) end
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
            if #stack>0 then buffer[#buffer+1]=ch quoted=true end
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
    if not f then log("FILE MISSING "..fname) return end
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
    local roles={"recon","infantry","capture_infantry","defense_infantry","antiair","tank","tank80plus","aircraftlight","aat","antirad","strike","duel_heli","duel_fighter"}
    C.Candidates={}
    for _,r in ipairs(roles) do C.Candidates[r]={} end

    for _,rec in ipairs(C.Units) do
        if type(rec)=="table" then
            for _,r in ipairs(roles) do
                if roleMatches(rec,r) then C.Candidates[r][#C.Candidates[r]+1]=rec end
            end
        end
    end

    local preferred={}
    for _,rec in ipairs(C.Candidates.infantry or {}) do
        local text=lower((rec.unit or "").." "..(rec.raw or ""))
        if text:find("vehicle_supporter",1,true) then preferred[#preferred+1]=rec end
    end
    if #preferred>0 then
        C.Candidates.capture_infantry=preferred
        C.CaptureSource="vehicle_supporter"
    else
        local fallback={}
        for _,rec in ipairs(C.Candidates.infantry or {}) do fallback[#fallback+1]=rec end
        C.Candidates.capture_infantry=fallback
        C.CaptureSource="all infantry fallback"
    end

    for _,r in ipairs(roles) do log("ROLE "..r.." candidates="..#(C.Candidates[r] or {})) end
    log("CAPTURE SOURCE="..C.CaptureSource)
end

local function pendingForGroup(role,gid)
    for _,x in ipairs(C.SpawnIntents) do
        if x.role==role and x.groupId==gid then return true end
    end
    if C.AwaitingArrival and C.AwaitingArrival.role==role and C.AwaitingArrival.groupId==gid then return true end
    return false
end

local function enqueueSpawn(role,reason,delaySec,target,groupId,mode)
    local due=C.Time+(delaySec or 0)
    C.SpawnIntents[#C.SpawnIntents+1]={role=role,reason=reason or "",due=due,target=target,groupId=groupId,mode=mode,attempts=0,tried={}}
    if role=="capture_infantry" and target then C.NeutralPending[target]=true end
    log("QUEUE role="..role.." due="..due.." group="..tostring(groupId).." target="..tostring(target).." mode="..tostring(mode).." reason="..tostring(reason))
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
    if intent.role=="tank" or intent.role=="tank80plus" then
        log("TANK RANDOM unit="..tostring(rec.unit).." tags="..tostring(rec.tags))
    end
    return rec
end

local function processSpawn()
    if C.AwaitingArrival then return end
    local idx=nil
    for i,x in ipairs(C.SpawnIntents) do
        if x.due<=C.Time then idx=i break end
    end
    if not idx then return end

    local intent=table.remove(C.SpawnIntents,idx)
    local rec=chooseUntried(intent)
    if not rec then
        if intent.role=="capture_infantry" and intent.target then C.NeutralPending[intent.target]=nil end
        log("NO UNIT role="..intent.role)
        return
    end

    intent.attempts=intent.attempts+1
    local ticket={role=intent.role,reason=intent.reason,target=intent.target,groupId=intent.groupId,mode=intent.mode,unit=rec.unit}
    C.SpawnTickets[#C.SpawnTickets+1]=ticket

    local maxSize=MaxSquadSize
    if intent.role=="capture_infantry" then maxSize=NEU_BOT.NeutralCaptureSquadSize or 2 end

    local ok=BotApi.Commands:Spawn(rec.unit,maxSize)
    if ok then
        C.AwaitingArrival=ticket
        log("SPAWN OK role="..intent.role.." unit="..rec.unit.." group="..tostring(intent.groupId).." maxSquad="..tostring(maxSize))
    else
        table.remove(C.SpawnTickets,#C.SpawnTickets)
        if intent.attempts < #(C.Candidates[intent.role] or {}) then
            intent.due=C.Time+NEU_BOT.SpawnRetrySec
            C.SpawnIntents[#C.SpawnIntents+1]=intent
        else
            if intent.role=="capture_infantry" and intent.target then C.NeutralPending[intent.target]=nil end
            log("SPAWN FAILED role="..intent.role)
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

local function flagObj(name)
    for _,f in pairs(BotApi.Scene.Flags) do
        if f.name==name then return f end
    end
    return nil
end

local function flagOccupant(name)
    local f=flagObj(name)
    return f and f.occupant or nil
end

local function flagNumber(name)
    return type(name)=="string" and tonumber(name:match("(%d+)$")) or nil
end

local function detectTeamEdge()
    if C.TeamEdge then return C.TeamEdge end
    local myRaw=BotApi.Instance.team
    local enemyRaw=BotApi.Instance.enemyTeam
    local my=lower(myRaw)
    local enemy=lower(enemyRaw)
    local edge=nil

    if my=="a" or my=="team a" or my:find("team a",1,true) then edge="LOW" end
    if my=="b" or my=="team b" or my:find("team b",1,true) then edge="HIGH" end

    if not edge then
        local mn=tonumber(my)
        local en=tonumber(enemy)
        if mn and en and mn~=en then edge=(mn>en) and "HIGH" or "LOW" end
    end

    if not edge then
        if my:match("[%s_%-]a$") then edge="LOW" end
        if my:match("[%s_%-]b$") then edge="HIGH" end
    end

    C.TeamEdge=edge or "LOW"
    if not C.TeamEdgeLogged then
        C.TeamEdgeLogged=true
        log("TEAM SIDE team="..tostring(myRaw).." enemyTeam="..tostring(enemyRaw).." army="..tostring(BotApi.Instance.army).." edge="..C.TeamEdge)
    end
    return C.TeamEdge
end

local function sortByOwnSide(list)
    local edge=detectTeamEdge()
    table.sort(list,function(a,b)
        local na,nb=flagNumber(a),flagNumber(b)
        if na and nb then
            if edge=="HIGH" then return na>nb else return na<nb end
        end
        if edge=="HIGH" then return tostring(a)>tostring(b) else return tostring(a)<tostring(b) end
    end)
end

local function sortFrontline(list)
    sortByOwnSide(list)
    local out={}
    for i=#list,1,-1 do out[#out+1]=list[i] end
    return out
end

local function chooseOwnFlag()
    local f=flags()
    if #f.mine==0 then return nil end
    sortByOwnSide(f.mine)
    return f.mine[1]
end

local function chooseFrontOwnFlag(used)
    local f=flags()
    local list=sortFrontline(f.mine)
    for _,name in ipairs(list) do
        if not (used and used[name]) then return name end
    end
    return list[1]
end

local function chooseOwnFlagBefore(target)
    local f=flags()
    if #f.mine==0 then return nil end
    local tn=flagNumber(target)
    local edge=detectTeamEdge()
    local best=nil
    local bestDist=nil
    for _,name in ipairs(f.mine) do
        local n=flagNumber(name)
        if n and tn then
            local behind=(edge=="HIGH" and n>tn) or (edge=="LOW" and n<tn)
            if behind then
                local d=math.abs(n-tn)
                if not bestDist or d<bestDist then best=name bestDist=d end
            end
        end
    end
    if best then return best end
    return chooseFrontOwnFlag(nil)
end

local function squadAlive(id)
    return id and BotApi.Scene:IsSquadExists(id)
end

local function capture(id,flag)
    if not (id and flag and squadAlive(id)) then return end
    local occ=flagOccupant(flag)
    local role=C.SquadRole[id]
    if occ~=BotApi.Instance.team and occ~=BotApi.Instance.enemyTeam and role~="capture_infantry" then
        log("BLOCK NEUTRAL NONCAPTURE squad="..tostring(id).." flag="..tostring(flag).." role="..tostring(role))
        return
    end
    log("ORDER squad="..tostring(id).." group="..tostring(C.SquadGroup[id]).." flag="..tostring(flag).." role="..tostring(role))
    BotApi.Commands:CaptureFlag(id,flag)
end

local function deferCapture(id,flag,delay)
    C.DeferredOrders[#C.DeferredOrders+1]={squad=id,flag=flag,due=C.Time+(delay or 0)}
end

local function processDeferredOrders()
    for i=#C.DeferredOrders,1,-1 do
        local o=C.DeferredOrders[i]
        if o.due<=C.Time then
            capture(o.squad,o.flag)
            table.remove(C.DeferredOrders,i)
        end
    end
end

local function newGroup(id)
    C.Groups[id]={id=id,target=nil,phase="opening",stopped=false,captured=false,
        infantry={},tanks={},defenders={},attackStartedAt=nil,resultCheckAt=nil,nextAttackAt=nil}
    if C.NextGroupId<=id then C.NextGroupId=id+1 end
    log("GROUP CREATE id="..id.." phase=opening")
end

local function setGroup(sid,gid)
    if sid and gid then C.SquadGroup[sid]=gid end
end

local function aliveCount(list)
    local n=0
    for _,sid in ipairs(list or {}) do if squadAlive(sid) then n=n+1 end end
    return n
end

local function activeGroups()
    local out={}
    for gid,g in pairs(C.Groups) do
        if not g.stopped then out[#out+1]=gid end
    end
    table.sort(out)
    return out
end

local function usedEnemyTargets(exceptGid)
    local used={}
    for gid,g in pairs(C.Groups) do
        if gid~=exceptGid and not g.stopped and g.target and flagOccupant(g.target)==BotApi.Instance.enemyTeam then
            used[g.target]=true
        end
    end
    return used
end

local function chooseEnemyTarget(exceptGid)
    local f=flags()
    local list={}
    for _,n in ipairs(f.enemy) do list[#list+1]=n end
    sortByOwnSide(list)
    local used=usedEnemyTargets(exceptGid)
    for _,name in ipairs(list) do
        if not used[name] then return name end
    end
    return nil
end

local function assignTankGroup()
    local best=nil
    local bestCount=nil
    for _,gid in ipairs(activeGroups()) do
        local g=C.Groups[gid]
        local c=aliveCount(g.tanks)
        if bestCount==nil or c<bestCount then best=gid bestCount=c end
    end
    return best
end

local function ensureGroupInfantry(gid,reason)
    local g=C.Groups[gid]
    if not g or g.stopped then return end
    if aliveCount(g.infantry)==0 and not pendingForGroup("infantry",gid) then
        enqueueSpawn("infantry",reason or "assault infantry",0,g.target,gid,"attack")
    end
end

local function ensureGroupTank(gid,role,reason,delay)
    local g=C.Groups[gid]
    if not g or g.stopped then return end
    local r=role or "tank80plus"
    if aliveCount(g.tanks)==0 and not pendingForGroup(r,gid) and not pendingForGroup("tank",gid) and not pendingForGroup("tank80plus",gid) then
        enqueueSpawn(r,reason or "assault tank",delay or 0,g.target,gid,"attack")
    end
end

local function unlockAttackIfNeeded()
    if C.AttackUnlocked then return end
    local f=flags()
    if C.Time>=NEU_BOT.AttackWaitSec then
        C.AttackUnlocked=true
        C.AttackUnlockReason="5 minutes"
    elseif f.enemyCount>f.mineCount then
        C.AttackUnlocked=true
        C.AttackUnlockReason="enemy flag advantage"
    end
    if C.AttackUnlocked then
        log("ATTACK UNLOCK reason="..tostring(C.AttackUnlockReason).." time="..C.Time.." mine="..f.mineCount.." enemy="..f.enemyCount.." neutral="..f.neutralCount)
    end
end

local function forceNeutralTransition()
    local f=flags()
    if f.neutralCount==0 then
        if not C.NeutralsCleared then
            C.NeutralsCleared=true
            log("NEUTRALS CLEARED time="..C.Time.." force-all-groups-ready=YES")
            for gid,g in pairs(C.Groups) do
                if not g.stopped then
                    g.phase="ready"
                    g.target=nil
                    g.resultCheckAt=nil
                    g.nextAttackAt=C.Time
                    log("GROUP READY id="..gid.." reason=neutrals-cleared")
                end
            end
        end
    else
        if C.NeutralsCleared then
            C.NeutralsCleared=false
            log("NEUTRALS RETURNED count="..f.neutralCount.." attacks-paused=YES")
        end
        for gid,g in pairs(C.Groups) do
            if not g.stopped and g.phase=="attack" then
                g.phase="hold_neutral"
                g.resultCheckAt=nil
                g.nextAttackAt=nil
                log("ATTACK PAUSE group="..gid.." neutralLeft="..f.neutralCount)
            end
        end
    end
end

local function startGroupAttack(gid)
    local g=C.Groups[gid]
    if not g or g.stopped then return end
    local f=flags()
    if f.neutralCount>0 or not C.AttackUnlocked then return end

    local target=chooseEnemyTarget(gid)
    if not target then
        g.phase="ready"
        g.target=nil
        g.nextAttackAt=C.Time+5
        log("ATTACK WAIT group="..gid.." reason=no-distinct-enemy-target")
        return
    end

    g.target=target
    g.phase="attack"
    g.captured=false
    g.attackStartedAt=C.Time
    g.resultCheckAt=C.Time+NEU_BOT.AttackResultCheckSec
    g.nextAttackAt=nil
    log("ATTACK START group="..gid.." flag="..target.." checkAt="..g.resultCheckAt)

    ensureGroupInfantry(gid,"new assault infantry")
    ensureGroupTank(gid,"tank80plus","attack tank support",0)
end

local function startReadyGroups()
    if not C.AttackUnlocked or not C.NeutralsCleared then return end
    for _,gid in ipairs(activeGroups()) do
        local g=C.Groups[gid]
        if (g.phase=="ready" or g.phase=="hold_neutral" or g.phase=="opening") and (not g.nextAttackAt or C.Time>=g.nextAttackAt) then
            startGroupAttack(gid)
        end
    end
end

local function captureIntentExists(target)
    for _,x in ipairs(C.SpawnIntents) do
        if x.role=="capture_infantry" and x.target==target then return true end
    end
    if C.AwaitingArrival and C.AwaitingArrival.role=="capture_infantry" and C.AwaitingArrival.target==target then return true end
    return false
end

local function processNeutralCapture()
    if C.Time<C.NextNeutralCaptureAt then return end
    C.NextNeutralCaptureAt=C.Time+(NEU_BOT.NeutralCaptureCheckSec or 5)

    local f=flags()
    local neutralSet={}
    for _,n in ipairs(f.neutral) do neutralSet[n]=true end

    for sid,target in pairs(C.NeutralCaptureTarget) do
        if not squadAlive(sid) then
            C.NeutralCaptureTarget[sid]=nil
            if target then C.NeutralPending[target]=nil end
        elseif target and neutralSet[target] then
            capture(sid,target)
        else
            if target then
                log("NEUTRAL CAPTURE DONE squad="..tostring(sid).." flag="..tostring(target).." occupant="..tostring(flagOccupant(target)))
                C.NeutralPending[target]=nil
            end
            C.NeutralCaptureTarget[sid]=nil
        end
    end

    if f.neutralCount==0 then return end

    local used={}
    for sid,target in pairs(C.NeutralCaptureTarget) do
        if squadAlive(sid) and target then used[target]=true end
    end
    for target,v in pairs(C.NeutralPending) do if v then used[target]=true end end

    local list={}
    for _,n in ipairs(f.neutral) do list[#list+1]=n end
    sortByOwnSide(list)

    for _,target in ipairs(list) do
        if not used[target] and not captureIntentExists(target) then
            enqueueSpawn("capture_infantry","neutral capture pair",0,target,nil,"neutral_capture")
            used[target]=true
        end
    end
end

local function processGroupOrders()
    if C.Time<C.NextInfantryOrderAt then return end
    C.NextInfantryOrderAt=C.Time+NEU_BOT.InfantryReissueSec

    for gid,g in pairs(C.Groups) do
        if not g.stopped and g.phase=="attack" and g.target and flagOccupant(g.target)==BotApi.Instance.enemyTeam then
            for _,sid in ipairs(g.infantry) do
                if squadAlive(sid) then capture(sid,g.target) end
            end
            for _,sid in ipairs(g.tanks) do
                if squadAlive(sid) and C.Time>=(C.TankReadyAt[sid] or 0) then capture(sid,g.target) end
            end
        end

        for _,sid in ipairs(g.defenders) do
            if squadAlive(sid) then
                local target=C.DetachedTarget[sid] or chooseOwnFlagBefore(g.target) or chooseFrontOwnFlag(nil)
                if target then capture(sid,target) end
            end
        end
    end
end

local function resolveAttackResults()
    for gid,g in pairs(C.Groups) do
        if not g.stopped and g.phase=="attack" and g.resultCheckAt and C.Time>=g.resultCheckAt then
            local success=(g.target and flagOccupant(g.target)==BotApi.Instance.team)
            if success then
                log("ATTACK RESULT group="..gid.." flag="..tostring(g.target).." success=YES")
                for _,sid in ipairs(g.infantry) do
                    if squadAlive(sid) then
                        g.defenders[#g.defenders+1]=sid
                        C.DetachedTarget[sid]=g.target
                    end
                end
                g.infantry={}
                g.phase="ready"
                g.captured=true
                g.resultCheckAt=nil
                g.nextAttackAt=C.Time+NEU_BOT.NextAttackDelaySec
            else
                log("ATTACK RESULT group="..gid.." flag="..tostring(g.target).." success=NO")
                enqueueSpawn("aircraftlight","stalled attack air support",0,g.target,gid,"support")
                local defenseFlag=chooseOwnFlagBefore(g.target) or chooseFrontOwnFlag(nil)
                enqueueSpawn("defense_infantry","stalled attack fallback defense",0,defenseFlag,gid,"defense")
                g.resultCheckAt=C.Time+NEU_BOT.AttackResultCheckSec
            end
        end
    end
end

local function processAA()
    if C.Time<C.NextPatrolAt then return end
    C.NextPatrolAt=C.Time+NEU_BOT.AntiAirPatrolSec
    local target=chooseFrontOwnFlag(nil) or chooseOwnFlag()
    if not target then return end
    for sid,role in pairs(C.SquadRole) do
        if squadAlive(sid) and (role=="antiair" or role=="aat") then capture(sid,target) end
    end
end

local function processBalanceDefense()
    local f=flags()
    local shouldDefend=(f.mineCount>f.enemyCount)
    if shouldDefend and not C.BalanceDefenseActive then
        C.BalanceDefenseActive=true
        local used={}
        log("BALANCE DEFENSE ON mine="..f.mineCount.." enemy="..f.enemyCount)
        for _,gid in ipairs(activeGroups()) do
            local target=chooseFrontOwnFlag(used)
            if target then
                used[target]=true
                enqueueSpawn("defense_infantry","flag advantage frontline defense",0,target,gid,"defense")
            end
        end
    elseif not shouldDefend and C.BalanceDefenseActive then
        C.BalanceDefenseActive=false
        log("BALANCE DEFENSE OFF mine="..f.mineCount.." enemy="..f.enemyCount)
    end
end

local function processPeriodicReinforcements()
    if C.Time>=C.NextTankReinforcementAt then
        C.NextTankReinforcementAt=C.Time+NEU_BOT.TankReinforcementSec
        for _,gid in ipairs(activeGroups()) do
            local g=C.Groups[gid]
            enqueueSpawn("tank80plus","5 minute tank reinforcement",0,g.target,gid,"attack")
        end
    end

    if C.Time>=C.NextInfantryReinforcementAt then
        C.NextInfantryReinforcementAt=C.Time+NEU_BOT.InfantryReinforcementSec
        local f=flags()
        if f.neutralCount>0 then
            log("INFANTRY REINFORCEMENT redirected=neutral-capture neutralLeft="..f.neutralCount)
            C.NextNeutralCaptureAt=0
        else
            for _,gid in ipairs(activeGroups()) do
                local g=C.Groups[gid]
                enqueueSpawn("infantry","5 minute infantry reinforcement",0,g.target,gid,"attack")
            end
        end
    end
end

local function stopDirection(gid,reason,role)
    local g=C.Groups[gid]
    if not g or g.stopped then return end
    g.stopped=true
    g.phase="stopped"
    g.nextAttackAt=nil
    g.resultCheckAt=nil
    log("DIRECTION STOP group="..tostring(gid).." flag="..tostring(g.target).." reason="..tostring(reason).." lostRole="..tostring(role))
end

local function detectLosses()
    for sid,role in pairs(C.SquadRole) do
        if not C.DeadSquads[sid] and not squadAlive(sid) then
            C.DeadSquads[sid]=true
            local gid=C.SquadGroup[sid]
            local g=gid and C.Groups[gid] or nil
            log("LOST squad="..tostring(sid).." role="..tostring(role).." group="..tostring(gid))

            if role=="capture_infantry" then
                local target=C.NeutralCaptureTarget[sid]
                if target then C.NeutralPending[target]=nil end
                C.NeutralCaptureTarget[sid]=nil
                C.NextNeutralCaptureAt=0
            end

            if g and not g.stopped and g.phase=="attack" and g.target and flagOccupant(g.target)==BotApi.Instance.enemyTeam then
                if role=="infantry" or role=="tank" or role=="tank80plus" then
                    stopDirection(gid,"combat-loss",role)
                end
            end

            if role=="tank" or role=="tank80plus" then
                local replacementGid=assignTankGroup()
                local target=replacementGid and C.Groups[replacementGid] and C.Groups[replacementGid].target or nil
                enqueueSpawn("tank80plus","tank destroyed replacement",0,target,replacementGid,"attack")
                enqueueSpawn("infantry","tank destroyed infantry support",0,target,replacementGid,"attack")
                enqueueSpawn("aat","tank destroyed random AA",0,chooseFrontOwnFlag(nil),replacementGid,"support")
                enqueueSpawn("aircraftlight","tank destroyed air support",0,target,replacementGid,"support")
            end
        end
    end
end

local function processEnemyRules()
    local s=C.EnemySignals

    if s.aatSeenAt and s.aatStage==1 and C.Time>=s.aatSeenAt+NEU_BOT.AntiRadDelaySec then
        enqueueSpawn("antirad","enemy aat response",0,nil,nil,"support")
        s.aatStage=2
        s.aatCheckAt=C.Time+NEU_BOT.EnemyResponseCheckSec
    elseif s.aatStage==2 and s.aatCheckAt and C.Time>=s.aatCheckAt then
        if s.aatDestroyedAt and s.aatDestroyedAt>=s.aatSeenAt then
            enqueueSpawn("duel_heli","aat destroyed",0,nil,nil,"support")
            s.aatStage=0
            s.aatCheckAt=nil
        else
            enqueueSpawn("antirad","aat survived",0,nil,nil,"support")
            enqueueSpawn("strike","aat survived",0,nil,nil,"support")
            s.aatCheckAt=C.Time+NEU_BOT.EnemyResponseCheckSec
        end
    end

    if s.aircraftSeenAt and s.aircraftResponseAt and C.Time>=s.aircraftResponseAt then
        if s.aircraftDestroyedAt and s.aircraftDestroyedAt>=s.aircraftSeenAt then
            local gid=assignTankGroup()
            local target=gid and C.Groups[gid] and C.Groups[gid].target or nil
            enqueueSpawn("tank80plus","aircraft destroyed reward",0,target,gid,"attack")
            enqueueSpawn("infantry","aircraft destroyed reward",0,target,gid,"attack")
        else
            enqueueSpawn("duel_fighter","aircraft alive",0,nil,nil,"support")
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
        C.EnemySignals.aatCheckAt=nil
        log("ENEMY TAG seen=aat")
    elseif tag=="aircraft" then
        C.EnemySignals.aircraftSeenAt=C.Time
        C.EnemySignals.aircraftDestroyedAt=nil
        C.EnemySignals.aircraftResponseAt=C.Time+NEU_BOT.EnemyResponseCheckSec
        if math.random(2)==1 then
            enqueueSpawn("duel_fighter","aircraft response 50/50",0,nil,nil,"support")
        else
            enqueueSpawn("aat","aircraft response 50/50",0,chooseFrontOwnFlag(nil),nil,"support")
        end
        log("ENEMY TAG seen=aircraft")
    end
end

function NEU_BOT_EnemyTagDestroyed(tag)
    tag=lower(tag)
    if tag=="aat" then
        C.EnemySignals.aatDestroyedAt=C.Time
        log("ENEMY TAG destroyed=aat")
    elseif tag=="aircraft" then
        C.EnemySignals.aircraftDestroyedAt=C.Time
        log("ENEMY TAG destroyed=aircraft")
    end
end

local function processDetachedSquads()
    if flags().neutralCount>0 then return end
    local used=usedEnemyTargets(nil)
    for _,sid in pairs(BotApi.Scene.Squads) do
        if sid and not C.SquadRole[sid] and squadAlive(sid) then
            local target=nil
            local f=flags()
            local list={}
            for _,n in ipairs(f.enemy) do list[#list+1]=n end
            sortByOwnSide(list)
            for _,name in ipairs(list) do
                if not used[name] then target=name used[name]=true break end
            end
            C.SquadRole[sid]="infantry_detached"
            C.DeadSquads[sid]=false
            C.DetachedTarget[sid]=target
            log("DETACHED squad="..tostring(sid).." target="..tostring(target))
            if target then capture(sid,target) end
        end
    end
end

local function processDetachedOrders()
    if flags().neutralCount>0 then return end
    for sid,target in pairs(C.DetachedTarget) do
        if C.SquadRole[sid]=="infantry_detached" and squadAlive(sid) then
            if target and flagOccupant(target)==BotApi.Instance.team then
                local f=flags()
                local list={}
                for _,n in ipairs(f.enemy) do list[#list+1]=n end
                sortByOwnSide(list)
                target=list[1]
                C.DetachedTarget[sid]=target
            end
            if target then capture(sid,target) end
        end
    end
end

local function onSecond()
    C.Time=C.Time+1
    detectLosses()
    processDeferredOrders()
    unlockAttackIfNeeded()
    processEnemyRules()
    processNeutralCapture()
    forceNeutralTransition()
    startReadyGroups()
    resolveAttackResults()
    processDetachedSquads()
    processGroupOrders()
    processDetachedOrders()
    processAA()
    processBalanceDefense()
    processPeriodicReinforcements()
    processSpawn()

    if C.Time%30==0 then
        local f=flags()
        local parts={}
        for gid,g in pairs(C.Groups) do
            parts[#parts+1]="G"..gid.."="..tostring(g.target)..":"..tostring(g.phase)..":I"..aliveCount(g.infantry)..":T"..aliveCount(g.tanks)
        end
        local cap=0
        for sid,target in pairs(C.NeutralCaptureTarget) do
            if squadAlive(sid) and target then cap=cap+1 end
        end
        log("TIME="..C.Time.." SIDE="..tostring(C.TeamEdge).." ATTACK="..tostring(C.AttackUnlocked).." FLAGS="..f.mineCount.."/"..f.enemyCount.." N="..f.neutralCount.." CAP2="..cap.." GROUPS "..table.concat(parts," "))
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
    local gen=C.TimerGeneration
    local function pulse()
        if gen~=C.TimerGeneration then return end
        C.Timer=nil
        onSecond()
        if gen==C.TimerGeneration then C.Timer=BotApi.Events:SetQuantTimer(pulse,NEU_BOT.TickMs) end
    end
    C.Timer=BotApi.Events:SetQuantTimer(pulse,NEU_BOT.TickMs)
end

local function makeOpeningGroups()
    if C.Groups[1] then return end
    for i=1,NEU_BOT.AssaultGroups do
        newGroup(i)
        enqueueSpawn("infantry","opening BTG infantry",0,nil,i,"opening")
        enqueueSpawn("tank","opening BTG tank",NEU_BOT.OpeningTankDelaySec,nil,i,"opening")
    end
end

function onGameStart()
    local host=tonumber(BotApi.Instance.hostId) or 1
    math.randomseed(os.time()*host)

    C.Units={count=1,seen={}}
    readAllUnits(nil,C.Units,BotApi.Instance.army)
    buildCandidates()

    C.SpawnIntents={}
    C.SpawnTickets={}
    C.AwaitingArrival=nil
    C.SquadRole={}
    C.DeadSquads={}
    C.SquadGroup={}
    C.DeferredOrders={}
    C.DetachedTarget={}
    C.TankReadyAt={}
    C.Groups={}
    C.NextGroupId=1
    C.Time=0
    C.Timer=nil
    C.TeamEdge=nil
    C.TeamEdgeLogged=false
    C.AttackUnlocked=false
    C.AttackUnlockReason=nil
    C.NeutralsCleared=false
    C.NextTankReinforcementAt=NEU_BOT.TankReinforcementSec
    C.NextInfantryReinforcementAt=NEU_BOT.InfantryReinforcementSec
    C.NextPatrolAt=0
    C.NextInfantryOrderAt=0
    C.NextNeutralCaptureAt=0
    C.NeutralCaptureTarget={}
    C.NeutralPending={}
    C.BalanceDefenseActive=false
    C.ReconSquad=nil
    C.EnemySignals={aatSeenAt=nil,aatDestroyedAt=nil,aatStage=0,aatCheckAt=nil,
                    aircraftSeenAt=nil,aircraftDestroyedAt=nil,aircraftResponseAt=nil}

    detectTeamEdge()
    enqueueSpawn("recon","opening recon",0,nil,nil,"opening")
    enqueueSpawn("antiair","opening aa",0,nil,nil,"opening")

    log("START v1.7 army="..tostring(BotApi.Instance.army).." playerId="..tostring(BotApi.Instance.playerId).." hostId="..tostring(BotApi.Instance.hostId).." units="..tostring((C.Units.count or 1)-1))
    log("RULE two-BTG=ON strict-neutral-first=ON capture-pair-size="..tostring(NEU_BOT.NeutralCaptureSquadSize).." direction-stop=ON balance-defense=ON")
    log("RULE tank-standoff-100m=NOT-EXACT: BotApi Move/coordinates are still not verified")

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
        log("UNMATCHED SPAWN squad="..tostring(args and args.squadId))
        return
    end
    if C.AwaitingArrival==ticket then C.AwaitingArrival=nil end

    local sid=args.squadId
    C.SquadRole[sid]=ticket.role
    C.DeadSquads[sid]=false
    if ticket.groupId then setGroup(sid,ticket.groupId) end

    log("ARRIVED squad="..tostring(sid).." role="..ticket.role.." group="..tostring(ticket.groupId).." target="..tostring(ticket.target).." mode="..tostring(ticket.mode))

    if ticket.role=="recon" then
        C.ReconSquad=sid
        makeOpeningGroups()

    elseif ticket.role=="capture_infantry" then
        C.NeutralPending[ticket.target]=nil
        C.NeutralCaptureTarget[sid]=ticket.target
        if ticket.target then capture(sid,ticket.target) end

    elseif ticket.role=="infantry" then
        local gid=ticket.groupId
        if gid and C.Groups[gid] then C.Groups[gid].infantry[#C.Groups[gid].infantry+1]=sid end
        if gid and C.Groups[gid] and C.Groups[gid].phase=="attack" and C.Groups[gid].target then
            capture(sid,C.Groups[gid].target)
        end

    elseif ticket.role=="defense_infantry" then
        local gid=ticket.groupId
        if gid and C.Groups[gid] then C.Groups[gid].defenders[#C.Groups[gid].defenders+1]=sid end
        C.DetachedTarget[sid]=ticket.target
        if ticket.target then capture(sid,ticket.target) end

    elseif ticket.role=="tank" or ticket.role=="tank80plus" then
        local gid=ticket.groupId or assignTankGroup()
        if gid and C.Groups[gid] and not C.Groups[gid].stopped then
            setGroup(sid,gid)
            C.Groups[gid].tanks[#C.Groups[gid].tanks+1]=sid
            C.TankReadyAt[sid]=C.Time+NEU_BOT.VehicleFollowDelaySec
            if C.Groups[gid].phase=="attack" and C.Groups[gid].target then
                deferCapture(sid,C.Groups[gid].target,NEU_BOT.VehicleFollowDelaySec)
            end
        end

    elseif ticket.role=="antiair" or ticket.role=="aat" then
        local own=ticket.target or chooseFrontOwnFlag(nil) or chooseOwnFlag()
        if own then capture(sid,own) end

    elseif ticket.target then
        local occ=flagOccupant(ticket.target)
        if occ==BotApi.Instance.enemyTeam or occ==BotApi.Instance.team then capture(sid,ticket.target) end
    end

    processSpawn()
end

BotApi.Events:Subscribe(BotApi.Events.GameStart,onGameStart)
BotApi.Events:Subscribe(BotApi.Events.GameEnd,onGameStop)
BotApi.Events:Subscribe(BotApi.Events.Quant,onGameQuant)
BotApi.Events:Subscribe(BotApi.Events.GameSpawn,onGameSpawn)
