-- v1.21 support lifecycle. Enemy AA observations require a real external adapter.
-- Unknown is never interpreted as absence. No hypothetical native methods are called.
local N=require([[/script/multiplayer/bot.v1_21.core]])
local C=N.C
function N.isAirRole(role)
 return role=='aircraftlight' or role=='airbot' or role=='uavbot' or role=='antirad'
end
function N.resetSupport()
 C.EnemyAAReport=nil C.EnemyAASince=nil C.NextAAMaintenanceAt=0 C.LastAirGroupAt={}
 C.SupportBatch=0 C.SupportQueueBatch=nil C.NextSupportLogAt=0
end
-- Integration point, NOT a claim that stock BotApi exposes enemy AAT.
-- A provider must positively observe presence, or verify a COMPLETE army scan
-- for absence. Reports expire. A flag is optional and must be an observed sector.
function N.reportEnemyAA(present,flag,source)
 if type(present)~='boolean' or type(source)~='string' or source=='' then return false end
 if flag and not N.flagObj(flag) then return false end
 local old=N.enemyAAState()
 C.EnemyAAReport={present=present,flag=flag,source=source,at=C.Time}
 if present then if old~=true then C.EnemyAASince=C.Time end else C.EnemyAASince=nil end
 return true
end
function N.enemyAAState()
 local r=C.EnemyAAReport
 if not r or C.Time-r.at>(NEU_BOT.EnemyAAReportMaxAgeSec or 45) then return nil end
 return r.present
end
local function airPending()
 for _,x in ipairs(C.SpawnIntents) do if N.isAirRole(x.role) then return true end end
 return C.AwaitingArrival and N.isAirRole(C.AwaitingArrival.role)
end
function N.allowSupportQueue(role,mode)
 if not N.isAirRole(role) then return true end
 if C.SupportQueueBatch and mode==C.SupportQueueBatch then return true end
 if C.Time<(C.NextAircraftAllowedAt or 0) or airPending() then return false end
 C.NextAircraftAllowedAt=C.Time+math.max(360,NEU_BOT.AirSupportCooldownSec or 360)
 N.log('AIR COOLDOWN START next='..C.NextAircraftAllowedAt..' role='..role)
 return true
end
function N.validateSupportSpawn(intent)
 if intent.role=='uavbot' and N.enemyAAState()~=false then
  N.log('UAV CANCEL group='..tostring(intent.groupId)..' reason=enemy AA present or unknown') return false
 end
 if intent.role=='antirad' and N.enemyAAState()~=true then
  N.log('ANTIRAD CANCEL reason=enemy AA not confirmed') return false
 end
 return true
end
local function hasAir(gid)
 for sid,s in pairs(C.AirSupport) do if N.squadAlive(sid) and (not gid or s.groupId==gid) then return true end end
 return false
end
local function activeGroups()
 local ids={}
 for id,g in pairs(C.Groups) do if g.target then ids[#ids+1]=id end end
 table.sort(ids) return ids
end
local function supportLog(message)
 if C.Time>=(C.NextSupportLogAt or 0) then C.NextSupportLogAt=C.Time+30 N.log(message) end
end
function N.ensureAir(id,target)
 if not target or hasAir(id) or airPending() or C.Time<(C.NextAircraftAllowedAt or 0) then return end
 -- Rotate single-aircraft support between active BTGs across cooldown cycles.
 local best,bestAt=nil,nil
 for _,gid in ipairs(activeGroups()) do
  local at=(C.LastAirGroupAt or {})[gid] or -1
  if not hasAir(gid) and (bestAt==nil or at<bestAt) then best,bestAt=gid,at end
 end
 if best then id=best target=C.Groups[id].target end
 local aa=N.enemyAAState()
 if aa==true then
  if C.Time-(C.EnemyAASince or C.Time)<(NEU_BOT.AntiradResponseDelaySec or 180) then return end
  if #(C.Candidates.antirad or {})==0 then supportLog('ANTIRAD BLOCK no candidates') return end
  N.enqueueSpawn('antirad','confirmed enemy AAT response',0,(C.EnemyAAReport and C.EnemyAAReport.flag) or target,id,'support')
  return
 end
 local planes=#(C.Candidates.airbot or {})>0
 local ids=activeGroups()
 local uavs=aa==false and #(C.Candidates.uavbot or {})>0 and #ids>=2 and not hasAir(nil)
 if uavs and (not planes or math.random(1,2)==2) then
  -- A pair is ONE support request; reserve the global cooldown only once.
  C.SupportBatch=(C.SupportBatch or 0)+1
  local batch='uavpair:'..C.SupportBatch
  if not N.allowSupportQueue('uavbot','support') then return end
  C.SupportQueueBatch=batch
  for i=1,2 do local gid=ids[i] N.enqueueSpawn('uavbot','confirmed AA clear; paired BTG support',0,C.Groups[gid].target,gid,batch) end
  C.SupportQueueBatch=nil
  N.log('UAV PAIR QUEUED groups='..ids[1]..'|'..ids[2])
 elseif planes then
  N.enqueueSpawn('airbot','BTG aircraft support; AA='..tostring(aa),0,target,id,'support')
 else
  if aa==nil then supportLog('AA INTEL UNKNOWN: conditional UAV/antirad unavailable; normal aircraft support retained') end
  if #(C.Candidates.aircraftlight or {})>0 then N.enqueueSpawn('aircraftlight','BTG legacy aircraft support',0,target,id,'support') end
 end
end
function N.supportArrived(sid,ticket)
 C.LastAirGroupAt=C.LastAirGroupAt or {} if ticket.groupId then C.LastAirGroupAt[ticket.groupId]=C.Time end
 C.NextAircraftAllowedAt=math.max(C.NextAircraftAllowedAt or 0,C.Time+math.max(360,NEU_BOT.AirSupportCooldownSec or 360))
 local g=ticket.groupId and C.Groups[ticket.groupId]
 local t=(ticket.role=='antirad' and ticket.target) or (g and g.target) or ticket.target
 C.AirSupport[sid]={groupId=ticket.groupId,target=t,home=N.chooseOwnFlagBefore(t),leg='target',role=ticket.role}
 N.log('AIR ARRIVED role='..ticket.role..' group='..tostring(ticket.groupId)..' cooldownUntil='..C.NextAircraftAllowedAt)
 if t then N.capture(sid,t,true) end
end
function N.maintainAA()
 if C.Time<(C.NextAAMaintenanceAt or 0) then return end
 C.NextAAMaintenanceAt=C.Time+(NEU_BOT.AAReplacementRetrySec or 30)
 local alive=0
 for sid,r in pairs(C.SquadRole) do if (r=='antiair' or r=='aat') and N.squadAlive(sid) then alive=alive+1 end end
 if alive>0 then return end
 for _,x in ipairs(C.SpawnIntents) do if x.role=='antiair' or x.role=='aat' then return end end
 if C.AwaitingArrival and (C.AwaitingArrival.role=='antiair' or C.AwaitingArrival.role=='aat') then return end
 local role=(#(C.Candidates.antiair or {})>0 and 'antiair') or (#(C.Candidates.aat or {})>0 and 'aat')
 if not role then N.log('AA REPLACE BLOCK no candidates') return end
 N.log('AA REPLACE no surviving registered AA squad')
 N.enqueueSpawn(role,'AA maintenance replacement',0,N.chooseFrontOwnFlag(nil),nil,'defense')
end
return N
