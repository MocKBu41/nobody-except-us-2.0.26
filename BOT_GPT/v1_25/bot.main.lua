local N=require([[/script/multiplayer/bot.v1_21.core]])
local T=require([[/script/multiplayer/bot.telemetry]])
T.install(N)
require([[/script/multiplayer/bot.v1_25.logic]])
BotApi.Events:Subscribe(BotApi.Events.Quant,T.onQuant)
N.log('v1.25 LIVE MAP + UNIT ROUTE TELEMETRY ACTIVE')
return N
