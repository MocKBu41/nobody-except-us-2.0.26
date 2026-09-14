# NEU BOT 2.0.3 — ALL FLAGS FIRST

Статус: **НУЖЕН ТЕСТ В ИГРЕ**.

Версия построена поверх 2.0.2 после анализа реальных telemetry обеих сторон.

## Исправлено

### 1. Сторона A больше не блокируется вертолётом
В 2.0.2 игра вернула `SPAWN OK` для opening heli, но не прислала `GameSpawn`. Общая очередь осталась в `AwaitingArrival` и перестала вызывать наземные юниты.

В 2.0.3 opening `patrol_heli` вызывается отдельно от сериализованной ground-очереди. Даже если callback не придёт, pointstart/infantry/tank продолжают spawn.

### 2. PointStart больше не зависит от специального тега
В 2.0.2 сторона B имела `SPAWN FAILED role=pointstart ... no candidates`.

В 2.0.3 пул `pointstart` содержит нативные pointstart-кандидаты плюс обычную infantry как fallback. Поэтому каждая сторона должна иметь чем отправить отдельный отряд на каждый neutral flag.

### 3. БТГ запрещено формироваться раньше покрытия карты
При старте:

1. Считать все neutral flags.
2. Поставить отдельный pointstart-захватчик на каждый флаг с priority=1000.
3. Основной `infantry -> recon -> tank -> mech_inf` заморозить.
4. Для каждого появившегося pointstart немедленно `CaptureFlag` на закреплённый флаг.
5. Считать флаг покрытым после успешной выдачи capture-order либо если флаг уже принадлежит нашей стороне.
6. Только после `covered == total` вывести `OPENING COVERAGE COMPLETE ... -> RELEASE MAIN BTG` и разрешить обычный OPENING.

Для карты теста с 11 neutral flags до БТГ ожидаются 11 отдельных захватчиков/приказов.

## Установка

Из `BOT_GPT/v2_0_3/` скопировать в `resource/script/multiplayer/`:

- `bot.main.lua`
- `bot.lua`
- `bot.core.lua`
- `bot.logic.lua`
- `bot.logic.base.lua`
- `bot.geometry.lua`
- `_flag_points_final.json`
- `_spawn_points_index.json`
- `_map_points_index.json`

`bot_visualizer.html` — текущий визуализатор. Геометрия продолжает встраиваться в один telemetry-файл каждой стороны.

## Обязательные строки следующего теста

- `BOT 2.0.3 EVENTS ACTIVE`
- `ROLE pointstart native=N with_infantry_fallback=M` где M > 0
- `OPENING MAIN FROZEN`
- `OPENING POINTSTART queued=11` (на карте текущего теста)
- `POINTSTART ORDER ... flag=fN`
- `OPENING COVERED ... progress=N/11`
- `OPENING COVERAGE COMPLETE assigned=11/11 -> RELEASE MAIN BTG`

Если вертолёт снова не даст callback, должно быть:
`OPENING HELI ACCEPTED without GameSpawn ... ground queue NOT blocked`
и после этой строки наземные pointstart всё равно должны продолжать появляться.

После теста загрузить `game ... 2.0.3.log` и telemetry A/B в `/LOG/`.
