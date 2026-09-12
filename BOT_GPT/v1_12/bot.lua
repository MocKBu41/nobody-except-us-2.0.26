-- NEU BOT v1.12
-- Based on v1.11.
-- Fixes pointstart opening coverage, adopts infantry that dismounts from APCs into the active assault group,
-- and adds one opening helicopter that patrols the bot's captured flags.
-- Verified BotApi commands only: Spawn, CaptureFlag, Income, EnemyHasTanks.

require([[/script/multiplayer/bot.data]])
require([[/script/multiplayer/bot.mapdata]])
local MAP=NEU_MAPDATA

local C={
 Units={},Candidates={},SpawnIntents={},SpawnTickets={},AwaitingArrival=nil,
 SquadRole={},DeadSquads={},SquadGroup={},DeferredOrders={},DefendTarget={},TankReadyAt={},Groups={},LastOrder={},
 Time=0,Timer=nil,TimerGeneration=0,AttackUnlocked=false,AttackUnlockReason=nil,NeutralsCleared=false,
 NextTankReinforcementAt=0,NextInfantryReinforcementAt=0,NextPatrolAt=0,NextOrderAt=0,NextOpeningMaintenanceAt=0,NextPointStartCheckAt=0,NextHeliPatrolAt=0,
 PointStartTarget={},PointStartPending={},PointStartDone={},HostileNeutral={},StartPointList={},PointStartQueued=false,
 ReconSquad=nil,PatrolHeliSquad=nil,PatrolHeliLastFlag=nil,DetachWindows={},DetachAssignCursor=0,BalanceDefenseActive=false,
 EnemySignals={aatSeenAt=nil,aatDestroyedAt=nil,aatStage=0,aatCheckAt=nil,aircraftSeenAt=nil,aircraftDestroyedAt=nil,aircraftResponseAt=nil}
}

local function log(m) print("[NEU-BOT] "..tostring(m)) end
local function lower(s) return string.lower(tostring(s or "")) end
local function splitTags(tags) local o={} for t in string.gmatch(tags or "","%S+") do o[lower(t)]=true end return o end
local function hasTag(r,t) return r and r.tagset and r.tagset[lower(t)]==true end
local function recText(r) return lower((r and r.unit or "").." "..(r and r.raw or "")) end

local function roleMatches(r,role)
 local text=recText(r)
 if role=="pointstart" then return hasTag(r,"pointstart") end
 if role=="patrol_heli" then return hasTag(r,"duel_heli") or hasTag(r,"duel_heli2") end
 if role=="aircraftlight" then return hasTag(r,"aircraftlight") or text:find("support_light",1,true)~=nil end
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
 local records,buffer,stack={},{},{} local quoted,escaped,comment=false,false,false
 for i=1,#raw do
  local ch=raw:sub(i,i)
  if comment then if ch=="\n" then comment=false if #stack>0 then buffer[#buffer+1]=" " end end
  elseif quoted then buffer[#buffer+1]=ch if escaped then escaped=false elseif ch=="\\" then escaped=true elseif ch=='"' then quoted=false end
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
 local f=io.open(fname,"r") if not f then log("FILE MISSING "..fname) return end
 local raw=f:read("*a") f:close()
 units.count=units.count or 1 units.seen=units.seen or {} local added=0
 for _,line in ipairs(parseRecords(raw)) do
  local side=detectSide(line)
  if side and lower(side)==lower(army) then
   local parts={} for tags in line:gmatch('%f[%w]t%s*%(([^)]*)%)') do parts[#parts+1]=tags end
   local tags=table.concat(parts," ")
   local vehicle=line:match('^%s*{%s*"([^"]+)"')
   local name=vehicle or line:match('%f[%w]name%s*%(([^)]+)%)')
   if name and not name:find("mp/",1,true) then
    local id=vehicle or (name.."("..army..")")
    if not units.seen[id] then
     local rec={unit=id,tags=tags,tagset=splitTags(tags),raw=line,side=side,nobot=(line:find("nobot",1,true)~=nil)}
     units[units.count]=rec units.count=units.count+1 units.seen[id]=true added=added+1
    end
   end
  end
 end
 log("READ "..fname.." added="..added)
end

local function buildCandidates()
 local roles={"pointstart","patrol_heli","recon","infantry","defense_infantry","antiair","tank","tank80plus","aircraftlight","aat","antirad","strike","duel_heli","duel_fighter"}
 C.Candidates={} for _,r in ipairs(roles) do C.Candidates[r]={} end
 for _,rec in ipairs(C.Units) do
  if type(rec)=="table" then
   for _,r in ipairs(roles) do if roleMatches(rec,r) then C.Candidates[r][#C.Candidates[r]+1]=rec end end
  end
 end
 for _,r in ipairs(roles) do log("ROLE "..r.." candidates="..#(C.Candidates[r] or {})) end
 if #(C.Candidates.pointstart or {})==0 then log("POINTSTART ERROR candidates=0; no fallback is allowed") end
 if #(C.Candidates.patrol_heli or {})==0 then log("PATROL HELI ERROR candidates=0") end
end

local function flags()
 local my,enemy=BotApi.Instance.team,BotApi.Instance.enemyTeam
 local f={mine={},enemy={},neutral={},mineCount=0,enemyCount=0,neutralCount=0}
 for _,x in pairs(BotApi.Scene.Flags) do
  if x.occupant==my then f.mine[#f.mine+1]=x.name f.mineCount=f.mineCount+1
  elseif x.occupant==enemy then f.enemy[#f.enemy+1]=x.name f.enemyCount=f.enemyCount+1
  else f.neutral[#f.neutral+1]=x.name f.neutralCount=f.neutralCount+1 end
 end
 return f
end

local function flagObj(name) for _,f in pairs(BotApi.Scene.Flags) do if f.name==name then return f end end end
local function flagOccupant(name) local f=flagObj(name) return f and f.occupant or nil end
local function isNeutral(name) local o=flagOccupant(name) return o~=BotApi.Instance.team and o~=BotApi.Instance.enemyTeam end
local function flagNumber(name) return type(name)=="string" and tonumber(name:match("(%d+)$")) or nil end
local function numericSort(list) table.sort(list,function(a,b) local na,nb=flagNumber(a),flagNumber(b) if na and nb and na~=nb then return na<nb end return tostring(a)<tostring(b) end) end
local function geoSortSpawn(list,reason) if MAP and MAP.loaded and MAP.spawn then MAP:sortFromSpawn(list) if #list>0 then log("TARGET GEO reason="..reason.." first="..tostring(list[1]).." distSpawn="..tostring(MAP:distanceFromSpawn(list[1]))) end else numericSort(list) end end
local function geoSortFromFlag(list,from,reason) if MAP and MAP.loaded and from and MAP:point(from) then MAP:sortFromFlag(list,from) if #list>0 then log("TARGET GEO reason="..reason.." from="..from.." first="..tostring(list[1]).." dist="..tostring(MAP:distanceNames(from,list[1]))) end else geoSortSpawn(list,reason) end end

local function hostileNeutralActiveCount()
 local n=0 for name,v in pairs(C.HostileNeutral) do if v and isNeutral(name) then n=n+1 end end return n
end
local function strategicNeutralList()
 local f=flags() local out={}
 for _,n in ipairs(f.neutral) do if not C.HostileNeutral[n] then out[#out+1]=n end end
 return out
end
local function strategicNeutralCount() return #strategicNeutralList() end
local function effectiveEnemyCount() local f=flags() return f.enemyCount+hostileNeutralActiveCount() end
local function isStrategicEnemy(name) return flagOccupant(name)==BotApi.Instance.enemyTeam or C.HostileNeutral[name]==true end

local function frontOwnList()
 local f=flags() local enemy={}
 for _,n in ipairs(f.enemy) do enemy[#enemy+1]=n end
 for name,v in pairs(C.HostileNeutral) do if v and isNeutral(name) then enemy[#enemy+1]=name end end
 if MAP and MAP.loaded then return MAP:frontOwnFlags(f.mine,enemy) end
 numericSort(f.mine) return f.mine
end
local function chooseFrontOwnFlag(used) local list=frontOwnList() for _,n in ipairs(list) do if not (used and used[n]) then return n end end return list[1] end
local function chooseOwnFlagBefore(target)
 local f=flags() if #f.mine==0 then return nil end
 if MAP and MAP.loaded and MAP:point(target) then
  local best,bd=nil,nil local td=MAP:distanceFromSpawn(target)
  for _,name in ipairs(f.mine) do
   local d=MAP:distanceNames(name,target) local sd=MAP:distanceFromSpawn(name)
   if d and (not td or not sd or sd<=td) and (not bd or d<bd) then best,bd=name,d end
  end
  if not best then best,bd=MAP:nearestToFlag(f.mine,target,nil) end
  if best then log("FRONTLINE GEO defend="..best.." before="..tostring(target).." distance="..tostring(bd)) return best end
 end
 return chooseFrontOwnFlag(nil)
end

local function squadAlive(id) return id and BotApi.Scene:IsSquadExists(id) end
local function capture(id,flag,force)
 if not (id and flag and squadAlive(id)) then return end
 local role=C.SquadRole[id] local occ=flagOccupant(flag)
 local neutral=(occ~=BotApi.Instance.team and occ~=BotApi.Instance.enemyTeam)
 if neutral and role~="pointstart" and not C.HostileNeutral[flag] then return end
 local last=C.LastOrder[id] local cooldown=NEU_BOT.OrderCooldownSec or 12
 if not force and last and last.flag==flag and C.Time-(last.time or 0)<cooldown then return end
 C.LastOrder[id]={flag=flag,time=C.Time}
 log("ORDER squad="..tostring(id).." group="..tostring(C.SquadGroup[id]).." flag="..tostring(flag).." role="..tostring(role).." hostileNeutral="..tostring(C.HostileNeutral[flag]==true))
 BotApi.Commands:CaptureFlag(id,flag)
end
local function deferCapture(id,flag,delay) C.DeferredOrders[#C.DeferredOrders+1]={squad=id,flag=flag,due=C.Time+(delay or 0)} end
local function processDeferredOrders() for i=#C.DeferredOrders,1,-1 do local o=C.DeferredOrders[i] if o.due<=C.Time then capture(o.squad,o.flag,true) table.remove(C.DeferredOrders,i) end end end

local function pendingForGroup(role,gid) for _,x in ipairs(C.SpawnIntents) do if x.role==role and x.groupId==gid then return true end end return C.AwaitingArrival and C.AwaitingArrival.role==role and C.AwaitingArrival.groupId==gid end
local function enqueueSpawn(role,reason,delay,target,gid,mode)
 C.SpawnIntents[#C.SpawnIntents+1]={role=role,reason=reason or "",due=C.Time+(delay or 0),target=target,groupId=gid,mode=mode,attempts=0,cycles=0,tried={}}
 if role=="pointstart" and target then C.PointStartPending[target]=true end
 log("QUEUE role="..role.." due="..(C.Time+(delay or 0)).." group="..tostring(gid).." target="..tostring(target).." reason="..tostring(reason))
end
local function chooseUntried(intent)
 local list=C.Candidates[intent.role] or {} local a={}
 for _,r in ipairs(list) do if not intent.tried[r.unit] then a[#a+1]=r end end
 if #a==0 then return nil end
 local r=a[math.random(1,#a)] intent.tried[r.unit]=true return r
end
local function criticalRole(role) return role=="tank" or role=="tank80plus" or role=="infantry" end
local function processSpawn()
 if C.AwaitingArrival then return end
 local idx=nil for i,x in ipairs(C.SpawnIntents) do if x.due<=C.Time then idx=i break end end if not idx then return end
 local intent=table.remove(C.SpawnIntents,idx)
 if intent.role=="pointstart" and intent.target and not isNeutral(intent.target) then
  C.PointStartPending[intent.target]=nil
  if flagOccupant(intent.target)==BotApi.Instance.team then C.PointStartDone[intent.target]=true else C.HostileNeutral[intent.target]=true end
  log("POINTSTART CANCEL target="..tostring(intent.target).." occupant="..tostring(flagOccupant(intent.target)))
  return processSpawn()
 end
 local rec=chooseUntried(intent)
 if not rec then
  if intent.role=="pointstart" and intent.target then C.PointStartPending[intent.target]=nil end
  log("NO UNIT role="..intent.role.." target="..tostring(intent.target)) return
 end
 intent.attempts=intent.attempts+1
 local ticket={role=intent.role,reason=intent.reason,target=intent.target,groupId=intent.groupId,mode=intent.mode,unit=rec.unit}
 C.SpawnTickets[#C.SpawnTickets+1]=ticket
 local maxSize=(intent.role=="pointstart") and (NEU_BOT.PointStartSquadSize or MaxSquadSize) or MaxSquadSize
 local ok=BotApi.Commands:Spawn(rec.unit,maxSize)
 if ok then
  C.AwaitingArrival=ticket
  log("SPAWN OK role="..intent.role.." unit="..rec.unit.." group="..tostring(intent.groupId).." target="..tostring(intent.target).." maxSquad="..tostring(maxSize))
 else
  table.remove(C.SpawnTickets,#C.SpawnTickets)
  local total=#(C.Candidates[intent.role] or {})
  if intent.attempts<total then
   intent.due=C.Time+(NEU_BOT.SpawnRetrySec or 2) C.SpawnIntents[#C.SpawnIntents+1]=intent
  elseif intent.role=="pointstart" and (intent.cycles or 0)<(NEU_BOT.PointStartSpawnRetryCycles or 20) then
   intent.cycles=(intent.cycles or 0)+1 intent.attempts=0 intent.tried={}
   intent.due=C.Time+(NEU_BOT.PointStartSpawnRetrySec or 5) C.SpawnIntents[#C.SpawnIntents+1]=intent
   log("POINTSTART RETRY target="..tostring(intent.target).." cycle="..intent.cycles.." due="..intent.due)
  elseif criticalRole(intent.role) and (intent.cycles or 0)<(NEU_BOT.CriticalSpawnRetryCycles or 3) then
   intent.cycles=(intent.cycles or 0)+1 intent.attempts=0 intent.tried={} intent.due=C.Time+(NEU_BOT.CriticalSpawnRetrySec or 10) C.SpawnIntents[#C.SpawnIntents+1]=intent
   log("SPAWN RETRY CYCLE role="..intent.role.." cycle="..intent.cycles.." group="..tostring(intent.groupId))
  else
   if intent.role=="pointstart" and intent.target then C.PointStartPending[intent.target]=nil end
   log("SPAWN FAILED role="..intent.role.." target="..tostring(intent.target))
  end
 end
end

local function aliveCount(list) local n=0 for _,sid in ipairs(list or {}) do if squadAlive(sid) then n=n+1 end end return n end
local function newGroup(id) C.Groups[id]={id=id,target=nil,phase="opening",stopped=false,failedTarget=nil,restartAt=nil,infantry={},detached={},tanks={},defenders={},resultCheckAt=nil,nextAttackAt=nil} log("GROUP CREATE id="..id) end
local function activeGroups() local a={} for id,g in pairs(C.Groups) do if not g.stopped then a[#a+1]=id end end table.sort(a) return a end
local function usedEnemyTargets(except)
 local u={} for id,g in pairs(C.Groups) do if id~=except and not g.stopped and g.target and isStrategicEnemy(g.target) then u[g.target]=true end end return u
end
local function chooseEnemyTarget(gid)
 local f=flags() local used=usedEnemyTargets(gid) local g=C.Groups[gid] local candidates={} local seen={}
 for _,n in ipairs(f.enemy) do if not used[n] and not seen[n] then candidates[#candidates+1]=n seen[n]=true end end
 for n,v in pairs(C.HostileNeutral) do if v and isNeutral(n) and not used[n] and not seen[n] then candidates[#candidates+1]=n seen[n]=true end end
 if #candidates==0 then return nil end
 if MAP and MAP.loaded then
  local enemyForFront={} for _,n in ipairs(candidates) do enemyForFront[#enemyForFront+1]=n end
  local front=MAP:frontOwnFlags(f.mine,enemyForFront) local from=front[1]
  if from then geoSortFromFlag(candidates,from,"enemy-front") log("TARGET GEO group="..gid.." fromFront="..tostring(from).." candidates="..#candidates) else geoSortSpawn(candidates,"enemy-no-own-front") end
 else numericSort(candidates) end
 for _,n in ipairs(candidates) do if not g or not g.failedTarget or n~=g.failedTarget then return n end end
 return candidates[1]
end
local function assignTankGroup() local best,bn=nil,nil for _,id in ipairs(activeGroups()) do local n=aliveCount(C.Groups[id].tanks) if bn==nil or n<bn then best,bn=id,n end end return best end
local function ensureInfantry(id,reason) local g=C.Groups[id] if g and not g.stopped and aliveCount(g.infantry)==0 and not pendingForGroup("infantry",id) then enqueueSpawn("infantry",reason,0,g.target,id,g.phase) end end
local function ensureTank(id,reason,delay) local g=C.Groups[id] if g and not g.stopped and aliveCount(g.tanks)==0 and not pendingForGroup("tank",id) and not pendingForGroup("tank80plus",id) then enqueueSpawn("tank80plus",reason,delay or 0,g.target,id,g.phase) end end
local function makeOpeningGroups() if C.Groups[1] then return end for i=1,NEU_BOT.AssaultGroups do newGroup(i) enqueueSpawn("infantry","opening BTG infantry",0,nil,i,"opening") enqueueSpawn("tank","opening BTG tank",NEU_BOT.OpeningTankDelaySec,nil,i,"opening") end end
local function processOpeningMaintenance()
 if C.Time<C.NextOpeningMaintenanceAt then return end C.NextOpeningMaintenanceAt=C.Time+(NEU_BOT.OpeningMaintenanceSec or 10)
 if strategicNeutralCount()<=0 then return end
 for id,g in pairs(C.Groups) do if not g.stopped and (g.phase=="opening" or g.phase=="hold_neutral") then ensureInfantry(id,"opening infantry recovery") ensureTank(id,"opening tank recovery",0) end end
end

local function armDetachWindow(id,target,reason)
 if not id or not target then return end
 C.DetachWindows[id]={groupId=id,target=target,until=C.Time+(NEU_BOT.DetachedAdoptWindowSec or 25),remaining=NEU_BOT.DetachedAdoptMaxPerGroup or 6,reason=reason}
 log("DETACH WINDOW group="..id.." target="..target.." until="..C.DetachWindows[id].until.." reason="..tostring(reason))
end
local function adoptUnmatchedDetached(sid)
 local ids={} for id,w in pairs(C.DetachWindows) do if w and w.until>=C.Time and (w.remaining or 0)>0 and C.Groups[id] and not C.Groups[id].stopped and C.Groups[id].phase=="attack" and C.Groups[id].target then ids[#ids+1]=id end end
 table.sort(ids)
 if #ids==0 then return false end
 C.DetachAssignCursor=(C.DetachAssignCursor%#ids)+1
 local id=ids[C.DetachAssignCursor] local w=C.DetachWindows[id] local g=C.Groups[id]
 w.remaining=w.remaining-1
 C.SquadRole[sid]="infantry_detached" C.SquadGroup[sid]=id C.DeadSquads[sid]=false g.detached[#g.detached+1]=sid
 log("DETACHED ADOPT squad="..sid.." group="..id.." target="..tostring(g.target).." remaining="..w.remaining)
 capture(sid,g.target,true)
 return true
end

local function queuePointStartTargets()
 if C.PointStartQueued then return end C.PointStartQueued=true
 local f=flags() local list={} for _,n in ipairs(f.neutral) do list[#list+1]=n end
 geoSortSpawn(list,"pointstart-opening-nearest-spawn")
 C.StartPointList={}
 for _,target in ipairs(list) do
  C.StartPointList[#C.StartPointList+1]=target
  enqueueSpawn("pointstart","opening one-squad-per-point",0,target,nil,"pointstart")
 end
 log("POINTSTART PLAN points="..#list.." squads="..#list.." candidates="..#(C.Candidates.pointstart or {}))
end

local function pointStartActiveCount()
 local n=0 for sid,target in pairs(C.PointStartTarget) do if squadAlive(sid) and target and not C.PointStartDone[target] then n=n+1 end end
 for target,v in pairs(C.PointStartPending) do if v and not C.PointStartDone[target] then n=n+1 end end
 return n
end

local function processPointStartCapture()
 if C.Time<C.NextPointStartCheckAt then return end C.NextPointStartCheckAt=C.Time+(NEU_BOT.PointStartCheckSec or 5)
 for sid,target in pairs(C.PointStartTarget) do
  if squadAlive(sid) and target then
   local occ=flagOccupant(target)
   if occ==BotApi.Instance.team then
    if not C.PointStartDone[target] then log("POINTSTART CAPTURE DONE squad="..sid.." flag="..target) end
    C.PointStartDone[target]=true C.PointStartTarget[sid]=nil C.PointStartPending[target]=nil
   else capture(sid,target) end
  end
 end
end

local function unlockAttack()
 if C.AttackUnlocked then return end local f=flags() local ee=effectiveEnemyCount()
 if C.Time>=NEU_BOT.AttackWaitSec then C.AttackUnlocked=true C.AttackUnlockReason="5 minutes"
 elseif ee>f.mineCount then C.AttackUnlocked=true C.AttackUnlockReason="enemy flag advantage" end
 if C.AttackUnlocked then log("ATTACK UNLOCK reason="..C.AttackUnlockReason.." enemyEffective="..ee.." mine="..f.mineCount) end
end

local function neutralTransition()
 local f=flags() local strategic=strategicNeutralCount() local hostile=hostileNeutralActiveCount()
 if strategic==0 then
  if not C.NeutralsCleared then
   C.NeutralsCleared=true
   log("NEUTRALS CLEARED strategic=YES rawNeutral="..f.neutralCount.." hostileNeutral="..hostile.." time="..C.Time)
   for id,g in pairs(C.Groups) do if not g.stopped then g.phase="ready" g.target=nil g.resultCheckAt=nil g.nextAttackAt=C.Time log("GROUP READY id="..id.." reason=strategic-neutrals-cleared") end end
  end
  if C.AttackUnlocked then log("ATTACK GATE OPEN strategicNeutral=0 hostileNeutral="..hostile.." reason="..tostring(C.AttackUnlockReason)) end
 else
  if C.NeutralsCleared then C.NeutralsCleared=false log("NEUTRALS RETURNED strategic="..strategic) end
  for _,g in pairs(C.Groups) do if not g.stopped and g.phase=="attack" then g.phase="hold_neutral" g.resultCheckAt=nil end end
 end
end

local function startAttack(id)
 local g=C.Groups[id]
 if not g or g.stopped or not C.AttackUnlocked or strategicNeutralCount()>0 then return end
 local target=chooseEnemyTarget(id)
 if not target then g.phase="ready" g.nextAttackAt=C.Time+5 return end
 local old=g.failedTarget g.target=target g.failedTarget=nil g.phase="attack" g.resultCheckAt=C.Time+NEU_BOT.AttackResultCheckSec g.nextAttackAt=nil
 log("ATTACK START group="..id.." flag="..target.." strategicEnemy="..tostring(isStrategicEnemy(target)).." previousFailed="..tostring(old).." dSpawn="..tostring(MAP and MAP:distanceFromSpawn(target)))
 armDetachWindow(id,target,"attack-start")
 ensureInfantry(id,"new assault infantry") ensureTank(id,"attack tank",0)
end
local function startReadyGroups() if not C.AttackUnlocked or not C.NeutralsCleared then return end for _,id in ipairs(activeGroups()) do local g=C.Groups[id] if (g.phase=="ready" or g.phase=="opening" or g.phase=="hold_neutral") and (not g.nextAttackAt or C.Time>=g.nextAttackAt) then startAttack(id) end end end

local function processOrders()
 if C.Time<C.NextOrderAt then return end C.NextOrderAt=C.Time+NEU_BOT.InfantryReissueSec
 for id,g in pairs(C.Groups) do
  if not g.stopped and g.phase=="attack" and g.target and isStrategicEnemy(g.target) then
   armDetachWindow(id,g.target,"attack-order")
   for _,sid in ipairs(g.infantry) do if squadAlive(sid) then capture(sid,g.target) end end
   for _,sid in ipairs(g.detached) do if squadAlive(sid) then capture(sid,g.target) end end
   for _,sid in ipairs(g.tanks) do if squadAlive(sid) and C.Time>=(C.TankReadyAt[sid] or 0) then capture(sid,g.target) end end
  end
  for _,sid in ipairs(g.defenders) do if squadAlive(sid) then local t=C.DefendTarget[sid] or chooseOwnFlagBefore(g.target) if t then capture(sid,t) end end end
 end
end

local function processHeliPatrol()
 local sid=C.PatrolHeliSquad
 if not squadAlive(sid) then return end
 if C.Time<C.NextHeliPatrolAt then return end C.NextHeliPatrolAt=C.Time+(NEU_BOT.HeliPatrolSec or 20)
 local f=flags() if #f.mine==0 then return end
 local list={} for _,n in ipairs(f.mine) do list[#list+1]=n end
 geoSortSpawn(list,"heli-own-patrol")
 local target=nil
 if #list==1 then target=list[1]
 else
  local pos=nil for i,n in ipairs(list) do if n==C.PatrolHeliLastFlag then pos=i break end end
  if not pos then target=list[1] else target=list[(pos%#list)+1] end
 end
 if target then C.PatrolHeliLastFlag=target log("HELI PATROL squad="..sid.." flag="..target.." ownFlags="..#list) capture(sid,target,true) end
end

local function resolveAttackResults()
 for id,g in pairs(C.Groups) do
  if not g.stopped and g.phase=="attack" and g.resultCheckAt and C.Time>=g.resultCheckAt then
   if g.target and flagOccupant(g.target)==BotApi.Instance.team then
    log("ATTACK RESULT group="..id.." flag="..g.target.." success=YES")
    C.HostileNeutral[g.target]=nil
    for _,sid in ipairs(g.infantry) do if squadAlive(sid) then g.defenders[#g.defenders+1]=sid C.DefendTarget[sid]=g.target end end
    for _,sid in ipairs(g.detached) do if squadAlive(sid) then g.defenders[#g.defenders+1]=sid C.DefendTarget[sid]=g.target end end
    g.infantry={} g.detached={} g.phase="ready" g.resultCheckAt=nil g.nextAttackAt=C.Time+NEU_BOT.NextAttackDelaySec C.DetachWindows[id]=nil
   else
    log("ATTACK RESULT group="..id.." flag="..tostring(g.target).." success=NO")
    enqueueSpawn("aircraftlight","stalled attack air support",0,g.target,id,"support")
    enqueueSpawn("defense_infantry","stalled fallback defense",0,chooseOwnFlagBefore(g.target),id,"defense")
    g.resultCheckAt=C.Time+NEU_BOT.AttackResultCheckSec
   end
  end
 end
end

local function stopDirection(id,reason) local g=C.Groups[id] if not g or g.stopped then return end g.stopped=true g.phase="stopped" g.failedTarget=g.target g.restartAt=C.Time+(NEU_BOT.DirectionRecoverySec or 30) g.resultCheckAt=nil C.DetachWindows[id]=nil log("DIRECTION STOP group="..id.." failed="..tostring(g.failedTarget).." reason="..reason.." rebuildAt="..g.restartAt) end
local function recoverDirections() if strategicNeutralCount()>0 or not C.AttackUnlocked then return end for id,g in pairs(C.Groups) do if g.stopped and g.restartAt and C.Time>=g.restartAt then g.stopped=false g.phase="ready" g.target=nil g.nextAttackAt=C.Time+5 g.restartAt=nil g.infantry={} g.detached={} log("DIRECTION REBUILD group="..id.." failed="..tostring(g.failedTarget).." freshInfantry=YES freshTank=YES") enqueueSpawn("infantry","direction rebuild infantry",0,nil,id,"rebuild") enqueueSpawn("tank80plus","direction rebuild tank",0,nil,id,"rebuild") end end end

local function detectLosses()
 for sid,role in pairs(C.SquadRole) do
  if not C.DeadSquads[sid] and not squadAlive(sid) then
   C.DeadSquads[sid]=true C.LastOrder[sid]=nil
   local id=C.SquadGroup[sid] local g=id and C.Groups[id]
   log("LOST squad="..sid.." role="..role.." group="..tostring(id))
   if role=="pointstart" then
    local t=C.PointStartTarget[sid]
    C.PointStartTarget[sid]=nil
    if t then
     C.PointStartPending[t]=nil
     if flagOccupant(t)~=BotApi.Instance.team then C.HostileNeutral[t]=true log("POINTSTART LOST squad="..sid.." flag="..t.." -> HOSTILE evenIfNeutral="..tostring(isNeutral(t))) else C.PointStartDone[t]=true end
    end
   end
   if role=="recon" then C.ReconSquad=nil end
   if role=="patrol_heli" then C.PatrolHeliSquad=nil log("HELI PATROL LOST squad="..sid.." no-respawn=YES") end
   if role=="infantry" and g and not g.stopped and g.phase=="attack" and aliveCount(g.infantry)==0 and aliveCount(g.detached)==0 then stopDirection(id,"main-infantry-lost") end
   if role=="tank" or role=="tank80plus" then
    local rid=(g and not g.stopped) and id or assignTankGroup()
    local target=rid and C.Groups[rid] and C.Groups[rid].target or nil
    if rid then log("TANK LOSS CONTINUE group="..rid) end
    enqueueSpawn("tank80plus","tank destroyed replacement",0,target,rid,"attack")
    enqueueSpawn("infantry","tank destroyed infantry support",0,target,rid,"attack")
    enqueueSpawn("aat","tank destroyed AA",0,chooseFrontOwnFlag(nil),rid,"support")
    enqueueSpawn("aircraftlight","tank destroyed air support",0,target,rid,"support")
   end
  end
 end
end

local function processAA() if C.Time<C.NextPatrolAt then return end C.NextPatrolAt=C.Time+NEU_BOT.AntiAirPatrolSec local t=chooseFrontOwnFlag(nil) if t then for sid,role in pairs(C.SquadRole) do if squadAlive(sid) and (role=="antiair" or role=="aat") then capture(sid,t) end end end end
local function processBalanceDefense() local f=flags() local should=(f.mineCount>effectiveEnemyCount()) if should and not C.BalanceDefenseActive then C.BalanceDefenseActive=true local used={} log("BALANCE DEFENSE ON mine="..f.mineCount.." enemyEffective="..effectiveEnemyCount()) for _,id in ipairs(activeGroups()) do local t=chooseFrontOwnFlag(used) if t then used[t]=true enqueueSpawn("defense_infantry","geo frontline defense",0,t,id,"defense") end end elseif not should and C.BalanceDefenseActive then C.BalanceDefenseActive=false log("BALANCE DEFENSE OFF mine="..f.mineCount.." enemyEffective="..effectiveEnemyCount()) end end
local function processReinforcements() if C.Time>=C.NextTankReinforcementAt then C.NextTankReinforcementAt=C.Time+NEU_BOT.TankReinforcementSec for _,id in ipairs(activeGroups()) do enqueueSpawn("tank80plus","5 minute tank",0,C.Groups[id].target,id,"attack") end end if C.Time>=C.NextInfantryReinforcementAt then C.NextInfantryReinforcementAt=C.Time+NEU_BOT.InfantryReinforcementSec if strategicNeutralCount()==0 then for _,id in ipairs(activeGroups()) do enqueueSpawn("infantry","5 minute infantry",0,C.Groups[id].target,id,"attack") end end end end
local function processEnemyRules() local s=C.EnemySignals if s.aatSeenAt and s.aatStage==1 and C.Time>=s.aatSeenAt+NEU_BOT.AntiRadDelaySec then enqueueSpawn("antirad","enemy aat response",0,nil,nil,"support") s.aatStage=2 s.aatCheckAt=C.Time+NEU_BOT.EnemyResponseCheckSec elseif s.aatStage==2 and s.aatCheckAt and C.Time>=s.aatCheckAt then if s.aatDestroyedAt and s.aatDestroyedAt>=s.aatSeenAt then enqueueSpawn("duel_heli","aat destroyed",0,nil,nil,"support") s.aatStage=0 s.aatCheckAt=nil else enqueueSpawn("antirad","aat survived",0,nil,nil,"support") enqueueSpawn("strike","aat survived",0,nil,nil,"support") s.aatCheckAt=C.Time+NEU_BOT.EnemyResponseCheckSec end end if s.aircraftSeenAt and s.aircraftResponseAt and C.Time>=s.aircraftResponseAt then if s.aircraftDestroyedAt and s.aircraftDestroyedAt>=s.aircraftSeenAt then local id=assignTankGroup() local t=id and C.Groups[id] and C.Groups[id].target or nil enqueueSpawn("tank80plus","aircraft destroyed reward",0,t,id,"attack") enqueueSpawn("infantry","aircraft destroyed reward",0,t,id,"attack") else enqueueSpawn("duel_fighter","aircraft alive",0,nil,nil,"support") end s.aircraftResponseAt=nil end end
function NEU_BOT_EnemyTagSeen(tag) tag=lower(tag) if tag=="aat" then C.EnemySignals.aatSeenAt=C.Time C.EnemySignals.aatDestroyedAt=nil C.EnemySignals.aatStage=1 C.EnemySignals.aatCheckAt=nil elseif tag=="aircraft" then C.EnemySignals.aircraftSeenAt=C.Time C.EnemySignals.aircraftDestroyedAt=nil C.EnemySignals.aircraftResponseAt=C.Time+NEU_BOT.EnemyResponseCheckSec if math.random(2)==1 then enqueueSpawn("duel_fighter","aircraft response 50/50",0,nil,nil,"support") else enqueueSpawn("aat","aircraft response 50/50",0,chooseFrontOwnFlag(nil),nil,"support") end end end
function NEU_BOT_EnemyTagDestroyed(tag) tag=lower(tag) if tag=="aat" then C.EnemySignals.aatDestroyedAt=C.Time elseif tag=="aircraft" then C.EnemySignals.aircraftDestroyedAt=C.Time end end

local function onSecond()
 C.Time=C.Time+1
 detectLosses()
 processDeferredOrders()
 unlockAttack()
 processEnemyRules()
 processPointStartCapture()
 neutralTransition()
 processOpeningMaintenance()
 recoverDirections()
 startReadyGroups()
 resolveAttackResults()
 processOrders()
 processHeliPatrol()
 processAA()
 processBalanceDefense()
 processReinforcements()
 processSpawn()
 if C.Time%30==0 then
  local f=flags() local p={}
  for id,g in pairs(C.Groups) do p[#p+1]="G"..id.."="..tostring(g.target)..":"..g.phase..":I"..aliveCount(g.infantry)..":D"..aliveCount(g.detached)..":T"..aliveCount(g.tanks) end
  log("TIME="..C.Time.." MAP="..tostring(MAP and MAP.mapKey).." FLAGS="..f.mineCount.."/"..f.enemyCount.." Nraw="..f.neutralCount.." Nstrategic="..strategicNeutralCount().." HOSTILE="..hostileNeutralActiveCount().." PS="..pointStartActiveCount().." HELI="..tostring(squadAlive(C.PatrolHeliSquad)).." "..table.concat(p," "))
 end
end

local function stopClock() C.TimerGeneration=C.TimerGeneration+1 if C.Timer then BotApi.Events:KillQuantTimer(C.Timer) C.Timer=nil end end
local function startClock() stopClock() local gen=C.TimerGeneration local function pulse() if gen~=C.TimerGeneration then return end C.Timer=nil onSecond() if gen==C.TimerGeneration then C.Timer=BotApi.Events:SetQuantTimer(pulse,NEU_BOT.TickMs) end end C.Timer=BotApi.Events:SetQuantTimer(pulse,NEU_BOT.TickMs) end

function onGameStart()
 local host=tonumber(BotApi.Instance.hostId) or 1 math.randomseed(os.time()*host)
 C.Units={count=1,seen={}} readAllUnits(nil,C.Units,BotApi.Instance.army) buildCandidates()
 C.SpawnIntents={} C.SpawnTickets={} C.AwaitingArrival=nil C.SquadRole={} C.DeadSquads={} C.SquadGroup={} C.DeferredOrders={} C.DefendTarget={} C.TankReadyAt={} C.Groups={} C.LastOrder={} C.Time=0
 C.AttackUnlocked=false C.AttackUnlockReason=nil C.NeutralsCleared=false C.NextTankReinforcementAt=NEU_BOT.TankReinforcementSec C.NextInfantryReinforcementAt=NEU_BOT.InfantryReinforcementSec C.NextPatrolAt=0 C.NextOrderAt=0 C.NextOpeningMaintenanceAt=0 C.NextPointStartCheckAt=0 C.NextHeliPatrolAt=0
 C.PointStartTarget={} C.PointStartPending={} C.PointStartDone={} C.HostileNeutral={} C.StartPointList={} C.PointStartQueued=false C.ReconSquad=nil C.PatrolHeliSquad=nil C.PatrolHeliLastFlag=nil C.DetachWindows={} C.DetachAssignCursor=0 C.BalanceDefenseActive=false
 C.EnemySignals={aatSeenAt=nil,aatDestroyedAt=nil,aatStage=0,aatCheckAt=nil,aircraftSeenAt=nil,aircraftDestroyedAt=nil,aircraftResponseAt=nil}
 local mapOk=MAP and MAP:load() or false
 queuePointStartTargets()
 enqueueSpawn("recon","opening recon",0,nil,nil,"opening")
 enqueueSpawn("antiair","opening aa",0,nil,nil,"opening")
 enqueueSpawn("patrol_heli","opening one helicopter patrol",0,nil,nil,"patrol")
 log("START v1.12 army="..tostring(BotApi.Instance.army).." team="..tostring(BotApi.Instance.team).." units="..tostring((C.Units.count or 1)-1))
 log("RULE opening-capture=pointstart-ONLY one-squad-per-start-point=ON pointstart-retry=ON")
 log("RULE pointstart-death-before-capture => flag=HOSTILE evenIfNeutral")
 log("RULE dismounted-infantry-adoption=SCOPED attack-window="..tostring(NEU_BOT.DetachedAdoptWindowSec).."s")
 log("RULE opening-heli=ONE patrol-own-captured-flags=ON interval="..tostring(NEU_BOT.HeliPatrolSec).."s")
 log("RULE hostile-neutral participates-as-enemy=ON strict-neutral-first-excludes-hostile=YES")
 log("RULE map-unique-fuzzy-match=ON duplicate-flag-geometry=ON nearest-route=ON")
 log("RULE opening-recovery=ON critical-spawn-retry=ON order-cooldown="..tostring(NEU_BOT.OrderCooldownSec))
 log("MAP KNOWLEDGE source=_flag_points_final loaded="..tostring(mapOk).." key="..tostring(MAP and MAP.mapKey).." ratio="..tostring(MAP and MAP.matchRatio).." spawn="..tostring(MAP and MAP.spawn~=nil))
 log("RULE exact-tank-100m=NOT-AVAILABLE verified-Move-command=NO")
 startClock() processSpawn()
end
function onGameStop() stopClock() collectgarbage("collect") end
function onGameQuant() processSpawn() end

function onGameSpawn(args)
 local ticket=nil if #C.SpawnTickets>0 then ticket=table.remove(C.SpawnTickets,1) end
 local sid=args and args.squadId
 if not ticket then
  if sid and adoptUnmatchedDetached(sid) then return end
  log("UNMATCHED SPAWN squad="..tostring(sid).." policy=ignore-no-active-detach-window") return
 end
 if C.AwaitingArrival==ticket then C.AwaitingArrival=nil end
 C.SquadRole[sid]=ticket.role C.DeadSquads[sid]=false if ticket.groupId then C.SquadGroup[sid]=ticket.groupId end
 log("ARRIVED squad="..sid.." role="..ticket.role.." group="..tostring(ticket.groupId).." target="..tostring(ticket.target))
 if ticket.role=="pointstart" then
  C.PointStartPending[ticket.target]=nil C.PointStartTarget[sid]=ticket.target
  if ticket.target then capture(sid,ticket.target,true) end
 elseif ticket.role=="recon" then
  C.ReconSquad=sid makeOpeningGroups()
 elseif ticket.role=="patrol_heli" then
  C.PatrolHeliSquad=sid C.NextHeliPatrolAt=0 log("HELI PATROL READY squad="..sid.." unit="..tostring(ticket.unit)) processHeliPatrol()
 elseif ticket.role=="infantry" then
  local id=ticket.groupId
  if id and C.Groups[id] then
   C.Groups[id].infantry[#C.Groups[id].infantry+1]=sid
   if C.Groups[id].phase=="attack" and C.Groups[id].target then armDetachWindow(id,C.Groups[id].target,"infantry-arrival") capture(sid,C.Groups[id].target,true) end
  end
 elseif ticket.role=="defense_infantry" then
  local id=ticket.groupId if id and C.Groups[id] then C.Groups[id].defenders[#C.Groups[id].defenders+1]=sid end C.DefendTarget[sid]=ticket.target if ticket.target then capture(sid,ticket.target,true) end
 elseif ticket.role=="tank" or ticket.role=="tank80plus" then
  local id=ticket.groupId or assignTankGroup() if id and C.Groups[id] and not C.Groups[id].stopped then C.SquadGroup[sid]=id C.Groups[id].tanks[#C.Groups[id].tanks+1]=sid C.TankReadyAt[sid]=C.Time+NEU_BOT.VehicleFollowDelaySec if C.Groups[id].phase=="attack" and C.Groups[id].target then deferCapture(sid,C.Groups[id].target,NEU_BOT.VehicleFollowDelaySec) end end
 elseif ticket.role=="antiair" or ticket.role=="aat" then
  local t=ticket.target or chooseFrontOwnFlag(nil) if t then capture(sid,t,true) end
 elseif ticket.target then
  if isStrategicEnemy(ticket.target) or flagOccupant(ticket.target)==BotApi.Instance.team then capture(sid,ticket.target,true) end
 end
 processSpawn()
end

BotApi.Events:Subscribe(BotApi.Events.GameStart,onGameStart)
BotApi.Events:Subscribe(BotApi.Events.GameEnd,onGameStop)
BotApi.Events:Subscribe(BotApi.Events.Quant,onGameQuant)
BotApi.Events:Subscribe(BotApi.Events.GameSpawn,onGameSpawn)
