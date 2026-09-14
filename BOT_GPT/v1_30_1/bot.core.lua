-- NEU BOT v1.30.1 core
NEU1301=NEU1301 or {}
local N=NEU1301
N.C={Time=0,Units={},Candidates={},SpawnIntents={},SpawnTickets={},AwaitingArrival=nil,Spawning=false,SquadRole={},SquadGroup={},Dead={},LastOrder={},Groups={},PointTargets={},PointDone={},AirSupport={},ArtSupport={},PreviousOwn={},LostOwn={},Timer=nil,TimerGeneration=0,EnemyHasTanks=nil,NextAirAt=0,NextAAAt=0,NextPatrolAt=0,TelemetryReady=false}
local C=N.C
function N.log(m) print('[NEU-BOT] '..tostring(m)) end
local function lower(s) return string.lower(tostring(s or '')) end
local function tags(s) local t={} for x in string.gmatch(s or '','%S+') do t[lower(x)]=true end return t end
local function has(r,t) return r and r.tagset and r.tagset[lower(t)]==true end
local function text(r) return lower((r and r.unit or '')..' '..(r and r.raw or '')) end
local function roleMatch(r,role)
 local x=text(r)
 if role=='pointstart' then return has(r,'pointstart') end
 if role=='patrol_heli' then return has(r,'duel_heli') or has(r,'duel_heli2') end
 if role=='aircraftlight' then return has(r,'aircraftlight') or x:find('support_light',1,true)~=nil end
 if role=='strike' then return has(r,'strike') or x:find('_strike',1,true)~=nil end
 if role=='antirad' then return has(r,'antirad') or x:find('antirad',1,true)~=nil end
 if role=='artsupport' then return has(r,'artsupport') end
 if r and r.nobot then return false end
 if role=='recon' then return has(r,'all') and has(r,'recon') end
 if role=='infantry' then return has(r,'all') and has(r,'infantry') end
 if role=='antiair' then return has(r,'all') and has(r,'antiair') end
 if role=='aat' then return has(r,'aat') end
 if role=='tank' then return has(r,'duel_tanks70') or has(r,'duel_tanks80') or has(r,'duel_tanks90') end
 return false
end
local function detectSide(s) return s:match('%f[%w]side%s*%(%s*([^%)%s]+)%s*%)') or s:match('%f[%w]s%s*%(%s*([^%)%s]+)%s*%)') end
local function records(raw)
 local out,buf,stack={},{},{} local quote,esc,comment=false,false,false
 for i=1,#raw do local ch=raw:sub(i,i)
  if comment then if ch=='\n' then comment=false end
  elseif quote then buf[#buf+1]=ch if esc then esc=false elseif ch=='\\' then esc=true elseif ch=='"' then quote=false end
  elseif ch==';' then comment=true
  elseif ch=='"' then if #stack>0 then buf[#buf+1]=ch quote=true end
  elseif ch=='(' or ch=='{' then stack[#stack+1]=ch buf[#buf+1]=ch
  elseif ch==')' or ch=='}' then if #stack>0 then buf[#buf+1]=ch stack[#stack]=nil if #stack==0 then out[#out+1]=table.concat(buf) buf={} end end
  elseif #stack>0 then buf[#buf+1]=ch end
 end return out
end
local function readUnitsFile(path,army)
 local f=io.open(path,'r') if not f then return 0 end local raw=f:read('*a') f:close() local n=0
 for _,line in ipairs(records(raw)) do local side=detectSide(line)
  if side and lower(side)==lower(army) then local tt={} for s in line:gmatch('%f[%w]t%s*%(([^)]*)%)') do tt[#tt+1]=s end local tg=table.concat(tt,' ')
   local vehicle=line:match('^%s*{%s*"([^"]+)"') local name=vehicle or line:match('%f[%w]name%s*%(([^)]+)%)')
   if name and not name:find('mp/',1,true) then local id=vehicle or (name..'('..army..')') if not C.UnitSeen[id] then C.UnitSeen[id]=true C.Units[#C.Units+1]={unit=id,tagset=tags(tg),raw=line,nobot=line:find('nobot',1,true)~=nil} n=n+1 end end
  end
 end return n
end
function N.loadUnits()
 C.Units={} C.UnitSeen={} local base='mods\\'..NEU_BOT.ModFolder..'\\resource\\set\\multiplayer\\units\\' local fs={'units_nato.set','units_ch.set','units_rus.set','units_usa.set','units_nov.set','units_ukr.set','units_wagner.set'}
 for _,f in ipairs(fs) do readUnitsFile(base..f,BotApi.Instance.army) end N.log('UNITS loaded='..#C.Units..' army='..tostring(BotApi.Instance.army))
end
function N.buildCandidates()
 local roles={'pointstart','patrol_heli','recon','infantry','antiair','tank','aircraftlight','artsupport','aat','antirad','strike'} C.Candidates={}
 for _,r in ipairs(roles) do C.Candidates[r]={} end
 for _,u in ipairs(C.Units) do for _,r in ipairs(roles) do if roleMatch(u,r) then C.Candidates[r][#C.Candidates[r]+1]=u end end end
 for _,r in ipairs(roles) do N.log('ROLE '..r..' candidates='..#C.Candidates[r]) end
end
function N.flags()
 local o={mine={},enemy={},neutral={},mineCount=0,enemyCount=0,neutralCount=0} local my,en=BotApi.Instance.team,BotApi.Instance.enemyTeam
 for _,f in pairs(BotApi.Scene.Flags) do if f.occupant==my then o.mine[#o.mine+1]=f.name o.mineCount=o.mineCount+1 elseif f.occupant==en then o.enemy[#o.enemy+1]=f.name o.enemyCount=o.enemyCount+1 else o.neutral[#o.neutral+1]=f.name o.neutralCount=o.neutralCount+1 end end return o
end
local function fn(n) return tonumber(tostring(n):match('(%d+)$')) or 9999 end
function N.sortFlags(a,reverse) table.sort(a,function(x,y) if fn(x)==fn(y) then return tostring(x)<tostring(y) end if reverse then return fn(x)>fn(y) else return fn(x)<fn(y) end end) end
function N.flag(name) for _,f in pairs(BotApi.Scene.Flags) do if f.name==name then return f end end end
function N.owner(name) local f=N.flag(name) return f and f.occupant or nil end
function N.alive(id) return id~=nil and BotApi.Scene:IsSquadExists(id) end
function N.count(list) local n=0 for _,id in ipairs(list or {}) do if N.alive(id) then n=n+1 end end return n end
function N.groupInf(g) return N.count(g and g.infantry) end
function N.capture(id,flag,force)
 if not(N.alive(id) and N.flag(flag)) then return false end local last=C.LastOrder[id]
 if not force and last and last.flag==flag and C.Time-(last.time or 0)<(NEU_BOT.OrderCooldownSec or 15) then return false end
 C.LastOrder[id]={flag=flag,time=C.Time} BotApi.Commands:CaptureFlag(id,flag) N.log('ORDER squad='..tostring(id)..' role='..tostring(C.SquadRole[id])..' group='..tostring(C.SquadGroup[id])..' flag='..tostring(flag)) return true
end
function N.pending(role,gid)
 for _,x in ipairs(C.SpawnIntents) do if x.role==role and x.groupId==gid then return true end end
 return C.AwaitingArrival and C.AwaitingArrival.role==role and C.AwaitingArrival.groupId==gid
end
function N.queue(role,reason,delay,target,gid,priority)
 C.SpawnIntents[#C.SpawnIntents+1]={role=role,reason=reason or '',due=C.Time+(delay or 0),target=target,groupId=gid,priority=priority or 50,attempts=0,cycles=0,tried={}} N.log('QUEUE role='..role..' group='..tostring(gid)..' target='..tostring(target)..' p='..tostring(priority or 50))
end
local function chooseIntent()
 local bi=nil
 for i,x in ipairs(C.SpawnIntents) do if x.due<=C.Time then if not bi or x.priority>C.SpawnIntents[bi].priority or (x.priority==C.SpawnIntents[bi].priority and x.due<C.SpawnIntents[bi].due) then bi=i end end end return bi
end
function N.processSpawn()
 if C.Spawning or C.AwaitingArrival then return end local idx=chooseIntent() if not idx then return end local x=table.remove(C.SpawnIntents,idx) local list=C.Candidates[x.role] or {}
 local avail={} for _,r in ipairs(list) do if not x.tried[r.unit] then avail[#avail+1]=r end end
 if #avail==0 then if x.cycles<(NEU_BOT.SpawnRetryCycles or 3) then x.cycles=x.cycles+1 x.tried={} x.attempts=0 x.due=C.Time+(NEU_BOT.SpawnRetrySec or 3) C.SpawnIntents[#C.SpawnIntents+1]=x else N.log('SPAWN FAILED role='..x.role..' group='..tostring(x.groupId)..' no candidates') end return end
 local r=avail[math.random(1,#avail)] x.tried[r.unit]=true x.attempts=x.attempts+1 local ticket={role=x.role,target=x.target,groupId=x.groupId,unit=r.unit} C.SpawnTickets[#C.SpawnTickets+1]=ticket C.AwaitingArrival=ticket C.Spawning=true local ok=BotApi.Commands:Spawn(r.unit,MaxSquadSize) C.Spawning=false
 if ok or C.AwaitingArrival~=ticket then N.log('SPAWN OK role='..x.role..' unit='..r.unit) else C.AwaitingArrival=nil table.remove(C.SpawnTickets,#C.SpawnTickets) if x.attempts<#list then x.due=C.Time+(NEU_BOT.SpawnRetrySec or 3) C.SpawnIntents[#C.SpawnIntents+1]=x elseif x.cycles<(NEU_BOT.SpawnRetryCycles or 3) then x.cycles=x.cycles+1 x.attempts=0 x.tried={} x.due=C.Time+(NEU_BOT.SpawnRetrySec or 3) C.SpawnIntents[#C.SpawnIntents+1]=x else N.log('SPAWN FAILED role='..x.role..' group='..tostring(x.groupId)) end end
end
return N
