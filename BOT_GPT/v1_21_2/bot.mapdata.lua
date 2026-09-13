-- NEU BOT v1.11 map knowledge
-- Same robust map matching/geometry layer as v1.10.

NEU_MAPDATA = NEU_MAPDATA or {}
local M = NEU_MAPDATA
M.loaded=false
M.mapKey=nil
M.flags={}
M.spawn=nil
M.source=nil
M.spawnSource=nil
M.matchRatio=nil

local function lower(s) return string.lower(tostring(s or "")) end
local function log(s) print("[NEU-BOT] MAP "..tostring(s)) end

local function normalizeJson(text)
    text=tostring(text or "")
    if text:sub(1,3)==string.char(239,187,191) then text=text:sub(4) end
    text=text:gsub("^%s+","")
    return text
end

local function jsonDecode(text)
    text=normalizeJson(text)
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
            else out[#out+1]=c i=i+1 end
        end
        error("unterminated string")
    end
    local function arr()
        i=i+1 ws() local a={}
        if text:sub(i,i)==']' then i=i+1 return a end
        while i<=n do
            local v=value() a[#a+1]=v ws()
            local c=text:sub(i,i)
            if c==']' then i=i+1 return a end
            if c~=',' then error("expected , or ] at "..i) end
            i=i+1 ws()
        end
        error("unterminated array")
    end
    local function obj()
        i=i+1 ws() local o={}
        if text:sub(i,i)=='}' then i=i+1 return o end
        while i<=n do
            if text:sub(i,i)~='"' then error("expected key at "..i) end
            local k=str() ws()
            if text:sub(i,i)~=':' then error("expected : at "..i) end
            i=i+1 ws() local v=value() if v~=nil then o[k]=v end ws()
            local c=text:sub(i,i)
            if c=='}' then i=i+1 return o end
            if c~=',' then error("expected , or } at "..i) end
            i=i+1 ws()
        end
        error("unterminated object")
    end
    function value()
        ws() local c=text:sub(i,i)
        if c=='"' then return str() end
        if c=='{' then return obj() end
        if c=='[' then return arr() end
        if text:sub(i,i+3)=='true' then i=i+4 return true end
        if text:sub(i,i+4)=='false' then i=i+5 return false end
        if text:sub(i,i+3)=='null' then i=i+4 return nil end
        local tail=text:sub(i)
        local s,e=tail:find('^-?%d+%.?%d*[eE]?[+%-]?%d*')
        if s then local v=tonumber(tail:sub(s,e)); i=i+e; return v end
        error("bad json value at "..i.." byte="..tostring(string.byte(c or "")))
    end
    local v=value() ws() return v
end

local function readFirst(paths)
    for _,p in ipairs(paths) do
        local f=io.open(p,"rb")
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

local function uniqueNamesFromRuntime()
    local set,names={},{}
    for _,f in pairs(BotApi.Scene.Flags) do
        if f and f.name and not set[f.name] then set[f.name]=true names[#names+1]=f.name end
    end
    table.sort(names)
    return names,set
end

local function uniqueNamesFromMap(map)
    local set,names={},{}
    for _,f in ipairs((map and map.flags) or {}) do
        if f.canCapture~=false and type(f.name)=="string" and f.name:match("^f%d+") and not set[f.name] then
            set[f.name]=true names[#names+1]=f.name
        end
    end
    table.sort(names)
    return names,set
end

local function matchScore(runtimeNames,runtimeSet,map)
    local mapNames,mapSet=uniqueNamesFromMap(map)
    local hit=0
    for _,n in ipairs(runtimeNames) do if mapSet[n] then hit=hit+1 end end
    local ratio=(#runtimeNames>0) and hit/#runtimeNames or 0
    local extra=0 for _,n in ipairs(mapNames) do if not runtimeSet[n] then extra=extra+1 end end
    return ratio,hit,extra,#mapNames
end

local function pointCandidatesByName(map)
    local out={}
    for _,f in ipairs((map and map.flags) or {}) do
        if f.canCapture~=false and type(f.name)=="string" and type(f.x)=="number" and type(f.y)=="number" and f.name:match("^f%d+") then
            out[f.name]=out[f.name] or {}
            local dup=false
            for _,p in ipairs(out[f.name]) do if math.abs(p.x-f.x)<0.01 and math.abs(p.y-f.y)<0.01 then dup=true break end end
            if not dup then out[f.name][#out[f.name]+1]={x=f.x,y=f.y,z=f.z,name=f.name,nearest=f.nearest or {},mid=f.mid,order=f.order} end
        end
    end
    return out
end

local function median(a)
    if #a==0 then return nil end table.sort(a)
    local m=math.floor((#a+1)/2)
    if #a%2==1 then return a[m] end
    return (a[m]+a[m+1])/2
end

local function deriveSpawn(indexRoot,mapKey,team)
    local map=indexRoot and indexRoot.maps and indexRoot.maps[mapKey]
    if not map then return nil end
    local t=lower(team)
    local prefix=(t=="b" or t=="team b" or t:find("team b",1,true)) and "b" or "a"
    local xs,ys={},{}
    for _,p in ipairs(map.points or {}) do
        local name=lower(p.name) local src=lower(p.source)
        if name:match("^"..prefix.."%d") and type(p.x)=="number" and type(p.y)=="number" and src:find("battle_zones.mi",1,true) then
            xs[#xs+1]=p.x ys[#ys+1]=p.y
        end
    end
    local mx,my=median(xs),median(ys)
    if not mx then return nil end
    return {x=mx,y=my,count=#xs,team=prefix}
end

local function dist(p,q)
    if not p or not q then return nil end
    local dx,dy=p.x-q.x,p.y-q.y
    return math.sqrt(dx*dx+dy*dy)
end

function M:load()
    self.distanceCache={} self.spawnDistanceCache={}
    self.loaded=false self.mapKey=nil self.flags={} self.spawn=nil self.source=nil self.spawnSource=nil self.matchRatio=nil
    local finalName=(NEU_BOT and NEU_BOT.MapFinalFile) or "_flag_points_final.json"
    local indexName=(NEU_BOT and NEU_BOT.MapIndexFile) or "_map_points_index.json"
    local raw,path=readFirst(scannerPaths(finalName))
    if not raw then log("DATA MISSING file="..finalName) return false end
    raw=normalizeJson(raw)
    log("DATA OPEN file="..tostring(path).." bytes="..tostring(#raw).." first="..tostring(raw:sub(1,1)))
    local ok,root=pcall(jsonDecode,raw)
    if not ok or type(root)~="table" or type(root.maps)~="table" then log("DATA PARSE FAILED file="..tostring(path).." err="..tostring(root)) return false end

    local runtimeNames,runtimeSet=uniqueNamesFromRuntime()
    local best=nil
    for key,map in pairs(root.maps) do
        local ratio,hit,extra,mapCount=matchScore(runtimeNames,runtimeSet,map)
        local rank=ratio*100000 + hit*100 - extra
        if not best or rank>best.rank then best={key=key,map=map,ratio=ratio,hit=hit,extra=extra,mapCount=mapCount,rank=rank} end
    end
    local minRatio=(NEU_BOT and NEU_BOT.MapMatchMinRatio) or 0.75
    if not best or best.ratio<minRatio then
        log("MATCH NONE runtime="..table.concat(runtimeNames,"|").." best="..tostring(best and best.key).." ratio="..tostring(best and best.ratio))
        return false
    end

    self.mapKey=best.key self.matchRatio=best.ratio self.source=path

    local rawIndex,indexPath=readFirst(scannerPaths(indexName))
    if rawIndex then
        rawIndex=normalizeJson(rawIndex)
        local ok2,indexRoot=pcall(jsonDecode,rawIndex)
        if ok2 and type(indexRoot)=="table" then
            self.spawn=deriveSpawn(indexRoot,self.mapKey,BotApi.Instance.team)
            if self.spawn then self.spawnSource=indexPath else log("SPAWN INDEX no usable side points for key="..tostring(self.mapKey)) end
        else log("INDEX PARSE FAILED file="..tostring(indexPath).." err="..tostring(indexRoot)) end
    else log("INDEX MISSING file="..indexName) end

    if not self.spawn and self.mapKey=="3vs3/3vs3_country" then
        local t=lower(BotApi.Instance.team)
        if t=="b" or t=="team b" or t:find("team b",1,true) then self.spawn={x=-3940.62,y=-4411.44,count=5,team="b"}
        else self.spawn={x=3998.56,y=4701.02,count=4,team="a"} end
        self.spawnSource="built-in country anchor"
    end

    self.flags=pointCandidatesByName(best.map)
    self.loaded=true
    log(string.format("MATCH key=%s ratio=%.3f hit=%d runtime=%d mapUnique=%d extra=%d source=%s",self.mapKey,best.ratio,best.hit,#runtimeNames,best.mapCount,best.extra,tostring(path)))
    if self.spawn then log(string.format("SPAWN ANCHOR team=%s x=%.2f y=%.2f samples=%d source=%s",tostring(BotApi.Instance.team),self.spawn.x,self.spawn.y,self.spawn.count or 0,tostring(self.spawnSource)))
    else log("SPAWN ANCHOR unavailable; flag-to-flag geometry only") end
    for _,name in ipairs(runtimeNames) do
        local variants=self.flags[name] or {}
        log("FLAG GEO name="..name.." variants="..#variants.." dSpawn="..tostring(self:distanceFromSpawn(name)))
    end
    return true
end

function M:points(name) return (self.flags and self.flags[name]) or {} end
function M:point(name)
    local list=self:points(name)
    if #list==0 then return nil end
    if self.spawn then
        local best,bd=nil,nil
        for _,p in ipairs(list) do local d=dist(p,self.spawn) if d and (not bd or d<bd) then best,bd=p,d end end
        return best
    end
    return list[1]
end
function M:distanceNames(a,b)
    if not a or not b then return nil end
    self.distanceCache=self.distanceCache or {}
    local row=self.distanceCache[a]
    if row and row[b]~=nil then if row[b]==false then return nil end return row[b] end
    local aa,bb=self:points(a),self:points(b)
    local best=nil
    for _,p in ipairs(aa) do for _,q in ipairs(bb) do local d=dist(p,q) if d and (not best or d<best) then best=d end end end
    self.distanceCache[a]=self.distanceCache[a] or {}
    self.distanceCache[b]=self.distanceCache[b] or {}
    self.distanceCache[a][b]=best or false self.distanceCache[b][a]=best or false
    return best
end
function M:distanceFromSpawn(name)
    if not self.spawn or not name then return nil end
    self.spawnDistanceCache=self.spawnDistanceCache or {}
    local cached=self.spawnDistanceCache[name]
    if cached~=nil then if cached==false then return nil end return cached end
    local best=nil
    for _,p in ipairs(self:points(name)) do local d=dist(p,self.spawn) if d and (not best or d<best) then best=d end end
    self.spawnDistanceCache[name]=best or false
    return best
end
function M:nearestToSpawn(list,used)
    local best,bd=nil,nil
    for _,name in ipairs(list or {}) do if not (used and used[name]) then local d=self:distanceFromSpawn(name) if d and (not bd or d<bd) then best,bd=name,d end end end
    return best,bd
end
function M:nearestToFlag(list,from,used)
    local best,bd=nil,nil
    for _,name in ipairs(list or {}) do if not (used and used[name]) then local d=self:distanceNames(from,name) if d and (not bd or d<bd) then best,bd=name,d end end end
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
function M:sortFromFlag(list,from)
    table.sort(list,function(a,b)
        local da,db=self:distanceNames(from,a),self:distanceNames(from,b)
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
        for _,e in ipairs(enemy or {}) do local d=self:distanceNames(name,e) if d and (not best or d<best) then best=d end end
        scored[#scored+1]={name=name,d=best or 1e30}
    end
    table.sort(scored,function(a,b) if a.d~=b.d then return a.d<b.d end return a.name<b.name end)
    local out={} for _,x in ipairs(scored) do out[#out+1]=x.name end return out
end

return M


