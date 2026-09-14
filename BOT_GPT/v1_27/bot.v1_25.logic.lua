-- NEU BOT v1.25 tactical compatibility layer.
-- Keeps the proven v1.22 coordinate implementation intact while exposing it as v1.25.
local R=require([[/script/multiplayer/bot.v1_22.logic]])
local N=NEU21
local C=N.C
C.NEU25Plans=C.NEU22Plans or C.NEU25Plans or {}
function N.NEU25PlanForSquad(id)
 return C.NEU25Plans and C.NEU25Plans[id] or nil
end
N.log('v1.25 TACTICS ACTIVE routeStep='..tostring(NEU_BOT.RoutePointMeters or 30)..' deploy='..tostring(NEU_BOT.InfantryDeployMeters or 100)..' spacing='..tostring(NEU_BOT.InfantrySpacingMeters or 5.5)..' tank='..tostring(NEU_BOT.TankMinMeters or 50)..'..'..tostring(NEU_BOT.TankMaxMeters or 100)..' ifv='..tostring(NEU_BOT.IFVMinMeters or 20)..'..'..tostring(NEU_BOT.IFVMaxMeters or 50))
return R
