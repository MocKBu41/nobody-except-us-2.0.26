-- NEU BOT v1.6 RULE GUARD
-- Loaded before v1.5 core. Adds latest scheme rules without rewriting working core.

local V16={orders={},blockedTargets={},timer=nil,generation=0,lastNeutralCount=nil}
local function vlog(m) print("[NEU-V16] "..tostring(m)) end

local function getFlag(name)
    local ok,flags=pcall(function() return BotApi.Scene.Flags end)
    if not ok or not flags then return nil end
    for _,f in pairs(flags) do
        local okn,n=pcall(function() return f.name end)
        if okn and n==name then return f end
    end
    return nil
end

local function counts()
    local mine,enemy,neutral=0,0,0
    local my=BotApi.Instance.team
    local en=BotApi.Instance.enemyTeam
    local ok,flags=pcall(function() return BotApi.Scene.Flags end)
    if not ok or not flags then return mine,enemy,neutral end
    for _,f in pairs(flags) do
        local occ=nil
        pcall(function() occ=f.occupant end)
        if occ==my then mine=mine+1 elseif occ==en then enemy=enemy+1 else neutral=neutral+1 end
    end
    return mine,enemy,neutral
end

local OriginalCapture=BotApi.Commands.CaptureFlag
function BotApi.Commands:CaptureFlag(squadId,flagName)
    local f=getFlag(flagName)
    local occ=nil
    if f then pcall(function() occ=f.occupant end) end
    local en=BotApi.Instance.enemyTeam
    local _,_,neutral=counts()

    if occ==en and neutral>0 then
        vlog("BLOCK ENEMY ORDER squad="..tostring(squadId).." flag="..tostring(flagName).." neutralLeft="..tostring(neutral))
        return true
    end

    if V16.blockedTargets[flagName] then
        vlog("BLOCK LOST DIRECTION squad="..tostring(squadId).." flag="..tostring(flagName))
        return true
    end

    V16.orders[squadId]={flag=flagName,wasEnemy=(occ==en),time=os.time()}
    return OriginalCapture(self,squadId,flagName)
end

local function alive(sid)
    local ok,v=pcall(function() return BotApi.Scene:IsSquadExists(sid) end)
    return ok and v
end

local function tick()
    local _,_,neutral=counts()
    if V16.lastNeutralCount~=neutral then
        V16.lastNeutralCount=neutral
        vlog("NEUTRAL LEFT="..tostring(neutral))
        if neutral==0 then vlog("ENEMY ATTACKS UNLOCKED: all neutral flags captured") end
    end
    for sid,o in pairs(V16.orders) do
        if o and o.wasEnemy and not alive(sid) and not V16.blockedTargets[o.flag] then
            V16.blockedTargets[o.flag]=true
            vlog("DIRECTION STOP flag="..tostring(o.flag).." lostSquad="..tostring(sid))
        end
    end
end

local function stopTimer()
    V16.generation=V16.generation+1
    if V16.timer then pcall(function() BotApi.Events:KillQuantTimer(V16.timer) end) V16.timer=nil end
end

local function onStart()
    V16.orders={}
    V16.blockedTargets={}
    V16.lastNeutralCount=nil
    vlog("START v1.6 rules: neutral-first + stop-direction-on-loss + integrated probe")
    vlog("TANK STANDOFF 100m pending geometry/move API; no invented Move command")
    stopTimer()
    local gen=V16.generation
    local function pulse()
        if gen~=V16.generation then return end
        tick()
        if gen==V16.generation then V16.timer=BotApi.Events:SetQuantTimer(pulse,1000) end
    end
    V16.timer=BotApi.Events:SetQuantTimer(pulse,1000)
end

BotApi.Events:Subscribe(BotApi.Events.GameStart,onStart)
BotApi.Events:Subscribe(BotApi.Events.GameEnd,stopTimer)
