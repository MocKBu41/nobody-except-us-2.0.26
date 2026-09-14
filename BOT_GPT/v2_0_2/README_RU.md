# NEU BOT 2.0.2 — возврат полного старта + самостоятельная визуализация

Статус: **НУЖЕН ТЕСТ В ИГРЕ**.

Основание: логи `LOG/game bot 2.0.1.log`, `LOG/bot_gpt_telemetry_a bot 2.0.1.jsonl`, `LOG/bot_gpt_telemetry_b bot 2.0.1.jsonl`.

## Что подтвердил тест 2.0.1

- lifecycle исправлен: бот запускается и создаёт отряды;
- обе стороны видят 9 нейтральных флагов;
- новая OPENING создавала только 4 основных отряда и назначала только f1..f4;
- до конца теста флаги оставались 0/0/9;
- вертолёт блокировался строкой `HELI BLOCKED exact enemy tank count unavailable`;
- визуализатор читал telemetry, но без ручной загрузки индексов имел FLAGS=0 / SPAWN A=0 / SPAWN B=0.

## Возвращено из проверенной старой линии v1.21

1. На старте для **каждого нейтрального флага** ставится отдельный `pointstart` с конкретной целью.
2. На старте независимо ставится `patrol_heli` (`opening heli`).
3. После стартового покрытия продолжает работать основной OPENING 2.x: infantry -> recon -> tank -> mech_inf.
4. `pointstart` после появления немедленно получает `CaptureFlag` на свой закреплённый флаг.

## Новая визуализация

`bot.geometry.lua` читает `_flag_points_final.json` и `_spawn_points_index.json` внутри игры, выбирает все лучшие совпадающие по runtime-флагам варианты локации и записывает их прямо в обычную telemetry строкой `geometry_index`.

Поэтому для просмотра боя больше НЕ нужно вручную выбирать JSON-индексы.

Используются только:
- `bot_gpt_telemetry_a.jsonl` — один файл стороны A;
- `bot_gpt_telemetry_b.jsonl` — один файл стороны B.

Их можно загрузить в `bot_visualizer.html` одновременно. Если по именам флагов возможны несколько карт, визуализатор покажет список кандидатов — выбрать фактическую локацию. Это исключает старую ошибку ложного автовыбора карты по одинаковым f1..fN.

На карте отображаются:
- все FlagPoint выбранной локации с X/Y;
- все SpawnPoint A с X/Y;
- все SpawnPoint B с X/Y;
- назначения отрядов обеих сторон на флаги;
- состояния и события обеих telemetry.

## Установка

Скопировать из `BOT_GPT/v2_0_2/` в `resource/script/multiplayer/`:

- `bot.main.lua`
- `bot.lua`
- `bot.core.lua`
- `bot.logic.lua`
- `bot.logic.base.lua`
- `bot.geometry.lua`
- `_flag_points_final.json`
- `_spawn_points_index.json`

`_map_points_index.json` также сохранён в комплекте как полный проектный индекс, но новый визуализатор для FlagPoint/SpawnPoint его вручную не требует.

`bot_visualizer.html` можно открыть отдельно в браузере.

## Что искать в новом логе

Должны появиться:

- `BOT 2.0.2 EVENTS ACTIVE`
- `GEOMETRY candidates=...`
- `ROLE patrol_heli candidates=...`
- `OPENING HELI queued at battle start`
- `OPENING POINTSTART queued=9 ...` (для карты теста с 9 neutral)
- `OPENING HELI ARRIVED ...`
- для каждого стартового отряда `POINTSTART ORDER squad=... flag=fN`

В telemetry должна появиться строка `type=geometry_index`.

После теста положить `game bot 2.0.2.log`, `bot_gpt_telemetry_a.jsonl`, `bot_gpt_telemetry_b.jsonl` в `/LOG/`.
