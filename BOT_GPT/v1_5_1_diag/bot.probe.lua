-- NEU BOT v1.5.1 DIAGNOSTIC PROBE
-- Safe runtime probe for BotApi.Scene.Flags and GameSpawn geometry.
-- Does not issue any commands and does not change bot behaviour.

local function dlog(msg)
    print("[NEU-DIAG] " .. tostring(msg))
end

local function safe(label, fn)
    local ok, value = pcall(fn)
    if ok then
        if value ~= nil then dlog(label .. " = " .. tostring(value)) end
        return value
    end
    dlog(label .. " ERROR = " .. tostring(value))
    return nil
end

local function tryVector(prefix, obj)
    if obj == nil then return false end
    local found = false

    local function probeObject(label, v)
        if v == nil then return end
        dlog(label .. " type=" .. type(v) .. " value=" .. tostring(v))
        local x = safe(label .. ".x", function() return v.x end)
        local y = safe(label .. ".y", function() return v.y end)
        local z = safe(label .. ".z", function() return v.z end)
        if x ~= nil or y ~= nil or z ~= nil then found = true end
    end

    probeObject(prefix .. ".position", safe(prefix .. ".position(raw)", function() return obj.position end))
    probeObject(prefix .. ".pos",      safe(prefix .. ".pos(raw)",      function() return obj.pos end))
    probeObject(prefix .. ".point",    safe(prefix .. ".point(raw)",    function() return obj.point end))
    probeObject(prefix .. ".coords",   safe(prefix .. ".coords(raw)",   function() return obj.coords end))
    probeObject(prefix .. ".center",   safe(prefix .. ".center(raw)",   function() return obj.center end))

    local x = safe(prefix .. ".x", function() return obj.x end)
    local y = safe(prefix .. ".y", function() return obj.y end)
    local z = safe(prefix .. ".z", function() return obj.z end)
    if x ~= nil or y ~= nil or z ~= nil then found = true end

    return found
end

local function probeFlag(flag, index)
    local prefix = "FLAG[" .. tostring(index) .. "]"
    dlog("----- " .. prefix .. " BEGIN -----")
    dlog(prefix .. " type=" .. type(flag) .. " tostring=" .. tostring(flag))

    safe(prefix .. ".name", function() return flag.name end)
    safe(prefix .. ".occupant", function() return flag.occupant end)
    safe(prefix .. ".id", function() return flag.id end)
    safe(prefix .. ".entity", function() return flag.entity end)
    safe(prefix .. ".entityId", function() return flag.entityId end)
    safe(prefix .. ".object", function() return flag.object end)
    safe(prefix .. ".sceneObject", function() return flag.sceneObject end)
    safe(prefix .. ".handle", function() return flag.handle end)

    local geometry = tryVector(prefix, flag)
    dlog(prefix .. " geometry_direct=" .. tostring(geometry))

    -- If the flag exposes a linked object, probe it too.
    local linkedNames = {"entity", "object", "sceneObject", "handle"}
    for _, key in ipairs(linkedNames) do
        local linked = safe(prefix .. ".linked." .. key, function() return flag[key] end)
        if linked ~= nil and linked ~= flag then
            dlog(prefix .. " probing linked " .. key)
            tryVector(prefix .. "." .. key, linked)
        end
    end

    -- pairs() works only if the userdata/table exposes iteration; keep it protected.
    local ok, err = pcall(function()
        for k,v in pairs(flag) do
            dlog(prefix .. ".PAIR key=" .. tostring(k) .. " type=" .. type(v) .. " value=" .. tostring(v))
        end
    end)
    if not ok then dlog(prefix .. ".pairs ERROR = " .. tostring(err)) end

    dlog("----- " .. prefix .. " END -----")
end

local function probeAllFlags(reason)
    dlog("========== FLAG PROBE reason=" .. tostring(reason) .. " ==========")
    safe("BotApi.Instance.team", function() return BotApi.Instance.team end)
    safe("BotApi.Instance.enemyTeam", function() return BotApi.Instance.enemyTeam end)
    safe("BotApi.Instance.army", function() return BotApi.Instance.army end)
    safe("BotApi.Instance.playerId", function() return BotApi.Instance.playerId end)
    safe("BotApi.Instance.hostId", function() return BotApi.Instance.hostId end)

    local count = 0
    local ok, err = pcall(function()
        for i, flag in pairs(BotApi.Scene.Flags) do
            count = count + 1
            probeFlag(flag, i)
        end
    end)
    if not ok then dlog("FLAGS ITERATION ERROR = " .. tostring(err)) end
    dlog("FLAG COUNT = " .. tostring(count))
    dlog("========== FLAG PROBE END ==========")
end

local function probeSpawnArgs(args)
    dlog("========== SPAWN PROBE ==========")
    dlog("args type=" .. type(args) .. " tostring=" .. tostring(args))

    safe("spawn.squadId", function() return args.squadId end)
    safe("spawn.playerId", function() return args.playerId end)
    safe("spawn.unit", function() return args.unit end)
    safe("spawn.entity", function() return args.entity end)
    safe("spawn.object", function() return args.object end)
    safe("spawn.squad", function() return args.squad end)

    tryVector("spawn.args", args)

    local candidates = {"entity", "object", "squad"}
    for _,key in ipairs(candidates) do
        local linked = safe("spawn.linked." .. key, function() return args[key] end)
        if linked ~= nil then tryVector("spawn." .. key, linked) end
    end

    local ok, err = pcall(function()
        for k,v in pairs(args) do
            dlog("spawn.PAIR key=" .. tostring(k) .. " type=" .. type(v) .. " value=" .. tostring(v))
        end
    end)
    if not ok then dlog("spawn.pairs ERROR = " .. tostring(err)) end

    dlog("========== SPAWN PROBE END ==========")
end

local function onDiagStart()
    dlog("START v1.5.1 diagnostic probe")
    probeAllFlags("GameStart")

    -- Repeat after 3 seconds in case flag wrappers are not fully initialized at GameStart.
    local function later()
        probeAllFlags("GameStart+3s")
    end
    BotApi.Events:SetQuantTimer(later, 3000)
end

local function onDiagSpawn(args)
    probeSpawnArgs(args)
end

BotApi.Events:Subscribe(BotApi.Events.GameStart, onDiagStart)
BotApi.Events:Subscribe(BotApi.Events.GameSpawn, onDiagSpawn)
