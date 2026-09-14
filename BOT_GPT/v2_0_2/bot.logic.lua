-- NEU BOT 2.0.2 lifecycle/opening adapter
-- Base state machine stays in bot.logic.base.lua.
-- This adapter restores the old proven opening coverage without rewriting the base.

require([[/script/multiplayer/bot.logic.base]])
local N = NEU20
local C = N.C
local Geometry = require([[/script/multiplayer/bot.geometry]])

-- v2.0 core detects duel helicopters as attack_heli. For opening patrol use the
-- same validated candidate pool under a separate role, like the old v1.21 bot.
local baseBuildCandidates = N.buildCandidates
function N.buildCandidates()
    baseBuildCandidates()
    C.Candidates.patrol_heli = {}
    for _, u in ipairs(C.Candidates.attack_heli or {}) do
        C.Candidates.patrol_heli[#C.Candidates.patrol_heli + 1] = u
    end
    N.log("ROLE patrol_heli candidates=" .. tostring(#C.Candidates.patrol_heli))
end

local baseStart = onGameStart
local baseStop = onGameStop
local baseQuant = onGameQuant
local baseSpawn = onGameSpawn
local realProcessSpawn = N.processSpawn

local function neutralFlags()
    local out = {}
    for _, f in pairs(BotApi.Scene.Flags or {}) do
        if f.occupant ~= BotApi.Instance.team and f.occupant ~= BotApi.Instance.enemyTeam then
            out[#out + 1] = f.name
        end
    end
    table.sort(out, function(a,b)
        local na = tonumber(tostring(a):match("(%d+)$"))
        local nb = tonumber(tostring(b):match("(%d+)$"))
        if na and nb and na ~= nb then return na < nb end
        return tostring(a) < tostring(b)
    end)
    return out
end

local function queueOpeningCoverage()
    if NEU_BOT.OpeningCoverage and NEU_BOT.OpeningCoverage.PatrolHelicopterAtStart then
        N.queue("patrol_heli", "opening heli", true, nil, NEU_BOT.Strategy.OpeningPatrolHeliPriority or 220)
        N.log("OPENING HELI queued at battle start")
    end

    if NEU_BOT.OpeningCoverage and NEU_BOT.OpeningCoverage.PointStartEveryNeutralFlag then
        local flags = neutralFlags()
        for _, flag in ipairs(flags) do
            N.queue("pointstart", "opening point", true, flag, NEU_BOT.Strategy.OpeningPointStartPriority or 200)
        end
        N.log("OPENING POINTSTART queued=" .. tostring(#flags) .. " neutral flags=" .. table.concat(flags, "|"))
    end
end

function onGameStart()
    -- Prevent the base opening infantry request from spawning before the restored
    -- pointstart/heli requests are inserted. The request itself is still queued.
    local gate = true
    N.processSpawn = function(...)
        if gate then return false end
        return realProcessSpawn(...)
    end

    Geometry.prepare(N)
    baseStart()

    gate = false
    N.processSpawn = realProcessSpawn
    queueOpeningCoverage()
    Geometry.appendIndex(N)
    N.processSpawn()
end

function onGameStop()
    baseStop()
end

function onGameQuant()
    baseQuant()
end

function onGameSpawn(args)
    local ticket = C.SpawnTickets and C.SpawnTickets[1] or nil
    local role = ticket and ticket.role or nil
    local target = ticket and ticket.target or nil
    local id = args and args.squadId or nil

    baseSpawn(args)

    if id and role == "pointstart" and target and N.alive(id) then
        C.SquadTargets[id] = target
        N.capture(id, target, true)
        N.log("POINTSTART ORDER squad=" .. tostring(id) .. " flag=" .. tostring(target))
    elseif id and role == "patrol_heli" and N.alive(id) then
        N.log("OPENING HELI ARRIVED squad=" .. tostring(id))
    end
end

BotApi.Events:Subscribe(BotApi.Events.GameStart, onGameStart)
BotApi.Events:Subscribe(BotApi.Events.GameEnd, onGameStop)
BotApi.Events:Subscribe(BotApi.Events.Quant, onGameQuant)
BotApi.Events:Subscribe(BotApi.Events.GameSpawn, onGameSpawn)

N.log("BOT 2.0.2 EVENTS ACTIVE; opening coverage adapter installed")
return N
