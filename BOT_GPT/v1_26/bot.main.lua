-- NEU BOT v1.26 entry point
local N=require([[/script/multiplayer/bot.v1_21.core]])
local T=require([[/script/multiplayer/bot.telemetry]])
NEU_TELEMETRY=T
T.install(N)
require([[/script/multiplayer/bot.v1_26.logic]])
N.log('v1.26 LIVE MAP + UNIT ROUTE TELEMETRY ACTIVE')
return N
