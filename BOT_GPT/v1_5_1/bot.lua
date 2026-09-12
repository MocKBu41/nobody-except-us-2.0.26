-- NEU BOT v1.5.1
-- Based directly on working v1.5.
-- Adds the rules from bot-logic-editor (4)(1).html without command interception.
-- Uses only verified BotApi commands: Spawn, CaptureFlag, Income, EnemyHasTanks.

require([[/script/multiplayer/bot.data]])

local C={
    Units={},Candidates={},SpawnIntents={},SpawnTickets={},AwaitingArrival=nil,
    SquadRole={},DeadSquads={},SquadGroup={},DeferredOrders={},DetachedTarget={},
    Groups={},NextGroupId=1,
    Time=0,Timer=nil,TimerGeneration=0,
    TeamEdge=nil,TeamEdgeLogged=false,
    AttackUnlocked=false,AttackUnlockReason=nil,
    NextTankReinforcementAt=0,NextPatrolAt=0,NextInfantryOrderAt=0,
    ReconSquad=nil,ReconTarget=nil,
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
local function hasTag(r,t) return r and r.tagset and r.tagset[lower(t)]==true end
local function isDuelTank(r)
    return hasTag(r,"duel_tanks70") or hasTag(r,"duel_tanks80") or hasTag(r,"duel_tanks90")
end
local function isTank80Plus(r)
    return hasTag(r,"duel_tanks80") or hasTag(r,"duel_tanks90")
end
local function roleMatches(r,role)
    if role=="recon" then return hasTag(r,"all") and hasTag(r,"recon") end
    if role=="infantry" or role=="defense_infantry" then return hasTag(r,"all") and hasTag(r,"infantry") end
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
    local roles={"recon","infantry","defense_infantry","antiair","tank","tank80plus","aircraftlight","aat","antirad","strike","duel_heli","duel_fighter"}
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

local function enqueueSpawn(role,reason,delaySec,target,groupId,mode)
    local due=C.Time+(delaySec or 0)
    C.SpawnIntents[#C.SpawnIntents+1]={role=role,reason=reason or "",due=due,target=target,groupId=groupId,mode=mode,attempts=0,tried={}}
    log("QUEUE role="..role.." due="..due.." group="..tostring(groupId).." target="..tostring(target).." mode="..tostring(mode).." reason="..tostring(reason))
end

local function chooseUntried(intent)
    local list=C.Candidates[intent.role] or {}
    local available={}
    for _,rec in ipairs(list) do if not intent.tried[rec.unit] then available[#available+1]=rec end end
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
    for i,x in ipairs(C.SpawnIntents) do if x.due<=C.Time then idx=i break end end
    if not idx then return end
    local intent=table.remove(C.SpawnIntents,idx)
    local rec=chooseUntried(intent)
    if not rec then log("NO UNIT role="..intent.role) return end
    intent.attempts=intent.attempts+1
    local ticket={role=intent.role,reason=intent.reason,target=intent.target,groupId=intent.groupId,mode=intent.mode,unit=rec.unit}
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
        else
            log("SPAWN FAILED role="..intent.role)
        end
    end
end

local function flags()
    local my=BotApi.Instance.team
    local enemy=BotApi.Instance.enemyTeam
    local f={mine={},enemy={},neutral={},mineCount=0,enemyCount=0,neutralCount=0}
    for _,flag in pairs(BotApi.Scene.Flags) do
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

    if not edge then
        local army=lower(BotApi.Instance.army)
        if army=="usa" or army=="nato" then edge="HIGH" end
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

-- v1.5.1: strict neutral-first rule from the new scheme.
-- Enemy flags are returned only when no neutral flags remain.
local function availableTargets(includeEnemy)
    local f=flags()
    local list={}
    for _,n in ipairs(f.neutral) do list[#list+1]=n end
    if #list==0 and includeEnemy then
        for _,n in ipairs(f.enemy) do list[#list+1]=n end
    end
    sortByOwnSide(list)
    return list
end

local function chooseSideTarget(used,why,includeEnemy)
    local list=availableTargets(includeEnemy)
    for _,name in ipairs(list) do
        if not (used and used[name]) then
            log("TARGET SIDE flag="..tostring(name).." edge="..tostring(C.TeamEdge).." reason="..tostring(why))
            return name
        end
    end
    return nil
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
    sortByOwnSide(f.mine)
    return f.mine[1]
end

local function newGroup(target)
    local id=C.NextGroupId
    C.NextGroupId=C.NextGroupId+1
    C.Groups[id]={
        id=id,target=target,phase="opening",captured=false,stopped=false,
        attackStartedAt=nil,resultCheckAt=nil,nextAttackAt=nil,
        infantry={},tanks={},detached={},defenders={}
    }
    log("GROUP CREATE id="..id.." target="..tostring(target).." phase=opening")
    return id
end

local function setGroup(id,gid) if id and gid then C.SquadGroup[id]=gid end end
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
        if o.due<=C.Time then
            capture(o.squad,o.flag)
            table.remove(C.DeferredOrders,i)
        end
    end
end

local function chooseOwnFlag()
    local f=flags()
    if #f.mine==0 then return nil end
    sortByOwnSide(f.mine)
    return f.mine[1]
end

local function assignTankGroup()
    local best=nil
    local bestCount=nil
    for gid,g in pairs(C.Groups) do
        if not g.stopped and g.target and flagOccupant(g.target)~=BotApi.Instance.team then
            local c=#g.tanks
            if bestCount==nil or c<bestCount then best=gid bestCount=c end
        end
    end
    if not best then
        for gid,g in pairs(C.Groups) do
            if not g.stopped then best=gid break end
        end
    end
    return best
end

local function currentUsedTargets(exceptGid)
    local used={}
    for gid,g in pairs(C.Groups) do
        if gid~=exceptGid and not g.stopped and g.target and g.phase~="defend" then used[g.target]=true end
    end
    for sid,target in pairs(C.DetachedTarget) do
        if squadAlive(sid) and target then used[target]=true end
    end
    return used
end

local function chooseNextGroupTarget(gid,why)
    return chooseSideTarget(currentUsedTargets(gid),why or ("group "..gid.." next"),true)
end

local function startGroupAttack(gid)
    local g=C.Groups[gid]
    if not g or g.stopped then return end
    local t=chooseNextGroupTarget(gid,"attack group "..gid)
    if not t then return end
    g.target=t
    g.phase="attack"
    g.captured=false
    g.attackStartedAt=C.Time
    g.resultCheckAt=C.Time+NEU_BOT.AttackResultCheckSec
    g.nextAttackAt=nil
    log("ATTACK START group="..gid.." flag="..t.." checkAt="..g.resultCheckAt)
    if #g.infantry==0 then enqueueSpawn("infantry","new assault infantry",0,t,gid,"attack") end
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
        log("ATTACK UNLOCK reason="..C.AttackUnlockReason.." time="..C.Time.." mine="..f.mineCount.." enemy="..f.enemyCount)
        for gid,g in pairs(C.Groups) do
            if not g.stopped and g.phase=="opening" and g.target and flagOccupant(g.target)==BotApi.Instance.team then
                g.phase="defend"
                g.nextAttackAt=C.Time
            end
        end
    end
end

-- If the game creates separate squads after dismount/split, spread them to different free flags.
-- There is still no verified SplitSquad/Disembark command in BotApi, so v1.5.1 does not invent one.
local function discoverDetachedSquads()
    local used=currentUsedTargets(nil)
    for _,sid in pairs(BotApi.Scene.Squads) do
        if sid and not C.SquadRole[sid] and squadAlive(sid) then
            local t=chooseSideTarget(used,"detached infantry",true)
            if t then used[t]=true end
            C.SquadRole[sid]="infantry_detached"
            C.DeadSquads[sid]=false
            C.DetachedTarget[sid]=t
            log("DETACHED squad="..tostring(sid).." target="..tostring(t))
            if t then capture(sid,t) end
        end
    end
end

local function processDetachedOrders()
    for sid,target in pairs(C.DetachedTarget) do
        if squadAlive(sid) then
            if target and flagOccupant(target)==BotApi.Instance.team then
                local used=currentUsedTargets(nil)
                used[target]=nil
                local nextTarget=chooseSideTarget(used,"detached next",true)
                C.DetachedTarget[sid]=nextTarget
                target=nextTarget
            end
            if target then capture(sid,target) end
        end
    end
end

local function processGroupOrders()
    if C.Time<C.NextInfantryOrderAt then return end
    C.NextInfantryOrderAt=C.Time+NEU_BOT.InfantryReissueSec
    discoverDetachedSquads()

    for gid,g in pairs(C.Groups) do
        if not g.stopped and g.target and g.phase~="defend" then
            for _,sid in ipairs(g.infantry) do if squadAlive(sid) then capture(sid,g.target) end end
            for _,sid in ipairs(g.tanks) do if squadAlive(sid) then capture(sid,g.target) end end
        end
        for _,sid in ipairs(g.defenders) do
            if squadAlive(sid) then
                local d=C.DetachedTarget[sid] or chooseOwnFlagBefore(g.target) or chooseOwnFlag()
                if d then capture(sid,d) end
            end
        end
    end
    processDetachedOrders()
end

local function resolveAttackResults()
    for gid,g in pairs(C.Groups) do
        if not g.stopped and g.phase=="attack" and g.resultCheckAt and C.Time>=g.resultCheckAt then
            local success=(g.target and flagOccupant(g.target)==BotApi.Instance.team)
            if success then
                log("ATTACK RESULT group="..gid.." flag="..g.target.." success=YES")
                for _,sid in ipairs(g.infantry) do
                    if squadAlive(sid) then
                        g.defenders[#g.defenders+1]=sid
                        C.DetachedTarget[sid]=g.target
                    end
                end
                g.infantry={}
                g.phase="defend"
                g.captured=true
                g.nextAttackAt=C.Time+NEU_BOT.NextAttackDelaySec
            else
                log("ATTACK RESULT group="..gid.." flag="..tostring(g.target).." success=NO")
                enqueueSpawn("aircraftlight","stalled attack air support",0,g.target,gid,"support")
                local defenseFlag=chooseOwnFlagBefore(g.target)
                enqueueSpawn("defense_infantry","stalled attack fallback defense",0,defenseFlag,gid,"defense")
                g.resultCheckAt=C.Time+NEU_BOT.AttackResultCheckSec
            end
        end
    end
end

local function advanceGroups()
    for gid,g in pairs(C.Groups) do
        if not g.stopped and g.phase=="opening" and g.target and flagOccupant(g.target)==BotApi.Instance.team then
            if not g.captured then log("OPENING CAPTURE group="..gid.." flag="..g.target) end
            g.captured=true
            if C.AttackUnlocked then
                g.phase="defend"
                g.nextAttackAt=C.Time
            end
        elseif not g.stopped and g.phase=="defend" and C.AttackUnlocked and g.nextAttackAt and C.Time>=g.nextAttackAt then
            startGroupAttack(gid)
        end
    end
end

local function processRecon()
    if not C.ReconSquad or not squadAlive(C.ReconSquad) then return end
    if C.ReconTarget and flagOccupant(C.ReconTarget)~=BotApi.Instance.team then return end
    local used=currentUsedTargets(nil)
    local t=chooseSideTarget(used,"recon",true)
    C.ReconTarget=t
    if t then log("RECON NEXT flag="..t) capture(C.ReconSquad,t) end
end

local function processAA()
    if C.Time<C.NextPatrolAt then return end
    C.NextPatrolAt=C.Time+NEU_BOT.AntiAirPatrolSec
    local own=chooseOwnFlag()
    if own then
        for sid,role in pairs(C.SquadRole) do
            if squadAlive(sid) and (role=="antiair" or role=="aat") then capture(sid,own) end
        end
    end
end

local function processTankReinforcement()
    if C.Time<C.NextTankReinforcementAt then return end
    C.NextTankReinforcementAt=C.Time+NEU_BOT.TankReinforcementSec
    local gid=assignTankGroup()
    local target=gid and C.Groups[gid] and C.Groups[gid].target or nil
    enqueueSpawn("tank80plus","5 minute tank reinforcement",0,target,gid,"attack")
end

-- v1.5.1 direction rule: if an assault group loses an assault unit on an enemy-held target,
-- that group/direction stops attacking. Tank replacement is redirected to another active group.
local function detectLosses()
    for sid,role in pairs(C.SquadRole) do
        if not C.DeadSquads[sid] and not squadAlive(sid) then
            C.DeadSquads[sid]=true
            local gid=C.SquadGroup[sid]
            local g=gid and C.Groups[gid] or nil
            log("LOST squad="..tostring(sid).." role="..tostring(role).." group="..tostring(gid))

            if g and not g.stopped and g.phase=="attack" and g.target and flagOccupant(g.target)==BotApi.Instance.enemyTeam then
                if role=="infantry" or role=="infantry_detached" or role=="tank" or role=="tank80plus" then
                    g.stopped=true
                    g.phase="stopped"
                    g.nextAttackAt=nil
                    g.resultCheckAt=nil
                    log("DIRECTION STOP group="..tostring(gid).." flag="..tostring(g.target).." lostRole="..tostring(role))
                end
            end

            if role=="tank" or role=="tank80plus" then
                local replacementGid=gid
                if g and g.stopped then replacementGid=assignTankGroup() end
                local target=replacementGid and C.Groups[replacementGid] and C.Groups[replacementGid].target or nil
                enqueueSpawn("tank80plus","tank destroyed replacement",0,target,replacementGid,"attack")
                enqueueSpawn("infantry","tank destroyed infantry support",0,target,replacementGid,"attack")
                enqueueSpawn("aat","tank destroyed random AA",0,chooseOwnFlag(),replacementGid,"support")
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
            enqueueSpawn("aat","aircraft response 50/50",0,chooseOwnFlag(),nil,"support")
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

local function onSecond()
    C.Time=C.Time+1
    detectLosses()
    processDeferredOrders()
    unlockAttackIfNeeded()
    processEnemyRules()
    resolveAttackResults()
    advanceGroups()
    processGroupOrders()
    processRecon()
    processAA()
    processTankReinforcement()
    processSpawn()

    if C.Time%30==0 then
        local f=flags()
        local parts={}
        for gid,g in pairs(C.Groups) do
            parts[#parts+1]="G"..gid.."="..tostring(g.target)..":"..tostring(g.phase)
        end
        log("TIME="..C.Time.." SIDE="..tostring(C.TeamEdge).." ATTACK="..tostring(C.AttackUnlocked).." FLAGS="..f.mineCount.."/"..f.enemyCount.." N="..f.neutralCount.." GROUPS "..table.concat(parts," "))
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
        C.Timer=nil
        onSecond()
        if gen==C.TimerGeneration then C.Timer=BotApi.Events:SetQuantTimer(pulse,NEU_BOT.TickMs) end
    end
    C.Timer=BotApi.Events:SetQuantTimer(pulse,NEU_BOT.TickMs)
end

local function makeOpeningGroups()
    local used={}
    detectTeamEdge()
    for i=1,NEU_BOT.AssaultGroups do
        local target=chooseSideTarget(used,"opening group "..i,false)
        if target then used[target]=true end
        local gid=newGroup(target)
        enqueueSpawn("infantry","opening group infantry",0,target,gid,"opening")
    end
    local firstGid=1
    local tankTarget=C.Groups[firstGid] and C.Groups[firstGid].target or nil
    enqueueSpawn("tank","opening tank",NEU_BOT.OpeningTankDelaySec,tankTarget,firstGid,"opening")
end

function onGameStart()
    math.randomseed(os.time()*BotApi.Instance.hostId)
    C.Units={} C.Units.count=1
    readAllUnits(nil,C.Units,BotApi.Instance.army)
    buildCandidates()

    C.SpawnIntents={} C.SpawnTickets={} C.AwaitingArrival=nil
    C.SquadRole={} C.DeadSquads={} C.SquadGroup={} C.DeferredOrders={} C.DetachedTarget={}
    C.Groups={} C.NextGroupId=1
    C.Time=0 C.Timer=nil
    C.TeamEdge=nil C.TeamEdgeLogged=false
    C.AttackUnlocked=false C.AttackUnlockReason=nil
    C.NextTankReinforcementAt=NEU_BOT.TankReinforcementSec
    C.NextPatrolAt=0 C.NextInfantryOrderAt=0
    C.ReconSquad=nil C.ReconTarget=nil
    C.EnemySignals={aatSeenAt=nil,aatDestroyedAt=nil,aatStage=0,aatCheckAt=nil,
                    aircraftSeenAt=nil,aircraftDestroyedAt=nil,aircraftResponseAt=nil}

    detectTeamEdge()
    enqueueSpawn("recon","opening recon",0,nil,nil,"opening")
    enqueueSpawn("antiair","opening aa",0,nil,nil,"opening")
    log("START v1.5.1 army="..tostring(BotApi.Instance.army).." playerId="..tostring(BotApi.Instance.playerId).." hostId="..tostring(BotApi.Instance.hostId).." units="..tostring(C.Units.count-1))
    log("RULE neutral-first=ON direction-stop=ON split/dismount=runtime-only")
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

    local sid=args.squadId
    C.SquadRole[sid]=ticket.role
    C.DeadSquads[sid]=false
    if ticket.groupId then setGroup(sid,ticket.groupId) end
    log("ARRIVED squad="..tostring(sid).." role="..ticket.role.." group="..tostring(ticket.groupId).." target="..tostring(ticket.target).." mode="..tostring(ticket.mode))

    if ticket.role=="recon" then
        C.ReconSquad=sid
        if C.NextGroupId==1 then makeOpeningGroups() end
        local used=currentUsedTargets(nil)
        C.ReconTarget=chooseSideTarget(used,"opening recon",true)
        if C.ReconTarget then capture(sid,C.ReconTarget) end

    elseif ticket.role=="infantry" then
        local gid=ticket.groupId
        if gid and C.Groups[gid] then C.Groups[gid].infantry[#C.Groups[gid].infantry+1]=sid end
        if ticket.target then capture(sid,ticket.target) end

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
        end
        local t=(gid and C.Groups[gid] and not C.Groups[gid].stopped and C.Groups[gid].target) or ticket.target
        if t then deferCapture(sid,t,NEU_BOT.VehicleFollowDelaySec) end

    elseif ticket.role=="antiair" or ticket.role=="aat" then
        local own=ticket.target or chooseOwnFlag()
        if own then capture(sid,own) end

    elseif ticket.target then
        capture(sid,ticket.target)
    end

    processSpawn()
end

BotApi.Events:Subscribe(BotApi.Events.GameStart,onGameStart)
BotApi.Events:Subscribe(BotApi.Events.GameEnd,onGameStop)
BotApi.Events:Subscribe(BotApi.Events.Quant,onGameQuant)
BotApi.Events:Subscribe(BotApi.Events.GameSpawn,onGameSpawn)
