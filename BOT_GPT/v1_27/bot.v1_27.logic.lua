-- NEU BOT v1.27
-- Universal 30 m route planner for every bot squad.
-- Physical orders keep using the proven stock BotApi CaptureFlag path.
-- If an external coordinate bridge is present, route data is ready for point execution.
local R=require([[/script/multiplayer/bot.v1_26.logic]])
local N=NEU21
local C=N.C
local previousCapture=N.capture

local STEP=(NEU_BOT and (NEU_BOT.AllUnitRoutePointMeters or NEU_BOT.RoutePointMeters)) or 30
local LEASH=(NEU_BOT and NEU_BOT.CarrierEscortLeashMeters) or 15
C.NEU27Routes=C.NEU27Routes or {}

local function valid(p) return p and type(p.x)=='number' and type(p.y)=='number' end
local function clonePoint(p,kind)
 if not valid(p) then return nil end
 return {x=p.x,y=p.y,z=p.z,kind=kind or p.kind}
end
local function routeBetween(a,b,step)
 local out={}
 if not(valid(a) and valid(b)) then return out end
 local dx,dy=b.x-a.x,b.y-a.y
 local len=math.sqrt(dx*dx+dy*dy)
 if len<0.01 then out[1]={x=b.x,y=b.y,z=b.z,kind='goal',meters=0,index=1};return out end
 local ux,uy=dx/len,dy/len
 local d=step
 while d<len do
  out[#out+1]={x=a.x+ux*d,y=a.y+uy*d,z=a.z or b.z,kind='wp30',meters=d,index=#out+1}
  d=d+step
 end
 out[#out+1]={x=b.x,y=b.y,z=b.z,kind='goal',meters=len,index=#out+1}
 return out
end
local function startPoint(id)
 local old=C.NEU27Routes[id]
 if old and valid(old.to) then return clonePoint(old.to,'previous_goal') end
 local last=C.LastOrder and C.LastOrder[id]
 if last and type(last.x)=='number' and type(last.y)=='number' then return {x=last.x,y=last.y,z=last.z,kind='last_coordinate'} end
 if N.MAP and valid(N.MAP.spawn) then return clonePoint(N.MAP.spawn,'spawn') end
 return nil
end
local function speedForRole(role)
 role=tostring(role or '')
 if role=='infantry' or role=='infantry_detached' or role=='defense_infantry' then return (NEU_BOT and NEU_BOT.InfantryPlanSpeedMps) or 4 end
 if role=='patrol_heli' or role=='aircraftlight' or role=='strike' or role=='antirad' then return (NEU_BOT and NEU_BOT.AirPlanSpeedMps) or 25 end
 return (NEU_BOT and NEU_BOT.VehiclePlanSpeedMps) or 8
end
local function carrierEscort(points,from)
 local out={}
 local prev=clonePoint(from,'carrier_start')
 for i,p in ipairs(points or {}) do
  local target
  if i==1 then target=prev else target=points[i-1] end
  out[#out+1]={x=target.x,y=target.y,z=target.z,kind='carrier_escort',meters=math.max(0,(p.meters or 0)-LEASH),index=i}
 end
 return out
end
local function planRoute(id,flag)
 if not(id and flag and N.MAP and N.MAP.loaded) then return nil end
 local dest=N.MAP:point(flag)
 if not valid(dest) then return nil end
 local role=C.SquadRole[id] or 'unknown'
 local old=C.NEU27Routes[id]
 if old and old.target==flag and old.role==role then return old end
 local from=startPoint(id)
 if not valid(from) then return nil end
 local points=routeBetween(from,dest,STEP)
 local infantry=(role=='infantry' or role=='infantry_detached' or role=='defense_infantry')
 local r={squad=id,role=role,target=flag,from=from,to=clonePoint(dest,'target'),points=points,step=STEP,startedAt=C.Time or 0,visualSpeed=speedForRole(role),escort=infantry,carrierLeash=infantry and LEASH or 0,carrierPoints={}}
 if infantry then r.carrierPoints=carrierEscort(points,from) end
 C.NEU27Routes[id]=r
 -- IMPORTANT: do not print every 30 m waypoint. It made game.log and telemetry grow by megabytes.
 -- The full waypoint list stays in C.NEU27Routes and is written into compact periodic snapshots for the HTML visualizer.
 N.log('ROUTE30 squad='..tostring(id)..' role='..tostring(role)..' target='..tostring(flag)..' points='..tostring(#points)..' step='..tostring(STEP)..' escort='..tostring(infantry))
 if infantry then N.log('BTR ESCORT squad='..tostring(id)..' pace=infantry leash='..tostring(LEASH)..'m') end
 return r
end

function N.NEU27RouteForSquad(id) return C.NEU27Routes and C.NEU27Routes[id] or nil end
function N.NEU27PlanRoute(id,flag) return planRoute(id,flag) end

function N.capture(id,flag,force)
 planRoute(id,flag)
 return previousCapture(id,flag,force)
end

N.log('v1.27 UNIVERSAL ROUTES ACTIVE step='..tostring(STEP)..'m all_squads=true')
N.log('v1.27 BTR ESCORT PLAN pace=infantry leash='..tostring(LEASH)..'m')
return R
