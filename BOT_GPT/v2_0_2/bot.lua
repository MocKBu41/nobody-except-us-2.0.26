-- NEU BOT 2.0.2
-- Restores the proven v1.21 opening coverage: one pointstart per neutral flag
-- plus a patrol helicopter at battle start. Main 2.x strategy remains active.

MaxSquadSize = 6

NEU_BOT = {
    Version = "2.0.2",
    ModFolder = "nobody except us 2.0.26",
    TickMs = 1000,

    Economy = {
        StartPoints = 1200,
        IncomePerSecond = 20,
        ReservePoints = 200,
        Price = {
            recon = 100,
            tank = 450,
            mech_inf = 250,
            attack_heli = 750,
            patrol_heli = 0,
            artillery = 600,
            infantry = 150,
            antiair = 250,
            pointstart = 0,
            other = 9999
        },
        Cooldown = {
            recon = 45,
            tank = 90,
            mech_inf = 50,
            attack_heli = 180,
            patrol_heli = 180,
            artillery = 120,
            infantry = 35,
            antiair = 45,
            pointstart = 0,
            other = 9999
        }
    },

    Strategy = {
        FlagAdvantageToDefend = 1,
        VehicleFollowDelaySec = 10,
        ReevaluateEverySec = 3,
        OrderRefreshEverySec = 15,
        SpawnRetryEverySec = 2,
        SpawnTimeoutSec = 60,
        FailedRoleBackoffSec = 30,
        AttackHeliCheckEverySec = 30,
        OrderCooldownSec = 15,
        OpeningPointStartPriority = 200,
        OpeningPatrolHeliPriority = 220
    },

    -- Main combat opening is preserved. v2.0.2 adds pointstart coverage and patrol heli before it.
    Opening = { "infantry", "recon", "tank", "mech_inf" },
    ImportantRoles = { "recon", "tank", "mech_inf", "attack_heli" },

    OpeningCoverage = {
        PointStartEveryNeutralFlag = true,
        PatrolHelicopterAtStart = true
    },

    Air = {
        AllowAttackHelicopters = true,
        MaxAttackHelicopters = 1,
        RequiredEnemyTankCount = 3
    },

    Artillery = { Enabled = false },
    TelemetrySnapshotSec = 15,
    TelemetryMaxBytes = 2300000,
    GeometryTelemetry = true
}

local N = require([[/script/multiplayer/bot.core]])
function N.log(m) print("[BOT2.0.2] " .. tostring(m)) end
require([[/script/multiplayer/bot.logic]])
N.log("BOT 2.0.2 ACTIVE; pointstart-all-flags + opening patrol heli + self-contained geometry telemetry")
return N
