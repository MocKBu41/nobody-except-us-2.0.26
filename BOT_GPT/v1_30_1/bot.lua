-- NEU BOT v1.30.1
-- Minimal package: bot.lua + bot.core.lua + bot.logic.lua + bot_visualizer.html
MaxSquadSize=12
NEU_BOT={
 Version='1.30.1', ModFolder='nobody except us 2.0.26', TickMs=1000,
 AssaultGroups=2, OpeningCappers=3, OpeningInfantryPerGroup=2,
 MinAssaultInfantrySquads=2, MaxAssaultInfantrySquads=3,
 AttackWaitSec=75, AssemblySec=12, AssemblyMaxSec=45,
 AttackResultSec=60, CaptureNextDelaySec=5, OrderCooldownSec=15,
 SpawnRetrySec=3, SpawnRetryCycles=3,
 InfantryReplacementSec=8, TankReplacementSec=10,
 AAReplacementSec=30, AirSupportCooldownSec=360,
 AirSupportDelaySec=120, PatrolSec=30,
 TelemetrySnapshotSec=15,
 -- BOT-vs-BOT creates one file per team. 2.3 MB x 2 = 4.6 MB hard maximum total.
 TelemetryMaxBytes=2300000,
 TelemetryFile='bot_gpt_telemetry.jsonl'
}
local N=require([[/script/multiplayer/bot.core]])
require([[/script/multiplayer/bot.logic]])
N.log('v1.30.1 MINIMAL OPTIMIZED BOT ACTIVE')
return N
