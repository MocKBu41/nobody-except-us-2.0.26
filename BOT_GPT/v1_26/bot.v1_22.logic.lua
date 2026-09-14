-- NEU BOT v1.22
-- Tactics layer over the stable v1.21 battle logic.
-- Plans 30 m movement points, infantry deployment/front, tank and IFV standoff.
local R=require([[/script/multiplayer/bot.v1_21.logic]])
local N=NEU21
local C=N.C
local oldCapture=N.capture

local CFG={
 step=NEU_BOT.RoutePointMeters or 30,
 deploy=NEU_BOT.InfantryDeployMeters or 100,
 spacing=NEU_BOT.InfantrySpacingMeters or 5.5,
 infantryGoalBack=4,
 defaultMembers=8,
 tankMin=NEU_BOT.TankMinMeters or 50,
 tankMax=NEU_BOT.TankMaxMeters or 100,
 ifvMin=NEU_BOT.IFVMinMeters or 20,
 ifvMax=NEU_BOT.IFVMaxMeters or 50,
 tankLateral=28,
 ifvLateral=20
}
C.NEU22Plans=C.NEU22Plans or {}

local function stable01(id,salt)
 local n=math.abs(tonumber(id) or 0)
 return ((n*1103515245+12345+(tonumber(salt) or 0)*7919)%10000)/9999
end
local function stableRange(id,salt,a,b) return a+stable01(id,salt)*(b-a) end

local function targetGeometry(flagName)
 if not(N.MAP and N.MAP.loaded and N.MAP.spawn and flagName) then return nil end
 local flag=N.MAP:point(flagName) local spawn=N.MAP.spawn
 if not(flag and flag.x and flag.y and spawn.x and spawn.y) then return nil end
 local dx,dy=flag.x-spawn.x,flag.y-spawn.y local len=math.sqrt(dx*dx+dy*dy)
 if len<1 then return nil end
 local ux,uy=dx/len,dy/len
 return {flag=flagName,spawnX=spawn.x,spawnY=spawn.y,spawnZ=spawn.z,flagX=flag.x,flagY=flag.y,flagZ=flag.z,ux=ux,uy=uy,px=-uy,py=ux,length=len}
end

local function pointFromFlag(g,back,lateral)
 local b=math.min(back or 0,math.max(0,g.length-5)) local l=lateral or 0
 return {x=g.flagX-g.ux*b+g.px*l,y=g.flagY-g.uy*b+g.py*l,z=g.flagZ,distance=b,lateral=l}
end
local function pointAlong(g,d,lateral)
 local x=math.min(math.max(0,d or 0),g.length) local l=lateral or 0
 return {x=g.spawnX+g.ux*x+g.px*l,y=g.spawnY+g.uy*x+g.py*l,z=g.spawnZ or g.flagZ,distance=x,lateral=l}
end
local function tankPoint(id,g) return pointFromFlag(g,stableRange(id,11,CFG.tankMin,CFG.tankMax),stableRange(id,12,-CFG.tankLateral,CFG.tankLateral)) end
local function ifvPoint(id,g) return pointFromFlag(g,stableRange(id,21,CFG.ifvMin,CFG.ifvMax),stableRange(id,22,-CFG.ifvLateral,CFG.ifvLateral)) end
local function infantryDeployPoint(id,g) return pointFromFlag(g,CFG.deploy,stableRange(id,31,-10,10)) end

local function coordinateBridge() return type(NEU_EngineMove)=='function' and NEU_EngineMove or nil end
local function carrierBridge() return type(NEU_EngineMoveCarrier)=='function' and NEU_EngineMoveCarrier or nil end
local function memberBridge() return type(NEU_EngineMoveMember)=='function' and NEU_EngineMoveMember or nil end
local function memberCountBridge() return type(NEU_EngineMemberCount)=='function' and NEU_EngineMemberCount or nil end
local function disembarkBridge() return type(NEU_EngineDisembark)=='function' and NEU_EngineDisembark or nil end

local function getMemberCount(id)
 local fn=memberCountBridge()
 if fn then local ok,n=pcall(fn,id) n=ok and tonumber(n) or nil if n and n>=1 and n<=32 then return math.floor(n) end end
 return CFG.defaultMembers
end

local function routeBetween(a,b,step,kind)
 local out={} local dx,dy=b.x-a.x,b.y-a.y local len=math.sqrt(dx*dx+dy*dy)
 if len<0.01 then return {{x=b.x,y=b.y,z=b.z,kind=kind or 'goal'}} end
 local ux,uy=dx/len,dy/len local d=step
 while d<len do out[#out+1]={x=a.x+ux*d,y=a.y+uy*d,z=a.z or b.z,kind='wp30',meters=d};d=d+step end
 out[#out+1]={x=b.x,y=b.y,z=b.z,kind=kind or 'goal',meters=len}
 return out
end

local function logPoint(id,role,phase,kind,p,g,extra)
 N.log(string.format('MOVEPOINT squad=%s group=%s role=%s phase=%s kind=%s x=%.2f y=%.2f target=%s targetX=%.2f targetY=%.2f spawnX=%.2f spawnY=%.2f%s',tostring(id),tostring(C.SquadGroup[id]),tostring(role),tostring(phase),tostring(kind),p.x,p.y,tostring(g.flag),g.flagX,g.flagY,g.spawnX,g.spawnY,extra and (' '..extra) or ''))
end

local function buildPlan(id,role,g)
 local old=C.NEU22Plans[id]
 local key=tostring(role)..'|'..tostring(g.flag)
 if old and old.key==key then return old end
 local final
 if role=='tank' then final=tankPoint(id,g) else final=infantryDeployPoint(id,g) end
 local start={x=g.spawnX,y=g.spawnY,z=g.spawnZ or g.flagZ,kind='spawn'}
 local p={key=key,squad=id,group=C.SquadGroup[id],role=role,target=g.flag,spawn=start,targetPoint={x=g.flagX,y=g.flagY,z=g.flagZ},points=routeBetween(start,final,CFG.step,role=='tank' and 'tank_hold' or 'deploy_100m'),lanes={},carrierPoints={}}
 if role~='tank' then
  local ifv=ifvPoint(id,g)
  p.carrierGoal=ifv
  p.carrierPoints=routeBetween(start,ifv,CFG.step,'ifv_hold')
  local count=getMemberCount(id) local center=(count+1)*0.5
  for i=1,count do
   local lateral=(i-center)*CFG.spacing
   local stage=pointFromFlag(g,CFG.deploy,lateral)
   local goal=pointFromFlag(g,CFG.infantryGoalBack,lateral)
   p.lanes[i]={member=i,stage=stage,goal=goal,points=routeBetween(stage,goal,CFG.step,'assault_goal')}
  end
 end
 C.NEU22Plans[id]=p
 for i,x in ipairs(p.points) do logPoint(id,role,'plan','route_'..tostring(i),x,g,'index='..i..' step='..CFG.step) end
 if p.carrierGoal then
  for i,x in ipairs(p.carrierPoints) do logPoint(id,'ifv','plan','carrier_'..tostring(i),x,g,'index='..i..' step='..CFG.step) end
 end
 for _,lane in ipairs(p.lanes) do
  N.log(string.format('MEMBERPOINT squad=%s group=%s member=%d spacing=%.1f stageX=%.2f stageY=%.2f goalX=%.2f goalY=%.2f target=%s targetX=%.2f targetY=%.2f',tostring(id),tostring(C.SquadGroup[id]),lane.member,CFG.spacing,lane.stage.x,lane.stage.y,lane.goal.x,lane.goal.y,tostring(g.flag),g.flagX,g.flagY))
 end
 N.log('ROUTE PLAN squad='..tostring(id)..' role='..tostring(role)..' target='..tostring(g.flag)..' points='..#p.points..' step='..CFG.step)
 return p
end

function N.NEU22PlanForSquad(id) return C.NEU22Plans and C.NEU22Plans[id] or nil end

local function issueCoordinate(id,role,phase,kind,p,g,force)
 local last=C.LastOrder[id]
 if not force and last and last.kind==kind and last.flag==g.flag and C.Time-(last.time or 0)<(NEU_BOT.OrderCooldownSec or 5) then return last.bridge==true end
 logPoint(id,role,phase,kind,p,g)
 local bridge=coordinateBridge()
 if not bridge then C.LastOrder[id]={kind=kind,flag=g.flag,time=C.Time,x=p.x,y=p.y,bridge=false};return false end
 local ok,result=pcall(bridge,id,p.x,p.y,p.z)
 if not ok or result==false then N.log('MOVE FAILED squad='..tostring(id)..' kind='..kind..' err='..tostring(result));return false end
 C.LastOrder[id]={kind=kind,flag=g.flag,time=C.Time,x=p.x,y=p.y,bridge=true}
 return true
end

local function moveCarrier(id,phase,g,force)
 local p=ifvPoint(id,g) local bridge=carrierBridge()
 logPoint(id,'ifv',phase,'ifv_standoff',p,g,string.format('distance=%.1f lateral=%.1f',p.distance,p.lateral))
 if not bridge then return false end
 C.NEU22CarrierOrder=C.NEU22CarrierOrder or {} local last=C.NEU22CarrierOrder[id]
 if not force and last and last.flag==g.flag and C.Time-(last.time or 0)<(NEU_BOT.OrderCooldownSec or 5) then return true end
 local ok,result=pcall(bridge,id,p.x,p.y,p.z)
 if ok and result~=false then C.NEU22CarrierOrder[id]={time=C.Time,x=p.x,y=p.y,flag=g.flag};return true end
 N.log('IFV MOVE FAILED squad='..tostring(id)..' err='..tostring(result)) return false
end

local function orderInfantryFront(id,g,force)
 C.NEU22FrontOrdered=C.NEU22FrontOrdered or {} local rec=C.NEU22FrontOrdered[id]
 if not force and rec and rec.flag==g.flag and C.Time-(rec.time or 0)<(NEU_BOT.OrderCooldownSec or 5) then return rec.bridge==true end
 local dis=disembarkBridge() if dis then pcall(dis,id) end
 moveCarrier(id,'attack',g,force)
 local moveMember=memberBridge() local plan=buildPlan(id,C.SquadRole[id],g) local allOk=moveMember~=nil
 for _,lane in ipairs(plan.lanes or {}) do
  if moveMember then local ok,result=pcall(moveMember,id,lane.member,lane.goal.x,lane.goal.y,lane.goal.z) if not ok or result==false then allOk=false end end
 end
 C.NEU22FrontOrdered[id]={time=C.Time,flag=g.flag,bridge=allOk}
 if allOk then N.log('INFANTRY FRONT ACTIVE squad='..id..' spacing='..CFG.spacing);return true end
 N.log('INFANTRY FRONT PLAN squad='..id..' spacing='..CFG.spacing..' BRIDGE=WAIT') return false
end

local function assaultContext(id)
 local gid=C.SquadGroup[id] local group=gid and C.Groups[gid] or nil local role=C.SquadRole[id]
 if not(group and group.target and (role=='tank' or role=='infantry' or role=='infantry_detached')) then return nil end
 local g=targetGeometry(group.target) if not g then return nil end
 buildPlan(id,role,g)
 return group,role,g
end

function N.tankStandoffPoint(flagName,id) local g=targetGeometry(flagName) if not g then return nil end local p=tankPoint(id,g);p.flag=flagName;p.spawnX=g.spawnX;p.spawnY=g.spawnY;p.flagX=g.flagX;p.flagY=g.flagY;return p end
function N.ifvStandoffPoint(flagName,id) local g=targetGeometry(flagName) if not g then return nil end local p=ifvPoint(id,g);p.flag=flagName;return p end

function N.capture(id,flag,force)
 local group,role,g=assaultContext(id)
 if not group then return oldCapture(id,flag,force) end

 if group.phase=='assembling' then
  -- first executable coordinate is exactly one route step (30 m) from spawn
  local p=pointAlong(g,math.min(CFG.step,g.length),0)
  if issueCoordinate(id,role,group.phase,'spawn_exit_30m',p,g,force) then return true end
  return oldCapture(id,flag,force)
 end

 if group.phase=='approach' then
  if role=='tank' then
   local p=tankPoint(id,g)
   if issueCoordinate(id,role,group.phase,'tank_standoff',p,g,force) then return true end
   return false -- never drive a tank into flag center as fallback
  end
  moveCarrier(id,group.phase,g,force)
  local p=infantryDeployPoint(id,g)
  if issueCoordinate(id,role,group.phase,'infantry_deploy_100m',p,g,force) then return true end
  return oldCapture(id,flag,force)
 end

 if group.phase=='attack' then
  if role=='tank' then
   local p=tankPoint(id,g)
   if issueCoordinate(id,role,group.phase,'tank_standoff',p,g,force) then return true end
   return false
  end
  if orderInfantryFront(id,g,force) then return true end
  return oldCapture(id,flag,force)
 end
 return oldCapture(id,flag,force)
end

N.log('v1.22 TACTICS ACTIVE routeStep='..CFG.step..' deploy='..CFG.deploy..' spacing='..CFG.spacing..' tank='..CFG.tankMin..'..'..CFG.tankMax..' ifv='..CFG.ifvMin..'..'..CFG.ifvMax)
N.log('v1.22 BRIDGES move='..tostring(coordinateBridge()~=nil)..' carrier='..tostring(carrierBridge()~=nil)..' member='..tostring(memberBridge()~=nil)..' disembark='..tostring(disembarkBridge()~=nil))
return R
