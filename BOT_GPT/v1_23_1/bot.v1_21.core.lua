-- NEU BOT v1.21 core
require([[/script/multiplayer/bot.data]])
require([[/script/multiplayer/bot.mapdata]])
NEU21=NEU21 or {}
local N=NEU21
N.MAP=NEU_MAPDATA
N.C={Units={},Candidates={},SpawnIntents={},SpawnTickets={},AwaitingArrival=nil,SquadRole={},DeadSquads={},SquadGroup={},DefendTarget={},Groups={},LastOrder={},Time=0,AttackUnlocked=false,NeutralsCleared=false,HostileNeutral={},PointStartTarget={},PointStartPending={},PointStartDone={},PointStartQueued=false,PatrolHeliSquad=nil,AirSupport={},ArtSupport={},UnmatchedPending={},LastSpawnGroup=nil,LastSpawnGroupAt=-999,NextOrderAt=0,NextPointStartCheckAt=0,NextSupportPatrolAt=0,NextHeliPatrolAt=0,NextPatrolAt=0,FlagSnapshot=nil,FlagIndex=nil,Timer=nil,TimerGeneration=0}
local C=N.C
function N.log(m) print('[NEU-BOT] '..tostring(m)) end
local function lower(s) return string.lower(tostring(s or '')) end
local function splitTags(tags) local o={} for t in string.gmatch(tags or '', '%S+') do o[lower(t)]=true end return o end
local function hasTag(r,t) return r and r.tagset and r.tagset[lower(t)]==true end
local function recText(r) return lower((r and r.unit or '')..' '..(r and r.raw or '')) end
local function roleMatches(r,role)
 local text=recText(r)
 if role=='airbot' or role=='uavbot' then return hasTag(r,role) end
 if role=='pointstart' then return hasTag(r,'pointstart') end
 if role=='patrol_heli' then return hasTag(r,'duel_heli') or hasTag(r,'duel_heli2') end
 if role=='aircraftlight' then return hasTag(r,'aircraftlight') or text:find('support_light',1,true)~=nil end
 if role=='artsupport' then return hasTag(r,'artsupport') end
 if role=='antirad' then return hasTag(r,'antirad') or text:find('antirad',1,true)~=nil end
 if role=='strike' then return hasTag(r,'strike') or text:find('_strike',1,true)~=nil end
 if r and r.nobot then return false end
 if role=='recon' then return hasTag(r,'all') and hasTag(r,'recon') end
 if role=='infantry' or role=='defense_infantry' then return hasTag(r,'all') and hasTag(r,'infantry') end
 if role=='antiair' then return hasTag(r,'all') and hasTag(r,'antiair') end
 if role=='tank' then return hasTag(r,'duel_tanks70') or hasTag(r,'duel_tanks80') or hasTag(r,'duel_tanks90') end
 if role=='aat' then return hasTag(r,'aat') end
 return false
end
local function detectSide(line) return line:match('%f[%w]side%s*%(%s*([^%)%s]+)%s*%)') or line:match('%f[%w]s%s*%(%s*([^%)%s]+)%s*%)') end
local function parseRecords(raw)
 local records,buffer,stack={},{},{} local quoted,escaped,comment=false,false,false
 for i=1,#raw do
  local ch=raw:sub(i,i)
  if comment then if ch=='\n' then comment=false if #stack>0 then buffer[#buffer+1]=' ' end end
  elseif quoted then buffer[#buffer+1]=ch if escaped then escaped=false elseif ch=='\\' then escaped=true elseif ch=='"' then quoted=false end
  elseif ch==';' then comment=true
  elseif ch=='"' then if #stack>0 then buffer[#buffer+1]=ch quoted=true end
  elseif ch=='(' or ch=='{' then stack[#stack+1]=ch buffer[#buffer+1]=ch
  elseif ch==')' or ch=='}' then
   if #stack>0 then local expected=(ch==')') and '(' or '{' if stack[#stack]~=expected then return records end buffer[#buffer+1]=ch stack[#stack]=nil if #stack==0 then records[#records+1]=table.concat(buffer) buffer={} end end
  elseif #stack>0 then buffer[#buffer+1]=ch end
 end
 return records
end
function readUnitsRaw(fname,units,army)
 local f=io.open(fname,'r') if not f then N.log('FILE MISSING '..fname) return end
 local raw=f:read('*a') f:close() units.count=units.count or 1 units.seen=units.seen or {} local added=0
 for _,line in ipairs(parseRecords(raw)) do
  local side=detectSide(line)
  if side and lower(side)==lower(army) then
   local parts={} for tags in line:gmatch('%f[%w]t%s*%(([^)]*)%)') do parts[#parts+1]=tags end
   local tags=table.concat(parts,' ') local vehicle=line:match('^%s*{%s*"([^"]+)"') local name=vehicle or line:match('%f[%w]name%s*%(([^)]+)%)')
   if name and not name:find('mp/',1,true) then local id=vehicle or (name..'('..army..')') if not units.seen[id] then units[units.count]={unit=id,tags=tags,tagset=splitTags(tags),raw=line,side=side,nobot=(line:find('nobot',1,true)~=nil)} units.count=units.count+1 units.seen[id]=true added=added+1 end end
  end
 end
 N.log('READ '..fname..' added='..added)
end
function N.buildCandidates()
 local roles={'pointstart','patrol_heli','recon','infantry','defense_infantry','antiair','tank','aircraftlight','artsupport','aat','antirad','strike','airbot','uavbot'} C.Candidates={}
 for _,r in ipairs(roles) do C.Candidates[r]={} end
 for _,rec in ipairs(C.Units) do if type(rec)=='table' then for _,r in ipairs(roles) do if roleMatches(rec,r) then C.Candidates[r][#C.Candidates[r]+1]=rec end end end end
 for _,r in ipairs(roles) do N.log('ROLE '..r..' candidates='..#C.Candidates[r]) end
end
function N.flags()
 if C.FlagSnapshot then return C.FlagSnapshot end
 local my,enemy=BotApi.Instance.team,BotApi.Instance.enemyTeam local f={mine={},enemy={},neutral={},mineCount=0,enemyCount=0,neutralCount=0}
 for _,x in pairs(BotApi.Scene.Flags) do if x.occupant==my then f.mine[#f.mine+1]=x.name f.mineCount=f.mineCount+1 elseif x.occupant==enemy then f.enemy[#f.enemy+1]=x.name f.enemyCount=f.enemyCount+1 else f.neutral[#f.neutral+1]=x.name f.neutralCount=f.neutralCount+1 end end return f
end
function N.flagObj(name) if C.FlagIndex then return C.FlagIndex[name] end for _,f in pairs(BotApi.Scene.Flags) do if f.name==name then return f end end end
function N.flagOccupant(name) local f=N.flagObj(name) return f and f.occupant or nil end
function N.isNeutral(name) local o=N.flagOccupant(name) return o~=BotApi.Instance.team and o~=BotApi.Instance.enemyTeam end
local function flagNumber(name) return type(name)=='string' and tonumber(name:match('(%d+)$')) or nil end
function N.numericSort(list) table.sort(list,function(a,b) local na,nb=flagNumber(a),flagNumber(b) if na and nb and na~=nb then return na<nb end return tostring(a)<tostring(b) end) end
function N.geoSortSpawn(list) if N.MAP and N.MAP.loaded and N.MAP.spawn then N.MAP:sortFromSpawn(list) else N.numericSort(list) end end
function N.geoSortFromFlag(list,from) if N.MAP and N.MAP.loaded and from and N.MAP:point(from) then N.MAP:sortFromFlag(list,from) else N.geoSortSpawn(list) end end
function N.strategicNeutralCount() local f=N.flags() local n=0 for _,x in ipairs(f.neutral) do if not C.HostileNeutral[x] then n=n+1 end end return n end
function N.isStrategicEnemy(name) return N.flagOccupant(name)==BotApi.Instance.enemyTeam or (C.HostileNeutral[name] and N.isNeutral(name)) end
function N.frontOwnList()
 local f=N.flags() local enemy={} for _,n in ipairs(f.enemy) do enemy[#enemy+1]=n end for n,v in pairs(C.HostileNeutral) do if v and N.isNeutral(n) then enemy[#enemy+1]=n end end
 if N.MAP and N.MAP.loaded then return N.MAP:frontOwnFlags(f.mine,enemy) end N.numericSort(f.mine) return f.mine
end
function N.chooseFrontOwnFlag(used) local list=N.frontOwnList() for _,n in ipairs(list) do if not(used and used[n]) then return n end end return list[1] end
function N.chooseOwnFlagBefore(target)
 local f=N.flags() if #f.mine==0 then return nil end
 if N.MAP and N.MAP.loaded and target and N.MAP:point(target) then local best,bd=nil,nil for _,name in ipairs(f.mine) do local d=N.MAP:distanceNames(name,target) if d and (not bd or d<bd) then best,bd=name,d end end if best then return best end end
 return N.chooseFrontOwnFlag(nil)
end
function N.chooseSafeOwnFlag(target)
 local f=N.flags() if #f.mine==0 then return nil end local front={} for _,n in ipairs(N.frontOwnList()) do front[n]=true end local pool={} for _,n in ipairs(f.mine) do if not front[n] then pool[#pool+1]=n end end if #pool==0 then pool=f.mine end
 if N.MAP and N.MAP.loaded and target then local best=N.MAP:nearestToFlag(pool,target,nil) if best then return best end end N.numericSort(pool) return pool[1]
end
function N.randomApproach(target,last,avoid)
 local f=N.flags() if #f.mine==0 then return nil end local pool={}
 for _,n in ipairs(f.mine) do if n~=last and n~=avoid then pool[#pool+1]=n end end
 if #pool==0 then for _,n in ipairs(f.mine) do if n~=avoid then pool[#pool+1]=n end end end if #pool==0 then return f.mine[1] end
 if N.MAP and N.MAP.loaded and target then N.MAP:sortFromFlag(pool,target) else N.numericSort(pool) end local limit=math.min(#pool,NEU_BOT.RouteChoiceCount or 3) return pool[math.random(1,math.max(1,limit))]
end
function N.squadAlive(id) return id and BotApi.Scene:IsSquadExists(id) end
function N.aliveCount(list) local n=0 for _,sid in ipairs(list or {}) do if N.squadAlive(sid) then n=n+1 end end return n end
function N.groupInfCount(g) return N.aliveCount(g and g.infantry)+N.aliveCount(g and g.detached) end
function N.capture(id,flag,force)
 if not(id and flag and N.flagObj(flag) and N.squadAlive(id)) then return end local role=C.SquadRole[id] local occ=N.flagOccupant(flag) local neutral=(occ~=BotApi.Instance.team and occ~=BotApi.Instance.enemyTeam)
 local last=C.LastOrder[id] if not force and last and last.flag==flag and C.Time-(last.time or 0)<(NEU_BOT.OrderCooldownSec or 10) then return end C.LastOrder[id]={flag=flag,time=C.Time} N.log('ORDER squad='..id..' group='..tostring(C.SquadGroup[id])..' flag='..flag..' role='..tostring(role)) BotApi.Commands:CaptureFlag(id,flag)
end
function N.enqueueSpawn(role,reason,delay,target,gid,mode)
 if N.allowSupportQueue and not N.allowSupportQueue(role,mode) then return false end
 C.SpawnIntents[#C.SpawnIntents+1]={role=role,reason=reason or '',due=C.Time+(delay or 0),target=target,groupId=gid,mode=mode,attempts=0,cycles=0,tried={}} if role=='pointstart' and target then C.PointStartPending[target]=true end N.log('QUEUE role='..role..' group='..tostring(gid)..' target='..tostring(target)..' reason='..tostring(reason)) return true end
function N.pendingForGroup(role,gid) for _,x in ipairs(C.SpawnIntents) do if x.role==role and x.groupId==gid then return true end end return C.AwaitingArrival and C.AwaitingArrival.role==role and C.AwaitingArrival.groupId==gid end
function N.processSpawn()
 if C.Time<(NEU_BOT.InitialSpawnDelaySec or 3) then return end
 if C.Spawning or C.AwaitingArrival then return end local idx=nil for i,x in ipairs(C.SpawnIntents) do if x.due<=C.Time then idx=i break end end if not idx then return end local intent=table.remove(C.SpawnIntents,idx)
 if intent.role=='pointstart' and intent.target and not N.isNeutral(intent.target) then C.PointStartPending[intent.target]=nil return N.processSpawn() end
 if N.validateSupportSpawn and not N.validateSupportSpawn(intent) then return end
 local list=C.Candidates[intent.role] or {} local a={} for _,r in ipairs(list) do if not intent.tried[r.unit] then a[#a+1]=r end end if #a==0 then N.log('NO UNIT role='..intent.role) return end local rec=a[math.random(1,#a)] intent.tried[rec.unit]=true intent.attempts=intent.attempts+1
 local ticket={role=intent.role,target=intent.target,groupId=intent.groupId,mode=intent.mode,unit=rec.unit} C.SpawnTickets[#C.SpawnTickets+1]=ticket C.AwaitingArrival=ticket C.Spawning=true N.log('SPAWN BEGIN time='..tostring(C.Time)..' role='..intent.role..' unit='..rec.unit) local ok=BotApi.Commands:Spawn(rec.unit,(intent.role=='pointstart') and (NEU_BOT.PointStartSquadSize or MaxSquadSize) or MaxSquadSize) C.Spawning=false
 if ok or C.AwaitingArrival~=ticket then N.log('SPAWN OK role='..intent.role..' unit='..rec.unit) else C.AwaitingArrival=nil table.remove(C.SpawnTickets,#C.SpawnTickets) local retryMax=((N.isAirRole and N.isAirRole(intent.role)) or intent.role=='artsupport') and (NEU_BOT.SupportSpawnRetryCycles or 8) or (NEU_BOT.CriticalSpawnRetryCycles or 3) if intent.attempts<#list then intent.due=C.Time+(NEU_BOT.SpawnRetrySec or 2) C.SpawnIntents[#C.SpawnIntents+1]=intent elseif (intent.cycles or 0)<retryMax then intent.cycles=(intent.cycles or 0)+1 intent.attempts=0 intent.tried={} intent.due=C.Time+(((N.isAirRole and N.isAirRole(intent.role)) or intent.role=='artsupport') and (NEU_BOT.SupportSpawnRetrySec or 15) or (NEU_BOT.CriticalSpawnRetrySec or 10)) C.SpawnIntents[#C.SpawnIntents+1]=intent else N.log('SPAWN FAILED role='..intent.role..' group='..tostring(intent.groupId)) end end
end
return N

