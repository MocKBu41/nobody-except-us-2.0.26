# Анализ `game_bot 2.0.log`

Дата анализа: 2026-09-15.

Версия в тесте: `BOT_GPT/v2_0`.

## Итог

BOT 2.0 не выполнял игровую логику из-за потерянной регистрации callback-функций в `BotApi.Events`.

## Что подтверждает лог

Во время загрузки дважды успешно проходит цепочка:

- `/script/multiplayer/bot.main.lua`
- `/script/multiplayer/bot.lua`
- `/script/multiplayer/bot.core.lua`
- `/script/multiplayer/bot.logic.lua`
- `[BOT2.0] BOT 2.0 ACTIVE; canonical logic=BOT_MEMORY/BOT_LOGIC_CURRENT.json`

То есть проблема не была ошибкой пути `require` или синтаксической ошибкой загрузки этих модулей.

После `GameThreadStart` отсутствуют ожидаемые сообщения `START BOT 2.0`, `UNITS`, `ROLE`, `QUEUE`, `SPAWN`, `ARRIVED`, `STATE`.

## Найденная причина

В `BOT_GPT/v2_0/bot.logic.lua` определены:

- `onGameStart()`
- `onGameStop()`
- `onGameQuant()`
- `onGameSpawn(args)`

Но файл заканчивается после `onGameSpawn` и не содержит:

```lua
BotApi.Events:Subscribe(BotApi.Events.GameStart, onGameStart)
BotApi.Events:Subscribe(BotApi.Events.GameEnd, onGameStop)
BotApi.Events:Subscribe(BotApi.Events.Quant, onGameQuant)
BotApi.Events:Subscribe(BotApi.Events.GameSpawn, onGameSpawn)
```

Эти подписки есть в штатном боте MoWAS2 и присутствовали в рабочей линии `BOT_GPT/v1_30_1`.

## Второй регресс

Папка `BOT_GPT/v2_0` содержала только четыре файла и потеряла инфраструктуру визуализации/геометрии прошлых версий.

Из `v1_27` были потеряны как минимум:

- `bot_visualizer.html`
- `bot.telemetry.lua`/богатый формат визуализации
- `bot.mapdata.lua`
- `_flag_points_final.json`
- `_map_points_index.json`

Кроме того, новый `/_spawn_points_index.json` не был включён в пакет. В нём находятся прямые SpawnPoint A/B из `battle_zones.mi`.

## Исправление

Создана линия `BOT_GPT/v2_0_1`:

- возвращена регистрация GameStart/GameEnd/Quant/GameSpawn;
- исходная логика 2.0 сохранена отдельно в `bot.logic.base.lua`;
- возвращены три координатных индекса;
- добавлен визуализатор BOT 2.0.1 с ручным выбором карты и SpawnPoint A/B;
- `GITHUB_MEMORY.md` обновлён: эти компоненты теперь обязательны для следующих версий.

Статус исправления: **НУЖЕН ТЕСТ В ИГРЕ**.
