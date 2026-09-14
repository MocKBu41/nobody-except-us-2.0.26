# NEU BOT 2.0.1 — lifecycle fix + возвращённая визуализация

Статус: **НУЖЕН ТЕСТ В ИГРЕ**.

Основа поведения не менялась: источник истины — `BOT_MEMORY/BOT_LOGIC_CURRENT.json`.

## Что сломалось в BOT 2.0

`LOG/game_bot 2.0.log` подтвердил, что `bot.lua -> bot.core.lua -> bot.logic.lua` загружались и выводили `BOT 2.0 ACTIVE`, но после начала игры не было `START/UNITS/QUEUE/SPAWN/STATE`.

Причина: в конце `BOT_GPT/v2_0/bot.logic.lua` отсутствовали подписки на события движка:

- `BotApi.Events.GameStart`
- `BotApi.Events.GameEnd`
- `BotApi.Events.Quant`
- `BotApi.Events.GameSpawn`

Поэтому callbacks существовали, но движок их не вызывал.

## Что исправлено в 2.0.1

`bot.logic.base.lua` — сохранённая логика BOT 2.0.

`bot.logic.lua` — тонкий lifecycle-слой, который загружает `bot.logic.base.lua` и подписывает четыре callback через `BotApi.Events:Subscribe(...)`.

`bot.main.lua` — штатная точка входа `require(/script/multiplayer/bot)`.

В комплект возвращены координатные данные:

- `_flag_points_final.json` — координаты флагов/точек захвата;
- `_map_points_index.json` — полный индекс точек карт;
- `_spawn_points_index.json` — SpawnPoint сторон A/B из `battle_zones.mi`.

В комплект возвращён `bot_visualizer.html`, адаптированный к телеметрии BOT 2.x. Он позволяет вручную выбрать карту и показывает:

- координаты FlagPoint;
- SpawnPoint стороны A;
- SpawnPoint стороны B;
- опционально остальные точки `_map_points_index`;
- назначения живых отрядов на флаги из snapshot телеметрии.

Автовыбор неоднозначной карты сознательно не используется. Бой 7 доказал, что одинаковый набор имён `f1..f11` может существовать на разных картах.

## Установка BOT 2.0.1 в мод

Из этой папки скопировать в `resource/script/multiplayer/`:

1. `bot.main.lua`
2. `bot.lua`
3. `bot.core.lua`
4. `bot.logic.lua`
5. `bot.logic.base.lua`

JSON-индексы и `bot_visualizer.html` не нужны движку для запуска BOT 2.0.1; они нужны для анализа/визуализации и лежат рядом с версией как обязательная часть комплекта.

## Что должно появиться в следующем game.log

До матча/при загрузке:

`[BOT2.0.1] BOT 2.0.1 EVENT SUBSCRIPTIONS ACTIVE: GameStart/GameEnd/Quant/GameSpawn`

После события GameStart:

- `[BOT2.0.1] START BOT 2.0 ...`
- `[BOT2.0.1] UNITS loaded=...`
- `[BOT2.0.1] ROLE infantry candidates=...`
- `[BOT2.0.1] QUEUE role=infantry ...`
- затем `SPAWN OK` / `ARRIVED` либо диагностический `SPAWN REJECTED/FAILED`.

Если строк `EVENT SUBSCRIPTIONS ACTIVE` нет — установлена не эта версия.
Если она есть, но `START BOT 2.0` после запуска матча отсутствует — проблема уже выше слоя Lua callback и её надо искать по следующему логу.

## Визуализатор

Открыть `bot_visualizer.html` в браузере.

В верхней панели:

- загрузить `bot_gpt_telemetry_<team>.jsonl`;
- вторым выбором файлов одновременно выбрать `_flag_points_final.json`, `_map_points_index.json`, `_spawn_points_index.json`;
- выбрать фактическую локацию в списке.

Справа появятся точные X/Y флагов и SpawnPoint A/B.

## Следующий тест

После боя положить новый `game.log` и, если создался, `bot_gpt_telemetry_<team>.jsonl` в `/LOG/`.

После анализа результат должен быть внесён в `GITHUB_MEMORY.md`.
