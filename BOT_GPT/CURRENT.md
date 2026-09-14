# Текущая версия NEU BOT

Текущая версия для следующего игрового теста: **`BOT_GPT/v2_0_2/`**.

Статус: **НУЖЕН ТЕСТ**.

## Почему 2.0.1 заменён

По `LOG/bot_gpt_telemetry_a bot 2.0.1.jsonl` и `LOG/bot_gpt_telemetry_b bot 2.0.1.jsonl` lifecycle уже работает, но выявлены поведенческие регрессии:

- при 9 нейтральных флагах стартовые четыре отряда получили только f1..f4;
- до конца теста flags оставались 0/0/9;
- стартовый вертолёт не вызывался (`HELI BLOCKED ... exact enemy tank count unavailable`);
- визуализатор требовал ручной загрузки координатных индексов и без них показывал пустую карту.

## 2.0.2

Возвращает проверенное открытие из v1.21:

- отдельный `pointstart` на каждый neutral flag;
- `patrol_heli` в стартовой очереди;
- затем основной OPENING 2.x: infantry -> recon -> tank -> mech_inf.

Визуализация теперь работает по одному telemetry-файлу на сторону:

- `bot_gpt_telemetry_a.jsonl`;
- `bot_gpt_telemetry_b.jsonl`.

FlagPoint и SpawnPoint A/B встраиваются внутрь telemetry событием `geometry_index`; отдельные JSON больше не выбираются вручную в HTML.

Поведенческий override этого изменения: `BOT_MEMORY/BOT_LOGIC_CURRENT_V2_0_2_OVERRIDE.json`.
