-- NEU BOT 2.0.1
-- Canonical behaviour: BOT_MEMORY/BOT_LOGIC_CURRENT.json
-- Hotfix: restores BotApi lifecycle subscriptions lost in v2.0.

MaxSquadSize = 6

NEU_BOT = {
    Version = "2.0.1",
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
        OrderCooldownSec = 15
    },

    Opening = { "infantry", "recon", "tank", "mech_inf" },
    ImportantRoles = { "recon", "tank", "mech_inf", "attack_heli" },

    Air = {
        AllowAttackHelicopters = true,
        MaxAttackHelicopters = 1,
        RequiredEnemyTankCount = 3
    },

    Artillery = { Enabled = false },
    TelemetrySnapshotSec = 15,
    TelemetryMaxBytes = 2300000
}

local N = require([[/script/multiplayer/bot.core]])
-- Mark logs from the fixed build while keeping the tested v2.0 core implementation.
function N.log(m) print("[BOT2.0.1] " .. tostring(m)) end
require([[/script/multiplayer/bot.logic]])
N.log("BOT 2.0.1 ACTIVE; canonical logic=BOT_MEMORY/BOT_LOGIC_CURRENT.json")
return N
