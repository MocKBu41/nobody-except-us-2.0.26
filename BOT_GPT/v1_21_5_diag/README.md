# NEU BOT v1.21.5 targeted diagnostic

Диагностическая версия на базе v1.21.4. Боевая логика не меняется. Цель версии — найти точный путь `squadId -> unit/entity/actor -> position` и после этого добавить реальные координаты в телеметрию.

## Что уже установлено предыдущим тестом

- `BotApi.Scene` — userdata.
- В metatable `BotApi.Scene` виден `IsSquadExists`.
- `BotApi.Scene.Squads` существует, но содержит числовые squadId, а не объекты с x/y.
- `BotApi.Commands` содержит известные команды `CaptureFlag`, `EnemyHasTanks`, `Income`, `SayChat`, `Spawn`.

Поэтому v1.21.5 больше не делает широкий перебор всех Scene-коллекций.

## Что проверяет v1.21.5

Точечно исследуются:

- `BotApi.Bot`
- `BotApi.BotScene`
- `BotApi.BotCommands`
- `BotApi.BotEvent`
- `BotApi.BotEvents`
- `BotApi.Instance`
- `BotApi.Scene`
- `BotApi.Commands`
- `BotApi.Events`
- содержимое metatable, `__propget`, `__propset`, `__const`, `__index`
- глобальные Lua API, имена которых содержат `entity`, `actor`, `unit`, `squad`, `position`, `scene`, `vehicle`, `human`, `object`, `getposition` и похожие слова
- список реальных `Scene.Squads` и известные собственные `C.SquadRole`

Неизвестные native-функции НЕ вызываются. Это только чтение и перечисление доступных методов/свойств.

## Без мигающей консоли

В этой версии нет `os.execute`, `cmd.exe` и создания каталога во время боя. Диагностика пишет напрямую в уже существующую папку `telemetry` через `io.open`.

## Когда выполняется

Два раза за матч: примерно на 5-й и 30-й секунде. Этого достаточно для сравнения API до и после появления отрядов.

## Файл результата

`mods/nobody except us 2.0.26/resource/script/multiplayer/telemetry/bot_position_api_diag.jsonl`

Обычная телеметрия остаётся в:

`telemetry/bot_gpt_telemetry.jsonl`

## Установка

Скопировать содержимое `BOT_GPT/v1_21_5_diag` в:

`mods/nobody except us 2.0.26/resource/script/multiplayer/`

с заменой и начать новый матч.

В `game.log` должна быть строка:

`[NEU-BOT] POSITION API DIAG v1.21.5 ACTIVE path=...bot_position_api_diag.jsonl`

и:

`[NEU-BOT] v1.21.5 TARGETED POSITION API DIAG ACTIVE`

## Что прислать

После 40–60 секунд боя достаточно двух файлов:

1. `telemetry/bot_position_api_diag.jsonl`
2. свежий `game.log`

Если в class table/metatable найдётся функция вроде `GetPosition`, `GetSquad`, `GetUnit`, `GetEntity`, `GetActor` или соответствующее property, следующая версия уже проверит её точечно и безопасно на одном известном squadId.