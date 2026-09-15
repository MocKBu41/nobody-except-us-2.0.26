-- NEU / GEM2 / MoWAS2 runtime command probe
-- Diagnostic only: discovers visible script API and traces BotApi.Commands calls.
-- It DOES NOT automatically execute unknown commands.

NEU_COMMAND_PROBE = NEU_COMMAND_PROBE or {}
local P = NEU_COMMAND_PROBE

P.VERSION = "1.0.0"
P.installed = P.installed or false
P.entries = P.entries or {}
P.seen = P.seen or {}
P.hooked = P.hooked or {}
P.commandNames = P.commandNames or {Spawn=true, CaptureFlag=true}

P.staticFiles = P.staticFiles or {
    "script/multiplayer/bot.lua",
    "script/multiplayer/bot.main.lua",
    "script/multiplayer/bot.data.lua",
    "script/multiplayer/bot.mapdata.lua",
    "script/multiplayer/bot.v1_18.core.lua",
    "script/multiplayer/bot.v1_18.logic.lua",
    "script/multiplayer/bot.v1_19.patch.lua",
    "script/multiplayer/bot.v1_20.core.lua",
    "script/multiplayer/bot.v1_20.logic.lua",
    "script/multiplayer/bot.v1_21.core.lua",
    "script/multiplayer/bot.v1_21.logic.lua",
    "script/multiplayer/bot.v1_21.support.lua",
    "script/multiplayer/bot.v1_22.logic.lua"
}

local keywords = {
    "bot", "squad", "actor", "entity", "vehicle", "crew",
    "move", "order", "attack", "capture", "spawn", "target",
    "way", "formation", "stance", "enter", "exit", "load", "unload",
    "fire", "stop", "follow", "patrol", "land", "position", "command"
}

local function log(msg)
    print("[NEU-CMD-PROBE] " .. tostring(msg))
end
P.log = log

local function low(v)
    return string.lower(tostring(v or ""))
end

local function interesting(name)
    local s = low(name)
    if string.sub(s, 1, 2) == "md" then return true end
    for _, k in ipairs(keywords) do
        if string.find(s, k, 1, true) then return true end
    end
    return false
end

local function short(v, depth)
    depth = depth or 0
    if BotApi and v == BotApi then return "<BotApi>" end
    if BotApi and BotApi.Commands and v == BotApi.Commands then return "<BotApi.Commands>" end
    if BotApi and BotApi.Scene and v == BotApi.Scene then return "<BotApi.Scene>" end

    local t = type(v)
    if t == "nil" or t == "number" or t == "boolean" then return tostring(v) end
    if t == "string" then
        local s = v
        if #s > 120 then s = string.sub(s, 1, 117) .. "..." end
        return string.format("%q", s)
    end
    if t == "table" then
        if depth >= 1 then return "<table>" end
        local out, n = {}, 0
        local ok = pcall(function()
            for k, x in pairs(v) do
                n = n + 1
                if n > 8 then out[#out + 1] = "..." break end
                out[#out + 1] = tostring(k) .. "=" .. short(x, depth + 1)
            end
        end)
        if not ok then return "<table:unreadable>" end
        return "{" .. table.concat(out, ",") .. "}"
    end
    local ok, s = pcall(tostring, v)
    if ok then return "<" .. t .. ":" .. s .. ">" end
    return "<" .. t .. ">"
end

local function add(kind, owner, name, valueType, source)
    local key = tostring(kind) .. "|" .. tostring(owner) .. "|" .. tostring(name) .. "|" .. tostring(source or "")
    if P.seen[key] then return end
    P.seen[key] = true
    P.entries[#P.entries + 1] = {
        kind=kind, owner=owner, name=name, valueType=valueType, source=source
    }
    if owner == "BotApi.Commands" and name then P.commandNames[name] = true end
    log(string.format("FOUND kind=%s owner=%s name=%s type=%s source=%s",
        tostring(kind), tostring(owner), tostring(name), tostring(valueType), tostring(source or "runtime")))
end

local function enumerateTable(owner, obj, source)
    if obj == nil then return end
    local ok = pcall(function()
        for k, v in pairs(obj) do
            if type(k) == "string" then
                add("member", owner, k, type(v), source)
            end
        end
    end)
    if not ok then
        log("ENUM unavailable owner=" .. tostring(owner) .. " type=" .. type(obj))
    end
end

local function enumerateMeta(owner, obj)
    local ok, mt = pcall(getmetatable, obj)
    if not ok or type(mt) ~= "table" then return end
    enumerateTable(owner .. ".<metatable>", mt, "metatable")
    local idx = mt.__index
    if type(idx) == "table" then
        enumerateTable(owner, idx, "metatable.__index")
    end
end

function P.scanRuntime()
    log("RUNTIME SCAN BEGIN version=" .. P.VERSION)
    if not BotApi then
        log("BotApi is not available at scan time")
    else
        enumerateTable("BotApi", BotApi, "runtime")
        enumerateMeta("BotApi", BotApi)
        if BotApi.Commands then
            enumerateTable("BotApi.Commands", BotApi.Commands, "runtime")
            enumerateMeta("BotApi.Commands", BotApi.Commands)
        end
        if BotApi.Scene then
            enumerateTable("BotApi.Scene", BotApi.Scene, "runtime")
            enumerateMeta("BotApi.Scene", BotApi.Scene)
        end
        if BotApi.Instance then
            enumerateTable("BotApi.Instance", BotApi.Instance, "runtime")
            enumerateMeta("BotApi.Instance", BotApi.Instance)
        end
    end

    local ok = pcall(function()
        for k, v in pairs(_G) do
            if type(k) == "string" and interesting(k) then
                local tv = type(v)
                if tv == "function" or tv == "table" or tv == "userdata" then
                    add("global", "_G", k, tv, "runtime")
                end
            end
        end
    end)
    if not ok then log("GLOBAL enumeration unavailable") end
    log("RUNTIME SCAN END")
end

local function scanText(path, text)
    local found = 0
    local patterns = {
        {owner="BotApi.Commands", pat="BotApi%s*%.%s*Commands%s*:%s*([%a_][%w_]*)"},
        {owner="BotApi.Scene", pat="BotApi%s*%.%s*Scene%s*:%s*([%a_][%w_]*)"},
        {owner="BotApi.Instance", pat="BotApi%s*%.%s*Instance%s*:%s*([%a_][%w_]*)"},
        {owner="BotApi", pat="BotApi%s*:%s*([%a_][%w_]*)"},
        {owner="NEU bridge", pat="(NEU_Engine[%w_]+)%s*%("},
        {owner="md/global", pat="%f[%a_](md[%u_][%w_]*)%s*%("},
        {owner="Squad/global", pat="%f[%a_](Squad[%u_][%w_]*)%s*%("},
        {owner="Actor/global", pat="%f[%a_](Actor[%u_][%w_]*)%s*%("},
        {owner="Entity/global", pat="%f[%a_](Entity[%u_][%w_]*)%s*%("},
        {owner="Vehicle/global", pat="%f[%a_](Vehicle[%u_][%w_]*)%s*%("}
    }
    for _, p in ipairs(patterns) do
        for name in string.gmatch(text, p.pat) do
            add("static-call", p.owner, name, "call", path)
            found = found + 1
        end
    end
    return found
end

function P.scanKnownFiles()
    log("STATIC SCAN BEGIN")
    local total = 0
    for _, rel in ipairs(P.staticFiles) do
        local candidates = {rel, "/" .. rel}
        local text = nil
        for _, path in ipairs(candidates) do
            local f = io.open(path, "r")
            if f then
                text = f:read("*a")
                f:close()
                if text then
                    total = total + scanText(rel, text)
                    break
                end
            end
        end
    end
    log("STATIC SCAN END matches=" .. tostring(total))
end

function P.trace(method, ...)
    local args = {...}
    local out = {}
    for i=1,#args do out[#out + 1] = short(args[i]) end
    log("CALL BotApi.Commands:" .. tostring(method) .. "(" .. table.concat(out, ", ") .. ")")
end

local function hookCommand(name)
    if not BotApi or not BotApi.Commands or P.hooked[name] then return false end
    local cmd = BotApi.Commands
    local okGet, original = pcall(function() return cmd[name] end)
    if not okGet or type(original) ~= "function" then return false end

    local wrapper = function(...)
        P.trace(name, ...)
        return original(...)
    end

    local okSet = pcall(function() cmd[name] = wrapper end)
    if not okSet then return false end
    local okCheck, current = pcall(function() return cmd[name] end)
    if not okCheck or current ~= wrapper then
        pcall(function() cmd[name] = original end)
        return false
    end

    P.hooked[name] = {original=original, wrapper=wrapper}
    log("HOOKED BotApi.Commands:" .. tostring(name))
    return true
end

function P.installHooks()
    if not BotApi or not BotApi.Commands then
        log("HOOK skipped: BotApi.Commands unavailable")
        return
    end

    -- If Commands is enumerable, collect every visible function first.
    pcall(function()
        for k, v in pairs(BotApi.Commands) do
            if type(k) == "string" and type(v) == "function" then
                P.commandNames[k] = true
            end
        end
    end)

    local hooked = 0
    for name in pairs(P.commandNames) do
        if hookCommand(name) then hooked = hooked + 1 end
    end
    log("HOOK PASS complete hooked=" .. tostring(hooked))
end

-- Manual, explicit test helper. Never called automatically.
-- Example from a debug-capable script: NEU_COMMAND_PROBE.test("CaptureFlag", squadId, "flag1")
function P.test(name, ...)
    if not BotApi or not BotApi.Commands then
        log("TEST unavailable: BotApi.Commands missing")
        return false
    end
    local okGet, fn = pcall(function() return BotApi.Commands[name] end)
    if not okGet or type(fn) ~= "function" then
        log("TEST method not visible: " .. tostring(name))
        return false
    end
    P.trace("TEST/" .. tostring(name), ...)
    local ok, result = pcall(fn, BotApi.Commands, ...)
    log("TEST result name=" .. tostring(name) .. " ok=" .. tostring(ok) .. " value=" .. short(result))
    return ok, result
end

function P.summary()
    log("SUMMARY entries=" .. tostring(#P.entries))
    local commands = {}
    for name in pairs(P.commandNames) do commands[#commands + 1] = name end
    table.sort(commands)
    log("COMMAND NAMES: " .. table.concat(commands, ", "))
end

function P.install()
    if P.installed then return P end
    P.installed = true
    log("INSTALL BEGIN")
    local ok1, err1 = pcall(P.scanKnownFiles)
    if not ok1 then log("STATIC SCAN ERROR " .. tostring(err1)) end
    local ok2, err2 = pcall(P.scanRuntime)
    if not ok2 then log("RUNTIME SCAN ERROR " .. tostring(err2)) end
    local ok3, err3 = pcall(P.installHooks)
    if not ok3 then log("HOOK ERROR " .. tostring(err3)) end
    P.summary()
    log("INSTALL END; unknown commands are NOT executed automatically")
    return P
end

return P
