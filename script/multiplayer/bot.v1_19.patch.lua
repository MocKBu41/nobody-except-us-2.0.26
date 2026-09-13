-- NEU BOT v1.19 patch
-- Based on v1.18 BTG logic. Adds a global aircraftlight cooldown > 5 minutes.

local N = require([[/script/multiplayer/bot.v1_18.core]])
local C = N.C

NEU_BOT.AirSupportCooldownSec = NEU_BOT.AirSupportCooldownSec or 360
C.NextAircraftAllowedAt = C.NextAircraftAllowedAt or 0

local baseEnqueueSpawn = N.enqueueSpawn
function N.enqueueSpawn(role, reason, delay, target, gid, mode)
    if role == 'aircraftlight' then
        local now = C.Time or 0
        local nextAt = C.NextAircraftAllowedAt or 0
        if now < nextAt then
            N.log('AIR COOLDOWN BLOCK group='..tostring(gid)..' target='..tostring(target)..' remaining='..tostring(nextAt-now)..'s reason='..tostring(reason))
            return false
        end
        C.NextAircraftAllowedAt = now + (NEU_BOT.AirSupportCooldownSec or 360)
        N.log('AIR COOLDOWN START next='..tostring(C.NextAircraftAllowedAt)..' cd='..tostring(NEU_BOT.AirSupportCooldownSec or 360)..'s group='..tostring(gid)..' target='..tostring(target))
    end
    baseEnqueueSpawn(role, reason, delay, target, gid, mode)
    return true
end

N.log('PATCH v1.19 AIR GLOBAL COOLDOWN='..tostring(NEU_BOT.AirSupportCooldownSec)..'s')

-- v1.18 contains the current BTG assembly/approach/assault implementation.
-- Requiring it after patching the shared core makes all aircraftlight requests pass through this cooldown.
return require([[/script/multiplayer/bot.v1_18.logic]])
