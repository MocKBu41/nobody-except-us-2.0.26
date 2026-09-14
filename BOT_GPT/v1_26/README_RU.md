# NEU BOT v1.26

Основа: v1.25. Изменение этой версии: исправлен источник кадров `snapshot` для HTML-карты.

## Что показал тест №4

`game4.log` подтверждает, что геометрия карты загружается: `4vs4/4vs4_cw_russian_village`, MATCH ratio=1.000, найден SPAWN и координаты флагов f1-f11.

`bot_gpt_telemetry4.jsonl` содержит события работы бота, появления отрядов и приказы, но v1.25 не записывал `snapshot`, поэтому визуализатор показывал пустую карту.

## Исправление v1.26

Телеметрия больше не использует отдельную подписку `BotApi.Events.Quant` для snapshots. `T.onQuant()` вызывается из обёртки `N.processSpawn()`, которая уже используется рабочим циклом бота. Частота snapshot остаётся 1 раз в игровую секунду через `TelemetrySnapshotSec`.

Ожидаемые строки в логе:
- `TELEMETRY v1.26 ACTIVE ...`
- `TELEMETRY v1.26 SNAPSHOT DRIVER=N.processSpawn`
- `v1.26 LIVE MAP + UNIT ROUTE TELEMETRY ACTIVE`

Файл для карты: `bot_gpt_telemetry.jsonl`.
