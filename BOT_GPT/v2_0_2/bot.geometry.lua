-- NEU BOT 2.0.2 telemetry geometry bridge
-- Reads the static flag/spawn indexes once and writes only matching map candidates
-- into each side's normal bot_gpt_telemetry_<team>.jsonl file.
-- The HTML viewer therefore needs no separate JSON index selection.

local G = { candidates = {}, runtimeFlags = {}, prepared = false }

local function lower(s) return string.lower(tostring(s or "")) end
local function esc(v)
    return tostring(v or ""):gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\r", "\\r"):gsub("\n", "\\n")
end
local function q(v) return '"' .. esc(v) .. '"' end

local function normalizeJson(text)
    text = tostring(text or "")
    if text:sub(1,3) == string.char(239,187,191) then text = text:sub(4) end
    return text:gsub("^%s+", "")
end

local function jsonDecode(text)
    text = normalizeJson(text)
    local i, n = 1, #text
    local value
    local function ws()
        while i <= n do
            local c = text:sub(i,i)
            if c == " " or c == "\t" or c == "\r" or c == "\n" then i = i + 1 else break end
        end
    end
    local function str()
        i = i + 1
        local out = {}
        while i <= n do
            local c = text:sub(i,i)
            if c == '"' then i = i + 1 return table.concat(out) end
            if c == "\\" then
                i = i + 1
                local e = text:sub(i,i)
                local m = { ['"']='"', ['\\']='\\', ['/']='/', b='\b', f='\f', n='\n', r='\r', t='\t' }
                if e == 'u' then
                    local h = text:sub(i+1,i+4)
                    local cp = tonumber(h,16) or 63
                    out[#out+1] = cp < 128 and string.char(cp) or '?'
                    i = i + 5
                else
                    out[#out+1] = m[e] or e
                    i = i + 1
                end
            else
                out[#out+1] = c
                i = i + 1
            end
        end
        error("unterminated string")
    end
    local function arr()
        i = i + 1; ws()
        local a = {}
        if text:sub(i,i) == ']' then i = i + 1 return a end
        while i <= n do
            a[#a+1] = value(); ws()
            local c = text:sub(i,i)
            if c == ']' then i = i + 1 return a end
            if c ~= ',' then error("expected , or ] at " .. i) end
            i = i + 1; ws()
        end
        error("unterminated array")
    end
    local function obj()
        i = i + 1; ws()
        local o = {}
        if text:sub(i,i) == '}' then i = i + 1 return o end
        while i <= n do
            if text:sub(i,i) ~= '"' then error("expected key at " .. i) end
            local k = str(); ws()
            if text:sub(i,i) ~= ':' then error("expected : at " .. i) end
            i = i + 1; ws()
            local v = value(); if v ~= nil then o[k] = v end
            ws(); local c = text:sub(i,i)
            if c == '}' then i = i + 1 return o end
            if c ~= ',' then error("expected , or } at " .. i) end
            i = i + 1; ws()
        end
        error("unterminated object")
    end
    function value()
        ws(); local c = text:sub(i,i)
        if c == '"' then return str() end
        if c == '{' then return obj() end
        if c == '[' then return arr() end
        if text:sub(i,i+3) == 'true' then i = i + 4 return true end
        if text:sub(i,i+4) == 'false' then i = i + 5 return false end
        if text:sub(i,i+3) == 'null' then i = i + 4 return nil end
        local tail = text:sub(i)
        local s,e = tail:find('^-?%d+%.?%d*[eE]?[+%-]?%d*')
        if s then local v = tonumber(tail:sub(s,e)); i = i + e; return v end
        error("bad json value at " .. i)
    end
    local v = value(); ws(); return v
end

local function paths(file)
    local mod = (NEU_BOT and NEU_BOT.ModFolder) or "nobody except us 2.0.26"
    return {
        "mods\\" .. mod .. "\\resource\\script\\multiplayer\\" .. file,
        "resource\\script\\multiplayer\\" .. file,
        "script\\multiplayer\\" .. file,
        file
    }
end

local function readFirst(file)
    for _, p in ipairs(paths(file)) do
        local f = io.open(p, "rb")
        if f then local s = f:read("*a"); f:close(); return s, p end
    end
end

local function runtimeFlags()
    local a, seen = {}, {}
    for _, f in pairs(BotApi.Scene.Flags or {}) do
        if f and f.name and not seen[f.name] then seen[f.name] = true; a[#a+1] = f.name end
    end
    table.sort(a)
    return a, seen
end

local function flagPoints(map)
    local byName, names = {}, {}
    for _, f in ipairs((map and map.flags) or {}) do
        if f.canCapture ~= false and type(f.name) == "string" and f.name:match("^f%d+") and type(f.x) == "number" and type(f.y) == "number" then
            if not byName[f.name] then
                byName[f.name] = { name=f.name, x=f.x, y=f.y, z=f.z }
                names[#names+1] = f.name
            end
        end
    end
    table.sort(names)
    return byName, names
end

local function normKey(k)
    k = tostring(k or ""):gsub("\\", "/"):gsub("^/+", "")
    if k:sub(1,6) == "multi/" then k = k:sub(7) end
    return k
end

local function findSpawnMap(spawnRoot, flagKey)
    local wanted = normKey(flagKey)
    for k, m in pairs((spawnRoot and spawnRoot.maps) or {}) do
        if normKey(k) == wanted then return m end
    end
end

local function spawnLists(spawnMap)
    local A, B = {}, {}
    for _, p in ipairs((spawnMap and spawnMap.spawn_points) or {}) do
        if type(p.x) == "number" and type(p.y) == "number" then
            local x = { name=p.name or "", x=p.x, y=p.y, z=p.z, team=lower(p.team) }
            if x.team == "a" then A[#A+1] = x elseif x.team == "b" then B[#B+1] = x end
        end
    end
    return A, B
end

local function pointJson(p)
    if not p then return "null" end
    return '{"name":'..q(p.name or "")..',"x":'..tostring(p.x or 0)..',"y":'..tostring(p.y or 0)..',"z":'..tostring(p.z or 0)..'}'
end
local function listJson(a)
    local o = {}; for _, p in ipairs(a or {}) do o[#o+1] = pointJson(p) end
    return '[' .. table.concat(o, ',') .. ']'
end
local function stringListJson(a)
    local o = {}; for _, s in ipairs(a or {}) do o[#o+1] = q(s) end
    return '[' .. table.concat(o, ',') .. ']'
end

function G.prepare(N)
    G.prepared = false; G.candidates = {}
    local flagsRaw, flagsPath = readFirst("_flag_points_final.json")
    local spawnRaw, spawnPath = readFirst("_spawn_points_index.json")
    if not flagsRaw then N.log("GEOMETRY ERROR missing _flag_points_final.json"); return false end
    if not spawnRaw then N.log("GEOMETRY ERROR missing _spawn_points_index.json"); return false end

    local okF, flagsRoot = pcall(jsonDecode, flagsRaw)
    local okS, spawnRoot = pcall(jsonDecode, spawnRaw)
    if not okF or type(flagsRoot) ~= "table" or type(flagsRoot.maps) ~= "table" then N.log("GEOMETRY ERROR flag index parse failed"); return false end
    if not okS or type(spawnRoot) ~= "table" or type(spawnRoot.maps) ~= "table" then N.log("GEOMETRY ERROR spawn index parse failed"); return false end

    local names, set = runtimeFlags(); G.runtimeFlags = names
    local scored, best = {}, -1e30
    for key, map in pairs(flagsRoot.maps) do
        local byName, mapNames = flagPoints(map)
        local hit = 0
        for _, n in ipairs(names) do if byName[n] then hit = hit + 1 end end
        local ratio = (#names > 0) and hit / #names or 0
        local extra = math.max(0, #mapNames - hit)
        local score = ratio * 100000 + hit * 100 - extra
        if ratio >= 0.75 then
            scored[#scored+1] = { key=key, byName=byName, score=score, ratio=ratio, hit=hit, extra=extra }
            if score > best then best = score end
        end
    end

    table.sort(scored, function(a,b) return tostring(a.key) < tostring(b.key) end)
    for _, c in ipairs(scored) do
        if c.score == best then
            local pts = {}
            for _, n in ipairs(names) do if c.byName[n] then pts[#pts+1] = c.byName[n] end end
            local sm = findSpawnMap(spawnRoot, c.key)
            local A, B = spawnLists(sm)
            G.candidates[#G.candidates+1] = { key=c.key, flags=pts, spawnA=A, spawnB=B, ratio=c.ratio, hit=c.hit, extra=c.extra }
        end
    end

    G.prepared = #G.candidates > 0
    N.log("GEOMETRY candidates=" .. tostring(#G.candidates) .. " runtimeFlags=" .. table.concat(names,"|") .. " flags=" .. tostring(flagsPath) .. " spawns=" .. tostring(spawnPath))
    return G.prepared
end

local function telemetryPaths()
    local team = tostring(BotApi.Instance.team or "bot"):gsub("[^%w_-]", "_")
    local mod = (NEU_BOT and NEU_BOT.ModFolder) or "nobody except us 2.0.26"
    return {
        "mods\\" .. mod .. "\\resource\\script\\multiplayer\\bot_gpt_telemetry_" .. team .. ".jsonl",
        "bot_gpt_telemetry_" .. team .. ".jsonl"
    }
end

function G.appendIndex(N)
    if not G.prepared then return false end
    local candidates = {}
    for _, c in ipairs(G.candidates) do
        candidates[#candidates+1] = '{"key":'..q(c.key)..',"ratio":'..tostring(c.ratio)..',"flags":'..listJson(c.flags)..',"spawnA":'..listJson(c.spawnA)..',"spawnB":'..listJson(c.spawnB)..'}'
    end
    local line = '{"type":"geometry_index","version":"2.0.2","team":'..q(BotApi.Instance.team)..',"runtimeFlags":'..stringListJson(G.runtimeFlags)..',"candidates":['..table.concat(candidates,',')..']}'
    for _, p in ipairs(telemetryPaths()) do
        local f = io.open(p, "a")
        if f then f:write(line, "\n"); f:close(); N.log("GEOMETRY embedded in telemetry candidates=" .. tostring(#G.candidates)); return true end
    end
    N.log("GEOMETRY ERROR telemetry file unavailable for append")
    return false
end

return G
