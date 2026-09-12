-- NEU BOT v1.6.1 safe coordinate probe
local function dlog(m) print("[NEU-DIAG] "..tostring(m)) end
local function safe(fn) local ok,v=pcall(fn); if ok then return v end return nil end
local function vec(label,obj)
    if not obj then return false end
    local found=false
    local names={"position","pos","point","coords","center"}
    for _,k in ipairs(names) do
        local v=safe(function() return obj[k] end)
        if v~=nil then
            local x=safe(function() return v.x end)
            local y=safe(function() return v.y end)
            local z=safe(function() return v.z end)
            dlog(label.."."..k.."="..tostring(v).." x="..tostring(x).." y="..tostring(y).." z="..tostring(z))
            if x~=nil or y~=nil or z~=nil then found=true end
        end
    end
    local x=safe(function() return obj.x end)
    local y=safe(function() return obj.y end)
    local z=safe(function() return obj.z end)
    if x~=nil or y~=nil or z~=nil then
        dlog(label.." direct x="..tostring(x).." y="..tostring(y).." z="..tostring(z))
        found=true
    end
    return found
end
local function probeFlags(reason)
    dlog("FLAG PROBE v1.6.1 reason="..tostring(reason))
    local n=0
    local ok,err=pcall(function()
        for i,f in pairs(BotApi.Scene.Flags) do
            n=n+1
            local name=safe(function() return f.name end)
            local occ=safe(function() return f.occupant end)
            dlog("FLAG["..tostring(i).."] name="..tostring(name).." occupant="..tostring(occ).." type="..type(f))
            local got=vec("FLAG["..tostring(i).."]",f)
            for _,k in ipairs({"entity","object","sceneObject","handle"}) do
                local o=safe(function() return f[k] end)
                if o then vec("FLAG["..tostring(i).."]."..k,o) end
            end
            dlog("FLAG["..tostring(i).."] geometry="..tostring(got))
        end
    end)
    if not ok then dlog("FLAG PROBE ERROR="..tostring(err)) end
    dlog("FLAG COUNT="..tostring(n))
end
local function onStart()
    dlog("START v1.6.1 SAFE diagnostic")
    probeFlags("GameStart")
    BotApi.Events:SetQuantTimer(function() probeFlags("GameStart+3s") end,3000)
end
local function onSpawn(args)
    dlog("SPAWN squadId="..tostring(safe(function() return args.squadId end)))
    vec("spawn.args",args)
    for _,k in ipairs({"entity","object","squad"}) do
        local o=safe(function() return args[k] end)
        if o then vec("spawn."..k,o) end
    end
end
BotApi.Events:Subscribe(BotApi.Events.GameStart,onStart)
BotApi.Events:Subscribe(BotApi.Events.GameSpawn,onSpawn)
