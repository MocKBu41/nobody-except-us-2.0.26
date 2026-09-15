# GitHub Memory — GEM2 MoWAS2 / Nobody Except Us

> Постоянная проектная память для `MocKBu41/nobody-except-us-2.0.26`.

## ОБЯЗАТЕЛЬНОЕ ПРАВИЛО

Перед **любой** задачей GEM2 MoWAS2 / NEU сначала читать этот файл, затем `BOT_MEMORY/BOT_LOGIC_CURRENT.json`, текущую версию `BOT_GPT/CURRENT.md` и относящиеся к задаче последние файлы `/LOG/`.

Не переписывать рабочие подсистемы с нуля без необходимости. Продолжать от последней протестированной линии. После теста сохранять подтверждённый результат/ошибку в памяти и `/LOG/reports/`.

## Каноническая логика поведения

Главный и обязательный источник истины: **`BOT_MEMORY/BOT_LOGIC_CURRENT.json`**.

Если пользователь меняет поведение, приоритет, порядок старта, состав, дистанцию, условия вызова юнитов или переход состояния, изменение **обязательно вносится непосредственно в этот файл одновременно с кодом**. Отдельный override не заменяет обновление основного файла.

Оригинальная присланная 2026-09-14 плиточная схема сохранена без изменений в:
`BOT_MEMORY/archive/BOT_LOGIC_ORIGINAL_2026-09-14.json`.

## Текущая версия

**`BOT_GPT/v2_0_4/` — МОДЕЛЬНЫЕ ТЕСТЫ ПРОЙДЕНЫ, НУЖЕН ТЕСТ В ИГРЕ.**

Актуальное описание: `BOT_GPT/CURRENT.md`.

### Главный инвариант старта BOT 2.0.3

**ALL FLAGS FIRST:** сначала каждый neutral flag, существующий на старте боя, должен получить отдельный живой отряд-захватчик и `CaptureFlag` именно на свою точку. Только после того как покрыты все стартовые neutral flags (либо часть уже стала нашей), разрешается основной OPENING/БТГ `infantry -> recon -> tank -> mech_inf`.

Если специализированного `pointstart` нет, используется обычная infantry как fallback. Отсутствие pointstart-tagged unit никогда не должно отменять захват точки.

Стартовый `patrol_heli` вызывается в начале независимо от conditional attack_heli, но **не участвует в сериализованном AwaitingArrival ground-spawn**, поэтому отсутствие GameSpawn callback у вертолёта не имеет права блокировать наземные юниты.

## Результат BOT 2.0.2 — ОШИБКА

Источники:
- `LOG/game  bot 2.0.2.log`
- `LOG/bot_gpt_telemetry_a  bot 2.0.2.jsonl`
- `LOG/bot_gpt_telemetry_b bot 2.0.2.jsonl`
- отчёт `LOG/reports/BOT_2_0_2_TEST_ANALYSIS.md`.

Подтверждено:

- карта теста имела 11 neutral flags;
- сторона A: opening heli получил `SPAWN OK`, но без `ARRIVED/GameSpawn`; `AwaitingArrival` заблокировал всю дальнейшую очередь, поэтому до t=61 squads=[] и flags=0/0/11;
- сторона B: heli получил ARRIVED, но `pointstart` имел `no candidates`; затем преждевременно сформировался основной infantry/recon/tank/mech_inf и получил только часть флагов; оставшиеся pointstart завершались no candidates/timeout; flags остались 0/0/11.

Причины устранены в 2.0.3: infantry fallback для pointstart, priority=1000, hard gate основного OPENING и nonblocking opening heli.

## Предыдущая история

### BOT 2.0 — ОШИБКА
`LOG/game_bot 2.0.log`: Lua-модули грузились, но были потеряны `BotApi.Events:Subscribe(GameStart/GameEnd/Quant/GameSpawn)`, поэтому игровая логика не запускалась. Также из пакета выпали визуализатор/координатные данные.

### BOT 2.0.1 — lifecycle исправлен, поведение ошибочно
Lifecycle заработал, но при 9 neutral flags четыре основных отряда получили только f1..f4; flags оставались 0/0/9. Opening heli отсутствовал из-за conditional tank-counter gate. Это привело к 2.0.2.

## Стратегия после стартового покрытия

Из `BOT_MEMORY/BOT_LOGIC_CURRENT.json`:

- экономика: 1200 BP, +20 BP/сек, резерв 200;
- основной OPENING: infantry -> recon -> tank -> mech_inf;
- EXPAND: разные незахваченные цели, минимальная нагрузка; при равенстве neutral приоритетнее;
- infantry/mech_inf получают приказы раньше техники;
- tank/recon/attack_heli следуют с задержкой 10 сек;
- потеря recon/tank/mech_inf/attack_heli -> WAIT_REINFORCEMENT и замена;
- преимущество по флагам >=1 -> DEFEND; потеря преимущества -> EXPAND;
- отсутствие обычной infantry -> пополнение;
- conditional `attack_heli` — отдельная ветка, только при подтверждённых >=3 enemy tanks; максимум 1;
- opening `patrol_heli` — отдельный безусловный стартовый вызов;
- артиллерия отключена;
- unmatched/passenger squads не добавлять автоматически.

## Визуализация и координаты

Обязательные компоненты каждой новой версии:

- рабочие Event Subscribe;
- telemetry;
- `bot_visualizer.html`;
- `_flag_points_final.json` / актуальная база FlagPoint;
- `_spawn_points_index.json` для SpawnPoint A/B;
- полный `_map_points_index.json` сохранять как проектный индекс;
- совместимость telemetry ↔ visualizer.

Начиная с 2.0.2 визуализация использует **один telemetry-файл на сторону**: `bot_gpt_telemetry_a.jsonl` и `bot_gpt_telemetry_b.jsonl`. `bot.geometry.lua` добавляет `geometry_index` внутрь telemetry, поэтому пользователь не должен вручную подгружать координатные JSON в HTML.

Если одинаковые f1..fN соответствуют нескольким картам, нельзя молча выбирать одну: визуализатор должен дать выбор фактической карты. Это защита от ложной геометрии, найденной ранее на бою 7.

## Карты

Используются `flag_point`, `SpawnPoint`, координаты из `battle_zones.mi` внутри `multiplayer_maps.pak`. Существующие `_map_points_index`, `_flag_points_final`, `_spawn_points_index` являются базой и не должны заменяться несовместимыми форматами без необходимости.

## Пока не считать подтверждённо реализованным

- безопасная высадка только десанта из БМП/БТР;
- развёртывание пехоты примерно за 100 м и фронт 5–6 м;
- остановка танка примерно 50–100 м от точки;
- остановка БМП/БТР примерно 20–50 м;
- физическое coordinate-waypoint движение без проверенного engine bridge.

## Следующий тест 2.0.3

На карте с 11 neutral flags ожидаем до формирования БТГ:

- `OPENING POINTSTART queued=11`;
- `ROLE pointstart native=... with_infantry_fallback=...`, итоговый пул > 0;
- отдельные `POINTSTART ORDER ... flag=f1...f11`;
- прогресс `OPENING COVERED ... N/11`;
- затем `OPENING COVERAGE COMPLETE assigned=11/11 -> RELEASE MAIN BTG`;
- только после этой строки допускается обычный OPENING infantry/recon/tank/mech_inf.

Если opening heli не отдаст GameSpawn, ожидается `OPENING HELI ACCEPTED without GameSpawn ... ground queue NOT blocked`, после чего pointstart должны продолжить spawn.

---
Последнее обновление: **2026-09-15 — разобран BOT 2.0.2, найдены A-side heli deadlock и отсутствие pointstart candidates на B; создан BOT 2.0.3 ALL-FLAGS-FIRST, основной BOT_LOGIC_CURRENT обновлён.**

## BOT 2.0.4 — 2026-09-15
Продолжение snapshot 2.0.3 (11db92a2cb082a2177e570ae267735451f009e87), не новая реализация с нуля.
Исправлены таймаут ещё не начатых spawn-заявок, проверка живых захватчиков перед выпуском БТГ, повтор отклонённого CaptureFlag и пропуски OPENING/POINTSTART/ORDER в telemetry. Успешная выдача команды не означает подтверждённый физический захват.
Проверка: шесть Lua-модулей и regression harness Lua 5.4 PASS; сценарии и ограничения в BOT_GPT/v2_0_4/README_RU.md и LOG/reports/BOT_2_0_4_STATIC_VALIDATION.md. Игрового теста 2.0.3/2.0.4 в LOG пока нет.
Следующий тест — 2.0.4; ожидания предыдущего раздела 2.0.3 сохраняются, дополнительно проверять смерть захватчика и длительное стартовое покрытие.
Остаются риски унаследованного сопоставления GameSpawn: поздний helicopter callback и отсутствие наземного callback. Без проверенного ID запроса их исправление не заявляется.
