-- NEU BOT v1.20 patch
-- Adds live JSONL telemetry while preserving the v1.19 bot behavior.

local N = require([[/script/multiplayer/bot.v1_18.core]])
local T = require([[/script/multiplayer/bot.telemetry]])
T.install(N)

-- Load the current v1.19 behavior (air cooldown + v1.18 BTG logic).
require([[/script/multiplayer/bot.v1_19.patch]])

-- Snapshot once per game second. Quant can fire faster, telemetry module de-duplicates by C.Time.
BotApi.Events:Subscribe(BotApi.Events.Quant, T.onQuant)

N.log('PATCH v1.20 LIVE VISUALIZER TELEMETRY ENABLED')
return N
