# Анализ боя BOT 2.0.1

Дата анализа: 2026-09-15.

Источники:
- `LOG/game bot 2.0.1.log`
- `LOG/bot_gpt_telemetry_a bot 2.0.1.jsonl`
- `LOG/bot_gpt_telemetry_b bot 2.0.1.jsonl`
- пользовательский скриншот визуализатора 2.0.1.

## Подтверждено

Lifecycle regression версии 2.0 исправлен: BOT 2.0.1 создаёт основные отряды и переходит OPENING -> EXPAND.

Сторона A:
- neutral flags = 9;
- opening: infantry, recon, tank, mech_inf;
- цели после opening: f1, f2, f3, f4;
- до t=180 счёт флагов остаётся 0/0/9;
- на t=1: `HELI BLOCKED exact enemy tank count unavailable`.

Сторона B:
- neutral flags = 9;
- opening: infantry, recon, tank, mech_inf;
- цели после opening: f1, f2, f3, f4;
- до t=180 счёт флагов остаётся 0/0/9;
- на t=1: `HELI BLOCKED exact enemy tank count unavailable`.

## Регрессии относительно требуемого/старого поведения

1. Потерян стартовый `pointstart` на каждый neutral flag. В старой проверенной логике v1.21 `queueOpening()` ставил `pointstart` отдельно на каждую neutral point.
2. Потерян стартовый `patrol_heli`. В v1.21 `queueOpening()` ставил `patrol_heli` с reason `opening heli`.
3. Визуализатор 2.0.1 читает telemetry, но координаты карты не находятся внутри telemetry. Без ручной загрузки трёх индексов UI показывает FLAGS=0 / SPAWN A=0 / SPAWN B=0 и пустой canvas.
4. Формат telemetry 2.0.1 хранит только `[squadId, role, target]`, без геометрии.

## Решение

Создан `BOT_GPT/v2_0_2/`, статус NEEDS_GAME_TEST.

- восстановлен pointstart на каждый neutral flag;
- восстановлен patrol_heli при старте;
- основной 2.x OPENING сохранён;
- геометрия подходящих карт и SpawnPoint A/B записывается внутрь telemetry событием `geometry_index`;
- новый HTML требует только telemetry A/B, ручная загрузка map-index JSON удалена;
- при неоднозначном наборе f1..fN пользователь выбирает фактическую карту из кандидатов, поэтому ложный автоматический map match не используется.

Следующий тест должен подтвердить `OPENING POINTSTART queued=<neutralCount>`, `OPENING HELI ARRIVED`, `POINTSTART ORDER ... flag=fN`, уменьшение neutralCount и наличие `geometry_index` в обеих telemetry.
