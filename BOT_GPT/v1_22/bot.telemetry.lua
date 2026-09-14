-- NEU BOT v1.22 live telemetry.
-- Based on the proven v1.20/v1.21 visualizer exporter, extended with squad routes.
local T={}
local N,C=nil,nil
local installed=false
local fileReady=false
local activePath=nil
local lastSnapshot=-1

local function esc(v) local s=tostring(v or '') return s:gsub('\\','\\\\'):gsub('"','\\"'):gsub('\r','\\r'):gsub('\n','\\n'):gsub('\t','\\t') end
local function q(v) return '"'..esc(v)..'"' end
local function num(v) return type(v)=='number' and tostring(v) or 'null' end
local function bool(v) return v and 'true' or 'false' end

local function paths()
 local mod=(NEU_BOT and NEU_BOT.ModFolder) or 'nobody except us 2.0.26'
 local out={}
 if NEU_BOT and NEU_BOT.TelemetryPath then out[#out+1]=NEU_BOT.TelemetryPath end
 out[#out+1]='mods\\'..mod..'\\resource\\script\\multiplayer\\telemetry\\bot_gpt_telemetry.jsonl'
 out[#out+1]='resource\\script\\multiplayer\\telemetry\\bot_gpt_telemetry.jsonl'
 out[#out+1]='bot_gpt_telemetry.jsonl'
 return out
end
local function openFile(mode)
 if activePath then local f=io.open(activePath,mode) if f then return f end end
 for _,p in ipairs(paths()) do local f=io.open(p,mode) if f then activePath=p return f end end
 return nil
end
local function append(line) local f=openFile('a') if not f then return false end f:write(line,'\n');f:flush();f:close();return true end

local function mapPoint(name)
 if not(name and N and N.MAP and N.MAP.loaded) then return nil end
 local p=N.MAP:point(name) if p and p.x and p.y then return {name=name,x=p.x,y=p.y,z=p.z} end
 return nil
end
local function pointJson(p)
 if not p or type(p.x)~='number' or type(p.y)~='number' then return 'null' end
 return '{"x":'..num(p.x)..',"y":'..num(p.y)..',"z":'..num(p.z)..',"kind":'..q(p.kind or '')..'}'
end
local function namedPointJson(name) local p=mapPoint(name) if not p then return 'null' end return '{"name":'..q(name)..',"x":'..num(p.x)..',"y":'..num(p.y)..'}' end
local function ownerName(o) if o==BotApi.Instance.team then return 'bot' elseif o==BotApi.Instance.enemyTeam then return 'enemy' end return 'neutral' end
local function aliveListJson(list) local a={} for _,sid in ipairs(list or {}) do if N.squadAlive(sid) then a[#a+1]=tostring(sid) end end return '['..table.concat(a,',')..']' end

local function observed(id)
 local adapter=rawget(_G,'NEU_TacticalAdapter')
 if type(adapter)~='table' or type(adapter.getSquad)~='function' then return nil end
 local ok,s=pcall(adapter.getSquad,id)
 if not ok or type(s)~='table' then return nil end
 local p=s.position or s.pos
 if type(p)=='table' and type(p.x)=='number' and type(p.y)=='number' then return {x=p.x,y=p.y,z=p.z} end
 return nil
end

local function pointsJson(list)
 local a={} for _,p in ipairs(list or {}) do a[#a+1]=pointJson(p) end return '['..table.concat(a,',')..']'
end
local function lanesJson(lanes)
 local out={}
 for _,lane in ipairs(lanes or {}) do
  out[#out+1]='{"member":'..num(lane.member)..',"stage":'..pointJson(lane.stage)..',"goal":'..pointJson(lane.goal)..',"points":'..pointsJson(lane.points)..'}'
 end
 return '['..table.concat(out,',')..']'
end

local function eventKind(msg)
 local s=tostring(msg or '')
 if s:find('MOVEPOINT',1,true) or s:find('ORDER',1,true) then return 'order' end
 if s:find('SPAWN',1,true) or s:find('QUEUE',1,true) or s:find('ARRIVED',1,true) then return 'spawn' end
 if s:find('CAPTURED',1,true) then return 'capture' end
 if s:find('LOST',1,true) then return 'loss' end
 if s:find('ASSAULT',1,true) or s:find('APPROACH',1,true) or s:find('ROUTE',1,true) then return 'decision' end
 if s:find('FAILED',1,true) or s:find('BLOCK',1,true) then return 'warning' end
 return 'info'
end
function T.event(msg) if fileReady then append('{"type":"event","time":'..num(C and C.Time or 0)..',"kind":'..q(eventKind(msg))..',"message":'..q(msg)..'}') end end

local function groupJson(id,g)
 local dest
 if g.phase=='assembling' then dest=g.rally or g.approach or g.target elseif g.phase=='approach' then dest=g.approach or g.target elseif g.phase=='attack' then dest=g.target else dest=g.rally or g.approach or g.target end
 return '{"id":'..num(id)..',"phase":'..q(g.phase or 'unknown')..',"target":'..q(g.target or '')..',"rally":'..namedPointJson(g.rally)..',"approach":'..namedPointJson(g.approach)..',"tankApproach":'..namedPointJson(g.tankApproach)..',"destination":'..namedPointJson(dest)..',"wave":'..num(g.wave or 0)..',"failCount":'..num(g.failCount or 0)..',"infantryCount":'..num(N.groupInfCount(g))..',"tankCount":'..num(N.aliveCount(g.tanks))..',"infantry":'..aliveListJson(g.infantry)..',"detached":'..aliveListJson(g.detached)..',"tanks":'..aliveListJson(g.tanks)..'}'
end

local function squadJson(id,role)
 local plan=C.NEU22Plans and C.NEU22Plans[id] or nil local last=C.LastOrder and C.LastOrder[id] or nil local obs=observed(id)
 local lastj='null' if last and type(last.x)=='number' and type(last.y)=='number' then lastj=pointJson(last) end
 local obsj=obs and pointJson(obs) or 'null'
 local planj='null'
 if plan then
  planj='{"target":'..q(plan.target or '')..',"spawn":'..pointJson(plan.spawn)..',"targetPoint":'..pointJson(plan.targetPoint)..',"points":'..pointsJson(plan.points)..',"carrierGoal":'..pointJson(plan.carrierGoal)..',"carrierPoints":'..pointsJson(plan.carrierPoints)..',"lanes":'..lanesJson(plan.lanes)..'}'
 end
 return '{"id":'..num(id)..',"groupId":'..num(C.SquadGroup[id])..',"role":'..q(role or '')..',"alive":'..bool(N.squadAlive(id))..',"observed":'..obsj..',"lastCommand":'..lastj..',"plan":'..planj..'}'
end

function T.snapshot()
 if not(N and C and fileReady) then return end
 local flags={}
 for _,f in pairs(BotApi.Scene.Flags or {}) do local p=mapPoint(f.name) flags[#flags+1]='{"name":'..q(f.name)..',"owner":'..q(ownerName(f.occupant))..',"x":'..num(p and p.x)..',"y":'..num(p and p.y)..'}' end
 table.sort(flags)
 local groups={} for id,g in pairs(C.Groups or {}) do groups[#groups+1]=groupJson(id,g) end table.sort(groups)
 local squads={} for id,role in pairs(C.SquadRole or {}) do if N.squadAlive(id) then squads[#squads+1]=squadJson(id,role) end end table.sort(squads)
 local spawn='null' if N.MAP and N.MAP.spawn then spawn=pointJson(N.MAP.spawn) end
 local f=N.flags()
 append('{"type":"snapshot","version":"1.22","time":'..num(C.Time or 0)..',"map":'..q((N.MAP and N.MAP.mapKey) or 'unknown')..',"mapLoaded":'..bool(N.MAP and N.MAP.loaded)..',"team":'..q(BotApi.Instance.team)..',"enemyTeam":'..q(BotApi.Instance.enemyTeam)..',"attackUnlocked":'..bool(C.AttackUnlocked)..',"flagsMine":'..num(f.mineCount)..',"flagsEnemy":'..num(f.enemyCount)..',"flagsNeutral":'..num(f.neutralCount)..',"spawn":'..spawn..',"flags":['..table.concat(flags,',')..'],"groups":['..table.concat(groups,',')..'],"squads":['..table.concat(squads,',')..']}')
end

function T.onQuant()
 if not C then return end local t=C.Time or 0
 local step=(NEU_BOT and NEU_BOT.TelemetrySnapshotSec) or 1
 if lastSnapshot<0 or t-lastSnapshot>=step then lastSnapshot=t T.snapshot() end
end

function T.install(core)
 if installed then return T end installed=true N=core C=N.C
 if NEU_BOT.TelemetryEnabled==false then return T end
 local f=openFile('w')
 if f then f:write('{"type":"session","version":"1.22","time":0,"path":'..q(activePath)..'}\n');f:flush();f:close();fileReady=true end
 local baseLog=N.log
 function N.log(m) baseLog(m) T.event(m) end
 if fileReady then baseLog('TELEMETRY v1.22 ACTIVE path='..tostring(activePath)) else baseLog('TELEMETRY DISABLED: cannot create bot_gpt_telemetry.jsonl') end
 return T
end
return T
