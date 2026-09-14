-- Pure XY geometry. No BotApi calls; Z is interpolated only when known.
local P = {}
function P.finite(n) return type(n)=='number' and n==n and n~=math.huge and n~=-math.huge end
function P.point(p) return type(p)=='table' and P.finite(p.x) and P.finite(p.y) end
function P.copy(p) return {x=p.x,y=p.y,z=p.z} end
function P.distance(a,b) return math.sqrt((a.x-b.x)^2+(a.y-b.y)^2) end
local function mix(a,b,t)
 local p={x=a.x+(b.x-a.x)*t,y=a.y+(b.y-a.y)*t}
 if P.finite(a.z) and P.finite(b.z) then p.z=a.z+(b.z-a.z)*t end
 return p
end
-- Stable pseudo-random geometry; does not consume the original bot's RNG.
local function random(seed)
 local n=17
 for i=1,#seed do n=(n*131+seed:byte(i))%2147483647 end
 return function() n=(n*16807)%2147483647 return n/2147483647 end
end
function P.segment(a,b,step,limit)
 assert(P.point(a) and P.point(b) and P.finite(step) and step>0,'invalid segment')
 local d=P.distance(a,b)
 local count=math.max(1,math.ceil(d/step))
 assert(count<=(limit or 4096),'route exceeds waypoint limit')
 local out={}
 for i=1,count do out[i]=mix(a,b,d>0 and math.min(i*step/d,1) or 1) end
 return out
end
function P.plan(origin,target,kind,count,key,cfg)
 assert(P.point(origin) and P.point(target),'missing coordinates')
 local scale=cfg.UnitsPerMeter or 1
 assert(P.finite(scale) and scale>0,'invalid UnitsPerMeter')
 local step=cfg.WaypointMeters*scale
 local d=P.distance(origin,target)
 local ux,uy=0,1
 if d>0.000001 then ux=(target.x-origin.x)/d uy=(target.y-origin.y)/d end
 local goal=P.copy(target)
 local plan={origin=P.copy(origin),target=P.copy(target),kind=kind,
   calibrated=cfg.UnitsPerMeter~=nil,scale=scale,stepMeters=cfg.WaypointMeters}
 if kind=='tank' or kind=='ifv' then
  local rnd=random(tostring(key))
  local lo=kind=='tank' and cfg.TankMinMeters or cfg.IFVMinMeters
  local hi=kind=='tank' and cfg.TankMaxMeters or cfg.IFVMaxMeters
  assert(lo>0 and hi>=lo,'invalid standoff interval')
  local radius=(lo+(hi-lo)*rnd())*scale
  local angle=(rnd()-0.5)*math.pi/2 -- +/-45 degrees on approach side
  local bx=-ux*math.cos(angle)+uy*math.sin(angle)
  local by=-uy*math.cos(angle)-ux*math.sin(angle)
  goal={x=target.x+bx*radius,y=target.y+by*radius,z=target.z}
  plan.holdMeters=radius/scale
 end
 if kind=='infantry' then
  count=math.floor(count or 0)
  assert(count>0 and count<=128,'invalid infantry count')
  assert(cfg.SpacingMeters>=5 and cfg.SpacingMeters<=6,'spacing outside 5..6m')
  local deploy=math.min(d,cfg.DeployMeters*scale)
  goal={x=target.x-ux*deploy,y=target.y-uy*deploy,z=target.z}
  plan.deploy=P.copy(goal)
  plan.spacingMeters=cfg.SpacingMeters
  plan.members={}
  local center=P.segment(goal,target,step,cfg.MaxWaypoints)
  for i=1,count do
   local offset=(i-(count+1)/2)*cfg.SpacingMeters*scale
   local lane={slot=i,points={}}
   lane.deploy={x=goal.x-uy*offset,y=goal.y+ux*offset,z=goal.z}
   for j,p in ipairs(center) do lane.points[j]={x=p.x-uy*offset,y=p.y+ux*offset,z=p.z} end
   plan.members[i]=lane
  end
 end
 plan.goal=goal
 plan.points=P.segment(origin,goal,step,cfg.MaxWaypoints)
 return plan
end
return P
