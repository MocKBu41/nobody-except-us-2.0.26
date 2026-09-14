-- NEU BOT v1.30.1 adaptive logic + compact telemetry
local N=require([[/script/multiplayer/bot.core]])
local C=N.C

-- ---------------- compact telemetry ----------------
local TF={path=nil,bytes=0,ready=false,last=-999}
local function esc(v) return tostring(v or ''):gsub('\\','\\\\'):gsub('"','\\"'):gsub('\r','\\r'):gsub('\n','\\n') end
local function q(v) return '"'..esc(v)..'"' end
local function append(s)
 if not TF.ready or not TF.path then return end
 if TF.bytes+#s+2>(NEU_BOT.TelemetryMaxBytes or 4500000) then return end
 local f=io.open(TF.path,'a') if not f then TF.ready=false return end f:write(s,'\n') f:close() TF.bytes=TF.bytes+#s+1
end
local function important(m)
 m=tostring(m or '')
 return m:find('START ',1,true) or m:find('TARGET ',1,true) or m:find('CAPTURED',1,true) or m:find('LOST ',1,true) or m:find('SPAWN FAILED',1,true) or m:find('ARRIVED ',1,true) or m:find('ATTACK UNLOCK',1,true) or m:find('WAVE ',1,true) or m:find('AIR ',1,true) or m:find('AA ',1,true)
end
local baseLog=N.log
function N.log(m) baseLog(m) if TF.ready and important(m) then append('{"type":"event","v":"1.30.1","t":'..tostring(C.Time or 0)..',"team":'..q(BotApi.Instance.team)..',"m":'..q(m)..'}') end end
local function initTelemetry()
 local team=tostring(BotApi.Instance.team or 'bot'):gsub('[^%w_-]','_')
 TF.path='mods\\'..NEU_BOT.ModFolder..'\\resource\\script\\multiplayer\\bot_gpt_telemetry_'..team..'.jsonl'
 local f=io.open(TF.path,'w') if not f then TF.path='bot_gpt_telemetry_'..team..'.jsonl' f=io.open(TF.path,'w') end
 if f then local s='{"type":"session","v":"1.30.1","team":'..q(BotApi.Instance.team)..',"enemy":'..q(BotApi.Instance.enemyTeam)..',"snapshotSec":'..tostring(NEU_BOT.TelemetrySnapshotSec or 15)..',"geometry":"logical-only","realPositions":false}' f:write(s,'\n') f:close() TF.bytes=#s+1 TF.ready=true end
end
local function observedPositions()
 local out={} local a=rawget(_G,'NEU_TacticalAdapter') if type(a)~='table' or type(a.getSquad)~='function' then return out end
 for id,_ in pairs(C.SquadRole) do if N.alive(id) then local ok,s=pcall(a.getSquad,id) if ok and type(s)=='table' then local p=s.position or s.pos if type(p)=='table' and type(p.x)=='number' and type(p.y)=='number' then out[#out+1]='['..tostring(id)..','..tostring(p.x)..','..tostring(p.y)..']' end end end end return out
end
local function snapshot()
 if not TF.ready then return end local f=N.flags() local flags={}
 for _,x in pairs(BotApi.Scene.Flags) do local o='n' if x.occupant==BotApi.Instance.team then o='m' elseif x.occupant==BotApi.Instance.enemyTeam then o='e' end flags[#flags+1]='['..q(x.name)..','..q(o)..']' end table.sort(flags)
 local groups={} for id,g in pairs(C.Groups) do groups[#groups+1]='['..tostring(id)..','..q(g.phase)..','..q(g.target or '')..','..tostring(N.groupInf(g))..','..tostring(N.count(g.tanks))..','..tostring(g.wave or 0)..']' end table.sort(groups)
 local squads={} for id,r in pairs(C.SquadRole) do if N.alive(id) then local last=C.LastOrder[id] squads[#squads+1]='['..tostring(id)..','..q(r)..','..tostring(C.SquadGroup[id] or 0)..','..q(last and last.flag or '')..']' end end table.sort(squads)
 local pos=observedPositions()
 append('{"type":"snapshot","v":"1.30.1","t":'..tostring(C.Time)..',"team":'..q(BotApi.Instance.team)..',"mine":'..f.mineCount..',"enemy":'..f.enemyCount..',"neutral":'..f.neutralCount..',"flags":['..table.concat(flags,',')..'],"groups":['..table.concat(groups,',')..'],"squads":['..table.concat(squads,',')..'],"pos":['..table.concat(pos,',')..']}')
end

-- ---------------- support ----------------
local function airAlive()
 for id,_ in pairs(C.AirSupport) do if N.alive(id) then return true end end return false
end
local function pendingAny(roles)
 for _,x in ipairs(C.SpawnIntents) do for _,r in ipairs(roles) do if x.role==r then return true end end end
 if C.AwaitingArrival then for _,r in ipairs(roles) do if C.AwaitingArrival.role==r then return true end end end return false
end
local function ensureAA()
 if C.Time<(C.NextAAAt or 0) then return end C.NextAAAt=C.Time+(NEU_BOT.AAReplacementSec or 30)
 for id,r in pairs(C.SquadRole) do if (r=='antiair' or r=='aat') and N.alive(id) then return end end
 if pendingAny({'antiair','aat'}) then return end local role=#(C.Candidates.antiair or {})>0 and 'antiair' or (#(C.Candidates.aat or {})>0 and 'aat' or nil)
 if role then N.queue(role,'AA replacement',0,nil,nil,90) N.log('AA REPLACEMENT QUEUED') end
end
local function enemyScan()
 if C.Time%15~=0 then return end local ok,v=pcall(function() return BotApi.Commands:EnemyHasTanks() end) C.EnemyHasTanks=(ok and type(v)=='boolean') and v or nil
end
local function ensureAir()
 if C.Time<(NEU_BOT.AirSupportDelaySec or 120) or C.Time<(C.NextAirAt or 0) or C.EnemyHasTanks~=true or airAlive() or pendingAny({'strike','aircraftlight','patrol_heli','antirad'}) then return end
 local f=N.flags() if f.enemyCount==0 then return end local target=f.enemy[1] N.sortFlags(f.enemy,BotApi.Instance.team=='b') target=f.enemy[1]
 local role=#(C.Candidates.strike or {})>0 and 'strike' or (#(C.Candidates.aircraftlight or {})>0 and 'aircraftlight' or (#(C.Candidates.patrol_heli or {})>0 and 'patrol_heli' or nil))
 if role then C.NextAirAt=C.Time+(NEU_BOT.AirSupportCooldownSec or 360) N.queue(role,'enemy armour response',0,target,nil,70) N.log('AIR QUEUED role='..role..' target='..target) end
end

-- ---------------- adaptive front logic ----------------
local function newGroup(id) C.Groups[id]={id=id,phase='opening',target=nil,infantry={},tanks={},wave=0,failCount=0,started=0,attackAt=0,checkAt=0,nextAt=0} end
local function activeTarget(flag,except)
 for id,g in pairs(C.Groups) do if id~=except and g.target==flag and (g.phase=='assembling' or g.phase=='attack') then return true end end return false
end
local function lostCount() local n=0 for _ in pairs(C.LostOwn) do n=n+1 end return n end
local function targetScore(name,gid)
 local occ=N.owner(name) local s=0
 if C.LostOwn[name] then s=160 elseif occ==BotApi.Instance.enemyTeam then s=110 elseif occ~=BotApi.Instance.team then s=55 else return -9999 end
 if activeTarget(name,gid) then s=s-90 end local g=C.Groups[gid] if g and g.failedTarget==name then s=s-30 end
 return s+math.random(0,9)
end
local function chooseTarget(gid)
 local best,bs=nil,-99999 for _,f in pairs(BotApi.Scene.Flags) do local s=targetScore(f.name,gid) if s>bs then best,bs=f.name,s end end return best,bs
end
local function ensureGroup(g)
 while N.groupInf(g)<(NEU_BOT.MinAssaultInfantrySquads or 2) and not N.pending('infantry',g.id) do N.queue('infantry','group reinforcement',0,g.target,g.id,100) break end
 if N.count(g.tanks)==0 and not N.pending('tank',g.id) then N.queue('tank','group tank',0,g.target,g.id,95) end
end
local function orderGroup(g,force)
 if not g.target then return end for _,id in ipairs(g.infantry) do if N.alive(id) then N.capture(id,g.target,force) end end for _,id in ipairs(g.tanks) do if N.alive(id) then N.capture(id,g.target,force) end end
end
local function startWave(g,target)
 if not target then return end g.target=target g.phase='assembling' g.wave=(g.wave or 0)+1 g.started=C.Time g.attackAt=C.Time+(NEU_BOT.AssemblySec or 12) g.checkAt=0 ensureGroup(g) N.log('TARGET group='..g.id..' -> '..target..' wave='..g.wave)
end
local function launch(g)
 g.phase='attack' g.checkAt=C.Time+(NEU_BOT.AttackResultSec or 60) orderGroup(g,true) N.log('WAVE ATTACK group='..g.id..' target='..tostring(g.target)..' I='..N.groupInf(g)..' T='..N.count(g.tanks))
 if g.target and N.owner(g.target)==BotApi.Instance.enemyTeam and #(C.Candidates.artsupport or {})>0 and not N.pending('artsupport',g.id) then N.queue('artsupport','attack support',0,g.target,g.id,45) end
end
local function updateOwnership()
 for _,f in pairs(BotApi.Scene.Flags) do local now=f.occupant==BotApi.Instance.team local prev=C.PreviousOwn[f.name]
  if prev and not now then C.LostOwn[f.name]=C.Time N.log('LOST FLAG '..f.name) elseif now then C.LostOwn[f.name]=nil end C.PreviousOwn[f.name]=now
 end
end
local function unlock()
 if C.AttackUnlocked then return end local f=N.flags() if C.Time>=(NEU_BOT.AttackWaitSec or 75) or f.enemyCount>f.mineCount or lostCount()>0 then C.AttackUnlocked=true for _,g in pairs(C.Groups) do if g.phase=='opening' then g.phase='ready' g.nextAt=C.Time end end N.log('ATTACK UNLOCK') end
end
local function processGroups()
 for _,g in pairs(C.Groups) do ensureGroup(g)
  if C.AttackUnlocked and (g.phase=='ready' or g.phase=='opening') and C.Time>=(g.nextAt or 0) then local t=chooseTarget(g.id) if t then startWave(g,t) end
  elseif g.phase=='assembling' then if (N.groupInf(g)>=(NEU_BOT.MinAssaultInfantrySquads or 2) and N.count(g.tanks)>0 and C.Time>=g.attackAt) or C.Time-g.started>=(NEU_BOT.AssemblyMaxSec or 45) then launch(g) end
  elseif g.phase=='attack' and g.target then
   if N.owner(g.target)==BotApi.Instance.team then N.log('CAPTURED group='..g.id..' flag='..g.target) C.LostOwn[g.target]=nil g.target=nil g.phase='ready' g.failCount=0 g.nextAt=C.Time+(NEU_BOT.CaptureNextDelaySec or 5)
   elseif C.Time>=(g.checkAt or 999999) then local old=g.target g.failCount=(g.failCount or 0)+1 g.failedTarget=old g.target=nil g.phase='ready' g.nextAt=C.Time+3 N.log('WAVE FAILED group='..g.id..' flag='..old..' -> retarget') end
  end
 end
 -- Emergency retake: do not let both groups ignore a recently lost flag.
 if lostCount()>0 then for name,_ in pairs(C.LostOwn) do if not activeTarget(name,nil) then local pick=nil for _,g in pairs(C.Groups) do if g.phase=='ready' then pick=g break end end if pick then startWave(pick,name) end break end end end
end
local function openingTargets()
 local f=N.flags() local a={} for _,x in ipairs(f.neutral) do a[#a+1]=x end local reverse=BotApi.Instance.team=='b' N.sortFlags(a,reverse)
 local n=math.min(#a,NEU_BOT.OpeningCappers or 3) for i=1,n do N.queue('pointstart','opening capture',0,a[i],nil,80) end
end
local function processPoints()
 if C.Time%12~=0 then return end
 for id,t in pairs(C.PointTargets) do if N.alive(id) then if N.owner(t)==BotApi.Instance.team then if not C.PointDone[t] then C.PointDone[t]=true N.log('CAPTURED pointstart squad='..id..' flag='..t) end else N.capture(id,t,false) end end end
end
local function detectLosses()
 for id,r in pairs(C.SquadRole) do if not C.Dead[id] and not N.alive(id) then C.Dead[id]=true local gid=C.SquadGroup[id] N.log('LOST squad='..id..' role='..r..' group='..tostring(gid))
   if gid and C.Groups[gid] and r=='infantry' and not N.pending('infantry',gid) then N.queue('infantry','infantry replacement',NEU_BOT.InfantryReplacementSec or 8,C.Groups[gid].target,gid,100) end
   if gid and C.Groups[gid] and r=='tank' and not N.pending('tank',gid) then N.queue('tank','tank replacement',NEU_BOT.TankReplacementSec or 10,C.Groups[gid].target,gid,95) end
   if C.AirSupport[id] then C.AirSupport[id]=nil end if C.ArtSupport[id] then C.ArtSupport[id]=nil end
  end end
end
local function patrolOrders()
 if C.Time<(C.NextPatrolAt or 0) then return end C.NextPatrolAt=C.Time+(NEU_BOT.PatrolSec or 30) local f=N.flags() N.sortFlags(f.mine,false) local home=f.mine[1]
 for id,r in pairs(C.SquadRole) do if N.alive(id) and (r=='antiair' or r=='aat') and home then N.capture(id,home,false) end end
end
local function reissue()
 if C.Time%15~=0 then return end for _,g in pairs(C.Groups) do if g.phase=='attack' then orderGroup(g,false) end end
end
local function writeSnapIfDue() if C.Time-TF.last>=(NEU_BOT.TelemetrySnapshotSec or 15) then TF.last=C.Time snapshot() end end
local function onSecond()
 C.Time=C.Time+1 updateOwnership() detectLosses() enemyScan() processPoints() unlock() processGroups() ensureAA() ensureAir() patrolOrders() reissue() N.processSpawn() writeSnapIfDue()
 if C.Time%30==0 then local f=N.flags() local gs={} for id,g in pairs(C.Groups) do gs[#gs+1]='G'..id..'='..tostring(g.target)..':'..g.phase..':I'..N.groupInf(g)..':T'..N.count(g.tanks) end N.log('STATE t='..C.Time..' flags='..f.mineCount..'/'..f.enemyCount..'/'..f.neutralCount..' '..table.concat(gs,' ')) end
end
local function stopClock() C.TimerGeneration=C.TimerGeneration+1 if C.Timer then BotApi.Events:KillQuantTimer(C.Timer) C.Timer=nil end end
local function startClock() stopClock() local gen=C.TimerGeneration local function pulse() if gen~=C.TimerGeneration then return end C.Timer=nil onSecond() if gen==C.TimerGeneration then C.Timer=BotApi.Events:SetQuantTimer(pulse,NEU_BOT.TickMs or 1000) end end C.Timer=BotApi.Events:SetQuantTimer(pulse,NEU_BOT.TickMs or 1000) end

function onGameStart()
 C.Time=0 C.SpawnIntents={} C.SpawnTickets={} C.AwaitingArrival=nil C.Spawning=false C.SquadRole={} C.SquadGroup={} C.Dead={} C.LastOrder={} C.Groups={} C.PointTargets={} C.PointDone={} C.AirSupport={} C.ArtSupport={} C.PreviousOwn={} C.LostOwn={} C.AttackUnlocked=false C.NextAirAt=NEU_BOT.AirSupportDelaySec or 120 C.NextAAAt=0 C.NextPatrolAt=0
 local host=tonumber(BotApi.Instance.hostId) or 1 math.randomseed(os.time()+host*101) for _,f in pairs(BotApi.Scene.Flags) do C.PreviousOwn[f.name]=f.occupant==BotApi.Instance.team end
 initTelemetry() N.loadUnits() N.buildCandidates() for i=1,(NEU_BOT.AssaultGroups or 2) do newGroup(i) for k=1,(NEU_BOT.OpeningInfantryPerGroup or 2) do N.queue('infantry','opening assault infantry',0,nil,i,100) end N.queue('tank','opening assault tank',3,nil,i,95) end
 N.queue('antiair','opening AA',2,nil,nil,90) openingTargets() N.queue('recon','opening recon',8,nil,nil,40)
 N.log('START v1.30.1 team='..tostring(BotApi.Instance.team)..' mapGeometry=DISABLED reason=runtime map id unavailable/ambiguous') N.log('START adaptive flag priority + split targets + capped opening cappers') snapshot() startClock() N.processSpawn()
end
function onGameStop() snapshot() stopClock() collectgarbage('collect') end
function onGameQuant() N.processSpawn() end
function onGameSpawn(args)
 local id=args and args.squadId if not id then return end local ticket=#C.SpawnTickets>0 and table.remove(C.SpawnTickets,1) or nil
 if not ticket then N.log('UNMATCHED squad='..id..' ignored (prevents passenger/crew misclassification)') return end if C.AwaitingArrival==ticket then C.AwaitingArrival=nil end C.SquadRole[id]=ticket.role C.SquadGroup[id]=ticket.groupId C.Dead[id]=false N.log('ARRIVED squad='..id..' role='..ticket.role..' group='..tostring(ticket.groupId))
 if ticket.role=='pointstart' then C.PointTargets[id]=ticket.target if ticket.target then N.capture(id,ticket.target,true) end
 elseif ticket.role=='infantry' then local g=C.Groups[ticket.groupId] if g then g.infantry[#g.infantry+1]=id if g.target and g.phase=='attack' then N.capture(id,g.target,true) end end
 elseif ticket.role=='tank' then local g=C.Groups[ticket.groupId] if g then g.tanks[#g.tanks+1]=id if g.target and g.phase=='attack' then N.capture(id,g.target,true) end end
 elseif ticket.role=='antiair' or ticket.role=='aat' then local f=N.flags() N.sortFlags(f.mine,false) if f.mine[1] then N.capture(id,f.mine[1],true) end
 elseif ticket.role=='artsupport' then C.ArtSupport[id]={groupId=ticket.groupId,target=ticket.target} if ticket.target then N.capture(id,ticket.target,true) end
 elseif ticket.role=='strike' or ticket.role=='aircraftlight' or ticket.role=='patrol_heli' or ticket.role=='antirad' then C.AirSupport[id]={role=ticket.role,target=ticket.target} if ticket.target then N.capture(id,ticket.target,true) end N.log('AIR ARRIVED role='..ticket.role..' target='..tostring(ticket.target))
 elseif ticket.target then N.capture(id,ticket.target,true) end N.processSpawn()
end
BotApi.Events:Subscribe(BotApi.Events.GameStart,onGameStart)
BotApi.Events:Subscribe(BotApi.Events.GameEnd,onGameStop)
BotApi.Events:Subscribe(BotApi.Events.Quant,onGameQuant)
BotApi.Events:Subscribe(BotApi.Events.GameSpawn,onGameSpawn)
return N
