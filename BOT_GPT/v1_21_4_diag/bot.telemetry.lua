-- NEU BOT v1.21.3 telemetry exporter
-- v1.21.3 separates ACTUAL scene positions from bot orders/destinations.

local T={}
local N=nil
local C=nil
local installed=false
local lastSnapshot=-1
local fileReady=false

local MOD_FOLDER=(NEU_BOT and NEU_BOT.ModFolder) or "nobody except us 2.0.26"
local TELEMETRY_DIR="mods\\"..MOD_FOLDER.."\\resource\\script\\multiplayer\\telemetry"
local TELEMETRY_PATH=TELEMETRY_DIR.."\\bot_gpt_telemetry.jsonl"

local function esc(v)
 local s=tostring(v or "")
 s=s:gsub("\\","\\\\"):gsub('"','\\"'):gsub("\r","\\r"):gsub("\n","\\n"):gsub("\t","\\t")
 return s
end
local function q(v) return '"'..esc(v)..'"' end
local function bool(v) return v and "true" or "false" end
local function num(v) return type(v)=="number" and tostring(v) or "null" end

local function ensureDir()
 if os and os.execute then pcall(os.execute,'if not exist "'..TELEMETRY_DIR..'" mkdir "'..TELEMETRY_DIR..'"') end
end
local function openFile(mode)
 local f=io.open(TELEMETRY_PATH,mode)
 if f then return f end
 ensureDir()
 return io.open(TELEMETRY_PATH,mode)
end
local function append(line)
 local f=openFile("a")
 if not f then return false end
 f:write(line,"\n"); f:flush(); f:close(); return true
end
local function point(name)
 if not name or not N or not N.MAP or not N.MAP.loaded then return nil end
 local p=N.MAP:point(name)
 if not p then return nil end
 return {name=name,x=p.x,y=p.y}
end
local function pointJson(name)
 local p=point(name)
 if not p then return "null" end
 return '{"name":'..q(p.name)..',"x":'..num(p.x)..',"y":'..num(p.y)..'}'
end
local function ownerName(o)
 if o==BotApi.Instance.team then return "bot" end
 if o==BotApi.Instance.enemyTeam then return "player" end
 return "neutral"
end
local function aliveListJson(list)
 local out={}
 for _,sid in ipairs(list or {}) do if N.squadAlive(sid) then out[#out+1]=tostring(sid) end end
 return '['..table.concat(out,',')..']'
end
local function eventKind(msg)
 local s=tostring(msg or "")
 if s:find("ORDER",1,true) then return "order" end
 if s:find("SPAWN",1,true) or s:find("QUEUE",1,true) or s:find("ARRIVED",1,true) then return "spawn" end
 if s:find("CAPTURED",1,true) then return "capture" end
 if s:find("LOST",1,true) then return "loss" end
 if s:find("ASSAULT",1,true) or s:find("APPROACH",1,true) or s:find("ROUTE",1,true) then return "decision" end
 if s:find("AIR ",1,true) or s:find("art",1,true) or s:find("support",1,true) then return "support" end
 if s:find("FAILED",1,true) or s:find("BLOCK",1,true) then return "warning" end
 return "info"
end

local function safeField(o,k)
 local ok,v=pcall(function() return o and o[k] end)
 if ok then return v end
 return nil
end
local function readXY(o)
 if not o then return nil,nil end
 local p=safeField(o,"position") or safeField(o,"pos") or safeField(o,"center") or o
 local x=safeField(p,"x")
 local y=safeField(p,"y")
 local z=safeField(p,"z")
 if type(x)=="number" and type(y)=="number" then return x,y end
 if type(x)=="number" and type(z)=="number" then return x,z end
 return nil,nil
end
local function unitId(o,fallback)
 return safeField(o,"squadId") or safeField(o,"id") or safeField(o,"name") or fallback
end
local function sceneCollection(name)
 local ok,v=pcall(function() return BotApi.Scene and BotApi.Scene[name] end)
 if ok then return v end
 return nil
end
local function collectFrom(name,side,out,seen)
 local coll=sceneCollection(name)
 if type(coll)~="table" then return 0 end
 local n=0
 for k,v in pairs(coll) do
  local tv=type(v)
  if tv=="table" or tv=="userdata" then
   local x,y=readXY(v)
   if x and y then
    local id=unitId(v,k)
    local key=side..":"..tostring(id)..":"..tostring(x)..":"..tostring(y)
    if not seen[key] then
     seen[key]=true
     local role=(side=="bot" and C and C.SquadRole and C.SquadRole[id]) or safeField(v,"role") or safeField(v,"type") or "unknown"
     local group=(side=="bot" and C and C.SquadGroup and C.SquadGroup[id]) or safeField(v,"groupId")
     out[#out+1]='{"id":'..q(id)..',"side":'..q(side)..',"role":'..q(role)..',"group":'..num(group)..',"x":'..num(x)..',"y":'..num(y)..',"source":'..q("Scene."..name)..'}'
     n=n+1
    end
   end
  end
 end
 return n
end
local function actualUnitsJson()
 local out,seen={},{}
 -- Read-only probes only. No unknown native methods are called.
 collectFrom("Squads","bot",out,seen)
 collectFrom("OwnSquads","bot",out,seen)
 collectFrom("EnemySquads","player",out,seen)
 collectFrom("EnemyUnits","player",out,seen)
 collectFrom("Units","unknown",out,seen)
 collectFrom("Entities","unknown",out,seen)
 return '['..table.concat(out,',')..']',#out
end

function T.event(msg)
 if not fileReady then return end
 append('{"type":"event","time":'..num(C and C.Time or 0)..',"kind":'..q(eventKind(msg))..',"message":'..q(msg)..'}')
end

function T.snapshot()
 if not N or not C or not fileReady then return false end
 local flags={}
 for _,f in pairs(BotApi.Scene.Flags or {}) do
  local p=point(f.name)
  flags[#flags+1]='{"name":'..q(f.name)..',"owner":'..q(ownerName(f.occupant))..',"x":'..num(p and p.x)..',"y":'..num(p and p.y)..'}'
 end
 table.sort(flags)
 local groups={}
 for id,g in pairs(C.Groups or {}) do
  local dest=nil
  if g.phase=="assembling" then dest=g.rally or g.approach or g.target
  elseif g.phase=="approach" then dest=g.approach or g.target
  elseif g.phase=="attack" then dest=g.target
  else dest=g.rally or g.approach or g.target end
  groups[#groups+1]='{"id":'..num(id)..',"phase":'..q(g.phase or "unknown")..',"target":'..q(g.target or "")..',"rally":'..pointJson(g.rally)..',"approach":'..pointJson(g.approach)..',"tankApproach":'..pointJson(g.tankApproach)..',"destination":'..pointJson(dest)..',"wave":'..num(g.wave or 0)..',"failCount":'..num(g.failCount or 0)..',"infantryCount":'..num(N.groupInfCount(g))..',"tankCount":'..num(N.aliveCount(g.tanks))..',"infantry":'..aliveListJson(g.infantry)..',"detached":'..aliveListJson(g.detached)..',"tanks":'..aliveListJson(g.tanks)..'}'
 end
 table.sort(groups)
 local f=N.flags()
 local spawn="null"
 if N.MAP and N.MAP.spawn then spawn='{"x":'..num(N.MAP.spawn.x)..',"y":'..num(N.MAP.spawn.y)..'}' end
 local mapKey=(N.MAP and N.MAP.mapKey) or "unknown"
 local nextAir=C.NextAircraftAllowedAt or 0
 local actualUnits,actualCount=actualUnitsJson()
 local json='{"type":"snapshot","version":"1.21.3","time":'..num(C.Time or 0)..',"map":'..q(mapKey)..',"team":'..q(BotApi.Instance.team)..',"enemyTeam":'..q(BotApi.Instance.enemyTeam)..',"attackUnlocked":'..bool(C.AttackUnlocked)..',"neutralsCleared":'..bool(C.NeutralsCleared)..',"flagsMine":'..num(f.mineCount)..',"flagsEnemy":'..num(f.enemyCount)..',"flagsNeutral":'..num(f.neutralCount)..',"airCooldownRemaining":'..num(math.max(0,nextAir-(C.Time or 0)))..',"spawn":'..spawn..',"actualPositionCount":'..num(actualCount)..',"flags":['..table.concat(flags,',')..'],"groups":['..table.concat(groups,',')..'],"units":'..actualUnits..'}'
 return append(json)
end

function T.onBotTick()
 if not C or not fileReady then return end
 local t=C.Time or 0
 if t~=lastSnapshot then lastSnapshot=t T.snapshot() end
end
function T.onQuant() T.onBotTick() end

function T.install(core)
 if installed then return T end
 installed=true; N=core; C=N.C; N.Telemetry=T
 NEU_BOT=NEU_BOT or {}
 if NEU_BOT.TelemetryEnabled==nil then NEU_BOT.TelemetryEnabled=true end
 if not NEU_BOT.TelemetryEnabled then return T end
 ensureDir()
 local f=openFile("w")
 if f then f:write('{"type":"session","version":"1.21.3","time":0,"path":'..q(TELEMETRY_PATH)..'}\n'); f:flush(); f:close(); fileReady=true end
 local baseLog=N.log
 function N.log(m) baseLog(m); if fileReady then T.event(m) end end
 local baseProcessSpawn=N.processSpawn
 function N.processSpawn(...)
  local r=baseProcessSpawn(...)
  T.onBotTick()
  return r
 end
 if fileReady then
  baseLog('TELEMETRY v1.21.3 ACTIVE FIXED_PATH='..TELEMETRY_PATH)
  baseLog('TELEMETRY v1.21.3 ACTUAL POSITION PROBE=READ_ONLY_SCENE_FIELDS')
 else
  baseLog('TELEMETRY v1.21.3 ERROR cannot create FIXED_PATH='..TELEMETRY_PATH)
 end
 return T
end

return T
