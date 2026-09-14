# Текущая версия NEU BOT

Текущая версия для следующего игрового теста: **`BOT_GPT/v2_0_3/`**.

Статус: **НУЖЕН ТЕСТ**.

## Что подтвердил тест BOT 2.0.2

Источники:
- `LOG/bot_gpt_telemetry_a  bot 2.0.2.jsonl`
- `LOG/bot_gpt_telemetry_b bot 2.0.2.jsonl`
- `LOG/game  bot 2.0.2.log`

Сторона A: `patrol_heli` получил `SPAWN OK`, но `GameSpawn/ARRIVED` для него не пришёл. Старый сериализованный spawn-контур оставил `AwaitingArrival` занятым, поэтому после вертолёта сторона A больше не вызывала наземные отряды.

Сторона B: вертолёт получил `ARRIVED`, но `pointstart` сразу падал `no candidates`, потому что у этой стороны не нашлось специального кандидата роли pointstart. После этого основной OPENING сформировал infantry/recon/tank/mech_inf и начал распределять их по части флагов, хотя стартовое покрытие всех 11 neutral flags не было выполнено.

## BOT 2.0.3

Исправления:

1. **ALL FLAGS FIRST.** На каждый neutral flag на старте создаётся отдельная заявка захватчика с конкретной целью.
2. Если специальных `pointstart`-юнитов нет, в их пул добавляется обычная infantry этой стороны.
3. Основной OPENING/БТГ `infantry -> recon -> tank -> mech_inf` заморожен до момента, когда каждому стартовому neutral flag назначен свой живой захватчик/приказ либо флаг уже стал нашим.
4. `pointstart` имеет приоритет 1000 и при полном spawn failure переочередится на тот же флаг.
5. Стартовый `patrol_heli` вызывается вне общей `AwaitingArrival` ground-очереди. Отсутствие `GameSpawn` для вертолёта больше не может остановить вызов наземных юнитов.
6. Геометрия/визуализация 2.0.2 сохранена: один telemetry-файл на сторону, `geometry_index` внутри него.

Каноническая логика уже обновлена непосредственно в `BOT_MEMORY/BOT_LOGIC_CURRENT.json`. Старый исходный пользовательский граф сохранён без изменений в `BOT_MEMORY/archive/BOT_LOGIC_ORIGINAL_2026-09-14.json`.

## Что должно подтвердиться в следующем тесте

Для карты с 11 neutral flags ожидается:

- `OPENING POINTSTART queued=11`;
- `ROLE pointstart native=... with_infantry_fallback=...` и итоговый пул > 0;
- 11 строк `POINTSTART ORDER ... flag=fN` / `OPENING COVERED ... progress=N/11`;
- только после `OPENING COVERAGE COMPLETE assigned=11/11 -> RELEASE MAIN BTG` начинается обычный основной OPENING;
- если opening heli принят без GameSpawn: `OPENING HELI ACCEPTED without GameSpawn ... ground queue NOT blocked`, после чего pointstart всё равно продолжают появляться.
