-- NEU BOT 2.0.3 opening controller
-- Confirmed 2.0.2 regressions fixed here:
-- 1) patrol heli can no longer lock C.AwaitingArrival and block the whole side;
-- 2) pointstart falls back to normal infantry when the faction has no pointstart-tagged unit;
-- 3) main BTG opening stays frozen until every neutral flag has its own capture squad/order.

require([[/script/multiplayer/bot.logic.base]])
local N = NEU20
local C = N.C
local Geometry = require([[/script/multiplayer/bot.geometry]])

local baseBuildCandidates = N.buildCandidates
function N.buildCandidates()
    baseBuildCandidates()

    -- Opening patrol uses the validated helicopter pool, but it is not part of
    -- the serialized ground SpawnIntents queue in 2.0.3.
    C.Candidates.patrol_heli = {}
    for _, u in ipairs(C.Candidates.attack_heli or {}) do
        C.Candidates.patrol_heli[#C.Candidates.patrol_heli + 1] = u
    end

    -- Some factions/maps have no unit tagged pointstart. That must never cancel
    -- opening map coverage. Append ordinary infantry as guaranteed fallbacks.
    C.Candidates.pointstart = C.Candidates.pointstart or {}
    local seen = {}
    for _, u in ipairs(C.Candidates.pointstart) do seen[u.unit] = true end
    local nativeCount = #C.Candidates.pointstart
    if NEU_BOT.OpeningCoverage.PointStartInfantryFallback then
        for _, u in ipairs(C.Candidates.infantry or {}) do
            if not seen[u.unit] then
                C.Candidates.pointstart[#C.Candidates.pointstart + 1] = u
                seen[u.unit] = true
            end
        end
    end
    N.log("ROLE patrol_heli candidates=" .. tostring(#C.Candidates.patrol_heli))
    N.log("ROLE pointstart native=" .. tostring(nativeCount) .. " with_infantry_fallback=" .. tostring(#C.Candidates.pointstart))
end

local baseStart = onGameStart
local baseStop = onGameStop
local baseQuant = onGameQuant
local baseSpawn = onGameSpawn
local baseSpawnFailed = N.onSpawnFailed
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

local function coverageCount()
    local n = 0
    for _, ok in pairs(C.OpeningCoverageDone or {}) do if ok then n = n + 1 end end
    return n
end

local function freezeMainOpening()
    for _, x in ipairs(C.SpawnIntents or {}) do
        if x.reason == "opening" and x.role ~= "pointstart" then
            x.due = 1000000000
            x.coverageFrozen = true
        end
    end
    C.MainOpeningFrozen = true
    N.log("OPENING MAIN FROZEN until all start flags have capture squads")
end

local function releaseMainOpening()
    if C.OpeningCoverageReleased then return end
    if coverageCount() < (C.OpeningCoverageTotal or 0) then return end
    C.OpeningCoverageReleased = true
    C.MainOpeningFrozen = false
    for _, x in ipairs(C.SpawnIntents or {}) do
        if x.coverageFrozen then
            x.coverageFrozen = nil
            x.due = C.Time
        end
    end
    N.log("OPENING COVERAGE COMPLETE assigned=" .. tostring(coverageCount()) .. "/" .. tostring(C.OpeningCoverageTotal or 0) .. " -> RELEASE MAIN BTG")
    realProcessSpawn()
end

local function markCoverage(flag, why)
    if not flag or not C.OpeningCoverageTargets or not C.OpeningCoverageTargets[flag] then return end
    if C.OpeningCoverageDone[flag] then return end
    C.OpeningCoverageDone[flag] = true
    N.log("OPENING COVERED flag=" .. tostring(flag) .. " via=" .. tostring(why) .. " progress=" .. tostring(coverageCount()) .. "/" .. tostring(C.OpeningCoverageTotal))
    releaseMainOpening()
end

local function removeSatisfiedPointstartIntents()
    for i = #(C.SpawnIntents or {}), 1, -1 do
        local x = C.SpawnIntents[i]
        if x.role == "pointstart" and x.target and C.OpeningCoverageDone and C.OpeningCoverageDone[x.target] then
            table.remove(C.SpawnIntents, i)
        end
    end
end

local function refreshCoverageOwnership()
    if C.OpeningCoverageReleased then return end
    for flag in pairs(C.OpeningCoverageTargets or {}) do
        if N.owner(flag) == BotApi.Instance.team then markCoverage(flag, "already_owned") end
    end
    removeSatisfiedPointstartIntents()
    releaseMainOpening()
end

local function queueAllOpeningPoints()
    C.OpeningCoverageTargets = {}
    C.OpeningCoverageDone = {}
    C.OpeningCoverageTotal = 0
    C.OpeningCoverageReleased = false

    local flags = neutralFlags()
    for _, flag in ipairs(flags) do
        C.OpeningCoverageTargets[flag] = true
        C.OpeningCoverageTotal = C.OpeningCoverageTotal + 1
        N.queue("pointstart", "opening point", true, flag, NEU_BOT.Strategy.OpeningPointStartPriority or 1000)
    end
    N.log("OPENING POINTSTART queued=" .. tostring(#flags) .. " neutral flags=" .. table.concat(flags, "|"))
    if #flags == 0 then releaseMainOpening() end
end

local function spawnOpeningHeliNonBlocking()
    if not NEU_BOT.OpeningCoverage.PatrolHelicopterAtStart then return end
    local list = C.Candidates.patrol_heli or {}
    if #list == 0 then N.log("OPENING HELI unavailable: no candidates; ground opening continues"); return end

    for _, u in ipairs(list) do
        C.DirectOpeningHeliPending = { unit = u.unit }
        local ok = BotApi.Commands:Spawn(u.unit, MaxSquadSize)
        if C.DirectOpeningHeliPending == nil then
            N.log("OPENING HELI ARRIVED synchronously unit=" .. tostring(u.unit))
            return
        end
        C.DirectOpeningHeliPending = nil
        if ok then
            -- Some sides accept the helicopter but emit no GameSpawn callback.
            -- This is intentionally non-blocking: ground coverage must continue.
            N.log("OPENING HELI ACCEPTED without GameSpawn unit=" .. tostring(u.unit) .. "; ground queue NOT blocked")
            return
        end
        N.log("OPENING HELI REJECTED unit=" .. tostring(u.unit) .. " -> try next")
    end
    N.log("OPENING HELI failed all candidates; ground opening continues")
end

function N.onSpawnFailed(role, reason, intent)
    if role == "pointstart" and reason == "opening point" then
        local target = intent and intent.target or nil
        if target and C.OpeningCoverageTargets and C.OpeningCoverageTargets[target] and not C.OpeningCoverageDone[target] and N.owner(target) ~= BotApi.Instance.team then
            N.log("POINTSTART RETRY target=" .. tostring(target) .. " after spawn failure")
            N.queue("pointstart", "opening point", true, target, NEU_BOT.Strategy.OpeningPointStartPriority or 1000)
        else
            markCoverage(target, "no_longer_needed")
        end
        return
    end
    if type(baseSpawnFailed) == "function" then baseSpawnFailed(role, reason, intent) end
end

function onGameStart()
    -- Hold all actual queued spawning while the base initializes its state and
    -- creates the first normal infantry intent.
    local gate = true
    N.processSpawn = function(...)
        if gate then return false end
        return realProcessSpawn(...)
    end

    Geometry.prepare(N)
    baseStart()

    freezeMainOpening()
    queueAllOpeningPoints()
    Geometry.appendIndex(N)

    gate = false
    N.processSpawn = realProcessSpawn

    -- Air call is independent of AwaitingArrival and therefore cannot deadlock A/B.
    spawnOpeningHeliNonBlocking()

    -- Ground queue starts only after all high-priority pointstart requests exist.
    realProcessSpawn()
end

function onGameStop() baseStop() end

function onGameQuant()
    baseQuant()
    refreshCoverageOwnership()
end

function onGameSpawn(args)
    local id = args and args.squadId or nil

    -- Direct opening helicopter is deliberately outside SpawnTickets.
    if id and C.DirectOpeningHeliPending then
        C.DirectOpeningHeliPending = nil
        C.SquadRole[id] = "patrol_heli"
        C.Dead[id] = false
        N.log("OPENING HELI ARRIVED squad=" .. tostring(id) .. " (nonblocking direct spawn)")
        return
    end

    local ticket = C.SpawnTickets and C.SpawnTickets[1] or nil
    local role = ticket and ticket.role or nil
    local target = ticket and ticket.target or nil

    baseSpawn(args)

    if id and role == "pointstart" and target and N.alive(id) then
        C.SquadTargets[id] = target
        local ordered = N.capture(id, target, true)
        if ordered then
            N.log("POINTSTART ORDER squad=" .. tostring(id) .. " flag=" .. tostring(target))
            markCoverage(target, "capture_order")
        else
            N.log("POINTSTART ORDER FAILED squad=" .. tostring(id) .. " flag=" .. tostring(target))
        end
    end
end

BotApi.Events:Subscribe(BotApi.Events.GameStart, onGameStart)
BotApi.Events:Subscribe(BotApi.Events.GameEnd, onGameStop)
BotApi.Events:Subscribe(BotApi.Events.Quant, onGameQuant)
BotApi.Events:Subscribe(BotApi.Events.GameSpawn, onGameSpawn)

N.log("BOT 2.0.3 EVENTS ACTIVE; ALL-FLAGS-FIRST opening controller installed")
return N
