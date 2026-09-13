# NEU BOT v1.21.4 diagnostic

Диагностическая версия на базе v1.21.3. Рабочая логика бота не меняется; добавлено только безопасное исследование BotApi для поиска реальных координат своих и чужих отрядов.

## Что делает диагностика

Файл `bot.positiondiag.lua` запускается вместе с ботом и в моменты примерно 3, 15 и 60 секунд боя исследует доступные объекты BotApi в режиме только чтения.

Проверяются:

- `BotApi.Scene`
- `BotApi.Commands`
- `Scene.Squads`
- `Scene.OwnSquads`
- `Scene.EnemySquads`
- `Scene.EnemyUnits`
- `Scene.Units`
- `Scene.Entities`
- `Scene.Actors`
- `Scene.Vehicles`
- `Scene.Humans`
- `Scene.Objects`
- `Scene.Soldiers`
- `Scene.Players`
- `Scene.Teams`
- `Scene.Flags`

Для userdata/table записываются доступные metatable/`__index` ключи и безопасно читаются вероятные поля координат: `x/y/z`, `pos`, `position`, `center`, `location`, `coords`, а также ID, team, owner, role и связанные entity/unit поля.

Неизвестные native-функции не вызываются.

## Диагностический файл

После запуска матча создаётся:

`mods/nobody except us 2.0.26/resource/script/multiplayer/telemetry/bot_api_diag.jsonl`

Обычная телеметрия продолжает писаться отдельно в:

`telemetry/bot_gpt_telemetry.jsonl`

## Установка

Скопировать всё содержимое `BOT_GPT/v1_21_4_diag` в:

`mods/nobody except us 2.0.26/resource/script/multiplayer/`

с заменой файлов и начать новый бой.

В `game.log` должна появиться строка:

`[NEU-BOT] POSITION DIAG v1.21.4 ACTIVE path=...bot_api_diag.jsonl`

и затем:

`[NEU-BOT] v1.21.4 DIAGNOSTIC POSITION PROBE ACTIVE`

## Что прислать после теста

Достаточно прислать:

1. `telemetry/bot_api_diag.jsonl`
2. новый `game.log`

По этим двум файлам можно определить, какой объект или коллекция реально содержит координаты squad/unit, либо подтвердить, что обычный Lua BotApi координаты противника не экспортирует.
