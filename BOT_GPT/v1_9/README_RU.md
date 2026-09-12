# NEU BOT v1.9

Версия 1.9 — отдельный снимок на базе v1.8. Старые версии не перезаписываются.

## Исправлено по game(8).log

1. **Чтение `_flag_points_final.json`**
   - добавлено удаление UTF-8 BOM `EF BB BF`;
   - JSON открывается в бинарном режиме;
   - удаляются ведущие пробельные символы;
   - в лог пишется `MAP DATA OPEN ... first={`;
   - аналогичная очистка применяется к `_map_points_index.json`.

2. **Геометрия карты**
   - при успешном совпадении набора флагов ожидаются `MAP MATCH key=...` и `MAP SPAWN ANCHOR ...`;
   - recon и пары захвата сортируют нейтральные флаги по реальному расстоянию от своего спавна;
   - фронтовые свои точки и направления атаки используют расстояния между известными флагами.

3. **Восстановление БТГ во время нейтральной фазы**
   - если БТГ ещё в `opening/hold_neutral`, но потеряла всю основную пехоту, бот вызывает новую;
   - если нет танка, вызывается `tank80plus`;
   - проверка выполняется каждые 10 секунд.

4. **Retry критических спавнов**
   - `infantry`, `tank`, `tank80plus` после перебора кандидатов не прекращают попытки сразу;
   - до 3 дополнительных циклов с паузой 10 секунд;
   - лог: `SPAWN RETRY CYCLE role=...`.

5. **Зависшие нейтральные точки**
   - если пара захвата 60 секунд не смогла снять нейтральный статус точки, цель временно блокируется на 30 секунд;
   - группа пытается перейти на другую свободную нейтральную точку;
   - логи: `NEUTRAL STALL` и `NEUTRAL REASSIGN`.

6. **Меньше повторных приказов**
   - одинаковый `squad + flag` не переотправляется чаще одного раза в 12 секунд;
   - это снижает спам `ORDER` без изменения общего поведения.

7. **USA special-air roles**
   В `units_usa.set` реальные самолёты/вертолёты помечены `nobot`, поэтому v1.8 их отбрасывала до построения ролей. v1.9 сохраняет `nobot`-запрет для обычных ролей, но разрешает только специальные авиационные ветки логики:
   - `aircraftlight` → имя/запись `support_light` (например `a-10c_support_light`);
   - `antirad` → имя содержит `antirad`;
   - `strike` → тег `strike` или имя `_strike`;
   - `duel_heli` → `duel_heli` или `duel_heli2`;
   - `duel_fighter` → тег `duel_fighter`.

   Это не включает `nobot` для обычной пехоты, танков, recon и прочих ролей.

## Что проверить в следующем game.log

```text
[NEU-BOT] START v1.9
[NEU-BOT] MAP DATA OPEN ... first={
[NEU-BOT] MAP MATCH key=3vs3/3vs3_country
[NEU-BOT] MAP SPAWN ANCHOR team=b ...
[NEU-BOT] MAP KNOWLEDGE ... loaded=true key=3vs3/3vs3_country spawn=true
```

Далее ожидаются ненулевые кандидаты хотя бы для части специальных ролей США:

```text
ROLE aircraftlight candidates=...
ROLE antirad candidates=...
ROLE strike candidates=...
ROLE duel_heli candidates=...
ROLE duel_fighter candidates=...
```

При проблемах старта БТГ:

```text
SPAWN RETRY CYCLE role=tank ...
QUEUE role=infantry ... reason=opening infantry recovery
QUEUE role=tank80plus ... reason=opening tank recovery
```

При застрявшем захвате:

```text
NEUTRAL STALL squad=... flag=...
NEUTRAL REASSIGN squad=... from=... to=...
```

## Файлы для установки

В `resource/script/multiplayer/` должны лежать:

- `bot.lua`
- `bot.data.lua`
- `bot.main.lua`
- `bot.mapdata.lua`
- `_flag_points_final.json`
- `_map_points_index.json`

## Сохранённые правила логики

- сначала все нейтральные точки, только потом атака игрока;
- две независимые БТГ;
- разные направления атаки;
- потеря танка не закрывает направление;
- потеря всей основной пехоты в атаке останавливает только это направление и запускает восстановление;
- AAT/aircraft reaction branches сохранены;
- точные 100 игровых метров для танка всё ещё не реализуются, потому что проверенного BotApi `Move/Stop` на произвольную координату нет.
