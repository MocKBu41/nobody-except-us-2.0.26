-- NEU BOT v1.20 telemetry exporter
-- Writes JSONL snapshots/events for the standalone HTML visualizer.

local T={}
local N=nil
local C=nil
local installed=false
local lastSnapshot=-1
local fileReady=false
local activePath=nil

local function esc(v)
    local s=tostring(v or "")
    s=s:gsub("\\","\\\\"):gsub('"','\\"'):gsub("\r","\\r"):gsub("\n","\\n"):gsub("\t","\\t")
    return s
end
local function q(v) return '"'..esc(v)..'"' end
local function bool(v) return v and "true" or "false" end
local function num(v) return type(v)=="number" and tostring(v) or "null" end

local function candidatePaths()
    local out={}
    if NEU_BOT and NEU_BOT.TelemetryPath then out[#out+1]=NEU_BOT.TelemetryPath end
    local mod=(NEU_BOT and NEU_BOT.ModFolder) or "nobody except us 2.0.26"
    out[#out+1]="mods\\"..mod.."\\resource\\script\\multiplayer\\bot_gpt_telemetry.jsonl"
    out[#out+1]="resource\\script\\multiplayer\\bot_gpt_telemetry.jsonl"
    out[#out+1]="bot_gpt_telemetry.jsonl"
    return out
end

local function openTelemetry(mode)
    if activePath then
        local f=io.open(activePath,mode)
        if f then return f,activePath end
    end
    for _,p in ipairs(candidatePaths()) do
        local f=io.open(p,mode)
        if f then activePath=p return f,p end
    end
    return nil,nil
end

local function append(line)
    local f=openTelemetry("a")
    if not f then return false end
    f:write(line,"\n")
    f:flush()
    f:close()
    return true
end
local function point(name)
    if not name or not N or not N.MAP or not N.MAP.loaded then return nil end
    local p=N.MAP:point(name)
    if not p then return nil end
    return {name=name,x=p.x,y=p.y}
end
local function pointJson(name)
    local p=point(name)
    if not p then return "null" end
    return '{"name":'..q(p.name)..',"x":'..num(p.x)..',"y":'..num(p.y)..'}'
end
local function ownerName(o)
    if o==BotApi.Instance.team then return "bot" end
    if o==BotApi.Instance.enemyTeam then return "enemy" end
    return "neutral"
end
local function aliveListJson(list)
    local out={}
    for _,sid in ipairs(list or {}) do
        if N.squadAlive(sid) then out[#out+1]=tostring(sid) end
    end
    return '['..table.concat(out,',')..']'
end
local function eventKind(msg)
    local s=tostring(msg or "")
    if s:find("ORDER",1,true) then return "order" end
    if s:find("SPAWN",1,true) or s:find("QUEUE",1,true) or s:find("ARRIVED",1,true) then return "spawn" end
    if s:find("CAPTURED",1,true) then return "capture" end
    if s:find("LOST",1,true) then return "loss" end
    if s:find("ASSAULT",1,true) or s:find("APPROACH",1,true) or s:find("ROUTE",1,true) then return "decision" end
    if s:find("AIR ",1,true) or s:find("art",1,true) or s:find("support",1,true) then return "support" end
    if s:find("FAILED",1,true) or s:find("BLOCK",1,true) then return "warning" end
    return "info"
end

function T.event(msg)
    if not fileReady then return end
    append('{"type":"event","time":'..num(C and C.Time or 0)..',"kind":'..q(eventKind(msg))..',"message":'..q(msg)..'}')
end

function T.snapshot()
    if not N or not C or not fileReady then return end
    local flags={}
    for _,f in pairs(BotApi.Scene.Flags or {}) do
        local p=point(f.name)
        flags[#flags+1]='{"name":'..q(f.name)..',"owner":'..q(ownerName(f.occupant))..',"x":'..num(p and p.x)..',"y":'..num(p and p.y)..'}'
    end
    table.sort(flags)

    local groups={}
    for id,g in pairs(C.Groups or {}) do
        local dest=nil
        if g.phase=="assembling" then dest=g.rally or g.approach or g.target
        elseif g.phase=="approach" then dest=g.approach or g.target
        elseif g.phase=="attack" then dest=g.target
        else dest=g.rally or g.approach or g.target end
        groups[#groups+1]='{"id":'..num(id)..
            ',"phase":'..q(g.phase or "unknown")..
            ',"target":'..q(g.target or "")..
            ',"rally":'..pointJson(g.rally)..
            ',"approach":'..pointJson(g.approach)..
            ',"tankApproach":'..pointJson(g.tankApproach)..
            ',"destination":'..pointJson(dest)..
            ',"wave":'..num(g.wave or 0)..
            ',"failCount":'..num(g.failCount or 0)..
            ',"infantryCount":'..num(N.groupInfCount(g))..
            ',"tankCount":'..num(N.aliveCount(g.tanks))..
            ',"infantry":'..aliveListJson(g.infantry)..
            ',"detached":'..aliveListJson(g.detached)..
            ',"tanks":'..aliveListJson(g.tanks)..'}'
    end
    table.sort(groups)

    local f=N.flags()
    local spawn="null"
    if N.MAP and N.MAP.spawn then spawn='{"x":'..num(N.MAP.spawn.x)..',"y":'..num(N.MAP.spawn.y)..'}' end
    local mapKey=(N.MAP and N.MAP.mapKey) or "unknown"
    local nextAir=C.NextAircraftAllowedAt or 0
    local json='{"type":"snapshot","time":'..num(C.Time or 0)..
        ',"map":'..q(mapKey)..
        ',"team":'..q(BotApi.Instance.team)..
        ',"enemyTeam":'..q(BotApi.Instance.enemyTeam)..
        ',"attackUnlocked":'..bool(C.AttackUnlocked)..
        ',"neutralsCleared":'..bool(C.NeutralsCleared)..
        ',"flagsMine":'..num(f.mineCount)..
        ',"flagsEnemy":'..num(f.enemyCount)..
        ',"flagsNeutral":'..num(f.neutralCount)..
        ',"airCooldownRemaining":'..num(math.max(0,nextAir-(C.Time or 0)))..
        ',"spawn":'..spawn..
        ',"flags":['..table.concat(flags,',')..']'..
        ',"groups":['..table.concat(groups,',')..']}'
    append(json)
end

function T.onQuant()
    if not C then return end
    local t=C.Time or 0
    if t~=lastSnapshot then
        lastSnapshot=t
        T.snapshot()
    end
end

function T.install(core)
    if installed then return T end
    installed=true
    N=core
    C=N.C
    NEU_BOT=NEU_BOT or {}
    if NEU_BOT.TelemetryEnabled==nil then NEU_BOT.TelemetryEnabled=true end
    if not NEU_BOT.TelemetryEnabled then return T end

    local f,p=openTelemetry("w")
    if f then
        f:write('{"type":"session","version":"1.20","time":0,"path":'..q(p)..'}\n')
        f:flush()
        f:close()
        fileReady=true
    end

    local baseLog=N.log
    function N.log(m)
        baseLog(m)
        if fileReady then T.event(m) end
    end
    if fileReady then
        baseLog('TELEMETRY v1.20 ACTIVE path='..tostring(activePath))
    else
        baseLog('TELEMETRY DISABLED: cannot create bot_gpt_telemetry.jsonl in multiplayer/game paths')
    end
    return T
end

return T
