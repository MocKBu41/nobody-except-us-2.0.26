local N=require([[/script/multiplayer/bot.v1_20.core]])
local T=require([[/script/multiplayer/bot.telemetry]])
T.install(N)

require([[/script/multiplayer/bot.v1_20.logic]])
BotApi.Events:Subscribe(BotApi.Events.Quant,T.onQuant)
N.log('v1.20 LIVE VISUALIZER TELEMETRY ACTIVE')
return N
