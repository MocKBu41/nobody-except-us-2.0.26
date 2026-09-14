local N=require([[/script/multiplayer/bot.v1_21.core]])
local T=require([[/script/multiplayer/bot.telemetry]])
T.install(N)
require([[/script/multiplayer/bot.v1_27.logic]])
N.log('v1.27 60FPS MAP + ALL UNIT 30M ROUTES ACTIVE')
return N
