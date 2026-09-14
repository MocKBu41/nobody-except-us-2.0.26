-- Run from BOT_GPT/v1_23: lua tests/geometry.lua
local P=dofile('bot.tactics.geometry.lua')
local c=dofile('bot.tactics.config.lua')
c.UnitsPerMeter=1
local function close(a,b) assert(math.abs(a-b)<0.000001,tostring(a)..' ~= '..tostring(b)) end
for _,scale in ipairs({1,10,100}) do
 c.UnitsPerMeter=scale
 local o={x=-300*scale,y=70*scale}
 local t={x=100*scale,y=-50*scale}
 for _,kind in ipairs({'tank','ifv'}) do
  for id=1,100 do
   local p=P.plan(o,t,kind,0,tostring(id),c)
   local metres=P.distance(p.goal,t)/scale
   local lo=kind=='tank' and 50 or 20 local hi=kind=='tank' and 100 or 50
   assert(metres>=lo-1e-8 and metres<=hi+1e-8)
   local previous=o
   for _,q in ipairs(p.points) do assert(P.distance(previous,q)<=30*scale+1e-8) previous=q end
   local same=P.plan(o,t,kind,0,tostring(id),c)
   close(same.goal.x,p.goal.x) close(same.goal.y,p.goal.y)
  end
 end
 local p=P.plan(o,t,'infantry',12,'front',c)
 close(P.distance(p.deploy,t),100*scale)
 for i=2,#p.members do
  close(P.distance(p.members[i].deploy,p.members[i-1].deploy),5.5*scale)
  for j,q in ipairs(p.members[i].points) do close(P.distance(q,p.members[i-1].points[j]),5.5*scale) end
 end
 local short=P.plan(t,{x=t.x+15*scale,y=t.y},'infantry',8,'short',c)
 close(P.distance(short.deploy,t),0)
end
assert(not pcall(P.segment,{x=0,y=0},{x=1,y=1},0))
assert(not pcall(P.plan,{x=0/0,y=1},{x=0,y=0},'tank',1,'bad',c))
print('PASS geometry: radii, scales, waypoint lengths, stable targets, front spacing, short routes')
