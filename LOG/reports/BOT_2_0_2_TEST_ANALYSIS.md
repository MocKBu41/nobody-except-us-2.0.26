# BOT 2.0.2 — разбор испытания

Дата: 2026-09-15
Статус версии: **ОШИБКА / заменена BOT 2.0.3**

## Сторона A

`bot_gpt_telemetry_a  bot 2.0.2.jsonl`:

- t=0: 11 neutral flags;
- opening heli поставлен в старт;
- `SPAWN OK role=patrol_heli unit=warrior_wrap2`;
- после этого нет `ARRIVED` для вертолёта и нет ни одного наземного squad;
- t=61: состояние всё ещё OPENING, squads=[], flags=0/0/11.

Причина: BOT 2.0.2 использовал обычную сериализованную очередь для opening heli. На стороне A игра приняла Spawn, но не дала GameSpawn callback. `C.AwaitingArrival` остался занят и заблокировал всю дальнейшую очередь.

## Сторона B

`bot_gpt_telemetry_b bot 2.0.2.jsonl`:

- t=0: 11 neutral flags;
- opening heli успешно получил ARRIVED;
- первая попытка стартового захватчика: `SPAWN FAILED role=pointstart ... no candidates`;
- затем сформировались infantry/recon/tank/mech_inf;
- бот перешёл EXPAND и назначил только часть целей;
- pointstart продолжили завершаться `no candidates` / `timeout`;
- t=61: flags=0/0/11.

Причина: реализация ошибочно считала, что у каждой стороны обязательно существует специализированный кандидат с ролью/tag pointstart. Для стороны B это оказалось ложным.

## Решение BOT 2.0.3

- pointstart pool дополняется обычной infantry;
- все стартовые neutral flags получают отдельные заявки с priority=1000;
- обычный main opening заморожен до покрытия всех стартовых neutral flags;
- opening heli вынесен из общей AwaitingArrival-очереди и не может заблокировать ground spawn;
- canonical behavior записан в `BOT_MEMORY/BOT_LOGIC_CURRENT.json`.
