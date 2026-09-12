# NEU BOT v1.10

Версия построена на рабочей state-machine v1.9 и исправляет именно проблемы, выявленные в `game(9).log`.

## Что исправлено

- Матчинг карты больше не требует полного буквального совпадения списка флагов из JSON.
- Имена флагов в геометрии сравниваются как уникальный набор; дубли `f1/f2/f3/...` в сканере не ломают определение карты.
- Добавлен fuzzy-match карты: используется лучшая карта с долей совпавших runtime-флагов не ниже `MapMatchMinRatio` (по умолчанию 0.75).
- Для одного имени флага теперь могут храниться несколько координат. Расстояние до такого флага считается по ближайшему подходящему варианту, а не по случайной первой записи.
- Стартовые нейтральные цели сортируются по реальному расстоянию от spawn anchor своей команды.
- После захвата точки разведчик и capture-пара продолжают маршрут к ближайшей оставшейся нейтральной точке относительно предыдущей точки, а не снова начинают сортировку по номеру.
- Когда остаётся 3 или меньше нейтральных флагов, захватчики больше не бросают их каждые 60 секунд из-за stall-reassign. Они закрепляются за последними целями (`NEUTRAL PIN`) до захвата/гибели.
- После `N=0` обе БТГ переводятся в `ready`; если `ATTACK UNLOCK` уже произошёл, атака запускается в том же цикле.
- Сохранены исправления v1.9: opening recovery, critical spawn retry, command cooldown, tank-loss-continue, direction rebuild, USA special-air whitelist, AA patrol, defense, 2-minute attack result logic.

## Основные диагностические строки

При корректной работе геометрии на `3vs3/3vs3_country` ожидаются строки вида:

```text
[NEU-BOT] START v1.10 ...
[NEU-BOT] MAP MATCH key=3vs3/3vs3_country ratio=...
[NEU-BOT] MAP SPAWN ANCHOR team=b x=... y=...
[NEU-BOT] MAP FLAG GEO name=f... variants=... dSpawn=...
[NEU-BOT] MAP KNOWLEDGE ... loaded=true key=3vs3/3vs3_country ... spawn=true
```

Назначение нейтральных целей:

```text
TARGET GEO reason=recon-nearest-route ...
TARGET GEO reason=capture-pairs-nearest-spawn ...
TARGET GEO reason=capture-pair-next-nearest from=f... first=f...
NEUTRAL CONTINUE squad=... from=f... to=f...
```

Для последних нейтралов:

```text
NEUTRAL PIN squad=... flag=f... remaining=2
```

После очистки нейтралов:

```text
NEUTRALS CLEARED time=...
GROUP READY id=1 reason=neutrals-cleared
GROUP READY id=2 reason=neutrals-cleared
ATTACK GATE OPEN neutrals=0 reason=...
ATTACK START group=1 flag=...
ATTACK START group=2 flag=...
```

## Установка

Файлы `bot.lua`, `bot.data.lua`, `bot.main.lua`, `bot.mapdata.lua` из этой папки копируются в:

```text
mods\nobody except us 2.0.26\resource\script\multiplayer\
```

Там же должны находиться актуальные:

```text
_flag_points_final.json
_map_points_index.json
```

Эти два JSON-файла в папку `BOT_GPT/v1_10` данным коммитом не дублировались; бот ищет их в runtime-папке `resource\script\multiplayer` и резервных путях, описанных в `bot.mapdata.lua`.

## Ограничения

- Настоящий `SplitSquad` не используется: команда API не подтверждена. Capture pair остаётся отдельным `Spawn(..., 2)`.
- Точное удержание танка в 100 игровых метрах от точки пока не реализовано, поскольку не подтверждена команда BotApi для движения в произвольные координаты.
- Геометрия, полученная сканером, содержит дубли и алиасы имён. v1.10 учитывает их как несколько вариантов координат, но окончательную правильность выбора нужно проверить по следующему `game.log`.
