-- NEU BOT 2.0 logic
-- Behaviour source of truth: BOT_MEMORY/BOT_LOGIC_CURRENT.json
local N = require([[/script/multiplayer/bot.core]])
local C = N.C

-- ---------- compact telemetry ----------
local TF = { path = nil, bytes = 0, ready = false, last = -999 }
local function esc(v) return tostring(v or ""):gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\r", "\\r"):gsub("\n", "\\n") end
local function q(v) return '"' .. esc(v) .. '"' end
local function append(s)
    if not TF.ready or not TF.path then return end
    if TF.bytes + #s + 2 > (NEU_BOT.TelemetryMaxBytes or 2300000) then return end
    local f = io.open(TF.path, "a"); if not f then TF.ready = false; return end
    f:write(s, "\n"); f:close(); TF.bytes = TF.bytes + #s + 1
end
local function initTelemetry()
    local team = tostring(BotApi.Instance.team or "bot"):gsub("[^%w_-]", "_")
    TF.path = "mods\\" .. NEU_BOT.ModFolder .. "\\resource\\script\\multiplayer\\bot_gpt_telemetry_" .. team .. ".jsonl"
    local f = io.open(TF.path, "w")
    if not f then TF.path = "bot_gpt_telemetry_" .. team .. ".jsonl"; f = io.open(TF.path, "w") end
    if f then
        local s = '{"type":"session","v":"2.0","team":' .. q(BotApi.Instance.team) .. ',"enemy":' .. q(BotApi.Instance.enemyTeam) .. ',"logic":"BOT_LOGIC_CURRENT","geometry":"disabled-until-runtime-map-id"}'
        f:write(s, "\n"); f:close(); TF.bytes = #s + 1; TF.ready = true
    end
end
local baseLog = N.log
function N.log(m)
    baseLog(m)
    local x = tostring(m or "")
    if TF.ready and (x:find("STATE ",1,true) or x:find("TARGET ",1,true) or x:find("LOST ",1,true) or x:find("SPAWN ",1,true) or x:find("ARRIVED ",1,true) or x:find("HELI ",1,true)) then
        append('{"type":"event","v":"2.0","t":' .. tostring(C.Time or 0) .. ',"team":' .. q(BotApi.Instance.team) .. ',"m":' .. q(x) .. '}')
    end
end
local function snapshot()
    if not TF.ready then return end
    local f = N.flags(); local squads = {}
    for id, role in pairs(C.SquadRole) do
        if N.alive(id) then squads[#squads + 1] = '[' .. tostring(id) .. ',' .. q(role) .. ',' .. q(C.SquadTargets[id] or "") .. ']' end
    end
    table.sort(squads)
    append('{"type":"snapshot","v":"2.0","t":' .. tostring(C.Time) .. ',"state":' .. q(C.State) .. ',"bp":' .. tostring(C.Economy.points) .. ',"mine":' .. f.mineCount .. ',"enemy":' .. f.enemyCount .. ',"neutral":' .. f.neutralCount .. ',"squads":[' .. table.concat(squads, ",") .. ']}')
end

-- ---------- flags / targeting ----------
local function clearTargets()
    C.SquadTargets = {}
    C.DeferredOrders = {}
end
local function attackFlags()
    local out = {}
    for _, flag in pairs(BotApi.Scene.Flags) do
        if flag.occupant ~= BotApi.Instance.team then
            out[#out + 1] = { name = flag.name, neutral = flag.occupant ~= BotApi.Instance.enemyTeam }
        end
    end
    table.sort(out, function(a,b)
        if a.neutral ~= b.neutral then return a.neutral end
        return tostring(a.name) < tostring(b.name)
    end)
    return out
end
local function cleanTargets()
    for id, target in pairs(C.SquadTargets) do
        if not N.alive(id) or not N.flag(target) or N.owner(target) == BotApi.Instance.team then C.SquadTargets[id] = nil end
    end
end
local function targetLoad(name)
    local n = 0
    for id, target in pairs(C.SquadTargets) do if N.alive(id) and target == name then n = n + 1 end end
    return n
end
local function assignSquadTarget(id)
    cleanTargets()
    local old = C.SquadTargets[id]
    if old and N.owner(old) ~= BotApi.Instance.team then return old end
    local selected, selectedLoad = nil, nil
    for _, flag in ipairs(attackFlags()) do
        local load = targetLoad(flag.name)
        if not selected or load < selectedLoad
            or (load == selectedLoad and flag.neutral and not selected.neutral)
            or (load == selectedLoad and flag.neutral == selected.neutral and tostring(flag.name) < tostring(selected.name)) then
            selected, selectedLoad = flag, load
        end
    end
    local best = selected and selected.name or nil
    C.SquadTargets[id] = best
    if best then N.log("TARGET squad=" .. tostring(id) .. " role=" .. tostring(C.SquadRole[id]) .. " flag=" .. tostring(best) .. " load=" .. tostring(selectedLoad) .. " neutral=" .. tostring(selected.neutral)) end
    return best
end
local function ownFlags()
    local f = N.flags(); N.sortFlags(f.mine); return f.mine
end
local defendCursor = 0
local function chooseDefendFlag()
    local a = ownFlags(); if #a == 0 then return nil end
    defendCursor = defendCursor + 1; if defendCursor > #a then defendCursor = 1 end
    return a[defendCursor]
end

-- ---------- orders ----------
local function deferOrder(id, flag, delay)
    for i = #C.DeferredOrders, 1, -1 do if C.DeferredOrders[i].id == id then table.remove(C.DeferredOrders, i) end end
    C.DeferredOrders[#C.DeferredOrders + 1] = { id = id, flag = flag, due = C.Time + delay }
end
local function processDeferredOrders()
    for i = #C.DeferredOrders, 1, -1 do
        local x = C.DeferredOrders[i]
        if C.Time >= x.due then
            if C.State == "EXPAND" and N.alive(x.id) and C.SquadTargets[x.id] == x.flag and N.owner(x.flag) ~= BotApi.Instance.team then N.capture(x.id, x.flag, false) end
            table.remove(C.DeferredOrders, i)
        end
    end
end
local function issueRoleOrder(id, role)
    if C.State == "OPENING" then return end
    if C.State == "DEFEND" or C.State == "WAIT_REINFORCEMENT" then
        local home = chooseDefendFlag(); if home then N.capture(id, home, false) end
        return
    end
    local target = assignSquadTarget(id); if not target then return end
    if role == "tank" or role == "recon" or role == "attack_heli" then
        deferOrder(id, target, NEU_BOT.Strategy.VehicleFollowDelaySec)
    else
        N.capture(id, target, false)
    end
end
local function sortedLivingSquads()
    local ids = {}
    for id, role in pairs(C.SquadRole) do if role ~= "dead" and N.alive(id) then ids[#ids + 1] = id end end
    table.sort(ids, function(a,b)
        local ra, rb = C.SquadRole[a], C.SquadRole[b]
        local function p(r) if r == "infantry" then return 1 elseif r == "mech_inf" then return 2 else return 3 end end
        if p(ra) ~= p(rb) then return p(ra) < p(rb) end
        return tostring(a) < tostring(b)
    end)
    return ids
end
local function refreshOrders()
    if C.State == "EXPAND" then cleanTargets() end
    for _, id in ipairs(sortedLivingSquads()) do issueRoleOrder(id, C.SquadRole[id]) end
end
local function defendAll()
    C.DeferredOrders = {}
    for _, id in ipairs(sortedLivingSquads()) do local f = chooseDefendFlag(); if f then N.capture(id, f, true) end end
end

-- ---------- state machine / losses ----------
local function importantRole(role)
    for _, r in ipairs(NEU_BOT.ImportantRoles or {}) do if r == role then return true end end
    return false
end
local function replacementQueued(role)
    for _, r in ipairs(C.Replacements or {}) do if r == role then return true end end
    return C.ReplacementPending and C.ReplacementRole == role
end
local function enqueueReplacement(role)
    C.Replacements = C.Replacements or {}
    if not replacementQueued(role) then C.Replacements[#C.Replacements + 1] = role; N.log("REPLACEMENT QUEUED role=" .. tostring(role)) end
end
local function detectLosses()
    for id, role in pairs(C.SquadRole) do
        if not C.Dead[id] and not N.alive(id) then
            C.Dead[id] = true; C.SquadTargets[id] = nil
            N.log("LOST squad=" .. tostring(id) .. " role=" .. tostring(role))
            if C.State ~= "OPENING" and importantRole(role) then enqueueReplacement(role) end
        end
    end
end
local function processReplacementQueue()
    C.Replacements = C.Replacements or {}
    if C.ReplacementPending or #C.Replacements == 0 then return end
    local role = C.Replacements[1]
    if N.pending(role) then return end
    C.ReplacementRole = role; C.ReplacementPending = true
    N.queue(role, "replacement", true, nil, 120)
end
local function completeReplacement(role)
    C.Replacements = C.Replacements or {}
    for i, r in ipairs(C.Replacements) do if r == role then table.remove(C.Replacements, i); break end end
    C.ReplacementRole = nil; C.ReplacementPending = false
    N.log("REPLACEMENT ARRIVED role=" .. tostring(role))
end
local function shouldDefend(f) return f.mineCount >= f.enemyCount + NEU_BOT.Strategy.FlagAdvantageToDefend end
local function setState(state, reason)
    if C.State == state then return end
    C.State = state
    N.log("STATE -> " .. state .. " reason=" .. tostring(reason or ""))
    if state == "DEFEND" or state == "WAIT_REINFORCEMENT" then clearTargets(); defendAll()
    elseif state == "EXPAND" then clearTargets(); refreshOrders() end
end
local function updateStrategicState()
    if C.State == "OPENING" then return end
    C.Replacements = C.Replacements or {}
    if C.ReplacementPending or #C.Replacements > 0 then setState("WAIT_REINFORCEMENT", "important loss"); return end
    local f = N.flags()
    if shouldDefend(f) then setState("DEFEND", "flag advantage") else setState("EXPAND", "need flags") end
end
local function updateOwnership()
    for _, f in pairs(BotApi.Scene.Flags) do
        local now = f.occupant == BotApi.Instance.team
        local prev = C.PreviousOwn[f.name]
        if prev and not now then C.LostOwn[f.name] = C.Time; N.log("LOST FLAG " .. tostring(f.name))
        elseif now then C.LostOwn[f.name] = nil end
        C.PreviousOwn[f.name] = now
    end
end

-- ---------- opening / infantry ----------
local function processOpening()
    if C.State ~= "OPENING" then return end
    local role = NEU_BOT.Opening[C.OpeningIndex]
    if not role then setState("EXPAND", "opening complete"); return end
    if not N.pending(role) then N.queue(role, "opening", true, nil, 110) end
end
local function replenishInfantry()
    if C.State == "OPENING" then return end
    if N.aliveRoleCount("infantry") == 0 and not N.pending("infantry") then N.queue("infantry", "infantry replacement", true, nil, 105) end
end

-- ---------- helicopter gate ----------
local function maybeCallAttackHelicopter()
    if not NEU_BOT.Air.AllowAttackHelicopters then return end
    if N.aliveRoleCount("attack_heli") >= NEU_BOT.Air.MaxAttackHelicopters or N.pending("attack_heli") then return end
    local count = N.enemyTankCount(); C.EnemyTankCount = count
    if type(count) ~= "number" then
        if not C.HeliBlockedLogged then C.HeliBlockedLogged = true; N.log("HELI BLOCKED exact enemy tank count unavailable; boolean EnemyHasTanks is insufficient") end
        return
    end
    if count >= NEU_BOT.Air.RequiredEnemyTankCount then
        N.log("HELI UNLOCK enemyTanks=" .. tostring(count)); N.queue("attack_heli", "enemy tanks >= 3", false, nil, 70)
    end
end

-- ---------- spawn callbacks ----------
function N.onSpawnFailed(role, reason, intent)
    if reason == "opening" and C.State == "OPENING" then
        C.OpeningIndex = C.OpeningIndex + 1
        N.log("OPENING skip unavailable role=" .. tostring(role))
    elseif reason == "replacement" then
        completeReplacement(role)
        N.log("REPLACEMENT unavailable role=" .. tostring(role) .. " -> released")
    end
end
local function registerArrival(id, ticket)
    local role = ticket.role
    C.SquadRole[id] = role; C.Dead[id] = false
    N.log("ARRIVED squad=" .. tostring(id) .. " role=" .. tostring(role) .. " reason=" .. tostring(ticket.reason))
    if ticket.reason == "opening" and C.State == "OPENING" then C.OpeningIndex = C.OpeningIndex + 1 end
    if ticket.reason == "replacement" then completeReplacement(role) end
    if C.State ~= "OPENING" then issueRoleOrder(id, role) end
end

-- ---------- clock ----------
local function onSecond()
    C.Time = C.Time + 1
    C.Economy.points = C.Economy.points + NEU_BOT.Economy.IncomePerSecond
    C.Economy.earned = C.Economy.earned + NEU_BOT.Economy.IncomePerSecond
    updateOwnership(); detectLosses(); processReplacementQueue(); processOpening(); processDeferredOrders()
    if C.Time >= C.NextReevaluateAt then C.NextReevaluateAt = C.Time + NEU_BOT.Strategy.ReevaluateEverySec; replenishInfantry(); updateStrategicState() end
    if C.Time >= C.NextOrderRefreshAt then C.NextOrderRefreshAt = C.Time + NEU_BOT.Strategy.OrderRefreshEverySec; refreshOrders() end
    if C.Time >= C.NextHeliCheckAt then C.NextHeliCheckAt = C.Time + NEU_BOT.Strategy.AttackHeliCheckEverySec; maybeCallAttackHelicopter() end
    N.processSpawn()
    if C.Time - TF.last >= (NEU_BOT.TelemetrySnapshotSec or 15) then TF.last = C.Time; snapshot() end
    if C.Time % 30 == 0 then local f = N.flags(); N.log("STATE SNAP t=" .. C.Time .. " state=" .. C.State .. " BP=" .. C.Economy.points .. " flags=" .. f.mineCount .. "/" .. f.enemyCount .. "/" .. f.neutralCount) end
end
local function stopClock()
    C.TimerGeneration = C.TimerGeneration + 1
    if C.Timer then BotApi.Events:KillQuantTimer(C.Timer); C.Timer = nil end
end
local function startClock()
    stopClock(); local gen = C.TimerGeneration
    local function pulse()
        if gen ~= C.TimerGeneration then return end
        C.Timer = nil; onSecond()
        if gen == C.TimerGeneration then C.Timer = BotApi.Events:SetQuantTimer(pulse, NEU_BOT.TickMs or 1000) end
    end
    C.Timer = BotApi.Events:SetQuantTimer(pulse, NEU_BOT.TickMs or 1000)
end

function onGameStart()
    C.Time = 0; C.State = "OPENING"; C.OpeningIndex = 1
    C.SpawnIntents = {}; C.SpawnTickets = {}; C.AwaitingArrival = nil; C.Spawning = false
    C.SquadRole = {}; C.SquadTargets = {}; C.Dead = {}; C.LastOrder = {}; C.DeferredOrders = {}
    C.PreviousOwn = {}; C.LostOwn = {}; C.Replacements = {}; C.ReplacementRole = nil; C.ReplacementPending = false
    C.Economy = { points = NEU_BOT.Economy.StartPoints, spent = 0, earned = 0, roleReadyAt = {} }
    C.NextReevaluateAt = 0; C.NextOrderRefreshAt = 0; C.NextHeliCheckAt = 0; C.HeliBlockedLogged = false; C.EnemyTankCount = nil
    for _, f in pairs(BotApi.Scene.Flags) do C.PreviousOwn[f.name] = f.occupant == BotApi.Instance.team end
    local host = tonumber(BotApi.Instance.hostId) or 1; math.randomseed(os.time() + host * 101)
    initTelemetry(); N.loadUnits(); N.buildCandidates()
    N.log("START BOT 2.0 team=" .. tostring(BotApi.Instance.team) .. " BP=" .. tostring(C.Economy.points))
    N.log("START geometry movement/formation disabled until reliable runtime map id + coordinate bridge are confirmed")
    snapshot(); processOpening(); N.processSpawn(); startClock()
end

function onGameStop() snapshot(); stopClock(); collectgarbage("collect") end
function onGameQuant() N.processSpawn() end
function onGameSpawn(args)
    local id = args and args.squadId; if not id then return end
    local ticket = #C.SpawnTickets > 0 and table.remove(C.SpawnTickets, 1) or nil
    if not ticket then N.log("UNMATCHED squad=" .. tostring(id) .. " ignored (passenger/crew protection)"); return end
    if C.AwaitingArrival == ticket then C.AwaitingArrival = nil end
    registerArrival(id, ticket)
    processOpening(); processReplacementQueue(); N.processSpawn()
end
