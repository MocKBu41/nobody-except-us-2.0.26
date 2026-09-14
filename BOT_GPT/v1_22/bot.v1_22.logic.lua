-- NEU BOT v1.22
-- Tank standoff: tanks must NOT drive into the capture point.
-- Final tank position is 60..70 map units before the flag on the line
-- from our own spawn anchor to the target flag.
--
-- Stock MoWAS2 BotApi exposes CaptureFlag but no arbitrary-coordinate
-- attack command. Therefore this layer sends the exact coordinate through
-- NEU_EngineMove(squadId, x, y, z) when the low-level bridge is present.
-- Without that bridge the tank is deliberately kept at its previous
-- approach position instead of being ordered into the center of the flag.

local R = require([[/script/multiplayer/bot.v1_21.logic]])
local N = NEU21
local C = N.C

local oldCapture = N.capture

local function standoffDistance(squadId)
    -- Stable per-squad value 60..70, so repeated orders do not make the tank
    -- shuffle back and forth between different positions.
    local n = math.abs(tonumber(squadId) or 0)
    return 60 + ((n * 17 + 3) % 11)
end

function N.tankStandoffPoint(flagName, squadId)
    if not (N.MAP and N.MAP.loaded and N.MAP.spawn and flagName) then return nil end
    local flag = N.MAP:point(flagName)
    local spawn = N.MAP.spawn
    if not (flag and flag.x and flag.y and spawn.x and spawn.y) then return nil end

    local dx = flag.x - spawn.x
    local dy = flag.y - spawn.y
    local len = math.sqrt(dx * dx + dy * dy)
    if len < 1.0 then return nil end

    local d = standoffDistance(squadId)
    if d > len * 0.45 then d = math.max(10, len * 0.25) end

    return {
        x = flag.x - (dx / len) * d,
        y = flag.y - (dy / len) * d,
        z = flag.z,
        distance = d,
        flag = flagName,
        spawnX = spawn.x,
        spawnY = spawn.y,
        flagX = flag.x,
        flagY = flag.y
    }
end

local function coordinateBridge()
    return type(NEU_EngineMove) == 'function' and NEU_EngineMove or nil
end

local function orderTankStandoff(id, flag, force)
    local p = N.tankStandoffPoint(flag, id)
    if not p then
        N.log('TANK STANDOFF GEO unavailable squad='..tostring(id)..' flag='..tostring(flag)..' => HOLD')
        return false
    end

    local last = C.LastOrder[id]
    if not force and last and last.kind=='tank_standoff' and last.flag==flag and
       C.Time-(last.time or 0)<(NEU_BOT.OrderCooldownSec or 10) then
        return true
    end

    local bridge = coordinateBridge()
    if not bridge then
        -- Critical: do NOT fall back to CaptureFlag here. Falling back would
        -- reproduce the old bug and drive the tank into the capture circle.
        if not last or last.kind~='tank_standoff_wait' or C.Time-(last.time or 0)>=10 then
            N.log(string.format(
                'TANK STANDOFF REQUEST squad=%s flag=%s x=%.2f y=%.2f d=%.1f spawn=(%.2f,%.2f) BRIDGE=WAIT',
                tostring(id), tostring(flag), p.x, p.y, p.distance, p.spawnX, p.spawnY))
            C.LastOrder[id]={kind='tank_standoff_wait',flag=flag,time=C.Time,x=p.x,y=p.y}
        end
        return false
    end

    local ok, result = pcall(bridge, id, p.x, p.y, p.z)
    if not ok or result==false then
        N.log('TANK STANDOFF MOVE FAILED squad='..tostring(id)..' flag='..tostring(flag)..' err='..tostring(result))
        return false
    end

    C.LastOrder[id]={kind='tank_standoff',flag=flag,time=C.Time,x=p.x,y=p.y}
    N.log(string.format(
        'TANK STANDOFF MOVE squad=%s flag=%s x=%.2f y=%.2f d=%.1f spawn=(%.2f,%.2f)',
        tostring(id), tostring(flag), p.x, p.y, p.distance, p.spawnX, p.spawnY))
    return true
end

function N.capture(id, flag, force)
    local role = C.SquadRole[id]
    local gid = C.SquadGroup[id]
    local g = gid and C.Groups[gid] or nil

    -- Only assault tanks are intercepted. Infantry still receives CaptureFlag
    -- and therefore physically enters/captures the point as before.
    if role=='tank' and g and g.target==flag and g.phase=='attack' then
        return orderTankStandoff(id, flag, force)
    end

    return oldCapture(id, flag, force)
end

N.log('v1.22 TANK STANDOFF 60-70 FROM OWN SPAWN ACTIVE')
return R
