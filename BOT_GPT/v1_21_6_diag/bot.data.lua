MaxSquadSize = 12
OrderRotationPeriod = 600000
SpecialPoints = 16

UnitClass = { Infantry="Infantry", Vehicle="Vehicle", Tank="Tank", ATTank="ATTank", ATInfantry="ATInfantry", HeavyTank="HeavyTank", Hero="Hero" }

NEU_BOT = {
    ModFolder = "nobody except us 2.0.26",
    TickMs = 1000,
    AirSupportCooldownSec = 360,
    AAReplacementRetrySec = 30,
    AntiradResponseDelaySec = 180,
    EnemyAAReportMaxAgeSec = 45,
    SpawnRetrySec = 2,
    CriticalSpawnRetrySec = 10,
    CriticalSpawnRetryCycles = 3,
    SupportSpawnRetrySec = 15,
    SupportSpawnRetryCycles = 8,

    AssaultGroups = 2,
    OpeningTankDelaySec = 5,
    InfantryReissueSec = 5,
    OrderCooldownSec = 5,
    AntiAirPatrolSec = 20,
    SupportPatrolSec = 20,

    AttackWaitSec = 300,
    AttackResultCheckSec = 90,
    CaptureNextAttackDelaySec = 4,
    TankReinforcementSec = 180,
    InfantryReinforcementSec = 90,
    MinAssaultInfantrySquads = 2,
    MaxAssaultInfantrySquads = 4,
    MaxDefenseSquadsPerFlag = 1,

    BTGAssemblySec = 30,
    BTGApproachSec = 25,
    RouteChoiceCount = 3,
    MaxWavesSameTarget = 2,
    DismountAdoptDelaySec = 2,
    DismountHintWindowSec = 20,

    PointStartCheckSec = 3,
    PointStartSquadSize = 12,
    PointStartSpawnRetrySec = 5,
    HeliPatrolSec = 20,

    MapMatchMinRatio = 0.75,
    MapFinalFile = "_flag_points_final.json",
    MapIndexFile = "_map_points_index.json"
}

function readAllUnits(sq, units, army)
    local path = "mods\\" .. NEU_BOT.ModFolder .. "\\resource\\set\\multiplayer\\units\\"
    local files = {"units_nato.set","units_ch.set","units_rus.set","units_usa.set","units_nov.set","units_ukr.set","units_wagner.set"}
    for _, name in ipairs(files) do readUnitsRaw(path .. name, units, army) end
end

