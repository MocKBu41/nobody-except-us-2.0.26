# NEU BOT v1.21.7 actor/entity position diagnostic

Диагностическая версия на базе v1.21.6. Боевая логика не меняется. Цель — найти безопасный путь `squadId -> actor/entity/unit -> position`.

## Почему нужен этот этап

Предыдущая диагностика подтвердила, что `BotApi.Scene.Squads` содержит числовые squadId, но публичный BotApi не показал `GetPosition`, `GetEntity`, `GetActor` или `GetSquadPosition`. При этом `game.log` самого GEM2 явно использует actor/entity ID, например `human[42:...]`, `t72b3[80]` и строки `Remap actor_id ...`.

## Что делает v1.21.7

Только чтение, без вызова неизвестных native-функций:

- глубже исследует `BotApi`, его metatable, `__index`, `__propget`, `__const`;
- ищет глобальные таблицы и userdata с именами actor/entity/unit/squad/scene/object/position/transform/matrix;
- исследует `package.loaded` без подключения неизвестных модулей;
- если доступен `debug.getregistry()`, читает Lua registry и ищет зарегистрированные C++ классы/метатаблицы actor/entity/unit/scene;
- для известных собственных squadId безопасно проверяет индексируемые контейнеры `Actors/Entities/Units/Objects/Humans/Vehicles/Squads`;
- для найденных объектов читает только вероятные поля `id/actorId/entityId/squadId/x/y/z/pos/position/center/matrix/transform/entity/actor/unit/...`.

Никаких `os.execute`, `cmd.exe` и мигающей консоли нет.

## Когда запускается

Диагностика срабатывает примерно на 8, 30 и 60 секунде боя. Между этими моментами она не сканирует API постоянно.

## Результат

Создаётся файл:

`mods/nobody except us 2.0.26/resource/script/multiplayer/telemetry/bot_actor_entity_diag.jsonl`

Обычная телеметрия продолжает работать отдельно в `telemetry/bot_gpt_telemetry.jsonl`.

## Установка

Скопировать всё содержимое `BOT_GPT/v1_21_7_diag` в:

`mods/nobody except us 2.0.26/resource/script/multiplayer/`

с заменой файлов и начать новый матч.

В `game.log` должна появиться строка:

`[NEU-BOT] ACTOR/ENTITY POSITION DIAG v1.21.7 ACTIVE ...`

## Что прислать после теста

Поиграть 70–90 секунд и прислать:

1. `telemetry/bot_actor_entity_diag.jsonl`
2. свежий `game.log`

Если registry или один из контейнеров раскроет объект actor/entity, следующая версия уже сделает точечный безопасный тест получения позиции на одном известном squadId и затем подключит реальные координаты к `bot_gpt_telemetry.jsonl`.
