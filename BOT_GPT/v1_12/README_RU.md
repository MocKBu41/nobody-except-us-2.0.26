# NEU BOT v1.12

Основа: v1.11. Версия исправляет три проблемы из `game(10).log`.

## 1. Стартовый захват `pointstart`

- Все нейтральные точки, существующие в момент старта, планируются как `1 точка = 1 отдельный отряд pointstart`.
- `pointstart` не имеет fallback на обычную пехоту.
- В v1.11 при одном кандидате `vehicle_supporter(usa)` первые 4 вызова прошли, а остальные точки получили `SPAWN FAILED`. В v1.12 для каждого такого target добавлен отдельный retry: до `PointStartSpawnRetryCycles` циклов с задержкой `PointStartSpawnRetrySec`.
- Если за время ожидания точка уже стала нашей, задача отменяется как выполненная.
- Если точка уже стала вражеской, она помечается как hostile и стартовый отряд туда больше не вызывается.
- Если уже появившийся pointstart-отряд погиб по пути, его target считается вражеским даже при neutral occupant, как и в v1.11.

Ожидаемые строки лога:

```text
POINTSTART PLAN points=11 squads=11 ...
POINTSTART RETRY target=f... cycle=...
SPAWN OK role=pointstart ... target=f...
POINTSTART CAPTURE DONE squad=... flag=f...
```

## 2. Пехота, которая спешивается из БТР/БМП

В v1.11 бот знал только исходный squad бронемашины/пехотного юнита. Новые squads, возникающие после спешивания, приходили как `UNMATCHED SPAWN` и игнорировались.

В v1.12 возвращена обработка спешенной пехоты, но не старым глобальным способом. Используется ограниченное окно только во время активной атаки:

- при `ATTACK START` для группы открывается `DETACH WINDOW`;
- окно обновляется, пока основной infantry получает приказ атаковать target;
- `UNMATCHED SPAWN` внутри такого окна принимается как `infantry_detached`;
- squad привязывается к этой БТГ и сразу получает `CaptureFlag` на target группы;
- неактивные/случайные unmatched squads вне окна по-прежнему игнорируются;
- при успешном захвате спешенная пехота остаётся защитником точки.

Ожидаемые строки:

```text
DETACH WINDOW group=1 target=f...
DETACHED ADOPT squad=... group=1 target=f...
ORDER squad=... role=infantry_detached flag=f...
```

## 3. Один стартовый вертолёт-патруль

При старте вызывается ровно один `patrol_heli`. Кандидаты берутся из тех же unit-записей, где есть `duel_heli` или `duel_heli2`.

После появления вертолёт:

- не атакует neutral/enemy flags специально;
- каждые `HeliPatrolSec` секунд выбирает следующую уже захваченную ботом точку;
- циклически летает по списку собственных флагов;
- если флагов пока нет, ждёт;
- при гибели не вызывается повторно: требование — один вертолёт в начале.

Ожидаемые строки:

```text
ROLE patrol_heli candidates=...
SPAWN OK role=patrol_heli ...
HELI PATROL READY squad=...
HELI PATROL squad=... flag=f... ownFlags=...
```

## Конфигурация

В `bot.data.lua` добавлено:

```lua
PointStartSpawnRetrySec = 5
PointStartSpawnRetryCycles = 20
DetachedAdoptWindowSec = 25
DetachedAdoptMaxPerGroup = 6
HeliPatrolSec = 20
```

## Файлы

- `bot.lua`
- `bot.data.lua`
- `bot.main.lua`
- `bot.mapdata.lua`

Для геометрии, как и раньше, рядом с runtime-скриптами нужны `_flag_points_final.json` и `_map_points_index.json`.
