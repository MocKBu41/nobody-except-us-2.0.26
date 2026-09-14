-- Distances below are GAME METRES. Set scale only after measuring the map.
return {
    Enabled = false, -- requires NEU_TacticalAdapter v1, see ADAPTER_RU.md
    UnitsPerMeter = nil, -- unknown: plans use 1 provisionally and say uncalibrated
    WaypointMeters = 30,
    DeployMeters = 100,
    SpacingMeters = 5.5,
    TankMinMeters = 50, TankMaxMeters = 100,
    IFVMinMeters = 20, IFVMaxMeters = 50,
    ArrivalMeters = 1,
    RetrySeconds = 10,
    ExportSeconds = 3,
    PreviewInfantryCount = 8, -- preview only; never used to issue unit commands
    MaxWaypoints = 4096
}
