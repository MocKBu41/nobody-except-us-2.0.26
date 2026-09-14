-- Tactical extension to v1.22. Adapter is a project contract, NOT a stock API.
local N=require([[/script/multiplayer/bot.v1_22.logic]])
local P=require([[/script/multiplayer/bot.tactics.geometry]])
local cfg=require([[/script/multiplayer/bot.tactics.config]])
local T={config=cfg,geometry=P}
N.Tactics=T
local C=N.C
local previousCapture=N.capture
local routes,spawns,units,sequence={}, {}, {}, 0
local exportAt=0
local function adapter() return type(NEU_TacticalAdapter)=='table' and NEU_TacticalAdapter or nil end
local function call(name,...)
 local a=adapter()
 if not a or type(a[name])~='function' then return nil end
 local ok,value=pcall(a[name],...)
 if ok then return value end
 return nil
end
local function snapshot(id)
 local s=call('getSquad',id)
 if type(s)=='table' and P.point(s.position) and s.complete==true then return s end
end
local function inferredKind(id)
 if C.SquadRole[id]=='tank' then return 'tank' end
 local r=C.SquadRole[id]
 if r=='infantry' or r=='infantry_detached' or r=='pointstart' or r=='defense_infantry' then return 'infantry' end
 return 'other'
end
local function validKind(k) return k=='tank' or k=='ifv' or k=='infantry' or k=='other' end
local function aliveMembers(s)
 local list={}
 for _,m in ipairs((s and s.members) or {}) do
  if m.alive==true and m.id~=nil and P.point(m.position) then list[#list+1]=m end
 end
 table.sort(list,function(a,b) return tostring(a.id)<tostring(b.id) end)
 return list
end
function T.reset()
 routes={} spawns={} units={} sequence=0 exportAt=0 T.exportPath=nil
 N.log('v1.23 TACTICS '..(cfg.Enabled and 'ADAPTER REQUESTED' or 'PLAN ONLY')..'; scale='..tostring(cfg.UnitsPerMeter))
end
function T.onSpawn(id,ticket)
 units[id]=ticket and ticket.unit
 local s=snapshot(id)
 if s then spawns[id]={point=P.copy(P.point(s.spawn) and s.spawn or s.position),source=P.point(s.spawn) and 'adapter_spawn' or 'observed_on_spawn'} end
end
local function targetPoint(flag)
 if N.MAP and N.MAP.loaded then return N.MAP:point(flag) end
end
local function build(id,flag,s)
 local target=targetPoint(flag)
 local origin=s and s.position or (routes[id] and routes[id].lastConfirmed)
 local source=origin and 'measured' or 'estimated_spawn_anchor'
 if not origin then origin=spawns[id] and spawns[id].point or (N.MAP and N.MAP.spawn) end
 if not P.point(origin) or not P.point(target) then return nil end
 sequence=sequence+1
 local kind=(s and validKind(s.kind) and s.kind) or inferredKind(id)
 local members=aliveMembers(s)
 local count=#members>0 and #members or cfg.PreviewInfantryCount
 local ok,plan=pcall(P.plan,origin,target,kind,count,tostring(id)..':'..flag..':'..sequence,cfg)
 if not ok then N.log('TACTICS PLAN FAILED '..tostring(plan)) return nil end
 local r={id=id,flag=flag,role=C.SquadRole[id],unit=units[id],group=C.SquadGroup[id],
  plan=plan,originSource=source,spawn=spawns[id] and spawns[id].point or (N.MAP and N.MAP.spawn),
  spawnSource=spawns[id] and spawns[id].source or 'estimated_team_anchor',
  status='planned',stage='route',index=1,revision=sequence,created=C.Time,
  estimatedMembers=not s,memberIds={},lastConfirmed=s and P.copy(s.position)}
 for i,m in ipairs(members) do r.memberIds[i]=m.id end
 routes[id]=r
 return r
end
local function ready(r,s)
 local a=adapter()
 if not cfg.Enabled then return false,'preview_only' end
 if not P.finite(cfg.UnitsPerMeter) or cfg.UnitsPerMeter<=0 then return false,'uncalibrated' end
 if not a or a.version~=1 then return false,'adapter_missing' end
 if a.mapKey~=(N.MAP and N.MAP.mapKey) or type(a.mapKey)~='string' then return false,'map_not_verified' end
 if not s or not validKind(s.kind) or s.kind~=r.plan.kind then return false,'snapshot_or_kind_missing' end
 for _,key in ipairs({'moveSquad','holdSquad','validatePoint'}) do
  if type(a[key])~='function' then return false,'adapter_missing_'..key end
 end
 if r.plan.kind=='infantry' then
  if type(a.moveUnit)~='function' or type(a.holdUnit)~='function' or #r.memberIds==0 then return false,'individual_control_missing' end
 end
 if r.plan.kind=='other' then return false,'visualization_only_role' end
 return true
end
local function near(a,b) return P.distance(a,b)<=(cfg.ArrivalMeters*(cfg.UnitsPerMeter or 1)) end
local function command(r,name,id,p)
 if p and call('validatePoint',r.id,id,p)~=true then r.status='blocked_point' return false end
 if call(name,id,p and P.copy(p))~=true then r.status='command_failed' return false end
 return true
end
local function routeTick(r,s)
 local points=r.plan.points
 local p=points[r.index]
 if r.stage=='route' then
  if near(s.position,p) then
   r.lastConfirmed=P.copy(s.position)
   if r.index<#points then r.index=r.index+1 r.sent=nil
   elseif r.plan.kind=='infantry' then
    if command(r,'holdSquad',r.id) then r.stage='deploy' r.sent=nil r.unitSent={} end
   else
    if command(r,'holdSquad',r.id) then r.stage='hold' r.status='holding' end
   end
  elseif not r.sent or C.Time-r.sent>=cfg.RetrySeconds then
   if command(r,'moveSquad',r.id,p) then r.sent=C.Time r.status='moving' end
  end
 elseif r.stage=='deploy' or r.stage=='front' then
  local live={}
  for _,m in ipairs(aliveMembers(s)) do live[tostring(m.id)]=m end
  local all=true local count=0
  for i,mid in ipairs(r.memberIds) do
   local m=live[tostring(mid)]
   if m then
    count=count+1
    local lane=r.plan.members[i]
    local dest=r.stage=='deploy' and lane.deploy or lane.points[r.frontIndex]
    if near(m.position,dest) then
     if not r.unitHeld then r.unitHeld={} end
     if not r.unitHeld[i] then
      if command(r,'holdUnit',mid) then r.unitHeld[i]=true else all=false end
     end
    else
     all=false
     r.unitHeld=r.unitHeld or {} r.unitHeld[i]=nil
     r.unitDest=r.unitDest or {}
     if r.unitDest[i] and near(m.position,r.unitDest[i]) then r.unitSent[i]=nil end
     if not r.unitSent[i] or C.Time-r.unitSent[i]>=cfg.RetrySeconds then
      local nextPoint=P.segment(m.position,dest,cfg.WaypointMeters*cfg.UnitsPerMeter,cfg.MaxWaypoints)[1]
      if command(r,'moveUnit',mid,nextPoint) then r.unitDest[i]=nextPoint r.unitSent[i]=C.Time r.status=r.stage end
     end
    end
   end
  end
  if count==0 then r.status='no_live_members' return end
  if all then
   if r.stage=='deploy' then r.stage='front' r.frontIndex=1
   elseif r.frontIndex<#r.plan.members[1].points then r.frontIndex=r.frontIndex+1
   else r.stage='hold' r.status='front_at_flag' end
   r.unitSent={} r.unitHeld={} r.unitDest={}
  end
 elseif r.stage=='hold' then
  -- No CaptureFlag: it would collapse the front or pull armour into the centre.
  r.status=r.plan.kind=='infantry' and 'front_at_flag' or 'holding'
 end
end
function N.capture(id,flag,force)
 if not(id and flag and N.flagObj(flag) and N.squadAlive(id)) then return end
 local s=snapshot(id)
 local r=routes[id]
 if r and r.controlled and not s then
  r.status='snapshot_missing'
  if not r.paused then call('holdSquad',id) r.paused=true end
  return false
 end
 if not r or r.flag~=flag or (s and (r.originSource~='measured' or (validKind(s.kind) and r.plan.kind~=s.kind) or (s.kind=='infantry' and #r.memberIds==0 and #aliveMembers(s)>0))) then r=build(id,flag,s) end
 if not r then return previousCapture(id,flag,force) end
 local ok,reason=ready(r,s)
 if ok then
  -- Preview routes must start again at the first measured position before execution.
  if r.originSource~='measured' or (r.plan.kind=='infantry' and #r.memberIds==0) then r=build(id,flag,s) end
  if r then r.controlled=true return true end
 end
 if r.controlled then
  -- Losing telemetry never means "arrived" and must not send a conflicting capture.
  r.status=reason or 'snapshot_missing'
  if not r.paused then call('holdSquad',id) r.paused=true end
  return false
 end
 r.status=reason or 'planned'
 return previousCapture(id,flag,force)
end
local function quote(s)
 return '"'..tostring(s):gsub('[%z\1-\31\\"]',function(c)
  if c=='"' then return '\\"' elseif c=='\\' then return '\\\\' end
  return string.format('\\u%04x',string.byte(c))
 end)..'"'
end
local function json(v)
 if type(v)=='string' then return quote(v) end
 if type(v)=='number' then return P.finite(v) and tostring(v) or 'null' end
 if type(v)=='boolean' then return tostring(v) end
 if type(v)~='table' then return 'null' end
 local out={}
 if #v>0 then for _,x in ipairs(v) do out[#out+1]=json(x) end return '['..table.concat(out,',')..']' end
 for k,x in pairs(v) do out[#out+1]=quote(k)..':'..json(x) end
 return '{'..table.concat(out,',')..'}'
end
function T.export()
 local rows={} local flags={}
 for _,flag in pairs(BotApi.Scene.Flags) do
  local p=targetPoint(flag.name)
  flags[#flags+1]={name=flag.name,position=p,occupant=tostring(flag.occupant)}
 end
 local seen={}
 local function add(id)
  if seen[id] then return end seen[id]=true
  local r=routes[id]
  rows[#rows+1]=r or {id=id,role=C.SquadRole[id] or 'unknown',status='no_order_or_coordinates'}
 end
 for id in pairs(C.SquadRole) do if N.squadAlive(id) then add(id) end end
 for _,id in pairs(BotApi.Scene.Squads) do if type(id)=='number' or type(id)=='string' then if N.squadAlive(id) then add(id) end end end
 local host=tostring(BotApi.Instance.hostId or 'bot'):gsub('[^%w_-]','_')
 local name='bot_routes_'..host..'.json'
 local folder='mods\\'..NEU_BOT.ModFolder..'\\resource\\script\\multiplayer\\'
 local outputPath=folder..name
 local file=io.open(outputPath,'w')
 if not file then outputPath=name file=io.open(outputPath,'w') end
 if not file then
  if not T.writeError then N.log('TACTICS EXPORT CANNOT OPEN '..name) T.writeError=true end
  return
 end
 local payload={version='1.23',time=C.Time,host=host,map=N.MAP and N.MAP.mapKey,
  unitsPerMeter=cfg.UnitsPerMeter,calibrated=cfg.UnitsPerMeter~=nil,
  mode=cfg.Enabled and 'adapter_requested' or 'plan_only',flags=flags,squads=rows}
 local ok,err=pcall(function() assert(file:write(json(payload))) end)
 file:close()
 if not ok then N.log('TACTICS EXPORT ERROR '..tostring(err))
 elseif T.exportPath~=outputPath then T.exportPath=outputPath N.log('VISUALIZER FILE '..outputPath) end
end
function T.tick()
 for id,r in pairs(routes) do
  if not N.squadAlive(id) then routes[id]=nil spawns[id]=nil units[id]=nil
  else
   local s=snapshot(id)
   if s then r.lastConfirmed=P.copy(s.position) r.observedAt=C.Time end
   local ok,reason=ready(r,s)
   if r.controlled and ok then
    r.paused=nil
    routeTick(r,s)
   elseif r.controlled then
    r.status=reason
    if not r.paused then call('holdSquad',id) r.paused=true end
   end
  end
 end
 if C.Time>=exportAt then exportAt=C.Time+cfg.ExportSeconds T.export() end
end
return T
