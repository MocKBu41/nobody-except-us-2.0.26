-- NEU BOT v1.26 tactical layer.
-- Battle/tactical behavior stays on the proven v1.22 implementation;
-- v1.26 changes the telemetry snapshot driver only.
local R=require([[/script/multiplayer/bot.v1_22.logic]])
local N=NEU21
local C=N.C
C.NEU26Plans=C.NEU22Plans or C.NEU26Plans or {}
function N.NEU26PlanForSquad(id)
 return C.NEU26Plans and C.NEU26Plans[id] or nil
end
N.log('v1.26 TACTICS ACTIVE routeStep='..tostring(NEU_BOT.RoutePointMeters or 30)..' deploy='..tostring(NEU_BOT.InfantryDeployMeters or 100)..' spacing='..tostring(NEU_BOT.InfantrySpacingMeters or 5.5)..' tank='..tostring(NEU_BOT.TankMinMeters or 50)..'..'..tostring(NEU_BOT.TankMaxMeters or 100)..' ifv='..tostring(NEU_BOT.IFVMinMeters or 20)..'..'..tostring(NEU_BOT.IFVMaxMeters or 50))
return R
