-- NEU BOT v1.21.4 diagnostic position probe
-- Purpose: discover a READ-ONLY path to real unit/squad coordinates without calling unknown native methods.

local D={}
local N=nil
local C=nil
local installed=false
local ranAt={}

local MOD_FOLDER=(NEU_BOT and NEU_BOT.ModFolder) or "nobody except us 2.0.26"
local DIR="mods\\"..MOD_FOLDER.."\\resource\\script\\multiplayer\\telemetry"
local PATH=DIR.."\\bot_api_diag.jsonl"

local function esc(v)
 local s=tostring(v or "")
 s=s:gsub("\\","\\\\"):gsub('"','\\"'):gsub("\r","\\r"):gsub("\n","\\n"):gsub("\t","\\t")
 return s
end
local function q(v) return '"'..esc(v)..'"' end
local function ensureDir()
 if os and os.execute then pcall(os.execute,'if not exist "'..DIR..'" mkdir "'..DIR..'"') end
end
local function append(kind,name,data)
 ensureDir()
 local f=io.open(PATH,"a")
 if not f then return end
 f:write('{"type":"diag","time":'..tostring((C and C.Time) or 0)..',"kind":'..q(kind)..',"name":'..q(name)..',"data":'..q(data)..'}\n')
 f:flush(); f:close()
end
local function safeGet(o,k)
 local ok,v=pcall(function() return o and o[k] end)
 if ok then return true,v end
 return false,v
end
local function describe(v)
 local t=type(v)
 if t=="nil" or t=="number" or t=="boolean" or t=="string" then return t..":"..tostring(v) end
 local ok,s=pcall(tostring,v)
 return t..":"..(ok and s or "<tostring error>")
end
local function metaKeys(label,o)
 local ok,m=pcall(getmetatable,o)
 if not ok then append("meta_error",label,tostring(m)); return end
 append("meta",label,describe(m))
 if type(m)=="table" then
  local keys={}; local n=0
  for k,v in pairs(m) do n=n+1; if n>80 then break end; keys[#keys+1]=tostring(k)..":"..type(v) end
  table.sort(keys); append("meta_keys",label,table.concat(keys,"|"))
  local idx=m.__index
  if type(idx)=="table" then
   local ik={}; n=0
   for k,v in pairs(idx) do n=n+1; if n>120 then break end; ik[#ik+1]=tostring(k)..":"..type(v) end
   table.sort(ik); append("index_keys",label,table.concat(ik,"|"))
  else
   append("index",label,describe(idx))
  end
 end
end
local FIELD_CANDIDATES={
 "x","y","z","pos","position","center","location","coords","coordinate","point",
 "id","squadId","unitId","entityId","name","team","army","side","owner","role","type",
 "entity","unit","actor","vehicle","members","units","soldiers","objects"
}
local function probeFields(label,o)
 if o==nil then return end
 local out={}
 for _,k in ipairs(FIELD_CANDIDATES) do
  local ok,v=safeGet(o,k)
  if ok and v~=nil then out[#out+1]=k.."="..describe(v) end
 end
 if #out>0 then append("fields",label,table.concat(out,"|")) end
 metaKeys(label,o)
end
local function iterate(label,coll,maxn)
 maxn=maxn or 12
 if coll==nil then append("collection",label,"nil"); return end
 append("collection",label,describe(coll))
 metaKeys(label,coll)
 local ok,err=pcall(function()
  local n=0
  for k,v in pairs(coll) do
   n=n+1
   append("item",label.."["..tostring(k).."]","key="..describe(k).." value="..describe(v))
   if type(v)=="table" or type(v)=="userdata" then probeFields(label..".value"..n,v) end
   -- Some GEM collections enumerate squad IDs as scalar values. Try read-only indexing by key and by value.
   local okK,byK=safeGet(coll,k)
   if okK and byK~=nil and byK~=v then
    append("index_by_key",label.."["..tostring(k).."]",describe(byK))
    if type(byK)=="table" or type(byK)=="userdata" then probeFields(label..".byKey"..n,byK) end
   end
   if type(v)=="number" or type(v)=="string" then
    local okV,byV=safeGet(coll,v)
    if okV and byV~=nil and byV~=v then
     append("index_by_value",label.."["..tostring(v).."]",describe(byV))
     if type(byV)=="table" or type(byV)=="userdata" then probeFields(label..".byValue"..n,byV) end
    end
   end
   if n>=maxn then break end
  end
  append("collection_count_sampled",label,tostring(n))
 end)
 if not ok then append("iterate_error",label,tostring(err)) end
end
local function probeSceneField(name)
 local ok,v=safeGet(BotApi.Scene,name)
 if not ok then append("scene_field_error",name,tostring(v)); return end
 if v~=nil then
  append("scene_field",name,describe(v))
  if type(v)=="table" or type(v)=="userdata" then iterate("Scene."..name,v,12) end
 end
end
local function probeRoot(label,o)
 append("root",label,describe(o)); metaKeys(label,o); probeFields(label,o)
end
function D.run(tag)
 append("run","START",tostring(tag or "manual"))
 probeRoot("BotApi",BotApi)
 probeRoot("BotApi.Scene",BotApi and BotApi.Scene)
 probeRoot("BotApi.Commands",BotApi and BotApi.Commands)
 local names={"Squads","OwnSquads","EnemySquads","EnemyUnits","Units","Entities","Actors","Vehicles","Humans","Objects","Soldiers","Players","Teams","Flags"}
 for _,name in ipairs(names) do probeSceneField(name) end
 -- Probe known own squad IDs against Scene and likely containers without calling functions.
 if C and C.SquadRole then
  local count=0
  for sid,role in pairs(C.SquadRole) do
   count=count+1
   append("known_squad","sid="..tostring(sid),"role="..tostring(role))
   for _,containerName in ipairs({"Squads","OwnSquads","Units","Entities","Actors","Vehicles"}) do
    local okC,coll=safeGet(BotApi.Scene,containerName)
    if okC and coll~=nil then
     local okO,obj=safeGet(coll,sid)
     if okO and obj~=nil then
      append("known_lookup",containerName.."["..tostring(sid).."]",describe(obj))
      if type(obj)=="table" or type(obj)=="userdata" then probeFields(containerName..".sid"..tostring(sid),obj) end
     end
    end
   end
   if count>=8 then break end
  end
 end
 append("run","END",tostring(tag or "manual"))
end
function D.onTick()
 if not C then return end
 local t=C.Time or 0
 for _,at in ipairs({3,15,60}) do
  if t>=at and not ranAt[at] then ranAt[at]=true; D.run("t="..at) end
 end
end
function D.install(core)
 if installed then return D end
 installed=true; N=core; C=N.C
 ensureDir()
 local f=io.open(PATH,"w")
 if f then f:write('{"type":"session","version":"1.21.4-diagnostic","time":0}\n'); f:close() end
 local base=N.processSpawn
 function N.processSpawn(...)
  local r=base(...)
  D.onTick()
  return r
 end
 if N.log then N.log('POSITION DIAG v1.21.4 ACTIVE path='..PATH) end
 return D
end
return D
