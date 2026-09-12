# NEU BOT v1.6.1 SAFE

Аварийное исправление v1.6.

Причина поломки v1.6: `bot.guard.lua` пытался прочитать `BotApi.Commands.CaptureFlag` как поле и подменить метод. В движке BotApi.Commands — userdata/обёртка, у которой метод можно вызывать через `BotApi.Commands:CaptureFlag(...)`, но нельзя получить как `BotApi.Commands.CaptureFlag`. Из-за этого загрузка останавливалась до `bot.lua` и бот ничего не вызывал.

v1.6.1 возвращает полностью рабочее ядро v1.5 без guard-перехвата и оставляет только безопасную диагностику координат.

Установка в `script/multiplayer/`:
- `bot.lua` — из этой версии (точная копия v1.5)
- `bot.data.lua` — из этой версии (точная копия v1.5)
- `bot.probe.lua`
- `bot.main.lua`

`bot.guard.lua` НЕ устанавливать.

Ожидаемые строки в game.log:
- `[NEU-BOT] START v1.5 ...`
- `[NEU-BOT] SPAWN OK ...`
- `[NEU-DIAG] START v1.6.1 SAFE diagnostic`

После подтверждения работы правила neutral-first/stop-direction будут встраиваться внутрь ядра v1.5, а не через monkey-patch BotApi.