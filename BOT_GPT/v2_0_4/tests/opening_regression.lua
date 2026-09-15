-- Standalone Lua regression harness. Run from the version directory:
-- lua tests/opening_regression.lua
local realRequire = require
local modules = {}
function require(name)
    local file = name:match('/script/multiplayer/(.+)')
    if not file then return realRequire(name) end
    if not modules[file] then modules[file] = assert(loadfile(file .. '.lua'))() end
    return modules[file]
end
local files = {}
io.open = function(path, mode)
    if mode == 'r' or mode == 'rb' then return nil end
    if mode == 'w' then files[path] = '' end
    return {write=function(_, ...)
        for _, s in ipairs({...}) do files[path] = (files[path] or '') .. s end
    end, close=function() end}
end
local logs, live, timer, pending, nextId, attempts, rejectFlag, seen = {}, {}, nil, nil, 0, {}, nil, {}
print = function(s) logs[#logs+1]=s end
BotApi = {
 Instance={team='a',enemyTeam='b',army='test',hostId=1},
 Scene={Flags={}, IsSquadExists=function(_,id) return live[id] == true end},
 Events={GameStart='start',GameEnd='stop',Quant='quant',GameSpawn='spawn',
 Subscribe=function(_, event, fn) seen[event]=fn end,
 KillQuantTimer=function() timer=nil end,
 SetQuantTimer=function(_,fn) timer=fn; return 1 end},
 Commands={}
}
BotApi.Commands.Spawn=function(_,unit)
 if unit=='heli' then return true end -- accepted with no arrival callback
 assert(not pending, 'overlapping ground request')
 pending=unit
 return true
end
BotApi.Commands.CaptureFlag=function(_,id,flag)
 attempts[flag]=(attempts[flag] or 0)+1
 if flag==rejectFlag then return false end
 return nil -- void API result is compatible; not a confirmed physical capture
end
local N=require('/script/multiplayer/bot')
N.loadUnits=function()
 N.C.Units={{unit='infantry',role='infantry'}, {unit='heli',role='attack_heli'},
 {unit='recon',role='recon'},{unit='tank',role='tank'},{unit='mech',role='mech_inf'}}
end
local function reset(count)
 live={};pending=nil;nextId=0;attempts={};rejectFlag=nil;logs={}
 BotApi.Scene.Flags={}
 for i=1,count do BotApi.Scene.Flags[i]={name='f'..i,occupant='neutral'} end
 seen.start()
 assert(N.C.AwaitingArrival and N.C.AwaitingArrival.role=='pointstart')
 assert(N.C.Candidates.pointstart[1].unit=='infantry','missing fallback')
end
local function tick(n)
 for i=1,n do assert(timer)(); seen.quant() end
end
local function arrive()
 assert(pending,'no request at id='..nextId..' time='..N.C.Time..' logs='..table.concat(logs, '\n'))
 pending=nil;nextId=nextId+1;live[nextId]=true
 seen.spawn({squadId=nextId})
 return nextId
end
reset(11)
for i=1,11 do
 tick(7) -- exceed the original 60-second opening timeout
 assert(N.C.MainOpeningFrozen)
 arrive()
end
assert(N.C.OpeningCoverageReleased, 'coverage not released')
assert(N.C.AwaitingArrival.role=='infantry', 'main infantry skipped after long wait')
assert(N.C.OpeningIndex==1)
for i=1,11 do assert(attempts['f'..i], 'missing dedicated flag order') end
local telemetry=table.concat((function() local a={} for _,v in pairs(files) do a[#a+1]=v end return a end)())
assert(telemetry:find('"v":"2.0.4"',1,true))
assert(telemetry:find('OPENING COVERAGE COMPLETE',1,true), 'coverage missing in telemetry')
seen.stop()
reset(2)
rejectFlag='f1'
local first=arrive()
assert(not N.C.OpeningCoverageDone.f1, 'rejected order counted as coverage')
arrive()
assert(not N.C.OpeningCoverageReleased)
rejectFlag=nil
tick(16)
assert(N.C.OpeningCoverageReleased, 'existing squad order not retried')
assert(N.C.OpeningCoverageSquads.f1==first, 'retry bought a duplicate')
seen.stop()
reset(3)
local dead=arrive()
live[dead]=false
tick(1)
arrive();arrive()
assert(not N.C.OpeningCoverageReleased, 'dead squad released gate')
tick(1)
arrive()
assert(N.C.OpeningCoverageReleased, 'lost coverage not replaced')
assert(N.C.OpeningCoverageSquads.f1~=dead)
seen.stop()
reset(2)
local id=arrive()
BotApi.Scene.Flags[1].occupant='a'
live[id]=false
arrive()
assert(N.C.OpeningCoverageReleased, 'owned flag incorrectly requires live squad')
seen.stop()
-- Start-stop-start in one VM must reset telemetry cadence and frozen state.
reset(1)
arrive()
assert(N.C.OpeningCoverageReleased)
seen.stop()
-- Synchronous callbacks can occur inside Spawn; accounting and gate must survive.
BotApi.Commands.Spawn=function(_,unit)
 if unit=='heli' then
  nextId=nextId+1;live[nextId]=true;seen.spawn({squadId=nextId});return true
 end
 nextId=nextId+1;live[nextId]=true;seen.spawn({squadId=nextId});return true
end
pending=nil;live={};nextId=0;attempts={};rejectFlag=nil
BotApi.Scene.Flags={}
for i=1,11 do BotApi.Scene.Flags[i]={name='f'..i,occupant='neutral'} end
seen.start()
tick(20)
assert(N.C.OpeningCoverageReleased, 'synchronous callbacks stalled opening')
for i=1,11 do assert(attempts['f'..i]) end
assert(N.aliveRoleCount('patrol_heli')==1)
assert(N.aliveRoleCount('infantry')==1)
assert(N.C.Economy.spent==950, 'synchronous callback charged twice or skipped role')
seen.stop()
_G.TEST_RESULT='PASS: slow 11-flag opening; no-callback heli; infantry fallback; rejected-order retry; dead capture replacement; owned flag; restart; telemetry; synchronous callbacks'
