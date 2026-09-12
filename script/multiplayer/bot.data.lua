MaxSquadSize = 12
OrderRotationPeriod = 600000
SpecialPoints = 16

UnitClass = {
    Infantry = "Infantry",
    Vehicle = "Vehicle",
    Tank = "Tank",
    ATTank = "ATTank",
    ATInfantry = "ATInfantry",
    HeavyTank = "HeavyTank",
    Hero = "Hero"
}

NEU_BOT = {
    ModFolder = "nobody except us 2.0.26",
    TickMs = 1000,
    SpawnRetrySec = 2,
    CriticalSpawnRetrySec = 10,
    CriticalSpawnRetryCycles = 3,

    AssaultGroups = 2,
    OpeningTankDelaySec = 5,
    OpeningMaintenanceSec = 10,
    InfantryReissueSec = 5,
    OrderCooldownSec = 12,
    VehicleFollowDelaySec = 5,
    AntiAirPatrolSec = 20,

    AttackWaitSec = 300,
    AttackResultCheckSec = 120,
    NextAttackDelaySec = 5,
    TankReinforcementSec = 300,
    InfantryReinforcementSec = 300,

    PointStartCheckSec = 5,
    PointStartSquadSize = 12,
    PointStartSpawnRetrySec = 5,
    -- Pointstart retries continue until Spawn succeeds or ownership changes.

    DetachedAdoptWindowSec = 25,
    DetachedAdoptMaxPerGroup = 6,

    HeliPatrolSec = 20,

    DirectionRecoverySec = 30,

    AntiRadDelaySec = 180,
    EnemyResponseCheckSec = 120,

    MapMatchMinRatio = 0.75,
    MapFinalFile = "_flag_points_final.json",
    MapIndexFile = "_map_points_index.json"
}

function readAllUnits(sq, units, army)
    local path = "mods\\" .. NEU_BOT.ModFolder .. "\\resource\\set\\multiplayer\\units\\"
    local files = {
        "units_nato.set",
        "units_ch.set",
        "units_rus.set",
        "units_usa.set",
        "units_nov.set",
        "units_ukr.set",
        "units_wagner.set"
    }
    for _, name in ipairs(files) do
        readUnitsRaw(path .. name, units, army)
    end
end

