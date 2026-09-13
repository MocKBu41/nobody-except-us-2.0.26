-- NEU BOT v1.21.7 actor/entity position diagnostic
-- Read-only diagnostics. No os.execute/cmd and no calls to unknown native functions.

local D={}
local N=nil
local C=nil
local installed=false
local ranAt={}

local MOD_FOLDER=(NEU_BOT and NEU_BOT.ModFolder) or "nobody except us 2.0.26"
local PATH="mods\\"..MOD_FOLDER.."\\resource\\script\\multiplayer\\telemetry\\bot_actor_entity_diag.jsonl"

local function esc(v)
 local s=tostring(v or "")
 s=s:gsub("\\","\\\\"):gsub('"','\\"'):gsub("\r","\\r"):gsub("\n","\\n"):gsub("\t","\\t")
 return s
end
local function q(v) return '"'..esc(v)..'"' end
local function append(kind,name,data)
 local f=io.open(PATH,"a")
 if not f then return false end
 f:write('{"type":"actor_entity_diag","time":'..tostring((C and C.Time) or 0)..',"kind":'..q(kind)..',"name":'..q(name)..',"data":'..q(data)..'}\n')
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

local PAT={"actor","entity","unit","squad","scene","object","position","pos","coord","transform","matrix","world","game","human","vehicle","member"}
local FIELDS={"id","ID","actorId","actorID","actor_id","entityId","entityID","entity_id","squadId","squadID","squad_id","x","y","z","pos","Pos","position","Position","center","Center","location","Location","matrix","Matrix","transform","Transform","entity","Entity","actor","Actor","unit","Unit","squad","Squad","members","Members","units","Units","humans","Humans","vehicles","Vehicles","objects","Objects"}
local function interesting(s)
 s=string.lower(tostring(s or ""))
 for _,p in ipairs(PAT) do if string.find(s,p,1,true) then return true end end
 return false
end
local function interestingMethod(s)
 s=string.lower(tostring(s or ""))
 return interesting(s) or string.find(s,"get",1,true)~=nil or string.find(s,"find",1,true)~=nil or string.find(s,"lookup",1,true)~=nil
end

local function probeFields(label,o)
 if o==nil then return end
 local out={}
 for _,k in ipairs(FIELDS) do
  local ok,v=safeGet(o,k)
  if ok and v~=nil then out[#out+1]=k.."="..describe(v) end
 end
 if #out>0 then append("fields",label,table.concat(out,"|")) end
end

local function dumpMeta(label,o)
 local ok,m=pcall(getmetatable,o)
 if not ok or m==nil then return end
 append("meta",label,describe(m))
 if type(m)~="table" then return end
 local out={}; local n=0
 for k,v in pairs(m) do
  if interestingMethod(k) or k=="__index" or k=="__propget" or k=="__const" then
   n=n+1; out[#out+1]=tostring(k)..":"..type(v)
   if n>=160 then break end
  end
 end
 table.sort(out)
 if #out>0 then append("meta_keys",label,table.concat(out,"|")) end
 for _,sub in ipairs({"__index","__propget","__const"}) do
  local v=m[sub]
  if type(v)=="table" then
   local a={}; local c=0
   for k,x in pairs(v) do
    if interestingMethod(k) then c=c+1; a[#a+1]=tostring(k)..":"..type(x); if c>=180 then break end end
   end
   table.sort(a)
   if #a>0 then append("meta_"..sub,label,table.concat(a,"|")) end
  end
 end
end

local seen={}
local function inspectTable(label,t,depth)
 if type(t)~="table" or depth>2 or seen[t] then return end
 seen[t]=true
 local out={}; local n=0
 for k,v in pairs(t) do
  if interesting(k) or interesting(describe(v)) then
   n=n+1
   out[#out+1]=tostring(k).."="..describe(v)
   probeFields(label.."["..tostring(k).."]",v)
   dumpMeta(label.."["..tostring(k).."]",v)
   if type(v)=="table" and depth<2 then inspectTable(label.."."..tostring(k),v,depth+1) end
   if n>=120 then break end
  end
 end
 table.sort(out)
 if #out>0 then append("table_candidates",label,table.concat(out,"|")) end
end

local function scanGlobals()
 seen={}
 local out={}; local n=0
 for k,v in pairs(_G or {}) do
  if interesting(k) then
   n=n+1; out[#out+1]=tostring(k).."="..describe(v)
   probeFields("_G."..tostring(k),v)
   dumpMeta("_G."..tostring(k),v)
   if type(v)=="table" then inspectTable("_G."..tostring(k),v,1) end
   if n>=180 then break end
  end
 end
 table.sort(out)
 append("globals","_G",table.concat(out,"|"))
end

local function scanPackageLoaded()
 if not package or type(package.loaded)~="table" then return end
 local out={}; local n=0
 for k,v in pairs(package.loaded) do
  if interesting(k) or interesting(describe(v)) then
   n=n+1; out[#out+1]=tostring(k).."="..describe(v)
   probeFields("package.loaded."..tostring(k),v)
   dumpMeta("package.loaded."..tostring(k),v)
   if type(v)=="table" then inspectTable("package.loaded."..tostring(k),v,1) end
   if n>=120 then break end
  end
 end
 table.sort(out)
 if #out>0 then append("package_loaded","package.loaded",table.concat(out,"|")) end
end

local function scanRegistry()
 if not debug or type(debug.getregistry)~="function" then append("registry","status","unavailable"); return end
 local ok,r=pcall(debug.getregistry)
 if not ok or type(r)~="table" then append("registry","status",describe(r)); return end
 append("registry","status","available")
 local out={}; local n=0
 for k,v in pairs(r) do
  local ks=tostring(k)
  if interesting(ks) or interesting(describe(v)) then
   n=n+1; out[#out+1]=ks.."="..describe(v)
   probeFields("registry["..ks.."]",v)
   dumpMeta("registry["..ks.."]",v)
   if type(v)=="table" then
    local methods={}; local c=0
    for mk,mv in pairs(v) do
     if interestingMethod(mk) then c=c+1; methods[#methods+1]=tostring(mk)..":"..type(mv); if c>=160 then break end end
    end
    table.sort(methods)
    if #methods>0 then append("registry_methods",ks,table.concat(methods,"|")) end
   end
   if n>=260 then break end
  end
 end
 table.sort(out)
 append("registry_candidates","registry",table.concat(out,"|"))
end

local function collectOwnIds()
 local ids={}
 if C and type(C.SquadRole)=="table" then for sid,_ in pairs(C.SquadRole) do if type(sid)=="number" then ids[#ids+1]=sid end end end
 table.sort(ids)
 while #ids>16 do table.remove(ids) end
 return ids
end

local function scanKnownContainers()
 local ids=collectOwnIds()
 local roots={
  {"BotApi.Scene",BotApi and BotApi.Scene},
  {"BotApi.Instance",BotApi and BotApi.Instance},
  {"BotApi",BotApi}
 }
 local names={"Actors","actors","Entities","entities","Units","units","Objects","objects","Humans","humans","Vehicles","vehicles","Squads","squads"}
 for _,r in ipairs(roots) do
  for _,name in ipairs(names) do
   local ok,container=safeGet(r[2],name)
   if ok and container~=nil then
    append("container",r[1].."."..name,describe(container))
    probeFields(r[1].."."..name,container)
    dumpMeta(r[1].."."..name,container)
    if type(container)=="table" then
     for _,sid in ipairs(ids) do
      for _,key in ipairs({sid,sid+1,tostring(sid)}) do
       local gok,v=safeGet(container,key)
       if gok and v~=nil then
        append("squad_lookup",r[1].."."..name.."["..tostring(key).."]","squad="..tostring(sid).." value="..describe(v))
        probeFields("lookup.squad."..tostring(sid),v)
        dumpMeta("lookup.squad."..tostring(sid),v)
       end
      end
     end
    end
   end
  end
 end
end

local function scanBotApiDeep()
 if not BotApi then append("botapi","status","nil"); return end
 for _,name in ipairs({"Bot","BotScene","BotCommands","BotEvent","BotEvents","Instance","Scene","Commands","Events"}) do
  local ok,v=safeGet(BotApi,name)
  if ok and v~=nil then
   append("botapi_object","BotApi."..name,describe(v))
   probeFields("BotApi."..name,v)
   dumpMeta("BotApi."..name,v)
   if type(v)=="table" then inspectTable("BotApi."..name,v,1) end
  end
 end
end

function D.run(tag)
 append("run","START",tostring(tag or "manual"))
 scanBotApiDeep()
 scanKnownContainers()
 scanGlobals()
 scanPackageLoaded()
 scanRegistry()
 local ids=collectOwnIds(); local a={}; for _,v in ipairs(ids) do a[#a+1]=tostring(v) end
 append("known_squads","C.SquadRole",table.concat(a,","))
 append("run","END",tostring(tag or "manual"))
end

function D.onTick()
 if not C then return end
 local t=C.Time or 0
 for _,at in ipairs({8,30,60}) do
  if t>=at and not ranAt[at] then ranAt[at]=true; D.run("t="..at) end
 end
end

function D.install(core)
 if installed then return D end
 installed=true; N=core; C=N.C
 local f=io.open(PATH,"w")
 if f then f:write('{"type":"session","version":"1.21.7-actor-entity-diagnostic","time":0}\n'); f:close() end
 local base=N.processSpawn
 function N.processSpawn(...)
  local r=base(...)
  D.onTick()
  return r
 end
 if N.log then N.log('ACTOR/ENTITY POSITION DIAG v1.21.7 ACTIVE path='..PATH) end
 return D
end
return D
