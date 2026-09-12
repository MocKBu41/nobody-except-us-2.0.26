-- NEU BOT v1.8
-- Map-aware targeting based on _flag_points_final.json.
-- Neutral-first, 2 BTGs, recon capture, vehicle_supporter capture pairs.
-- Verified BotApi commands only: Spawn, CaptureFlag, Income, EnemyHasTanks.

require([[/script/multiplayer/bot.data]])
require([[/script/multiplayer/bot.mapdata]])
local MAP=NEU_MAPDATA

local C={
 Units={},Candidates={},SpawnIntents={},SpawnTickets={},AwaitingArrival=nil,
 SquadRole={},DeadSquads={},SquadGroup={},DeferredOrders={},DefendTarget={},TankReadyAt={},Groups={},
 Time=0,Timer=nil,TimerGeneration=0,AttackUnlocked=false,AttackUnlockReason=nil,NeutralsCleared=false,
 NextTankReinforcementAt=0,NextInfantryReinforcementAt=0,NextPatrolAt=0,NextOrderAt=0,NextNeutralAt=0,
 NeutralCaptureTarget={},NeutralPending={},ReconSquad=nil,ReconTarget=nil,CaptureSource="all infantry fallback",
 BalanceDefenseActive=false,
 EnemySignals={aatSeenAt=nil,aatDestroyedAt=nil,aatStage=0,aatCheckAt=nil,aircraftSeenAt=nil,aircraftDestroyedAt=nil,aircraftResponseAt=nil}
}

local function log(m) print("[NEU-BOT] "..tostring(m)) end
local function lower(s) return string.lower(tostring(s or "")) end
local function splitTags(tags) local o={} for t in string.gmatch(tags or "","%S+") do o[lower(t)]=true end return o end
local function hasTag(r,t) return r and r.tagset and r.tagset[lower(t)]==true end
local function roleMatches(r,role)
 if role=="recon" then return hasTag(r,"all") and hasTag(r,"recon") end
 if role=="infantry" or role=="defense_infantry" or role=="capture_infantry" then return hasTag(r,"all") and hasTag(r,"infantry") end
 if role=="antiair" then return hasTag(r,"all") and hasTag(r,"antiair") end
 if role=="tank" then return hasTag(r,"duel_tanks70") or hasTag(r,"duel_tanks80") or hasTag(r,"duel_tanks90") end
 if role=="tank80plus" then return hasTag(r,"duel_tanks80") or hasTag(r,"duel_tanks90") end
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
 local records,buffer,stack={},{},{} local quoted,escaped,comment=false,false,false
 for i=1,#raw do
  local ch=raw:sub(i,i)
  if comment then if ch=="\n" then comment=false if #stack>0 then buffer[#buffer+1]=" " end end
  elseif quoted then buffer[#buffer+1]=ch if escaped then escaped=false elseif ch=="\\" then escaped=true elseif ch=='"' then quoted=false end
  elseif ch==";" then comment=true
  elseif ch=='"' then if #stack>0 then buffer[#buffer+1]=ch quoted=true end
  elseif ch=="(" or ch=="{" then stack[#stack+1]=ch buffer[#buffer+1]=ch
  elseif ch==")" or ch=="}" then
   if #stack>0 then local expected=(ch==")") and "(" or "{" if stack[#stack]~=expected then return records end buffer[#buffer+1]=ch stack[#stack]=nil if #stack==0 then records[#records+1]=table.concat(buffer) buffer={} end end
  elseif #stack>0 then buffer[#buffer+1]=ch end
 end
 return records
end
function readUnitsRaw(fname,units,army)
 local f=io.open(fname,"r") if not f then log("FILE MISSING "..fname) return end local raw=f:read("*a") f:close()
 units.count=units.count or 1 units.seen=units.seen or {} local added=0
 for _,line in ipairs(parseRecords(raw)) do
  local side=detectSide(line)
  if side and lower(side)==lower(army) then
   local parts={} for tags in line:gmatch('%f[%w]t%s*%(([^)]*)%)') do parts[#parts+1]=tags end local tags=table.concat(parts," ")
   local vehicle=line:match('^%s*{%s*"([^"]+)"') local name=vehicle or line:match('%f[%w]name%s*%(([^)]+)%)')
   if name and not name:find("mp/",1,true) then
    local id=vehicle or (name.."("..army..")")
    if not units.seen[id] then local rec={unit=id,tags=tags,tagset=splitTags(tags),raw=line,side=side,nobot=(line:find("nobot",1,true)~=nil)} if not rec.nobot then units[units.count]=rec units.count=units.count+1 units.seen[id]=true added=added+1 end end
   end
  end
 end
 log("READ "..fname.." added="..added)
end
local function buildCandidates()
 local roles={"recon","infantry","capture_infantry","defense_infantry","antiair","tank","tank80plus","aircraftlight","aat","antirad","strike","duel_heli","duel_fighter"}
 C.Candidates={} for _,r in ipairs(roles) do C.Candidates[r]={} end
 for _,rec in ipairs(C.Units) do if type(rec)=="table" then for _,r in ipairs(roles) do if roleMatches(rec,r) then C.Candidates[r][#C.Candidates[r]+1]=rec end end end end
 local preferred={}
 for _,rec in ipairs(C.Candidates.infantry or {}) do local text=lower((rec.unit or "").." "..(rec.raw or "")) if text:find("vehicle_supporter",1,true) then preferred[#preferred+1]=rec end end
 if #preferred>0 then C.Candidates.capture_infantry=preferred C.CaptureSource="vehicle_supporter" else C.Candidates.capture_infantry=C.Candidates.infantry C.CaptureSource="all infantry fallback" end
 for _,r in ipairs(roles) do log("ROLE "..r.." candidates="..#(C.Candidates[r] or {})) end log("CAPTURE SOURCE="..C.CaptureSource)
end

local function flags()
 local my,enemy=BotApi.Instance.team,BotApi.Instance.enemyTeam local f={mine={},enemy={},neutral={},mineCount=0,enemyCount=0,neutralCount=0}
 for _,x in pairs(BotApi.Scene.Flags) do if x.occupant==my then f.mine[#f.mine+1]=x.name f.mineCount=f.mineCount+1 elseif x.occupant==enemy then f.enemy[#f.enemy+1]=x.name f.enemyCount=f.enemyCount+1 else f.neutral[#f.neutral+1]=x.name f.neutralCount=f.neutralCount+1 end end
 return f
end
local function flagObj(name) for _,f in pairs(BotApi.Scene.Flags) do if f.name==name then return f end end end
local function flagOccupant(name) local f=flagObj(name) return f and f.occupant or nil end
local function flagNumber(name) return type(name)=="string" and tonumber(name:match("(%d+)$")) or nil end
local function numericSort(list) table.sort(list,function(a,b) local na,nb=flagNumber(a),flagNumber(b) if na and nb and na~=nb then return na<nb end return tostring(a)<tostring(b) end) end
local function geoSortSpawn(list,reason)
 if MAP and MAP.loaded and MAP.spawn then MAP:sortFromSpawn(list) if #list>0 then log("TARGET GEO reason="..reason.." first="..tostring(list[1]).." distSpawn="..tostring(MAP:distanceFromSpawn(list[1]))) end else numericSort(list) end
end
local function frontOwnList()
 local f=flags() if MAP and MAP.loaded then return MAP:frontOwnFlags(f.mine,f.enemy) end numericSort(f.mine) return f.mine
end
local function chooseFrontOwnFlag(used) local list=frontOwnList() for _,n in ipairs(list) do if not (used and used[n]) then return n end end return list[1] end
local function chooseOwnFlagBefore(target)
 local f=flags() if #f.mine==0 then return nil end
 if MAP and MAP.loaded and MAP:point(target) then
  local best,bd=nil,nil local td=MAP:distanceFromSpawn(target)
  for _,name in ipairs(f.mine) do local d=MAP:distanceNames(name,target) local sd=MAP:distanceFromSpawn(name) if d and (not td or not sd or sd<=td) and (not bd or d<bd) then best,bd=name,d end end
  if not best then best,bd=MAP:nearestToFlag(f.mine,target,nil) end
  if best then log("FRONTLINE GEO defend="..best.." before="..tostring(target).." distance="..tostring(bd)) return best end
 end
 return chooseFrontOwnFlag(nil)
end

local function squadAlive(id) return id and BotApi.Scene:IsSquadExists(id) end
local function capture(id,flag)
 if not (id and flag and squadAlive(id)) then return end local role=C.SquadRole[id] local occ=flagOccupant(flag)
 if occ~=BotApi.Instance.team and occ~=BotApi.Instance.enemyTeam and role~="capture_infantry" and role~="recon" then return end
 log("ORDER squad="..tostring(id).." group="..tostring(C.SquadGroup[id]).." flag="..tostring(flag).." role="..tostring(role)) BotApi.Commands:CaptureFlag(id,flag)
end
local function deferCapture(id,flag,delay) C.DeferredOrders[#C.DeferredOrders+1]={squad=id,flag=flag,due=C.Time+(delay or 0)} end
local function processDeferredOrders() for i=#C.DeferredOrders,1,-1 do local o=C.DeferredOrders[i] if o.due<=C.Time then capture(o.squad,o.flag) table.remove(C.DeferredOrders,i) end end end

local function pendingForGroup(role,gid) for _,x in ipairs(C.SpawnIntents) do if x.role==role and x.groupId==gid then return true end end return C.AwaitingArrival and C.AwaitingArrival.role==role and C.AwaitingArrival.groupId==gid end
local function enqueueSpawn(role,reason,delay,target,gid,mode)
 C.SpawnIntents[#C.SpawnIntents+1]={role=role,reason=reason or "",due=C.Time+(delay or 0),target=target,groupId=gid,mode=mode,attempts=0,tried={}}
 if role=="capture_infantry" and target then C.NeutralPending[target]=true end
 log("QUEUE role="..role.." due="..(C.Time+(delay or 0)).." group="..tostring(gid).." target="..tostring(target).." reason="..tostring(reason))
end
local function chooseUntried(intent)
 local list=C.Candidates[intent.role] or {} local a={} for _,r in ipairs(list) do if not intent.tried[r.unit] then a[#a+1]=r end end if #a==0 then return nil end local r=a[math.random(1,#a)] intent.tried[r.unit]=true return r
end
local function processSpawn()
 if C.AwaitingArrival then return end local idx=nil for i,x in ipairs(C.SpawnIntents) do if x.due<=C.Time then idx=i break end end if not idx then return end
 local intent=table.remove(C.SpawnIntents,idx) local rec=chooseUntried(intent)
 if not rec then if intent.role=="capture_infantry" and intent.target then C.NeutralPending[intent.target]=nil end log("NO UNIT role="..intent.role) return end
 intent.attempts=intent.attempts+1 local ticket={role=intent.role,reason=intent.reason,target=intent.target,groupId=intent.groupId,mode=intent.mode,unit=rec.unit} C.SpawnTickets[#C.SpawnTickets+1]=ticket
 local maxSize=(intent.role=="capture_infantry") and (NEU_BOT.NeutralCaptureSquadSize or 2) or MaxSquadSize local ok=BotApi.Commands:Spawn(rec.unit,maxSize)
 if ok then C.AwaitingArrival=ticket log("SPAWN OK role="..intent.role.." unit="..rec.unit.." group="..tostring(intent.groupId).." maxSquad="..tostring(maxSize))
 else table.remove(C.SpawnTickets,#C.SpawnTickets) if intent.attempts<#(C.Candidates[intent.role] or {}) then intent.due=C.Time+(NEU_BOT.SpawnRetrySec or 2) C.SpawnIntents[#C.SpawnIntents+1]=intent else if intent.role=="capture_infantry" and intent.target then C.NeutralPending[intent.target]=nil end log("SPAWN FAILED role="..intent.role) end end
end

local function aliveCount(list) local n=0 for _,sid in ipairs(list or {}) do if squadAlive(sid) then n=n+1 end end return n end
local function newGroup(id) C.Groups[id]={id=id,target=nil,phase="opening",stopped=false,failedTarget=nil,restartAt=nil,infantry={},tanks={},defenders={},resultCheckAt=nil,nextAttackAt=nil} log("GROUP CREATE id="..id) end
local function activeGroups() local a={} for id,g in pairs(C.Groups) do if not g.stopped then a[#a+1]=id end end table.sort(a) return a end
local function usedEnemyTargets(except) local u={} for id,g in pairs(C.Groups) do if id~=except and not g.stopped and g.target and flagOccupant(g.target)==BotApi.Instance.enemyTeam then u[g.target]=true end end return u end
local function chooseEnemyTarget(gid)
 local f=flags() if #f.enemy==0 then return nil end local used=usedEnemyTargets(gid) local g=C.Groups[gid] local candidates={} for _,n in ipairs(f.enemy) do if not used[n] then candidates[#candidates+1]=n end end
 if MAP and MAP.loaded then local front=MAP:frontOwnFlags(f.mine,f.enemy) local from=front[1] if from then table.sort(candidates,function(a,b) return (MAP:distanceNames(from,a) or 1e30)<(MAP:distanceNames(from,b) or 1e30) end) log("TARGET GEO group="..gid.." fromFront="..tostring(from).." candidates="..#candidates) else geoSortSpawn(candidates,"enemy-no-own-front") end else numericSort(candidates) end
 for _,n in ipairs(candidates) do if not g or not g.failedTarget or n~=g.failedTarget then return n end end return candidates[1]
end
local function assignTankGroup() local best,bn=nil,nil for _,id in ipairs(activeGroups()) do local n=aliveCount(C.Groups[id].tanks) if bn==nil or n<bn then best,bn=id,n end end return best end
local function ensureInfantry(id,reason) local g=C.Groups[id] if g and not g.stopped and aliveCount(g.infantry)==0 and not pendingForGroup("infantry",id) then enqueueSpawn("infantry",reason,0,g.target,id,"attack") end end
local function ensureTank(id,reason,delay) local g=C.Groups[id] if g and not g.stopped and aliveCount(g.tanks)==0 and not pendingForGroup("tank",id) and not pendingForGroup("tank80plus",id) then enqueueSpawn("tank80plus",reason,delay or 0,g.target,id,"attack") end end
local function makeOpeningGroups() if C.Groups[1] then return end for i=1,NEU_BOT.AssaultGroups do newGroup(i) enqueueSpawn("infantry","opening BTG infantry",0,nil,i,"opening") enqueueSpawn("tank","opening BTG tank",NEU_BOT.OpeningTankDelaySec,nil,i,"opening") end end

local function activeCaptureReservations()
 local n=0 for sid,target in pairs(C.NeutralCaptureTarget) do if squadAlive(sid) and target and flagOccupant(target)~=BotApi.Instance.team then n=n+1 end end for target,v in pairs(C.NeutralPending) do if v and flagOccupant(target)~=BotApi.Instance.team then n=n+1 end end return n
end
local function captureIntentExists(target) for _,x in ipairs(C.SpawnIntents) do if x.role=="capture_infantry" and x.target==target then return true end end return C.AwaitingArrival and C.AwaitingArrival.role=="capture_infantry" and C.AwaitingArrival.target==target end
local function neutralUsed() local u={} if C.ReconTarget then u[C.ReconTarget]=true end for sid,t in pairs(C.NeutralCaptureTarget) do if squadAlive(sid) and t then u[t]=true end end for t,v in pairs(C.NeutralPending) do if v then u[t]=true end end return u end
local function chooseNeutral(used,reason) local f=flags() local list={} for _,n in ipairs(f.neutral) do if not (used and used[n]) then list[#list+1]=n end end geoSortSpawn(list,reason) return list[1] end
local function processRecon()
 if not squadAlive(C.ReconSquad) then return end local f=flags() if f.neutralCount==0 then C.ReconTarget=nil return end
 if C.ReconTarget and flagOccupant(C.ReconTarget)~=BotApi.Instance.team and flagOccupant(C.ReconTarget)~=BotApi.Instance.enemyTeam then capture(C.ReconSquad,C.ReconTarget) return end
 C.ReconTarget=nil local target=chooseNeutral(neutralUsed(),"recon-nearest-spawn") if target then C.ReconTarget=target log("RECON TARGET GEO flag="..target.." dSpawn="..tostring(MAP and MAP:distanceFromSpawn(target))) capture(C.ReconSquad,target) end
end
local function processNeutralCapture()
 if C.Time<C.NextNeutralAt then return end C.NextNeutralAt=C.Time+(NEU_BOT.NeutralCaptureCheckSec or 5) local f=flags() local neutral={} for _,n in ipairs(f.neutral) do neutral[n]=true end
 for sid,target in pairs(C.NeutralCaptureTarget) do if not squadAlive(sid) then C.NeutralCaptureTarget[sid]=nil if target then C.NeutralPending[target]=nil end elseif target and neutral[target] then capture(sid,target) else if target then log("NEUTRAL CAPTURE DONE squad="..sid.." flag="..target) end C.NeutralCaptureTarget[sid]=nil if target then C.NeutralPending[target]=nil end end end
 if f.neutralCount==0 then return end local limit=NEU_BOT.NeutralCaptureMaxActive or 3 local used=neutralUsed() local list={} for _,n in ipairs(f.neutral) do if not used[n] then list[#list+1]=n end end geoSortSpawn(list,"capture-pairs-nearest-spawn")
 for _,target in ipairs(list) do if activeCaptureReservations()>=limit then break end if not captureIntentExists(target) then enqueueSpawn("capture_infantry","neutral capture pair GEO",0,target,nil,"neutral_capture") used[target]=true end end
end

local function unlockAttack()
 if C.AttackUnlocked then return end local f=flags() if C.Time>=NEU_BOT.AttackWaitSec then C.AttackUnlocked=true C.AttackUnlockReason="5 minutes" elseif f.enemyCount>f.mineCount then C.AttackUnlocked=true C.AttackUnlockReason="enemy flag advantage" end if C.AttackUnlocked then log("ATTACK UNLOCK reason="..C.AttackUnlockReason) end
end
local function neutralTransition()
 local f=flags()
 if f.neutralCount==0 then if not C.NeutralsCleared then C.NeutralsCleared=true log("NEUTRALS CLEARED") for id,g in pairs(C.Groups) do if not g.stopped then g.phase="ready" g.target=nil g.resultCheckAt=nil g.nextAttackAt=C.Time end end end
 else if C.NeutralsCleared then C.NeutralsCleared=false log("NEUTRALS RETURNED") end for _,g in pairs(C.Groups) do if not g.stopped and g.phase=="attack" then g.phase="hold_neutral" g.resultCheckAt=nil end end end
end
local function startAttack(id)
 local g=C.Groups[id] if not g or g.stopped or not C.AttackUnlocked or flags().neutralCount>0 then return end local target=chooseEnemyTarget(id)
 if not target then g.phase="ready" g.nextAttackAt=C.Time+5 return end local old=g.failedTarget g.target=target g.failedTarget=nil g.phase="attack" g.resultCheckAt=C.Time+NEU_BOT.AttackResultCheckSec g.nextAttackAt=nil
 log("ATTACK START group="..id.." flag="..target.." previousFailed="..tostring(old).." dSpawn="..tostring(MAP and MAP:distanceFromSpawn(target))) ensureInfantry(id,"new assault infantry") ensureTank(id,"attack tank",0)
end
local function startReadyGroups() if not C.AttackUnlocked or not C.NeutralsCleared then return end for _,id in ipairs(activeGroups()) do local g=C.Groups[id] if (g.phase=="ready" or g.phase=="opening" or g.phase=="hold_neutral") and (not g.nextAttackAt or C.Time>=g.nextAttackAt) then startAttack(id) end end end
local function processOrders()
 if C.Time<C.NextOrderAt then return end C.NextOrderAt=C.Time+NEU_BOT.InfantryReissueSec
 for _,g in pairs(C.Groups) do
  if not g.stopped and g.phase=="attack" and g.target and flagOccupant(g.target)==BotApi.Instance.enemyTeam then for _,sid in ipairs(g.infantry) do if squadAlive(sid) then capture(sid,g.target) end end for _,sid in ipairs(g.tanks) do if squadAlive(sid) and C.Time>=(C.TankReadyAt[sid] or 0) then capture(sid,g.target) end end end
  for _,sid in ipairs(g.defenders) do if squadAlive(sid) then local t=C.DefendTarget[sid] or chooseOwnFlagBefore(g.target) if t then capture(sid,t) end end end
 end
end
local function resolveAttackResults()
 for id,g in pairs(C.Groups) do if not g.stopped and g.phase=="attack" and g.resultCheckAt and C.Time>=g.resultCheckAt then
  if g.target and flagOccupant(g.target)==BotApi.Instance.team then
   log("ATTACK RESULT group="..id.." flag="..g.target.." success=YES") for _,sid in ipairs(g.infantry) do if squadAlive(sid) then g.defenders[#g.defenders+1]=sid C.DefendTarget[sid]=g.target end end g.infantry={} g.phase="ready" g.resultCheckAt=nil g.nextAttackAt=C.Time+NEU_BOT.NextAttackDelaySec
  else
   log("ATTACK RESULT group="..id.." flag="..tostring(g.target).." success=NO") enqueueSpawn("aircraftlight","stalled attack air support",0,g.target,id,"support") enqueueSpawn("defense_infantry","stalled fallback defense",0,chooseOwnFlagBefore(g.target),id,"defense") g.resultCheckAt=C.Time+NEU_BOT.AttackResultCheckSec
  end
 end end
end

local function stopDirection(id,reason) local g=C.Groups[id] if not g or g.stopped then return end g.stopped=true g.phase="stopped" g.failedTarget=g.target g.restartAt=C.Time+(NEU_BOT.DirectionRecoverySec or 30) g.resultCheckAt=nil log("DIRECTION STOP group="..id.." failed="..tostring(g.failedTarget).." reason="..reason) end
local function recoverDirections()
 if flags().neutralCount>0 or not C.AttackUnlocked then return end
 for id,g in pairs(C.Groups) do if g.stopped and g.restartAt and C.Time>=g.restartAt then g.stopped=false g.phase="ready" g.target=nil g.nextAttackAt=C.Time+5 g.restartAt=nil g.infantry={} log("DIRECTION REBUILD group="..id.." failed="..tostring(g.failedTarget)) enqueueSpawn("infantry","direction rebuild infantry",0,nil,id,"rebuild") enqueueSpawn("tank80plus","direction rebuild tank",0,nil,id,"rebuild") end end
end
local function detectLosses()
 for sid,role in pairs(C.SquadRole) do if not C.DeadSquads[sid] and not squadAlive(sid) then
  C.DeadSquads[sid]=true local id=C.SquadGroup[sid] local g=id and C.Groups[id] log("LOST squad="..sid.." role="..role.." group="..tostring(id))
  if role=="capture_infantry" then local t=C.NeutralCaptureTarget[sid] C.NeutralCaptureTarget[sid]=nil if t then C.NeutralPending[t]=nil end C.NextNeutralAt=0 end
  if role=="recon" then C.ReconSquad=nil C.ReconTarget=nil end
  if role=="infantry" and g and not g.stopped and g.phase=="attack" and aliveCount(g.infantry)==0 then stopDirection(id,"main-infantry-lost") end
  if role=="tank" or role=="tank80plus" then local rid=(g and not g.stopped) and id or assignTankGroup() local target=rid and C.Groups[rid] and C.Groups[rid].target or nil if rid then log("TANK LOSS CONTINUE group="..rid) end enqueueSpawn("tank80plus","tank destroyed replacement",0,target,rid,"attack") enqueueSpawn("infantry","tank destroyed infantry support",0,target,rid,"attack") enqueueSpawn("aat","tank destroyed AA",0,chooseFrontOwnFlag(nil),rid,"support") enqueueSpawn("aircraftlight","tank destroyed air support",0,target,rid,"support") end
 end end
end

local function processAA() if C.Time<C.NextPatrolAt then return end C.NextPatrolAt=C.Time+NEU_BOT.AntiAirPatrolSec local t=chooseFrontOwnFlag(nil) if t then for sid,role in pairs(C.SquadRole) do if squadAlive(sid) and (role=="antiair" or role=="aat") then capture(sid,t) end end end end
local function processBalanceDefense()
 local f=flags() local should=(f.mineCount>f.enemyCount)
 if should and not C.BalanceDefenseActive then C.BalanceDefenseActive=true local used={} log("BALANCE DEFENSE ON") for _,id in ipairs(activeGroups()) do local t=chooseFrontOwnFlag(used) if t then used[t]=true enqueueSpawn("defense_infantry","geo frontline defense",0,t,id,"defense") end end elseif not should and C.BalanceDefenseActive then C.BalanceDefenseActive=false log("BALANCE DEFENSE OFF") end
end
local function processReinforcements()
 if C.Time>=C.NextTankReinforcementAt then C.NextTankReinforcementAt=C.Time+NEU_BOT.TankReinforcementSec for _,id in ipairs(activeGroups()) do enqueueSpawn("tank80plus","5 minute tank",0,C.Groups[id].target,id,"attack") end end
 if C.Time>=C.NextInfantryReinforcementAt then C.NextInfantryReinforcementAt=C.Time+NEU_BOT.InfantryReinforcementSec if flags().neutralCount>0 then C.NextNeutralAt=0 else for _,id in ipairs(activeGroups()) do enqueueSpawn("infantry","5 minute infantry",0,C.Groups[id].target,id,"attack") end end end
end
local function processEnemyRules()
 local s=C.EnemySignals
 if s.aatSeenAt and s.aatStage==1 and C.Time>=s.aatSeenAt+NEU_BOT.AntiRadDelaySec then enqueueSpawn("antirad","enemy aat response",0,nil,nil,"support") s.aatStage=2 s.aatCheckAt=C.Time+NEU_BOT.EnemyResponseCheckSec
 elseif s.aatStage==2 and s.aatCheckAt and C.Time>=s.aatCheckAt then if s.aatDestroyedAt and s.aatDestroyedAt>=s.aatSeenAt then enqueueSpawn("duel_heli","aat destroyed",0,nil,nil,"support") s.aatStage=0 s.aatCheckAt=nil else enqueueSpawn("antirad","aat survived",0,nil,nil,"support") enqueueSpawn("strike","aat survived",0,nil,nil,"support") s.aatCheckAt=C.Time+NEU_BOT.EnemyResponseCheckSec end end
 if s.aircraftSeenAt and s.aircraftResponseAt and C.Time>=s.aircraftResponseAt then if s.aircraftDestroyedAt and s.aircraftDestroyedAt>=s.aircraftSeenAt then local id=assignTankGroup() local t=id and C.Groups[id] and C.Groups[id].target or nil enqueueSpawn("tank80plus","aircraft destroyed reward",0,t,id,"attack") enqueueSpawn("infantry","aircraft destroyed reward",0,t,id,"attack") else enqueueSpawn("duel_fighter","aircraft alive",0,nil,nil,"support") end s.aircraftResponseAt=nil end
end
function NEU_BOT_EnemyTagSeen(tag)
 tag=lower(tag)
 if tag=="aat" then C.EnemySignals.aatSeenAt=C.Time C.EnemySignals.aatDestroyedAt=nil C.EnemySignals.aatStage=1 C.EnemySignals.aatCheckAt=nil
 elseif tag=="aircraft" then C.EnemySignals.aircraftSeenAt=C.Time C.EnemySignals.aircraftDestroyedAt=nil C.EnemySignals.aircraftResponseAt=C.Time+NEU_BOT.EnemyResponseCheckSec if math.random(2)==1 then enqueueSpawn("duel_fighter","aircraft response 50/50",0,nil,nil,"support") else enqueueSpawn("aat","aircraft response 50/50",0,chooseFrontOwnFlag(nil),nil,"support") end end
end
function NEU_BOT_EnemyTagDestroyed(tag) tag=lower(tag) if tag=="aat" then C.EnemySignals.aatDestroyedAt=C.Time elseif tag=="aircraft" then C.EnemySignals.aircraftDestroyedAt=C.Time end end

local function onSecond()
 C.Time=C.Time+1 detectLosses() processDeferredOrders() unlockAttack() processEnemyRules() processRecon() processNeutralCapture() neutralTransition() recoverDirections() startReadyGroups() resolveAttackResults() processOrders() processAA() processBalanceDefense() processReinforcements() processSpawn()
 if C.Time%30==0 then local f=flags() local p={} for id,g in pairs(C.Groups) do p[#p+1]="G"..id.."="..tostring(g.target)..":"..g.phase..":I"..aliveCount(g.infantry)..":T"..aliveCount(g.tanks) end log("TIME="..C.Time.." MAP="..tostring(MAP and MAP.mapKey).." FLAGS="..f.mineCount.."/"..f.enemyCount.." N="..f.neutralCount.." RES="..activeCaptureReservations().." "..table.concat(p," ")) end
end
local function stopClock() C.TimerGeneration=C.TimerGeneration+1 if C.Timer then BotApi.Events:KillQuantTimer(C.Timer) C.Timer=nil end end
local function startClock() stopClock() local gen=C.TimerGeneration local function pulse() if gen~=C.TimerGeneration then return end C.Timer=nil onSecond() if gen==C.TimerGeneration then C.Timer=BotApi.Events:SetQuantTimer(pulse,NEU_BOT.TickMs) end end C.Timer=BotApi.Events:SetQuantTimer(pulse,NEU_BOT.TickMs) end

function onGameStart()
 local host=tonumber(BotApi.Instance.hostId) or 1 math.randomseed(os.time()*host)
 C.Units={count=1,seen={}} readAllUnits(nil,C.Units,BotApi.Instance.army) buildCandidates()
 C.SpawnIntents={} C.SpawnTickets={} C.AwaitingArrival=nil C.SquadRole={} C.DeadSquads={} C.SquadGroup={} C.DeferredOrders={} C.DefendTarget={} C.TankReadyAt={} C.Groups={} C.Time=0
 C.AttackUnlocked=false C.AttackUnlockReason=nil C.NeutralsCleared=false C.NextTankReinforcementAt=NEU_BOT.TankReinforcementSec C.NextInfantryReinforcementAt=NEU_BOT.InfantryReinforcementSec C.NextPatrolAt=0 C.NextOrderAt=0 C.NextNeutralAt=0 C.NeutralCaptureTarget={} C.NeutralPending={} C.ReconSquad=nil C.ReconTarget=nil C.BalanceDefenseActive=false
 C.EnemySignals={aatSeenAt=nil,aatDestroyedAt=nil,aatStage=0,aatCheckAt=nil,aircraftSeenAt=nil,aircraftDestroyedAt=nil,aircraftResponseAt=nil}
 local mapOk=MAP and MAP:load() or false
 enqueueSpawn("recon","opening recon",0,nil,nil,"opening") enqueueSpawn("antiair","opening aa",0,nil,nil,"opening")
 log("START v1.8 army="..tostring(BotApi.Instance.army).." team="..tostring(BotApi.Instance.team).." units="..tostring((C.Units.count or 1)-1))
 log("RULE logic-editor=neutral-first two-BTG=ON recon-capture=ON capture-pair=vehicle_supporter/2")
 log("MAP KNOWLEDGE source=_flag_points_final loaded="..tostring(mapOk).." key="..tostring(MAP and MAP.mapKey).." spawn="..tostring(MAP and MAP.spawn~=nil))
 log("RULE exact-tank-100m=NOT-AVAILABLE verified-Move-command=NO")
 startClock() processSpawn()
end
function onGameStop() stopClock() collectgarbage("collect") end
function onGameQuant() processSpawn() end
function onGameSpawn(args)
 local ticket=nil if #C.SpawnTickets>0 then ticket=table.remove(C.SpawnTickets,1) end if not ticket then log("UNMATCHED SPAWN squad="..tostring(args and args.squadId).." policy=ignore") return end if C.AwaitingArrival==ticket then C.AwaitingArrival=nil end
 local sid=args.squadId C.SquadRole[sid]=ticket.role C.DeadSquads[sid]=false if ticket.groupId then C.SquadGroup[sid]=ticket.groupId end
 log("ARRIVED squad="..sid.." role="..ticket.role.." group="..tostring(ticket.groupId).." target="..tostring(ticket.target))
 if ticket.role=="recon" then C.ReconSquad=sid makeOpeningGroups() processRecon()
 elseif ticket.role=="capture_infantry" then C.NeutralPending[ticket.target]=nil C.NeutralCaptureTarget[sid]=ticket.target if ticket.target then capture(sid,ticket.target) end
 elseif ticket.role=="infantry" then local id=ticket.groupId if id and C.Groups[id] then C.Groups[id].infantry[#C.Groups[id].infantry+1]=sid if C.Groups[id].phase=="attack" and C.Groups[id].target then capture(sid,C.Groups[id].target) end end
 elseif ticket.role=="defense_infantry" then local id=ticket.groupId if id and C.Groups[id] then C.Groups[id].defenders[#C.Groups[id].defenders+1]=sid end C.DefendTarget[sid]=ticket.target if ticket.target then capture(sid,ticket.target) end
 elseif ticket.role=="tank" or ticket.role=="tank80plus" then local id=ticket.groupId or assignTankGroup() if id and C.Groups[id] and not C.Groups[id].stopped then C.SquadGroup[sid]=id C.Groups[id].tanks[#C.Groups[id].tanks+1]=sid C.TankReadyAt[sid]=C.Time+NEU_BOT.VehicleFollowDelaySec if C.Groups[id].phase=="attack" and C.Groups[id].target then deferCapture(sid,C.Groups[id].target,NEU_BOT.VehicleFollowDelaySec) end end
 elseif ticket.role=="antiair" or ticket.role=="aat" then local t=ticket.target or chooseFrontOwnFlag(nil) if t then capture(sid,t) end
 elseif ticket.target then local o=flagOccupant(ticket.target) if o==BotApi.Instance.enemyTeam or o==BotApi.Instance.team then capture(sid,ticket.target) end end
 processSpawn()
end

BotApi.Events:Subscribe(BotApi.Events.GameStart,onGameStart)
BotApi.Events:Subscribe(BotApi.Events.GameEnd,onGameStop)
BotApi.Events:Subscribe(BotApi.Events.Quant,onGameQuant)
BotApi.Events:Subscribe(BotApi.Events.GameSpawn,onGameSpawn)
