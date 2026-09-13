local nativeRequire=require
function require(name)
 if name:find('/script/multiplayer/',1,true) then
  if package.loaded[name] then return package.loaded[name] end
  local value=dofile('./'..name:match('([^/]+)$')..'.lua')
  package.loaded[name]=value return value
 end
 return nativeRequire(name)
end
local timers,alive,orders,logs={},{},{},{}
local originalPrint=print
print=function(s) logs[#logs+1]=s end
BotApi={Instance={team='a',enemyTeam='b',army='rus',hostId=1},Scene={Flags={},Squads={}},Commands={},Events={GameStart=1,GameEnd=2,Quant=3,GameSpawn=4}}
function BotApi.Events:Subscribe() end
function BotApi.Events:KillQuantTimer(id) timers[id]=nil end
local timerId=0
function BotApi.Events:SetQuantTimer(fn) timerId=timerId+1 timers[timerId]=fn return timerId end
function BotApi.Scene:IsSquadExists(id) return alive[id]==true end
function BotApi.Commands:Spawn() return false end
function BotApi.Commands:CaptureFlag(id,flag) orders[id]=flag end
function BotApi.Commands:EnemyHasTanks() return true end
local N=dofile('bot.main.lua') local C=N.C
N.MAP.load=function() return false end
readAllUnits=function() end
local function reset()
 BotApi.Scene.Flags={{name='f1',occupant='a'},{name='f2',occupant='a'},{name='f3',occupant='b'},{name='f4',occupant='neutral'}}
 BotApi.Scene.Squads={} alive={} orders={}
 onGameStart() C.SpawnIntents={}
 for i,g in pairs(C.Groups) do alive[i]=true g.infantry={i} C.SquadRole[i]='infantry' C.SquadGroup[i]=i BotApi.Scene.Squads[#BotApi.Scene.Squads+1]=i end
end
local function tick(n) for i=1,n do local id=C.Timer local fn=timers[id] assert(fn) timers[id]=nil fn() end end
local function countRole(role) local n=0 for _,v in ipairs(C.SpawnIntents) do if v.role==role then n=n+1 end end return n end
reset()
BotApi.Scene.Flags[1].occupant='neutral' tick(1)
assert(C.LostOwnFlags.f1 and C.AttackUnlocked,'lost neutral flag must unlock retake')
local g
for _,x in pairs(C.Groups) do if x.target=='f1' then g=x end end
assert(g and g.retake,'retake must be assigned despite untouched neutral f4')
g.phase='attack' g.resultCheckAt=C.Time+90 tick(5)
assert(orders[g.infantry[1]]=='f1','neutral retake must receive commands')
g.resultCheckAt=C.Time+1 tick(1) assert(g.target=='f1' and g.retake,'first failed wave must retain retake')
g.phase='attack' g.resultCheckAt=C.Time+1 tick(1) assert(not g.retake and C.LostOwnFlags.f1.retryAfter>C.Time,'second failure permits bounded reprioritization')
BotApi.Scene.Flags[1].occupant='a' tick(1) assert(not C.LostOwnFlags.f1,'recapture clears lost flag')
reset() C.AttackUnlocked=true tick(1)
assert(C.Groups[1].target=='f3','ordinary offensive must not wait for all neutrals')
C.Groups[1].phase='attack' C.Groups[1].resultCheckAt=999
BotApi.Scene.Flags[4].occupant='a' tick(1)
assert(C.Groups[1].target=='f3' and C.Groups[1].phase=='attack','neutral completion must preserve attack')
alive[55]=true BotApi.Scene.Squads[#BotApi.Scene.Squads+1]=55 tick(13)
assert(C.SquadRole[55]=='infantry_detached' and orders[55],'scene-only squad must receive order without spawn event')
alive[77]=true onGameSpawn({squadId=77}) tick(12)
assert(not C.SquadRole[77],'unconfirmed event must not be adopted')
C.SpawnTickets={{role='tank',groupId=1}} C.LastOrder[1]={flag='f3',time=C.Time}
onGameSpawn({squadId=1}) assert(#C.SpawnTickets==1 and not C.LastOrder[1],'known event must preserve purchase ticket and refresh orders')
C.SpawnTickets={} C.SpawnIntents={} C.NextAircraftAllowedAt=0
N.enqueueSpawn('aircraftlight','test',0,'f3',1)
N.enqueueSpawn('aircraftlight','test',0,'f3',2)
assert(countRole('aircraftlight')==1,'air cooldown is global')
C.SpawnIntents={} C.Time=C.NextAircraftAllowedAt-1 N.enqueueSpawn('aircraftlight','test',0,'f3',2)
assert(countRole('aircraftlight')==0,'cooldown must survive aircraft loss')
C.Time=C.Time+1 N.enqueueSpawn('aircraftlight','test',0,'f3',2) assert(countRole('aircraftlight')==1)
reset() assert(C.NextAircraftAllowedAt==0,'new match must reset cooldown')
BotApi.Commands.EnemyHasTanks=nil tick(30)
assert(C.Time==30,'missing enemy API must not stop timer')
assert(C.Groups[1].tankApproach==C.Groups[1].approach,'shared corridor')
-- Support lifecycle with controllable scene state, including queue races.
reset() C.Candidates.antiair={{unit='test-aa'}}
C.SpawnIntents={} N.maintainAA()
assert(countRole('antiair')==1,'AA must be replenished')
C.NextAAMaintenanceAt=0 N.maintainAA() assert(countRole('antiair')==1,'AA purchase must not duplicate')
C.SpawnIntents={} alive[90]=true C.SquadRole[90]='antiair'
C.NextAAMaintenanceAt=0 N.maintainAA() assert(countRole('antiair')==0,'living AA squad must not duplicate')
alive[90]=false C.NextAAMaintenanceAt=0 N.maintainAA() assert(countRole('antiair')==1,'AA loss must trigger replacement')
reset() C.SpawnIntents={} C.Candidates.airbot={{unit='test-plane'}} C.Candidates.uavbot={{unit='test-uav'}}
C.Groups[1].target='f3' C.Groups[2].target='f3'
N.ensureAir(1,'f3') assert(countRole('airbot')==1 and countRole('uavbot')==0,'unknown AA allows normal plane, not conditional UAV')
C.SpawnIntents={} C.NextAircraftAllowedAt=0 C.Candidates.airbot={}
N.ensureAir(1,'f3') assert(countRole('uavbot')==0,'unknown must not become AA-clear')
assert(N.reportEnemyAA(false,nil,'test complete scan'))
N.ensureAir(1,'f3') assert(countRole('uavbot')==2,'one UAV per BTG')
assert(C.SpawnIntents[1].groupId~=C.SpawnIntents[2].groupId,'distinct BTGs')
local uav=C.SpawnIntents[1]
N.reportEnemyAA(true,'f3','test visible AAT')
assert(not N.validateSupportSpawn(uav),'new AAT cancels queued UAV')
C.SpawnIntents={} C.NextAircraftAllowedAt=0 C.Candidates.antirad={{unit='test-antirad'}}
N.ensureAir(1,'f3') assert(countRole('antirad')==0,'anti-radar response delay')
for i=1,6 do C.Time=C.Time+30 N.reportEnemyAA(true,'f3','test refreshed AAT') end
N.ensureAir(1,'f3') assert(countRole('antirad')==1,'confirmed persistent AAT queues response')
C.Time=C.Time+46 assert(N.enemyAAState()==nil,'stale report becomes unknown')
assert(not N.validateSupportSpawn(C.SpawnIntents[1]),'stale AA report cancels conditional request')
C.Time=700 N.supportArrived(123,{role='uavbot',groupId=2,target='f3'})
assert(C.AirSupport[123].groupId==2 and C.NextAircraftAllowedAt>=1060,'UAV arrival assigns BTG and extends cooldown')
originalPrint('PASS: AA replacement/deduplication, airbot selection, unknown AA gating, paired UAVs, changed AA cancellation, delayed antirad, stale intel, UAV arrival')
originalPrint('PASS: retake, neutral orders, two-wave lock, recapture, offense gate, no target reset, scene-only adoption, unknown event filtering, known event refresh, global cooldown, match reset, missing API')
