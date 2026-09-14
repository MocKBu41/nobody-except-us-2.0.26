-- NEU BOT v1.21 logic
local N=require([[/script/multiplayer/bot.v1_21.core]])
local C=N.C
require([[/script/multiplayer/bot.v1_21.support]])

local function newGroup(id)
 C.Groups[id]={id=id,target=nil,phase='opening',failedTarget=nil,failCount=0,infantry={},detached={},tanks={},defenders={},nextAttackAt=nil,resultCheckAt=nil,rally=nil,approach=nil,tankApproach=nil,lastApproach=nil,lastTankApproach=nil,wave=0,assembleUntil=nil,approachUntil=nil}
end
local function activeGroups() local a={} for id,g in pairs(C.Groups) do a[#a+1]=id end table.sort(a) return a end
local function leastInfGroup() local best,bn=nil,nil for _,id in ipairs(activeGroups()) do local n=N.groupInfCount(C.Groups[id]) if bn==nil or n<bn then best,bn=id,n end end return best end
local function chooseEnemyTarget(gid)
 local f=N.flags() local g=C.Groups[gid] local used={} for id,x in pairs(C.Groups) do if id~=gid and x.target and N.isStrategicEnemy(x.target) then used[x.target]=true end end
 local c={} for _,n in ipairs(f.enemy) do if not used[n] then c[#c+1]=n end end for n,v in pairs(C.HostileNeutral) do if v and N.isNeutral(n) and not used[n] then c[#c+1]=n end end
 if #c==0 then for _,n in ipairs(f.enemy) do c[#c+1]=n end end if #c==0 then return nil end
 if N.MAP and N.MAP.loaded then local front=N.MAP:frontOwnFlags(f.mine,c) if front[1] then N.geoSortFromFlag(c,front[1]) else N.geoSortSpawn(c) end else N.numericSort(c) end
 for _,n in ipairs(c) do if n~=g.failedTarget then return n end end return c[1]
end
local function ensureInf(id,reason,minCount) local g=C.Groups[id] if not g then return end minCount=minCount or 1 if N.groupInfCount(g)<minCount and not N.pendingForGroup('infantry',id) then N.enqueueSpawn('infantry',reason,0,g.target,id,g.phase) end end
local function ensureTank(id,reason) local g=C.Groups[id] if g and N.aliveCount(g.tanks)==0 and not N.pendingForGroup('tank',id) then N.log('TANK RANDOM pool=duel_tanks70|duel_tanks80|duel_tanks90 group='..id) N.enqueueSpawn('tank',reason,0,g.target,id,g.phase) end end
local function hasSupport(tbl,gid) for sid,s in pairs(tbl) do if N.squadAlive(sid) and s.groupId==gid then return true end end return false end
local function ensureAir(id,target) N.ensureAir(id,target) end
local function ensureArt(id,target) if #(C.Candidates.artsupport or {})>0 and not hasSupport(C.ArtSupport,id) and not N.pendingForGroup('artsupport',id) then N.enqueueSpawn('artsupport','BTG artillery support',0,target,id,'support') end end

local function destFor(g,role)
 if g.phase=='assembling' then return g.rally or g.approach or g.target end
 if g.phase=='approach' then if role=='tank' then return g.tankApproach or g.approach or g.target end return g.approach or g.target end
 if g.phase=='attack' then return g.target end
 return g.rally or g.approach or g.target
end
local function orderGroup(g,label,force)
 for _,sid in ipairs(g.infantry) do if N.squadAlive(sid) then local d=destFor(g,C.SquadRole[sid]) if d then N.capture(sid,d,force) end end end
 for _,sid in ipairs(g.detached) do if N.squadAlive(sid) then local d=destFor(g,C.SquadRole[sid]) if d then N.capture(sid,d,force) end end end
 for _,sid in ipairs(g.tanks) do if N.squadAlive(sid) then local d=destFor(g,'tank') if d then N.capture(sid,d,force) end end end
 if label then N.log('BTG ORDER group='..g.id..' '..label..' rally='..tostring(g.rally)..' infApproach='..tostring(g.approach)..' tankApproach='..tostring(g.tankApproach)..' target='..tostring(g.target)) end
end
local function newRoute(g,target)
 g.rally=N.chooseOwnFlagBefore(target)
 g.approach=N.randomApproach(target,g.lastApproach,nil)
 g.tankApproach=g.approach -- Shared corridor keeps armour and infantry in the same wave.
 g.lastApproach=g.approach g.lastTankApproach=g.tankApproach g.wave=(g.wave or 0)+1
 N.log('ROUTE NEW group='..g.id..' wave='..g.wave..' rally='..tostring(g.rally)..' inf='..tostring(g.approach)..' tank='..tostring(g.tankApproach)..' target='..target)
end
local function beginWave(id,target,resetFail)
 local g=C.Groups[id] if not g or not target then return end if resetFail then g.failCount=0 end g.target=target newRoute(g,target) g.phase='assembling' g.assemblyStartedAt=C.Time g.assembleUntil=C.Time+(NEU_BOT.BTGAssemblySec or 30) g.approachUntil=nil g.resultCheckAt=nil g.nextAttackAt=nil ensureInf(id,'BTG assemble infantry',NEU_BOT.MinAssaultInfantrySquads or 2) ensureTank(id,'BTG assemble tank') ensureAir(id,target) ensureArt(id,target) orderGroup(g,'ASSEMBLE',true)
end
local function launchApproach(g) g.phase='approach' g.approachUntil=C.Time+(NEU_BOT.BTGApproachSec or 15) N.log('BTG APPROACH group='..g.id..' I='..N.groupInfCount(g)..' T='..N.aliveCount(g.tanks)) orderGroup(g,'APPROACH',true) end
local function launchAssault(g) g.phase='attack' g.resultCheckAt=C.Time+(NEU_BOT.AttackResultCheckSec or 90) N.log('BTG ASSAULT group='..g.id..' wave='..g.wave..' target='..g.target..' I='..N.groupInfCount(g)..' T='..N.aliveCount(g.tanks)) orderGroup(g,'ASSAULT',true) end

local function queueOpening()
 if C.PointStartQueued then return end C.PointStartQueued=true local f=N.flags() local list={} for _,x in ipairs(f.neutral) do list[#list+1]=x end N.geoSortSpawn(list) for _,x in ipairs(list) do N.enqueueSpawn('pointstart','opening point',0,x,nil,'pointstart') end
 for i=1,(NEU_BOT.AssaultGroups or 2) do newGroup(i) N.enqueueSpawn('infantry','opening infantry',0,nil,i,'opening') N.enqueueSpawn('tank','opening random tank',NEU_BOT.OpeningTankDelaySec or 5,nil,i,'opening') end
 N.enqueueSpawn('recon','opening recon',0,nil,nil,'opening') N.enqueueSpawn('antiair','opening aa',0,nil,nil,'opening') N.enqueueSpawn('patrol_heli','opening heli',0,nil,nil,'patrol')
end
local function processPointStart()
 if C.Time<C.NextPointStartCheckAt then return end C.NextPointStartCheckAt=C.Time+(NEU_BOT.PointStartCheckSec or 3)
 for sid,target in pairs(C.PointStartTarget) do if N.squadAlive(sid) then if N.flagOccupant(target)==BotApi.Instance.team then C.PointStartTarget[sid]=nil C.PointStartDone[target]=true local id=leastInfGroup() local g=id and C.Groups[id] if g and N.groupInfCount(g)<(NEU_BOT.MaxAssaultInfantrySquads or 4) then C.SquadRole[sid]='infantry_detached' C.SquadGroup[sid]=id g.detached[#g.detached+1]=sid local d=destFor(g,'infantry_detached') if d then N.capture(sid,d,true) end N.log('POINTSTART -> BTG squad='..sid..' group='..id) else local hold=N.chooseFrontOwnFlag(nil) C.SquadRole[sid]='defense_infantry' C.DefendTarget[sid]=hold if hold then N.capture(sid,hold,true) end end else N.capture(sid,target) end end end
end
local function unlockAttack()
 if C.AttackUnlocked then return end local f=N.flags() local hostile=0 for n,v in pairs(C.HostileNeutral) do if v and N.isNeutral(n) then hostile=hostile+1 end end
 if C.Time>=(NEU_BOT.AttackWaitSec or 300) or (f.enemyCount+hostile)>f.mineCount then C.AttackUnlocked=true N.log('ATTACK UNLOCK') end
end
local function neutralTransition()
 local n=N.strategicNeutralCount() if n==0 and not C.NeutralsCleared then C.NeutralsCleared=true for _,g in pairs(C.Groups) do if g.phase=='opening' then g.phase='ready' g.nextAttackAt=C.Time end end N.log('NEUTRALS CLEARED') elseif n>0 then C.NeutralsCleared=false end
end
local function completeCaptured()
 for id,g in pairs(C.Groups) do if g.target and N.flagOccupant(g.target)==BotApi.Instance.team and (g.phase=='assembling' or g.phase=='approach' or g.phase=='attack') then N.log('BTG CAPTURED group='..id..' flag='..g.target) C.HostileNeutral[g.target]=nil C.LostOwnFlags[g.target]=nil g.retake=nil g.target=nil g.phase='ready' g.resultCheckAt=nil g.assembleUntil=nil g.approachUntil=nil g.failCount=0 g.nextAttackAt=C.Time+(NEU_BOT.CaptureNextAttackDelaySec or 4) end end
end
local function startReady()
 if not C.AttackUnlocked then return end
 for _,id in ipairs(activeGroups()) do local g=C.Groups[id] if (g.phase=='ready' or g.phase=='opening') and (not g.nextAttackAt or C.Time>=g.nextAttackAt) then local t=chooseEnemyTarget(id) if t then beginWave(id,t,true) else g.nextAttackAt=C.Time+5 end end end
end
local function processWaves()
 for id,g in pairs(C.Groups) do
  if g.target and g.phase=='assembling' and C.Time>=(g.assembleUntil or 0) then if N.groupInfCount(g)>=(NEU_BOT.MinAssaultInfantrySquads or 2) or (N.groupInfCount(g)>0 and C.Time-(g.assemblyStartedAt or C.Time)>=60) then launchApproach(g) else ensureInf(id,'BTG waiting infantry',1) g.assembleUntil=C.Time+5 end
  elseif g.target and g.phase=='approach' and C.Time>=(g.approachUntil or 0) then launchAssault(g)
  elseif g.target and g.phase=='attack' and C.Time>=(g.resultCheckAt or 1e30) then
   if N.flagOccupant(g.target)==BotApi.Instance.team then completeCaptured() else
    local old=g.target g.failCount=(g.failCount or 0)+1 N.log('BTG WAVE FAILED group='..id..' target='..old..' fail='..g.failCount..' => REGROUP') ensureInf(id,'failed wave infantry',NEU_BOT.MinAssaultInfantrySquads or 2) ensureTank(id,'failed wave tank')
    if g.retake and g.failCount>=2 then C.LostOwnFlags[g.target].retryAfter=C.Time+120 g.retake=nil end
    if not g.retake and g.failCount>=(NEU_BOT.MaxWavesSameTarget or 2) then g.failedTarget=old local nt=chooseEnemyTarget(id) if nt and nt~=old then N.log('BTG SWITCH TARGET group='..id..' '..old..' -> '..nt) beginWave(id,nt,true) else beginWave(id,old,false) end else beginWave(id,old,false) end
   end
  end
 end
end
local function processUnmatched()
 for sid,x in pairs(C.UnmatchedPending) do if C.Time>=x.due then C.UnmatchedPending[sid]=nil if C.VisibleOwn[sid] and N.squadAlive(sid) and not C.SquadRole[sid] then local id=(x.groupId and C.Groups[x.groupId]) and x.groupId or leastInfGroup() local g=id and C.Groups[id] if g then C.SquadRole[sid]='infantry_detached' C.SquadGroup[sid]=id C.DeadSquads[sid]=false g.detached[#g.detached+1]=sid local d=destFor(g,'infantry_detached') N.log('OWN RESERVE ADOPT (passenger link unknown) squad='..sid..' group='..id..' phase='..g.phase..' dest='..tostring(d)) if d then N.capture(sid,d,true) end end end end end
end
local function maintenance()
 for id,g in pairs(C.Groups) do if g.phase=='assembling' or g.phase=='approach' or g.phase=='attack' then ensureInf(id,'BTG maintenance infantry',NEU_BOT.MinAssaultInfantrySquads or 2) ensureTank(id,'BTG maintenance tank') if g.target then ensureAir(id,g.target) ensureArt(id,g.target) end end end
end
local function processOrders()
 if C.Time<C.NextOrderAt then return end C.NextOrderAt=C.Time+(NEU_BOT.InfantryReissueSec or 5)
 for _,g in pairs(C.Groups) do if g.target and (g.phase=='assembling' or g.phase=='approach' or g.phase=='attack') then orderGroup(g,nil,false) end for _,sid in ipairs(g.defenders) do local t=C.DefendTarget[sid] if t then N.capture(sid,t) end end end
end
local function processSupport()
 if C.Time<C.NextSupportPatrolAt then return end C.NextSupportPatrolAt=C.Time+(NEU_BOT.SupportPatrolSec or 20)
 for sid,s in pairs(C.AirSupport) do if N.squadAlive(sid) then local g=s.groupId and C.Groups[s.groupId] if g and g.target then s.target=(s.role=='antirad' and N.enemyAAState()==true and C.EnemyAAReport.flag) or g.target s.home=N.chooseOwnFlagBefore(s.target) local d=(s.leg=='home') and s.home or s.target if d then N.capture(sid,d,true) end s.leg=(s.leg=='home') and 'target' or 'home' end else C.AirSupport[sid]=nil end end
 for sid,s in pairs(C.ArtSupport) do if N.squadAlive(sid) then local g=s.groupId and C.Groups[s.groupId] local t=(g and g.target) or s.target local home=N.chooseSafeOwnFlag(t) if home then s.home=home s.target=t N.capture(sid,home,true) end else C.ArtSupport[sid]=nil end end
end
local function detectLosses()
 for sid,role in pairs(C.SquadRole) do if not C.DeadSquads[sid] and not N.squadAlive(sid) then C.DeadSquads[sid]=true local id=C.SquadGroup[sid] local g=id and C.Groups[id] N.log('LOST squad='..sid..' role='..tostring(role)..' group='..tostring(id)) if role=='tank' and id then ensureTank(id,'tank replacement') end if (role=='infantry' or role=='infantry_detached') and id then ensureInf(id,'infantry replacement',NEU_BOT.MinAssaultInfantrySquads or 2) end if N.isAirRole(role) then C.AirSupport[sid]=nil if id and g and g.target then ensureAir(id,g.target) end end if role=='artsupport' then C.ArtSupport[sid]=nil if id and g and g.target then ensureArt(id,g.target) end end if role=='pointstart' then local t=C.PointStartTarget[sid] C.PointStartTarget[sid]=nil if t and N.flagOccupant(t)~=BotApi.Instance.team then C.HostileNeutral[t]=true end end end end
end
local function processPatrols()
 if C.PatrolHeliSquad and N.squadAlive(C.PatrolHeliSquad) and C.Time>=C.NextHeliPatrolAt then C.NextHeliPatrolAt=C.Time+(NEU_BOT.HeliPatrolSec or 20) local f=N.flags() if #f.enemy>0 then N.geoSortSpawn(f.enemy) N.capture(C.PatrolHeliSquad,f.enemy[1],true) end end
 if C.Time>=C.NextPatrolAt then C.NextPatrolAt=C.Time+(NEU_BOT.AntiAirPatrolSec or 20) local t=N.chooseFrontOwnFlag(nil) if t then for sid,r in pairs(C.SquadRole) do if N.squadAlive(sid) and (r=='antiair' or r=='aat') then N.capture(sid,t) end end end end
end


-- Track ownership transitions before deciding whether neutral flags block the opening.
local function updateFront()
 for _,f in pairs(BotApi.Scene.Flags) do
  local own=f.occupant==BotApi.Instance.team
  if C.PreviousOwn[f.name] and not own then
   C.LostOwnFlags[f.name]={since=C.Time,retryAfter=0}
   C.HostileNeutral[f.name]=true C.AttackUnlocked=true
   N.log('LOST FLAG '..f.name..' -> PRIORITY RETAKE')
  elseif own then C.LostOwnFlags[f.name]=nil C.HostileNeutral[f.name]=nil end
  C.PreviousOwn[f.name]=own
 end
end
local function processRetakes()
 local targets={}
 for name,x in pairs(C.LostOwnFlags) do if C.Time>=(x.retryAfter or 0) then targets[#targets+1]=name end end
 table.sort(targets,function(a,b)
  local aa,bb=C.LostOwnFlags[a].since,C.LostOwnFlags[b].since
  if aa~=bb then return aa<bb end return a<b
 end)
 for _,target in ipairs(targets) do
  local assigned=false
  for _,g in pairs(C.Groups) do if g.target==target then g.retake=true assigned=true break end end
  if not assigned then
   local best,score=nil,nil
   for _,id in ipairs(activeGroups()) do
    local g=C.Groups[id]
    if not g.retake then
     -- Last order/target is a proxy, not a measured squad position.
     local anchor=g.target or g.rally
     local d=(N.MAP and N.MAP.loaded and N.MAP:distanceNames(anchor,target)) or 100000
     if g.phase=='ready' or g.phase=='opening' then d=d-200000 end
     if score==nil or d<score then best,score=g,d end
    end
   end
   if best then best.retake=true N.log('RETAKE ASSIGN group='..best.id..' target='..target) beginWave(best.id,target,true) end
  end
 end
 -- A lost staging point must not remain a staging destination.
 for _,g in pairs(C.Groups) do
  if g.target and (g.phase=='assembling' or g.phase=='approach') then
   local d=(g.phase=='assembling') and g.rally or g.approach
   if d and N.flagOccupant(d)~=BotApi.Instance.team then
    g.rally=N.chooseOwnFlagBefore(g.target) g.approach=g.rally g.tankApproach=g.rally
    orderGroup(g,'FRONT ROUTE REPAIR',true)
   end
  end
 end
end

-- The original Cold War bot enumerates Scene.Squads as its controllable squads.
-- This also catches squads that become available without a GameSpawn event.
local function scanOwnSquads()
 if C.Time%3~=0 then return end
 local ok,err=pcall(function()
  local visible={}
  for _,sid in pairs(BotApi.Scene.Squads) do
   if type(sid)=='number' or type(sid)=='string' then
    visible[sid]=true
    if N.squadAlive(sid) and not C.SquadRole[sid] and not C.UnmatchedPending[sid] then
     C.UnmatchedPending[sid]={due=C.Time+8,source='Scene.Squads'}
     N.log('OWN SCAN NEW squad='..sid)
    end
   end
  end
  C.VisibleOwn=visible
 end)
 if not ok and not C.OwnScanError then C.OwnScanError=true N.log('OWN SCAN UNAVAILABLE '..tostring(err)) end
end
local function scanEnemy()
 if C.Time%30~=0 then return end
 local ok,value=pcall(function() return BotApi.Commands:EnemyHasTanks() end)
 C.EnemyHasTanks=nil if ok and type(value)=='boolean' then C.EnemyHasTanks=value end
 N.log('ENEMY SCAN tanksPresent='..(ok and tostring(value) or 'unavailable')..' unitList=unavailable positions=unavailable')
 if C.ApiInspected then return end C.ApiInspected=true
 -- Inspect exposed names only. Never call unknown native methods/signatures.
 for _,name in ipairs({'Scene','Commands','Events'}) do
  local success=pcall(function()
   local obj=BotApi[name] local keys={} local count=0
   if type(obj)=='table' then for k,v in pairs(obj) do count=count+1 if count>80 then break end keys[#keys+1]=tostring(k)..':'..type(v) end end
   table.sort(keys) N.log('API CAPABILITIES '..name..' type='..type(obj)..' '..table.concat(keys,'|'))
  end)
  if not success then N.log('API CAPABILITIES '..name..' opaque') end
 end
end

local function onSecond()
 C.Time=C.Time+1 C.FlagSnapshot=nil C.FlagIndex={} C.FlagSnapshot=N.flags() for _,flag in pairs(BotApi.Scene.Flags) do C.FlagIndex[flag.name]=flag end
 updateFront() scanOwnSquads() detectLosses() processUnmatched() unlockAttack() processPointStart() neutralTransition() completeCaptured() processRetakes() N.maintainAA() startReady() processWaves() maintenance() processOrders() processSupport() processPatrols() scanEnemy() N.processSpawn()
 if N.Tactics then N.Tactics.tick() end
 if C.Time%30==0 then local f=N.flags() local p={} for id,g in pairs(C.Groups) do p[#p+1]='G'..id..'='..tostring(g.target)..':'..g.phase..':I'..N.groupInfCount(g)..':T'..N.aliveCount(g.tanks)..':W'..tostring(g.wave) end N.log('TIME='..C.Time..' FLAGS='..f.mineCount..'/'..f.enemyCount..' N='..N.strategicNeutralCount()..' '..table.concat(p,' ')) end
 C.FlagSnapshot=nil C.FlagIndex=nil
end
local function stopClock() C.TimerGeneration=C.TimerGeneration+1 if C.Timer then BotApi.Events:KillQuantTimer(C.Timer) C.Timer=nil end end
local function startClock() stopClock() local gen=C.TimerGeneration local function pulse() if gen~=C.TimerGeneration then return end C.Timer=nil onSecond() if gen==C.TimerGeneration then C.Timer=BotApi.Events:SetQuantTimer(pulse,NEU_BOT.TickMs) end end C.Timer=BotApi.Events:SetQuantTimer(pulse,NEU_BOT.TickMs) end

function onGameStart()
 C.PreviousOwn={} C.LostOwnFlags={} C.VisibleOwn={} C.NextAircraftAllowedAt=0 C.ApiInspected=false C.OwnScanError=false C.EnemyHasTanks=nil
 for _,f in pairs(BotApi.Scene.Flags) do C.PreviousOwn[f.name]=f.occupant==BotApi.Instance.team end
 N.resetSupport()
 C.Spawning=false C.Units={count=1,seen={}} readAllUnits(nil,C.Units,BotApi.Instance.army) N.buildCandidates() C.SpawnIntents={} C.SpawnTickets={} C.AwaitingArrival=nil C.SquadRole={} C.DeadSquads={} C.SquadGroup={} C.DefendTarget={} C.Groups={} C.LastOrder={} C.Time=0 C.AttackUnlocked=false C.NeutralsCleared=false C.HostileNeutral={} C.PointStartTarget={} C.PointStartPending={} C.PointStartDone={} C.PointStartQueued=false C.PatrolHeliSquad=nil C.AirSupport={} C.ArtSupport={} C.UnmatchedPending={} C.LastSpawnGroup=nil C.LastSpawnGroupAt=-999 C.NextOrderAt=0 C.NextPointStartCheckAt=0 C.NextSupportPatrolAt=0 C.NextHeliPatrolAt=0 C.NextPatrolAt=0
 local host=tonumber(BotApi.Instance.hostId) or 1 math.randomseed(os.time()*host) local mapOk=N.MAP and N.MAP:load() or false if N.Tactics then N.Tactics.reset() end queueOpening() N.log('START v1.21 map='..tostring(mapOk)) N.log('RULE BTG ASSEMBLY->APPROACH->ASSAULT; FAILED=>REGROUP+NEW ROUTE') N.log('RULE OWN SCENE SCAN=ON; SHARED RANDOM CORRIDOR=ON; ENEMY DIAGNOSTICS=ON') startClock() N.processSpawn()
end
function onGameStop() stopClock() collectgarbage('collect') end
function onGameQuant() N.processSpawn() end
function onGameSpawn(args)
 local sid=args and args.squadId if not sid then return end
 if C.SquadRole[sid] then C.LastOrder[sid]=nil N.log('KNOWN SQUAD EVENT squad='..sid..' order refresh queued') return end
 C.UnmatchedPending[sid]=nil
 local ticket=#C.SpawnTickets>0 and table.remove(C.SpawnTickets,1) or nil
 if not ticket then C.UnmatchedPending[sid]={due=C.Time+8,source='GameSpawn'} N.log('UNMATCHED squad='..sid..' awaiting own-scene confirmation') return end
 if N.Tactics then N.Tactics.onSpawn(sid,ticket) end
 if C.AwaitingArrival==ticket then C.AwaitingArrival=nil end C.SquadRole[sid]=ticket.role C.DeadSquads[sid]=false if ticket.groupId then C.SquadGroup[sid]=ticket.groupId C.LastSpawnGroup=ticket.groupId C.LastSpawnGroupAt=C.Time end N.log('ARRIVED squad='..sid..' role='..ticket.role..' group='..tostring(ticket.groupId))
 if ticket.role=='pointstart' then C.PointStartPending[ticket.target]=nil C.PointStartTarget[sid]=ticket.target if ticket.target then N.capture(sid,ticket.target,true) end
 elseif ticket.role=='patrol_heli' then C.PatrolHeliSquad=sid
 elseif ticket.role=='infantry' then local g=ticket.groupId and C.Groups[ticket.groupId] if g then g.infantry[#g.infantry+1]=sid local d=destFor(g,'infantry') if d then N.capture(sid,d,true) end end
 elseif ticket.role=='defense_infantry' then local g=ticket.groupId and C.Groups[ticket.groupId] if g then g.defenders[#g.defenders+1]=sid end C.DefendTarget[sid]=ticket.target if ticket.target then N.capture(sid,ticket.target,true) end
 elseif ticket.role=='tank' then local g=ticket.groupId and C.Groups[ticket.groupId] if g then g.tanks[#g.tanks+1]=sid local d=destFor(g,'tank') if d then N.capture(sid,d,true) end end
 elseif N.isAirRole(ticket.role) then N.supportArrived(sid,ticket)
 elseif ticket.role=='artsupport' then local g=ticket.groupId and C.Groups[ticket.groupId] local t=(g and g.target) or ticket.target local h=N.chooseSafeOwnFlag(t) C.ArtSupport[sid]={groupId=ticket.groupId,target=t,home=h} if h then N.capture(sid,h,true) end
 elseif ticket.role=='antiair' or ticket.role=='aat' then local t=ticket.target or N.chooseFrontOwnFlag(nil) if t then N.capture(sid,t,true) end
 elseif ticket.target then N.capture(sid,ticket.target,true) end
 N.processSpawn()
end

BotApi.Events:Subscribe(BotApi.Events.GameStart,onGameStart)
BotApi.Events:Subscribe(BotApi.Events.GameEnd,onGameStop)
BotApi.Events:Subscribe(BotApi.Events.Quant,onGameQuant)
BotApi.Events:Subscribe(BotApi.Events.GameSpawn,onGameSpawn)
return N

