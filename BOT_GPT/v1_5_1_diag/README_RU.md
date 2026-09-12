# NEU BOT v1.5.1 diagnostic

Диагностический модуль для проверки, отдаёт ли GEM2/BotApi координаты флагов и координаты появления отрядов во время матча.

## Что делает

Модуль НЕ меняет приказы бота и НЕ вызывает юниты. Он только подписывается на `GameStart` и `GameSpawn` и пишет в `game.log` строки с префиксом `[NEU-DIAG]`.

Проверяются у каждого объекта из `BotApi.Scene.Flags`:

- `name`, `occupant`
- `id`, `entity`, `entityId`, `object`, `sceneObject`, `handle`
- `position`, `pos`, `point`, `coords`, `center`
- прямые `x`, `y`, `z`
- те же координатные поля у связанных объектов `entity/object/sceneObject/handle`
- безопасный `pairs(flag)`, если userdata разрешает итерацию

Для `GameSpawn` аналогично проверяются `args`, `entity`, `object`, `squad` и возможные координаты.

## Как поставить поверх v1.5

1. Оставить текущие `script/multiplayer/bot.lua` и `bot.data.lua` от v1.5 без изменений.
2. Скопировать `BOT_GPT/v1_5_1_diag/bot.probe.lua` в мод как:
   `script/multiplayer/bot.probe.lua`
3. Заменить `script/multiplayer/bot.main.lua` на файл из этой папки. Он загружает сначала обычный бот, затем диагностический модуль.
4. Запустить один матч и дать боту вызвать несколько стартовых юнитов.
5. Прислать новый `game.log`.

## Что искать в логе

Основные строки:

- `[NEU-DIAG] START v1.5.1 diagnostic probe`
- `[NEU-DIAG] FLAG[...]`
- `.position`, `.pos`, `.point`, `.coords`, `.center`
- `.x`, `.y`, `.z`
- `spawn.*`
- `geometry_direct=true/false`

Если хотя бы у флагов и у одного spawn-объекта удастся получить координаты, следующая версия сможет считать реальные расстояния и выбирать физически ближайшие флаги вместо эвристики f1/f11.
