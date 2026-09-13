-- NEU BOT v1.21.5 targeted/silent position API diagnostic
-- Goal: discover squad -> unit/entity -> position access without calling unknown native methods.
-- IMPORTANT: no os.execute/cmd calls. Read-only introspection only.

local D={}
local N=nil
local C=nil
local installed=false
local ranAt={}

local MOD_FOLDER=(NEU_BOT and NEU_BOT.ModFolder) or "nobody except us 2.0.26"
local DIR="mods\\"..MOD_FOLDER.."\\resource\\script\\multiplayer\\telemetry"
local PATH=DIR.."\\bot_position_api_diag.jsonl"

local function esc(v)
 local s=tostring(v or "")
 s=s:gsub("\\","\\\\"):gsub('"','\\"'):gsub("\r","\\r"):gsub("\n","\\n"):gsub("\t","\\t")
 return s
end
local function q(v) return '"'..esc(v)..'"' end
local function append(kind,name,data)
 local f=io.open(PATH,"a")
 if not f then return false end
 f:write('{"type":"posdiag","time":'..tostring((C and C.Time) or 0)..',"kind":'..q(kind)..',"name":'..q(name)..',"data":'..q(data)..'}\n')
 f:flush(); f:close(); return true
end
local function describe(v)
 local t=type(v)
 if t=="nil" or t=="number" or t=="boolean" or t=="string" then return t..":"..tostring(v) end
 local ok,s=pcall(tostring,v)
 return t..":"..(ok and s or "<tostring error>")
end
local function safeGet(o,k)
 local ok,v=pcall(function() return o and o[k] end)
 return ok,v
end
local function dumpTable(label,t,maxn)
 if type(t)~="table" then append("table",label,describe(t)); return end
 local a={}; local n=0
 for k,v in pairs(t) do
  n=n+1
  if n>(maxn or 200) then a[#a+1]="..."; break end
  a[#a+1]=tostring(k)..":"..type(v)
 end
 table.sort(a)
 append("table_keys",label,table.concat(a,"|"))
end
local function dumpMeta(label,o)
 local ok,m=pcall(getmetatable,o)
 if not ok then append("meta_error",label,tostring(m)); return end
 append("meta",label,describe(m))
 if type(m)~="table" then return end
 dumpTable(label..".<meta>",m,250)
 for _,sub in ipairs({"__propget","__propset","__const","__index"}) do
  local v=m[sub]
  if type(v)=="table" then dumpTable(label.."."..sub,v,300)
  elseif v~=nil then append("meta_member",label.."."..sub,describe(v)) end
 end
end
local function dumpObject(label,o)
 append("object",label,describe(o))
 if type(o)=="table" then dumpTable(label,o,300) end
 if o~=nil then dumpMeta(label,o) end
end
local INTEREST={
 "position","pos","center","coord","coords","coordinate","location","point",
 "entity","entities","actor","actors","unit","units","squad","squads","member","members",
 "vehicle","vehicles","human","humans","soldier","soldiers","object","objects",
 "getposition","getsquad","getunit","getentity","getactor","getcenter","scene"
}
local function interestingName(s)
 s=string.lower(tostring(s or ""))
 for _,p in ipairs(INTEREST) do if string.find(s,p,1,true) then return true end end
 return false
end
local function scanGlobalApis()
 local out={}; local n=0
 for k,v in pairs(_G or {}) do
  if interestingName(k) then
   n=n+1
   out[#out+1]=tostring(k)..":"..type(v)
   if n>=250 then break end
  end
 end
 table.sort(out)
 append("global_candidates","_G",table.concat(out,"|"))
end
local function scanBotApiClassTables()
 if not BotApi then return end
 for _,name in ipairs({"Bot","BotScene","BotCommands","BotEvent","BotEvents"}) do
  local ok,v=safeGet(BotApi,name)
  if ok and v~=nil then dumpObject("BotApi."..name,v) end
 end
 for _,name in ipairs({"Instance","Scene","Commands","Events"}) do
  local ok,v=safeGet(BotApi,name)
  if ok and v~=nil then dumpObject("BotApi."..name,v) end
 end
end
local function scanKnownSquads()
 local ok,arr=safeGet(BotApi and BotApi.Scene,"Squads")
 if not ok or type(arr)~="table" then append("squads","Scene.Squads",describe(arr)); return end
 local ids={}
 for _,sid in pairs(arr) do if type(sid)=="number" then ids[#ids+1]=sid end end
 table.sort(ids)
 local sample={}; for i=1,math.min(#ids,30) do sample[#sample+1]=tostring(ids[i]) end
 append("squad_ids","Scene.Squads",table.concat(sample,","))
 if C and C.SquadRole then
  local own={}; for sid,role in pairs(C.SquadRole) do own[#own+1]=tostring(sid)..":"..tostring(role) end
  table.sort(own); append("known_own_squads","C.SquadRole",table.concat(own,"|"))
 end
end
local function scanLikelyFields()
 local roots={
  {"BotApi",BotApi},
  {"BotApi.Scene",BotApi and BotApi.Scene},
  {"BotApi.Commands",BotApi and BotApi.Commands},
  {"BotApi.Instance",BotApi and BotApi.Instance}
 }
 local fields={"Position","position","Pos","pos","GetPosition","GetSquadPosition","GetUnitPosition","GetEntityPosition","GetCenter","Squad","Squads","Units","Entities","Actors","Vehicles","Humans","Objects","Players","Teams"}
 for _,r in ipairs(roots) do
  local a={}
  for _,k in ipairs(fields) do
   local ok,v=safeGet(r[2],k)
   if ok and v~=nil then a[#a+1]=k.."="..describe(v) end
  end
  if #a>0 then append("likely_fields",r[1],table.concat(a,"|")) end
 end
end
function D.run(tag)
 append("run","START",tostring(tag or "manual"))
 scanBotApiClassTables()
 scanLikelyFields()
 scanKnownSquads()
 scanGlobalApis()
 append("run","END",tostring(tag or "manual"))
end
function D.onTick()
 if not C then return end
 local t=C.Time or 0
 for _,at in ipairs({5,30}) do
  if t>=at and not ranAt[at] then ranAt[at]=true; D.run("t="..at) end
 end
end
function D.install(core)
 if installed then return D end
 installed=true; N=core; C=N.C
 local f=io.open(PATH,"w")
 if f then f:write('{"type":"session","version":"1.21.5-targeted-diagnostic","time":0}\n'); f:close() end
 local base=N.processSpawn
 function N.processSpawn(...)
  local r=base(...)
  D.onTick()
  return r
 end
 if N.log then N.log('POSITION API DIAG v1.21.5 ACTIVE path='..PATH) end
 return D
end
return D
