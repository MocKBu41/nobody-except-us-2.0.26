-- NEU BOT v1.8 map knowledge
-- Reads cleaned flag geometry from _flag_points_final.json.
-- Optional _map_points_index.json supplies A/B spawn marker geometry.

NEU_MAPDATA = NEU_MAPDATA or {}
local M = NEU_MAPDATA
M.loaded=false
M.mapKey=nil
M.flags={}
M.spawn=nil
M.source=nil
M.spawnSource=nil

local function lower(s) return string.lower(tostring(s or "")) end
local function log(s) print("[NEU-BOT] MAP "..tostring(s)) end

local function jsonDecode(text)
    local i,n=1,#text
    local function ws()
        while i<=n do
            local c=text:sub(i,i)
            if c==" " or c=="\t" or c=="\r" or c=="\n" then i=i+1 else break end
        end
    end
    local value
    local function str()
        i=i+1
        local out={}
        while i<=n do
            local c=text:sub(i,i)
            if c=='"' then i=i+1 return table.concat(out) end
            if c=='\\' then
                i=i+1
                local e=text:sub(i,i)
                local map={['"']='"',['\\']='\\',['/']='/',b='\b',f='\f',n='\n',r='\r',t='\t'}
                if e=='u' then
                    local h=text:sub(i+1,i+4)
                    local cp=tonumber(h,16) or 63
                    if cp<128 then out[#out+1]=string.char(cp) else out[#out+1]='?' end
                    i=i+5
                else
                    out[#out+1]=map[e] or e
                    i=i+1
                end
            else
                out[#out+1]=c i=i+1
            end
        end
        error("unterminated string")
    end
    local function arr()
        i=i+1 ws()
        local a={}
        if text:sub(i,i)==']' then i=i+1 return a end
        while i<=n do
            a[#a+1]=value() ws()
            local c=text:sub(i,i)
            if c==']' then i=i+1 return a end
            if c~=',' then error("expected , or ] at "..i) end
            i=i+1 ws()
        end
        error("unterminated array")
    end
    local function obj()
        i=i+1 ws()
        local o={}
        if text:sub(i,i)=='}' then i=i+1 return o end
        while i<=n do
            if text:sub(i,i)~='"' then error("expected key at "..i) end
            local k=str() ws()
            if text:sub(i,i)~=':' then error("expected : at "..i) end
            i=i+1 ws() o[k]=value() ws()
            local c=text:sub(i,i)
            if c=='}' then i=i+1 return o end
            if c~=',' then error("expected , or } at "..i) end
            i=i+1 ws()
        end
        error("unterminated object")
    end
    function value()
        ws()
        local c=text:sub(i,i)
        if c=='"' then return str() end
        if c=='{' then return obj() end
        if c=='[' then return arr() end
        if text:sub(i,i+3)=='true' then i=i+4 return true end
        if text:sub(i,i+4)=='false' then i=i+5 return false end
        if text:sub(i,i+3)=='null' then i=i+4 return nil end
        local tail=text:sub(i)
        local s,e=tail:find('^-?%d+%.?%d*[eE]?[+%-]?%d*')
        if s then local v=tonumber(tail:sub(s,e)); i=i+e; return v end
        error("bad json value at "..i)
    end
    local v=value() ws()
    return v
end

local function readFirst(paths)
    for _,p in ipairs(paths) do
        local f=io.open(p,"r")
        if f then local s=f:read("*a"); f:close(); return s,p end
    end
    return nil,nil
end

local function scannerPaths(file)
    local mod=(NEU_BOT and NEU_BOT.ModFolder) or "nobody except us 2.0.26"
    return {
        "mods\\"..mod.."\\resource\\script\\multiplayer\\"..file,
        "mods\\"..mod.."\\resource\\"..file,
        "mods\\"..mod.."\\"..file,
        file
    }
end

local function signature(names)
    local a={}
    for _,name in ipairs(names or {}) do a[#a+1]=tostring(name) end
    table.sort(a)
    return table.concat(a,"|")
end

local function finalMapSignature(map)
    local names={}
    for _,f in ipairs((map and map.flags) or {}) do
        if f.canCapture~=false and type(f.name)=="string" then names[#names+1]=f.name end
    end
    return signature(names)
end

local function runtimeSignature()
    local names={}
    for _,f in pairs(BotApi.Scene.Flags) do if f and f.name then names[#names+1]=f.name end end
    return signature(names),names
end

local function pointIndexByName(map)
    local out={}
    for _,f in ipairs((map and map.flags) or {}) do
        if f.canCapture~=false and type(f.name)=="string" and type(f.x)=="number" and type(f.y)=="number" then
            if not out[f.name] then out[f.name]={x=f.x,y=f.y,z=f.z,name=f.name,nearest=f.nearest or {}} end
        end
    end
    return out
end

local function median(a)
    if #a==0 then return nil end
    table.sort(a)
    local m=math.floor((#a+1)/2)
    if #a%2==1 then return a[m] end
    return (a[m]+a[m+1])/2
end

local function deriveSpawn(indexRoot,mapKey,team)
    local map=indexRoot and indexRoot.maps and indexRoot.maps[mapKey]
    if not map then return nil end
    local prefix=lower(team):match("b") and "b" or "a"
    local xs,ys={},{}
    for _,p in ipairs(map.points or {}) do
        local name=lower(p.name)
        local src=lower(p.source)
        if name:match("^"..prefix.."%d") and type(p.x)=="number" and type(p.y)=="number" and src:find("battle_zones.mi",1,true) then
            xs[#xs+1]=p.x ys[#ys+1]=p.y
        end
    end
    local mx,my=median(xs),median(ys)
    if not mx then return nil end
    return {x=mx,y=my,count=#xs,team=prefix}
end

function M:load()
    self.loaded=false self.mapKey=nil self.flags={} self.spawn=nil self.source=nil self.spawnSource=nil
    local raw,path=readFirst(scannerPaths("_flag_points_final.json"))
    if not raw then log("DATA MISSING file=_flag_points_final.json") return false end
    local ok,root=pcall(jsonDecode,raw)
    if not ok or type(root)~="table" or type(root.maps)~="table" then log("DATA PARSE FAILED file="..tostring(path).." err="..tostring(root)) return false end

    local sig,names=runtimeSignature()
    local matches={}
    for key,map in pairs(root.maps) do
        if finalMapSignature(map)==sig then matches[#matches+1]={key=key,map=map} end
    end
    if #matches~=1 then
        log("MATCH "..(#matches==0 and "NONE" or "AMBIGUOUS").." signature="..sig.." count="..#matches)
        return false
    end

    self.mapKey=matches[1].key
    self.flags=pointIndexByName(matches[1].map)
    self.source=path

    local rawIndex,indexPath=readFirst(scannerPaths("_map_points_index.json"))
    if rawIndex then
        local ok2,indexRoot=pcall(jsonDecode,rawIndex)
        if ok2 and type(indexRoot)=="table" then
            self.spawn=deriveSpawn(indexRoot,self.mapKey,BotApi.Instance.team)
            if self.spawn then self.spawnSource=indexPath end
        end
    end

    if not self.spawn and self.mapKey=="3vs3/3vs3_country" then
        local t=lower(BotApi.Instance.team)
        if t=="b" or t=="team b" or t:find("team b",1,true) then
            self.spawn={x=-3940.62,y=-4411.44,count=5,team="b"}
        else
            self.spawn={x=3998.56,y=4701.02,count=4,team="a"}
        end
        self.spawnSource="built-in country anchor"
    end

    self.loaded=true
    log("MATCH key="..self.mapKey.." flags="..tostring(#names).." source="..tostring(path))
    if self.spawn then
        log(string.format("SPAWN ANCHOR team=%s x=%.2f y=%.2f samples=%d source=%s",tostring(BotApi.Instance.team),self.spawn.x,self.spawn.y,self.spawn.count or 0,tostring(self.spawnSource)))
    else
        log("SPAWN ANCHOR unavailable; flag-to-flag geometry only")
    end
    return true
end

function M:point(name) return self.flags and self.flags[name] or nil end
function M:distanceNames(a,b)
    local p,q=self:point(a),self:point(b)
    if not p or not q then return nil end
    local dx,dy=p.x-q.x,p.y-q.y
    return math.sqrt(dx*dx+dy*dy)
end
function M:distanceFromSpawn(name)
    local p=self:point(name)
    if not p or not self.spawn then return nil end
    local dx,dy=p.x-self.spawn.x,p.y-self.spawn.y
    return math.sqrt(dx*dx+dy*dy)
end
function M:nearestToSpawn(list,used)
    local best,bd=nil,nil
    for _,name in ipairs(list or {}) do
        if not (used and used[name]) then
            local d=self:distanceFromSpawn(name)
            if d and (not bd or d<bd) then best,bd=name,d end
        end
    end
    return best,bd
end
function M:nearestToFlag(list,from,used)
    local best,bd=nil,nil
    for _,name in ipairs(list or {}) do
        if not (used and used[name]) then
            local d=self:distanceNames(from,name)
            if d and (not bd or d<bd) then best,bd=name,d end
        end
    end
    return best,bd
end
function M:sortFromSpawn(list)
    table.sort(list,function(a,b)
        local da,db=self:distanceFromSpawn(a),self:distanceFromSpawn(b)
        if da and db and da~=db then return da<db end
        if da and not db then return true end
        if db and not da then return false end
        return tostring(a)<tostring(b)
    end)
end
function M:frontOwnFlags(own,enemy)
    local scored={}
    for _,name in ipairs(own or {}) do
        local best=nil
        for _,e in ipairs(enemy or {}) do
            local d=self:distanceNames(name,e)
            if d and (not best or d<best) then best=d end
        end
        scored[#scored+1]={name=name,d=best or 1e30}
    end
    table.sort(scored,function(a,b) if a.d~=b.d then return a.d<b.d end return a.name<b.name end)
    local out={} for _,x in ipairs(scored) do out[#out+1]=x.name end
    return out
end

return M
