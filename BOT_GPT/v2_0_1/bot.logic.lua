-- NEU BOT 2.0.1 lifecycle fix
-- v2.0 defined callbacks but forgot to subscribe them to BotApi.Events.
-- Keep the canonical v2.0 behaviour in bot.logic.base.lua and restore only
-- the engine event wiring that existed in working historical versions.

local N = require([[/script/multiplayer/bot.logic.base]])

BotApi.Events:Subscribe(BotApi.Events.GameStart, onGameStart)
BotApi.Events:Subscribe(BotApi.Events.GameEnd, onGameStop)
BotApi.Events:Subscribe(BotApi.Events.Quant, onGameQuant)
BotApi.Events:Subscribe(BotApi.Events.GameSpawn, onGameSpawn)

N.log("BOT 2.0.1 EVENT SUBSCRIPTIONS ACTIVE: GameStart/GameEnd/Quant/GameSpawn")
return N
