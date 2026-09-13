local N=require([[/script/multiplayer/bot.v1_21.core]])
local T=require([[/script/multiplayer/bot.telemetry]])
T.install(N)
local D=require([[/script/multiplayer/bot.positiondiag]])
D.install(N)
require([[/script/multiplayer/bot.v1_21.logic]])
N.log('v1.21.7 ACTOR/ENTITY POSITION DIAG ACTIVE')
return N
