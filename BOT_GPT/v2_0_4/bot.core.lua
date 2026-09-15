-- NEU BOT 2.0 core
NEU20 = NEU20 or {}
local N = NEU20

N.C = {
    Time = 0,
    State = "OPENING",
    Units = {}, Candidates = {}, UnitSeen = {}, RoleCursor = {},
    SpawnIntents = {}, SpawnTickets = {}, AwaitingArrival = nil, Spawning = false,
    SquadRole = {}, SquadTargets = {}, Dead = {}, LastOrder = {},
    PreviousOwn = {}, LostOwn = {}, DeferredOrders = {},
    ReplacementRole = nil, ReplacementPending = false,
    OpeningIndex = 1,
    Economy = { points = 0, spent = 0, earned = 0, roleReadyAt = {} },
    Timer = nil, TimerGeneration = 0,
    NextReevaluateAt = 0, NextOrderRefreshAt = 0, NextHeliCheckAt = 0,
    HeliBlockedLogged = false, EnemyTankCount = nil
}
local C = N.C

function N.log(m) print("[BOT2.0] " .. tostring(m)) end
local function lower(s) return string.lower(tostring(s or "")) end
local function tags(s)
    local t = {}
    for x in string.gmatch(s or "", "%S+") do t[lower(x)] = true end
    return t
end
local function hasTag(set, wanted) return set and set[lower(wanted)] == true end
local function detectSide(s)
    return s:match("%f[%w]side%s*%(%s*([^%)%s]+)%s*%)") or s:match("%f[%w]s%s*%(%s*([^%)%s]+)%s*%)")
end

local function balancedRecords(raw)
    local out, buf, stack = {}, {}, {}
    local quoted, escaped, comment = false, false, false
    for i = 1, #raw do
        local ch = raw:sub(i, i)
        if comment then
            if ch == "\n" then comment = false; if #stack > 0 then buf[#buf + 1] = " " end end
        elseif quoted then
            buf[#buf + 1] = ch
            if escaped then escaped = false elseif ch == "\\" then escaped = true elseif ch == '"' then quoted = false end
        elseif ch == ";" then comment = true
        elseif ch == '"' then if #stack > 0 then buf[#buf + 1] = ch; quoted = true end
        elseif ch == "(" or ch == "{" then stack[#stack + 1] = ch; buf[#buf + 1] = ch
        elseif ch == ")" or ch == "}" then
            if #stack > 0 then
                buf[#buf + 1] = ch; stack[#stack] = nil
                if #stack == 0 then out[#out + 1] = table.concat(buf); buf = {} end
            end
        elseif #stack > 0 then buf[#buf + 1] = ch end
    end
    return out
end

local function detectRole(line, tagset, vehicle)
    local x = lower(line)
    local template = lower(line:match('%(%s*"([^"]+)"') or "")
    if hasTag(tagset, "aircraft") or template == "p" or template == "h" then
        if template == "h" or hasTag(tagset, "duel_heli") or hasTag(tagset, "duel_heli2") or x:find("helic", 1, true) then return "attack_heli" end
        return "fixed_wing"
    end
    if hasTag(tagset, "pointstart") then return "pointstart" end
    if hasTag(tagset, "aat") or hasTag(tagset, "antiair") then return "antiair" end
    if hasTag(tagset, "recon") then return "recon" end
    if hasTag(tagset, "duel_tanks70") or hasTag(tagset, "duel_tanks80") or hasTag(tagset, "duel_tanks90") or hasTag(tagset, "tanks_only") then return "tank" end
    if hasTag(tagset, "artsupport") or hasTag(tagset, "art") then return "artillery" end
    if hasTag(tagset, "infantry") and vehicle then
        for passenger in line:gmatch("%f[%w]n[%da-z]+%s*%(%s*([^: %)]+)%s*:") do
            local p = lower(passenger)
            if not p:find("tankman", 1, true) and not p:find("pilot", 1, true) and not p:find("vehicle_supporter", 1, true) then
                return "mech_inf"
            end
        end
        return "transport"
    end
    if not vehicle then return "infantry" end
    if hasTag(tagset, "infantry") then return "mech_inf" end
    return "other"
end

local function readUnitsFile(path, army)
    local f = io.open(path, "r")
    if not f then return 0 end
    local raw = f:read("*a"); f:close()
    local n = 0
    for _, line in ipairs(balancedRecords(raw)) do
        local side = detectSide(line)
        if side and lower(side) == lower(army) then
            local tt = {}
            for s in line:gmatch("%f[%w]t%s*%(([^)]*)%)") do tt[#tt + 1] = s end
            local tagText = table.concat(tt, " ")
            local tagset = tags(tagText)
            local vehicle = line:match('^%s*{%s*"([^"]+)"')
            local name = vehicle or line:match("%f[%w]name%s*%(([^)]+)%)")
            local nobot = hasTag(tagset, "nobot")
            if name and not name:find("mp/", 1, true) then
                local role = detectRole(line, tagset, vehicle ~= nil)
                local allowNobotHeli = role == "attack_heli" and NEU_BOT.Air and NEU_BOT.Air.AllowAttackHelicopters
                local id = vehicle or (name .. "(" .. army .. ")")
                if (not nobot or allowNobotHeli) and role ~= "fixed_wing" and not C.UnitSeen[id] then
                    C.UnitSeen[id] = true
                    C.Units[#C.Units + 1] = { unit = id, role = role, raw = line, tags = tagText, tagset = tagset, nobot = nobot }
                    n = n + 1
                end
            end
        end
    end
    return n
end

function N.loadUnits()
    C.Units, C.UnitSeen, C.RoleCursor = {}, {}, {}
    local base = "mods\\" .. NEU_BOT.ModFolder .. "\\resource\\set\\multiplayer\\units\\"
    local files = { "units_nato.set", "units_rus.set", "units_usa.set", "units_cn.set", "units_ch.set", "units_nov.set", "units_ukr.set", "units_wagner.set" }
    local total = 0
    for _, name in ipairs(files) do total = total + readUnitsFile(base .. name, BotApi.Instance.army) end
    N.log("UNITS loaded=" .. tostring(#C.Units) .. " parsed=" .. tostring(total) .. " army=" .. tostring(BotApi.Instance.army))
end

function N.buildCandidates()
    local roles = { "pointstart", "recon", "infantry", "mech_inf", "tank", "attack_heli", "antiair", "artillery", "transport", "other" }
    C.Candidates = {}
    for _, r in ipairs(roles) do C.Candidates[r] = {} end
    for _, u in ipairs(C.Units) do
        if C.Candidates[u.role] then C.Candidates[u.role][#C.Candidates[u.role] + 1] = u end
    end
    for _, r in ipairs(roles) do N.log("ROLE " .. r .. " candidates=" .. tostring(#C.Candidates[r])) end
end

function N.flags()
    local o = { mine = {}, enemy = {}, neutral = {}, mineCount = 0, enemyCount = 0, neutralCount = 0 }
    local my, enemy = BotApi.Instance.team, BotApi.Instance.enemyTeam
    for _, f in pairs(BotApi.Scene.Flags) do
        if f.occupant == my then o.mine[#o.mine + 1] = f.name; o.mineCount = o.mineCount + 1
        elseif f.occupant == enemy then o.enemy[#o.enemy + 1] = f.name; o.enemyCount = o.enemyCount + 1
        else o.neutral[#o.neutral + 1] = f.name; o.neutralCount = o.neutralCount + 1 end
    end
    return o
end
function N.flag(name) for _, f in pairs(BotApi.Scene.Flags) do if f.name == name then return f end end end
function N.owner(name) local f = N.flag(name); return f and f.occupant or nil end
function N.alive(id) return id ~= nil and BotApi.Scene:IsSquadExists(id) end
function N.aliveRoleCount(role)
    local n = 0
    for id, r in pairs(C.SquadRole) do if r == role and N.alive(id) then n = n + 1 end end
    return n
end
function N.sortFlags(a)
    table.sort(a, function(x, y) return tostring(x) < tostring(y) end)
end

function N.capture(id, flag, force)
    if not (N.alive(id) and N.flag(flag)) then return false end
    local last = C.LastOrder[id]
    local cd = (NEU_BOT.Strategy and NEU_BOT.Strategy.OrderCooldownSec) or 15
    if not force and last and last.flag == flag and C.Time - (last.time or 0) < cd then return false end
    C.LastOrder[id] = { flag = flag, time = C.Time }
    local ok, result = pcall(function() return BotApi.Commands:CaptureFlag(id, flag) end)
    if not ok or result == false then
        N.log("ORDER REJECTED squad=" .. tostring(id) .. " flag=" .. tostring(flag) .. " result=" .. tostring(result))
        return false
    end
    N.log("ORDER squad=" .. tostring(id) .. " role=" .. tostring(C.SquadRole[id]) .. " flag=" .. tostring(flag))
    return true
end

local function rolePrice(role)
    return (NEU_BOT.Economy.Price[role] or NEU_BOT.Economy.Price.other)
end
local function roleCooldown(role)
    return (NEU_BOT.Economy.Cooldown[role] or NEU_BOT.Economy.Cooldown.other)
end
function N.roleReady(role)
    local t = C.Economy.roleReadyAt[role]
    return t == nil or C.Time >= t
end
function N.canAfford(role, ignoreReserve)
    local p = rolePrice(role)
    if ignoreReserve then return C.Economy.points >= p end
    return C.Economy.points - p >= NEU_BOT.Economy.ReservePoints
end
function N.charge(role)
    local p = rolePrice(role)
    C.Economy.points = C.Economy.points - p
    C.Economy.spent = C.Economy.spent + p
    C.Economy.roleReadyAt[role] = C.Time + roleCooldown(role)
    N.log("BUY role=" .. tostring(role) .. " price=" .. tostring(p) .. " BP=" .. tostring(C.Economy.points))
end

function N.pending(role)
    for _, x in ipairs(C.SpawnIntents) do if x.role == role then return true end end
    return C.AwaitingArrival and C.AwaitingArrival.role == role
end

function N.queue(role, reason, ignoreReserve, target, priority)
    C.SpawnIntents[#C.SpawnIntents + 1] = {
        role = role, reason = reason or "", ignoreReserve = ignoreReserve == true,
        target = target, priority = priority or 50, due = C.Time,
        requestedAt = C.Time, cursor = 0, tried = {}
    }
    N.log("QUEUE role=" .. tostring(role) .. " reason=" .. tostring(reason) .. " target=" .. tostring(target))
    return true
end

local function chooseIntent()
    local best = nil
    for i, x in ipairs(C.SpawnIntents) do
        if x.due <= C.Time then
            if not best or x.priority > C.SpawnIntents[best].priority or
               (x.priority == C.SpawnIntents[best].priority and x.requestedAt < C.SpawnIntents[best].requestedAt) then best = i end
        end
    end
    return best
end

local function removeTicket(ticket)
    for i = #C.SpawnTickets, 1, -1 do if C.SpawnTickets[i] == ticket then table.remove(C.SpawnTickets, i); return end end
end

local function spawnFailed(x, why)
    N.log("SPAWN FAILED role=" .. tostring(x.role) .. " reason=" .. tostring(x.reason) .. " why=" .. tostring(why))
    C.Economy.roleReadyAt[x.role] = C.Time + ((NEU_BOT.Strategy and NEU_BOT.Strategy.FailedRoleBackoffSec) or 30)
    if type(N.onSpawnFailed) == "function" then N.onSpawnFailed(x.role, x.reason, x) end
end

function N.processSpawn()
    if C.Spawning or C.AwaitingArrival then return end
    local idx = chooseIntent(); if not idx then return end
    local x = table.remove(C.SpawnIntents, idx)
    local timeout = (NEU_BOT.Strategy and NEU_BOT.Strategy.SpawnTimeoutSec) or 60
    local retry = (NEU_BOT.Strategy and NEU_BOT.Strategy.SpawnRetryEverySec) or 2
    if x.startedAt and C.Time - x.startedAt >= timeout then spawnFailed(x, "timeout"); return end
    if not N.roleReady(x.role) or not N.canAfford(x.role, x.ignoreReserve) then
        x.due = C.Time + 1; C.SpawnIntents[#C.SpawnIntents + 1] = x; return
    end
    x.startedAt = x.startedAt or C.Time
    local list = C.Candidates[x.role] or {}
    if #list == 0 then spawnFailed(x, "no candidates"); return end
    local candidate = nil
    for step = 1, #list do
        x.cursor = (x.cursor % #list) + 1
        local u = list[x.cursor]
        if not x.tried[u.unit] then candidate = u; break end
    end
    if not candidate then
        x.tried = {}; x.due = C.Time + retry; C.SpawnIntents[#C.SpawnIntents + 1] = x; return
    end
    x.tried[candidate.unit] = true
    local ticket = { role = x.role, unit = candidate.unit, reason = x.reason, target = x.target, intent = x }
    C.SpawnTickets[#C.SpawnTickets + 1] = ticket
    C.AwaitingArrival = ticket
    C.Spawning = true
    local ok = BotApi.Commands:Spawn(candidate.unit, MaxSquadSize)
    C.Spawning = false
    local callbackAlreadyArrived = C.AwaitingArrival ~= ticket
    if ok or callbackAlreadyArrived then
        N.charge(x.role)
        N.log("SPAWN OK role=" .. tostring(x.role) .. " unit=" .. tostring(candidate.unit))
    else
        if C.AwaitingArrival == ticket then C.AwaitingArrival = nil end
        removeTicket(ticket)
        x.due = C.Time + retry
        C.SpawnIntents[#C.SpawnIntents + 1] = x
        N.log("SPAWN REJECTED role=" .. tostring(x.role) .. " unit=" .. tostring(candidate.unit) .. " -> retry")
    end
end

function N.enemyTankCount()
    if type(NEU_EnemyTankCount) == "function" then
        local ok, v = pcall(NEU_EnemyTankCount)
        if ok and type(v) == "number" then return v end
    end
    local a = rawget(_G, "NEU_TacticalAdapter")
    if type(a) == "table" and type(a.getEnemyTankCount) == "function" then
        local ok, v = pcall(a.getEnemyTankCount)
        if ok and type(v) == "number" then return v end
    end
    return nil
end

return N

