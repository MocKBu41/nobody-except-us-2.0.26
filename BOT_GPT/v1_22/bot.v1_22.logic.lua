-- NEU BOT v1.22
-- Coordinate tactics layer on top of the proven v1.21 bot.
--
-- Behaviour:
--   * every assault squad receives a route point 30 m from own spawn;
--   * infantry reaches a 100 m deployment line, dismounts when a bridge exists,
--     spreads into a front with 5..6 m spacing and advances on the flag;
--   * tank stops at a stable pseudo-random position 50..100 m from the flag;
--   * infantry carrier / IFV stops at a stable pseudo-random position 20..50 m;
--   * every planned movement point is printed as MOVEPOINT/MEMBERPOINT so the
--     HTML visualizer can draw all squads and their movement lines.
--
-- Stock MoWAS2 BotApi can only CaptureFlag(squad, flag). Exact coordinates and
-- individual soldiers require the optional low-level bridge functions below.
-- The script NEVER crashes if a bridge is absent: it logs the desired points
-- and falls back to the original v1.21 order where that is safe.

local R = require([[/script/multiplayer/bot.v1_21.logic]])
local N = NEU21
local C = N.C

local oldCapture = N.capture

local CFG = {
    spawnExit = 30.0,
    infantryDeploy = 100.0,
    infantrySpacing = 5.5,
    infantryGoalBack = 4.0,
    defaultMembers = 8,
    tankMin = 50.0,
    tankMax = 100.0,
    ifvMin = 20.0,
    ifvMax = 50.0,
    tankLateral = 28.0,
    ifvLateral = 20.0
}

local function stable01(id, salt)
    local n = math.abs(tonumber(id) or 0)
    local s = tonumber(salt) or 0
    return ((n * 1103515245 + 12345 + s * 7919) % 10000) / 9999.0
end

local function stableRange(id, salt, a, b)
    return a + stable01(id, salt) * (b - a)
end

local function targetGeometry(flagName)
    if not (N.MAP and N.MAP.loaded and N.MAP.spawn and flagName) then return nil end
    local flag = N.MAP:point(flagName)
    local spawn = N.MAP.spawn
    if not (flag and flag.x and flag.y and spawn.x and spawn.y) then return nil end

    local dx = flag.x - spawn.x
    local dy = flag.y - spawn.y
    local len = math.sqrt(dx * dx + dy * dy)
    if len < 1.0 then return nil end

    local ux, uy = dx / len, dy / len
    return {
        flag = flagName,
        spawnX = spawn.x,
        spawnY = spawn.y,
        spawnZ = spawn.z,
        flagX = flag.x,
        flagY = flag.y,
        flagZ = flag.z,
        ux = ux,
        uy = uy,
        px = -uy,
        py = ux,
        length = len
    }
end

local function pointFromFlag(geo, back, lateral)
    local b = math.min(back or 0, math.max(0, geo.length - 5))
    local l = lateral or 0
    return {
        x = geo.flagX - geo.ux * b + geo.px * l,
        y = geo.flagY - geo.uy * b + geo.py * l,
        z = geo.flagZ,
        distance = b,
        lateral = l
    }
end

local function spawnExitPoint(geo)
    local d = math.min(CFG.spawnExit, math.max(5, geo.length * 0.25))
    return {
        x = geo.spawnX + geo.ux * d,
        y = geo.spawnY + geo.uy * d,
        z = geo.spawnZ or geo.flagZ,
        distance = d,
        lateral = 0
    }
end

local function logMovePoint(id, role, phase, kind, p, geo, extra)
    N.log(string.format(
        'MOVEPOINT squad=%s group=%s role=%s phase=%s kind=%s x=%.2f y=%.2f target=%s targetX=%.2f targetY=%.2f spawnX=%.2f spawnY=%.2f%s',
        tostring(id), tostring(C.SquadGroup[id]), tostring(role), tostring(phase), tostring(kind),
        p.x, p.y, tostring(geo.flag), geo.flagX, geo.flagY, geo.spawnX, geo.spawnY,
        extra and (' '..extra) or ''))
end

local function coordinateBridge()
    return type(NEU_EngineMove) == 'function' and NEU_EngineMove or nil
end

local function carrierBridge()
    return type(NEU_EngineMoveCarrier) == 'function' and NEU_EngineMoveCarrier or nil
end

local function memberBridge()
    return type(NEU_EngineMoveMember) == 'function' and NEU_EngineMoveMember or nil
end

local function memberCountBridge()
    return type(NEU_EngineMemberCount) == 'function' and NEU_EngineMemberCount or nil
end

local function disembarkBridge()
    return type(NEU_EngineDisembark) == 'function' and NEU_EngineDisembark or nil
end

local function issueCoordinate(id, role, phase, kind, p, geo, force)
    local last = C.LastOrder[id]
    if not force and last and last.kind == kind and last.flag == geo.flag and
       C.Time - (last.time or 0) < (NEU_BOT.OrderCooldownSec or 10) then
        return true
    end

    logMovePoint(id, role, phase, kind, p, geo)
    local bridge = coordinateBridge()
    if not bridge then
        C.LastOrder[id] = {kind=kind, flag=geo.flag, time=C.Time, x=p.x, y=p.y, bridge=false}
        return false
    end

    local ok, result = pcall(bridge, id, p.x, p.y, p.z)
    if not ok or result == false then
        N.log('MOVE FAILED squad='..tostring(id)..' kind='..kind..' err='..tostring(result))
        return false
    end

    C.LastOrder[id] = {kind=kind, flag=geo.flag, time=C.Time, x=p.x, y=p.y, bridge=true}
    return true
end

local function tankPoint(id, geo)
    local back = stableRange(id, 11, CFG.tankMin, CFG.tankMax)
    local lateral = stableRange(id, 12, -CFG.tankLateral, CFG.tankLateral)
    return pointFromFlag(geo, back, lateral)
end

local function ifvPoint(id, geo)
    local back = stableRange(id, 21, CFG.ifvMin, CFG.ifvMax)
    local lateral = stableRange(id, 22, -CFG.ifvLateral, CFG.ifvLateral)
    return pointFromFlag(geo, back, lateral)
end

local function infantryDeployPoint(id, geo)
    local lateral = stableRange(id, 31, -10.0, 10.0)
    return pointFromFlag(geo, CFG.infantryDeploy, lateral)
end

local function moveCarrier(id, phase, geo, force)
    local p = ifvPoint(id, geo)
    logMovePoint(id, 'ifv', phase, 'ifv_standoff', p, geo,
        string.format('distance=%.1f lateral=%.1f', p.distance, p.lateral))

    local bridge = carrierBridge()
    if not bridge then return false end

    local key = 'ifv_standoff_'..tostring(id)
    C.NEU22CarrierOrder = C.NEU22CarrierOrder or {}
    local last = C.NEU22CarrierOrder[key]
    if not force and last and C.Time - (last.time or 0) < (NEU_BOT.OrderCooldownSec or 10) then return true end

    local ok, result = pcall(bridge, id, p.x, p.y, p.z)
    if ok and result ~= false then
        C.NEU22CarrierOrder[key] = {time=C.Time, x=p.x, y=p.y, flag=geo.flag}
        return true
    end
    N.log('IFV MOVE FAILED squad='..tostring(id)..' err='..tostring(result))
    return false
end

local function getMemberCount(id)
    local fn = memberCountBridge()
    if fn then
        local ok, n = pcall(fn, id)
        n = ok and tonumber(n) or nil
        if n and n >= 1 and n <= 32 then return math.floor(n) end
    end
    return CFG.defaultMembers
end

local function orderInfantryFront(id, geo, force)
    C.NEU22FrontOrdered = C.NEU22FrontOrdered or {}
    local rec = C.NEU22FrontOrdered[id]
    if not force and rec and rec.flag == geo.flag and C.Time - (rec.time or 0) < (NEU_BOT.OrderCooldownSec or 10) then
        return rec.bridge == true
    end

    local dis = disembarkBridge()
    if dis then pcall(dis, id) end

    -- Keep the carrier behind the soldiers. This is independent from the
    -- soldier front and therefore still works when the transport is part of
    -- the infantry purchase.
    moveCarrier(id, 'attack', geo, force)

    local count = getMemberCount(id)
    local moveMember = memberBridge()
    local center = (count + 1) * 0.5
    local allOk = moveMember ~= nil

    for i = 1, count do
        local lateral = (i - center) * CFG.infantrySpacing
        local stage = pointFromFlag(geo, CFG.infantryDeploy, lateral)
        local goal = pointFromFlag(geo, CFG.infantryGoalBack, lateral)
        N.log(string.format(
            'MEMBERPOINT squad=%s group=%s member=%d spacing=%.1f stageX=%.2f stageY=%.2f goalX=%.2f goalY=%.2f target=%s targetX=%.2f targetY=%.2f',
            tostring(id), tostring(C.SquadGroup[id]), i, CFG.infantrySpacing,
            stage.x, stage.y, goal.x, goal.y, tostring(geo.flag), geo.flagX, geo.flagY))
        if moveMember then
            local ok, result = pcall(moveMember, id, i, goal.x, goal.y, goal.z)
            if not ok or result == false then allOk = false end
        end
    end

    C.NEU22FrontOrdered[id] = {time=C.Time, flag=geo.flag, bridge=allOk}
    if allOk then
        N.log('INFANTRY FRONT ACTIVE squad='..tostring(id)..' members='..count..' spacing='..CFG.infantrySpacing)
        return true
    end

    N.log('INFANTRY FRONT PLAN squad='..tostring(id)..' members='..count..' BRIDGE=WAIT')
    return false
end

local function assaultContext(id)
    local gid = C.SquadGroup[id]
    local g = gid and C.Groups[gid] or nil
    local role = C.SquadRole[id]
    if not (g and g.target and (role == 'tank' or role == 'infantry' or role == 'infantry_detached')) then
        return nil
    end
    local geo = targetGeometry(g.target)
    if not geo then return nil end
    return g, role, geo
end

function N.tankStandoffPoint(flagName, squadId)
    local geo = targetGeometry(flagName)
    if not geo then return nil end
    local p = tankPoint(squadId, geo)
    p.flag = flagName
    p.spawnX, p.spawnY = geo.spawnX, geo.spawnY
    p.flagX, p.flagY = geo.flagX, geo.flagY
    return p
end

function N.ifvStandoffPoint(flagName, squadId)
    local geo = targetGeometry(flagName)
    if not geo then return nil end
    local p = ifvPoint(squadId, geo)
    p.flag = flagName
    return p
end

function N.capture(id, flag, force)
    local g, role, geo = assaultContext(id)
    if not g then return oldCapture(id, flag, force) end

    -- 1) First waypoint: 30 metres from the team's spawn toward the real
    -- attack target. This is also emitted to the visualizer telemetry.
    if g.phase == 'assembling' then
        local p = spawnExitPoint(geo)
        local ok = issueCoordinate(id, role, g.phase, 'spawn_exit_30m', p, geo, force)
        if ok then return true end
        -- Without the coordinate bridge retain the proven v1.21 rally order.
        return oldCapture(id, flag, force)
    end

    -- 2) Approach phase.
    if g.phase == 'approach' then
        if role == 'tank' then
            local p = tankPoint(id, geo)
            logMovePoint(id, role, g.phase, 'tank_standoff', p, geo,
                string.format('distance=%.1f lateral=%.1f', p.distance, p.lateral))
            local ok = issueCoordinate(id, role, g.phase, 'tank_standoff', p, geo, force)
            if ok then return true end
            -- Critical: no CaptureFlag fallback for tanks; that would drive
            -- them into the point.
            return false
        end

        local p = infantryDeployPoint(id, geo)
        moveCarrier(id, g.phase, geo, force)
        local ok = issueCoordinate(id, role, g.phase, 'infantry_deploy_100m', p, geo, force)
        if ok then return true end
        return oldCapture(id, flag, force)
    end

    -- 3) Assault phase.
    if g.phase == 'attack' then
        if role == 'tank' then
            local p = tankPoint(id, geo)
            logMovePoint(id, role, g.phase, 'tank_standoff', p, geo,
                string.format('distance=%.1f lateral=%.1f', p.distance, p.lateral))
            local ok = issueCoordinate(id, role, g.phase, 'tank_standoff', p, geo, force)
            if ok then return true end
            return false
        end

        -- Infantry front: member bridge gives the exact 5.5 m line. If it is
        -- not installed, log every desired member point and use stock capture
        -- so the bot remains combat-capable rather than freezing.
        if orderInfantryFront(id, geo, force) then return true end
        return oldCapture(id, flag, force)
    end

    return oldCapture(id, flag, force)
end

N.log('v1.22 TACTICS ACTIVE spawnExit=30 infantryDeploy=100 spacing=5.5 tank=50..100 ifv=20..50')
N.log('v1.22 BRIDGES move='..tostring(coordinateBridge()~=nil)..' carrier='..tostring(carrierBridge()~=nil)..' member='..tostring(memberBridge()~=nil)..' disembark='..tostring(disembarkBridge()~=nil))
return R
