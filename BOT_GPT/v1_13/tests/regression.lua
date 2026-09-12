-- Run from BOT_GPT/v1_13: lua tests/regression.lua
for _,f in ipairs({'bot.lua','bot.data.lua','bot.mapdata.lua','bot.main.lua'}) do assert(loadfile(f)) end
local output=print
print=function() end
require=function() end
dofile('bot.data.lua')
local living,orders={},{}
local nextId=0
local failPoint=true
BotApi={Instance={team='a',enemyTeam='b',army='usa',hostId=1},Scene={Flags={{name='f1',occupant='none'},{name='f2',occupant='none'},{name='f3',occupant='b'},{name='f4',occupant='b'}}},Commands={},Events={}}
function BotApi.Scene:IsSquadExists(id) return living[id]==true end
function BotApi.Commands:CaptureFlag(id,flag) orders[#orders+1]={id=id,flag=flag} end
function BotApi.Commands:Spawn(unit,size)
 if unit=='point' and failPoint then return false end
 nextId=nextId+1 living[nextId]=true
 onGameSpawn({squadId=nextId}) -- synchronous callback regression
 return true
end
function BotApi.Events:Subscribe() end
function BotApi.Events:SetQuantTimer(fn) self.pulse=fn return 1 end
function BotApi.Events:KillQuantTimer() end
NEU_MAPDATA={load=function() return false end,distanceFromSpawn=function() return nil end}
dofile('bot.lua')
function readAllUnits(_,units)
 for _,r in ipairs({{'point','pointstart'},{'inf','all infantry'},{'tank','duel_tanks80'},{'heli','duel_heli'}}) do
  local tags={} for t in r[2]:gmatch('%S+') do tags[t]=true end
  units[#units+1]={unit=r[1],tagset=tags} units.count=units.count+1
 end
end
onGameStart()
local C
for i=1,100 do local name,value=debug.getupvalue(onGameStart,i) if not name then break end if name=='C' then C=value end end
assert(C and C.Groups[1] and C.Groups[2],'groups depend on recon')
local function ticks(n) for i=1,n do BotApi.Events.pulse() end end
ticks(150)
assert(C.PointStartPending.f1 and C.PointStartPending.f2,'point retries exhausted')
assert(not C.AwaitingArrival,'synchronous spawn blocks queue')
failPoint=false ticks(20)
local targets={}
for sid,target in pairs(C.PointStartTarget) do assert(not targets[target],'duplicate point squad') targets[target]=sid end
assert(targets.f1 and targets.f2,'missing start targets')
local heli=C.PatrolHeliSquad assert(heli,'heli failed to spawn')
local saw=false for _,o in ipairs(orders) do if o.id==heli then assert(o.flag=='f3' or o.flag=='f4','heli patrol own flags') saw=true end end assert(saw)
local before=#C.SpawnTickets
onGameSpawn({}) assert(#C.SpawnTickets==before,'invalid event consumed ticket')
onGameSpawn({squadId=heli}) assert(C.PatrolHeliSquad==heli)
living[targets.f1]=false
BotApi.Scene.Flags[2].occupant='a'
ticks(2)
assert(C.HostileNeutral.f1,'dead pointstart not hostile')
assert(C.NeutralsCleared,'hostile neutral blocks attack')
assert(C.Groups[1].phase=='attack' and C.Groups[2].phase=='attack','groups not attacking')
assert(C.Groups[1].target~=C.Groups[2].target,'same direction')
for i=1,12 do nextId=nextId+1 living[nextId]=true onGameSpawn({squadId=nextId}) end
ticks(10)
nextId=nextId+1 living[nextId]=true onGameSpawn({squadId=nextId})
assert(C.SquadRole[nextId]==nil,'detach limit resets on orders')
assert(#C.Groups[1].detached==6 and #C.Groups[2].detached==6)
assert(not C.FlagSnapshot and not C.FlagIndex,'tick cache leaked')
dofile('bot.mapdata.lua')
local M=NEU_MAPDATA M.spawn={x=0,y=0} M.flags={a={{x=3,y=4}},b={{x=6,y=8}}}
assert(M:distanceNames('a','b')==5 and M:distanceNames('b','a')==5)
assert(M:distanceFromSpawn('b')==10 and M:distanceFromSpawn('b')==10)
output('PASS: syntax, recon independence, synchronous spawn, persistent point retries, unique assignments, enemy patrol, invalid/duplicate events, hostile transition, two attack targets, detach cap, tick cache, distance cache')
