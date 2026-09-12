-- NEU BOT v1.5.3 targeted two-direction assault patch
-- Loaded AFTER the working v1.5.2 bot.lua.
-- Does not intercept BotApi methods and does not replace the v1.5.2 spawn logic.
-- Purpose: keep the two opening BMP+infantry squads attacking in two different directions
-- once all neutral flags are gone and the attack gate is open.

local P={
    time=0,
    timer=nil,
    generation=0,
    spawnIndex=0,
    assault={nil,nil},
    target={nil,nil},
    stopped={false,false},
    active=false,
    nextOrderAt=0
}

local function log(m) print("[NEU-153] "..tostring(m)) end

local function squadAlive(id)
    return id and BotApi.Scene:IsSquadExists(id)
end

local function flagNumber(name)
    return type(name)=="string" and tonumber(name:match("(%d+)$")) or nil
end

local function edge()
    local t=string.lower(tostring(BotApi.Instance.team or ""))
    if t=="b" or t=="team b" or t:find("team b",1,true) then return "HIGH" end
    return "LOW"
end

local function sceneFlags()
    local my=BotApi.Instance.team
    local enemy=BotApi.Instance.enemyTeam
    local f={mine={},enemy={},neutral={},mineCount=0,enemyCount=0,neutralCount=0}
    for _,flag in pairs(BotApi.Scene.Flags) do
        if flag.occupant==my then
            f.mine[#f.mine+1]=flag.name
            f.mineCount=f.mineCount+1
        elseif flag.occupant==enemy then
            f.enemy[#f.enemy+1]=flag.name
            f.enemyCount=f.enemyCount+1
        else
            f.neutral[#f.neutral+1]=flag.name
            f.neutralCount=f.neutralCount+1
        end
    end
    local e=edge()
    table.sort(f.enemy,function(a,b)
        local na,nb=flagNumber(a),flagNumber(b)
        if na and nb then return e=="HIGH" and na>nb or e~="HIGH" and na<nb end
        return e=="HIGH" and tostring(a)>tostring(b) or tostring(a)<tostring(b)
    end)
    return f
end

local function flagOccupant(name)
    if not name then return nil end
    for _,flag in pairs(BotApi.Scene.Flags) do
        if flag.name==name then return flag.occupant end
    end
    return nil
end

local function chooseTargets()
    local f=sceneFlags()
    local used={}
    for i=1,2 do
        if not P.stopped[i] then
            local current=P.target[i]
            if current and flagOccupant(current)==BotApi.Instance.enemyTeam and not used[current] then
                used[current]=true
            else
                P.target[i]=nil
                for _,name in ipairs(f.enemy) do
                    if not used[name] then
                        P.target[i]=name
                        used[name]=true
                        break
                    end
                end
            end
        end
    end
end

local function issueOrders()
    chooseTargets()
    for i=1,2 do
        local sid=P.assault[i]
        if not P.stopped[i] and sid then
            if not squadAlive(sid) then
                P.stopped[i]=true
                log("DIRECTION STOP slot="..i.." squad="..tostring(sid).." reason=squad_lost")
            elseif P.target[i] then
                log("ASSAULT slot="..i.." squad="..tostring(sid).." flag="..tostring(P.target[i]))
                BotApi.Commands:CaptureFlag(sid,P.target[i])
            end
        end
    end
end

local function tick()
    P.time=P.time+1
    local f=sceneFlags()

    if not P.active then
        local gate=(P.time>=300) or (f.enemyCount>f.mineCount)
        if gate and f.neutralCount==0 and P.assault[1] and P.assault[2] then
            P.active=true
            P.nextOrderAt=0
            log("TWO-DIRECTION ATTACK ENABLED time="..P.time.." squads="..tostring(P.assault[1])..","..tostring(P.assault[2]))
        end
    end

    if P.active then
        if f.neutralCount>0 then
            P.active=false
            log("ATTACK PAUSED neutralLeft="..f.neutralCount)
        elseif P.time>=P.nextOrderAt then
            P.nextOrderAt=P.time+5
            issueOrders()
        end
    end
end

local function stopClock()
    P.generation=P.generation+1
    if P.timer then BotApi.Events:KillQuantTimer(P.timer) P.timer=nil end
end

local function startClock()
    stopClock()
    local gen=P.generation
    local function pulse()
        if gen~=P.generation then return end
        P.timer=nil
        tick()
        if gen==P.generation then P.timer=BotApi.Events:SetQuantTimer(pulse,1000) end
    end
    P.timer=BotApi.Events:SetQuantTimer(pulse,1000)
end

local function onStart()
    P.time=0
    P.spawnIndex=0
    P.assault={nil,nil}
    P.target={nil,nil}
    P.stopped={false,false}
    P.active=false
    P.nextOrderAt=0
    log("START v1.5.3 patch two-direction=ON")
    startClock()
end

local function onStop()
    stopClock()
end

local function onSpawn(args)
    -- v1.5.2 spawn order at battle start is stable:
    -- 1 recon, 2 AA, 3 assault infantry group 1, 4 assault infantry group 2.
    -- Neutral-capture squads start afterwards from the 1-second controller.
    P.spawnIndex=P.spawnIndex+1
    if P.spawnIndex==3 then
        P.assault[1]=args.squadId
        log("TRACK assault1 squad="..tostring(args.squadId))
    elseif P.spawnIndex==4 then
        P.assault[2]=args.squadId
        log("TRACK assault2 squad="..tostring(args.squadId))
    end
end

BotApi.Events:Subscribe(BotApi.Events.GameStart,onStart)
BotApi.Events:Subscribe(BotApi.Events.GameEnd,onStop)
BotApi.Events:Subscribe(BotApi.Events.GameSpawn,onSpawn)
