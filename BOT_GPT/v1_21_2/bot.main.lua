local N=require([[/script/multiplayer/bot.v1_21.core]])
local T=require([[/script/multiplayer/bot.telemetry]])
T.install(N)

require([[/script/multiplayer/bot.v1_21.logic]])
N.log('v1.21.2 LIVE VISUALIZER TELEMETRY ACTIVE')
return N
