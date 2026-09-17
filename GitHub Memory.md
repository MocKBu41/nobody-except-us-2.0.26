# GitHub Memory — NEU / GEM2 MoWAS2

Этот файл — постоянная проектная память репозитория `nobody-except-us-2.0.26`.

## Правило работы

Перед новой задачей по NEU / GEM2 MoWAS2 сначала прочитать этот файл и учитывать сохранённый статус, проверенные решения, ошибки и результаты испытаний. После существенного проверенного изменения дополнять память, а не начинать проект заново.

Основная локальная рабочая копия пользователя: `D:\GPT_NEU`. При наличии доступа к локальной файловой системе рабочие версии и вспомогательные результаты можно сохранять туда в соответствующие папки проекта.

## Текущие точки входа бота

- `script/multiplayer/bot.lua` -> `bot.v1_21.logic`
- `script/multiplayer/bot.main.lua` -> `bot.v1_22.logic`
- Эти старые экспериментальные точки входа НЕ являются baseline новой линии `BOT_GPT/v1_0_0`.

## 2026-09-15 — Command Probe 1.0

Добавлена диагностика доступных боту команд GEM2/MoWAS2: `script/multiplayer/bot.command_probe.lua`, `tools/scan_bot_commands.py`, `BOT_COMMAND_PROBE.md`.

Подтверждённые команды/методы: `BotApi.Commands:Spawn(...)`, `BotApi.Commands:CaptureFlag(...)`, `BotApi.Scene:IsSquadExists(...)`.

## 2026-09-16 — baseline бота v1.0.0

Пользователь передал актуальный комплект бота архивом `multiplayer.rar` и назначил его базовой версией **1.0.0**.

Эталонный снимок:

- `BOT_GPT/v1_0_0/multiplayer/bot.data.lua`
- `BOT_GPT/v1_0_0/multiplayer/bot.lua`
- `BOT_GPT/v1_0_0/multiplayer/bot.main.lua`
- `BOT_GPT/v1_0_0/multiplayer/scan_bot_commands.py`
- `BOT_GPT/v1_0_0/README.md`

Правило: `BOT_GPT/v1_0_0` не переписывать. Следующие версии делать из baseline/последнего проверенного снимка в новой папке версии. Старые `v1_18..v1_22` не смешивать с baseline без явного решения пользователя.

Связанный полный тестовый лог `game — копия (2).log`: 1,154,513 байт, 8,237 строк, SHA-256 `78e5c199e905616ba2443ec197261a8797d739884d4dc1846a2596f4c5c2c00f`.

### Полный разбор поведения baseline

Отчёт сохранён: `BOT_GPT/v1_0_0/BEHAVIOR_FROM_LOG.md`.

Проверено по всему логу:

- 36 `SpawnUnit`;
- 36 `OnGameSpawn`;
- 49 `CaptureFlag`;
- каждый из 36 новых squad сразу получает первичный `CaptureFlag`;
- ещё 13 `CaptureFlag` появляются без нового `OnGameSpawn`;
- распределение целей: f5=20, f1=6, f9=6, f8=4, f10=4, f4=2, f11=2, f6=2, f7=1, f2=1, f3=1;
- baseline не имеет фаз БТГ/сборки/маршрута/подхода: новый squad отправляется к флагу сразу;
- `getFlagToCapture()` фактически выбирает случайный флаг; вычисленный `FlagPriority` при выборе цели не применяется;
- в логе 76 попыток engine-order `eLeave` (UKR=36, RUS=40), но `bot.lua` не вызывает eLeave явно. Это внутреннее поведение движка/другого игрового слоя, причём сообщения говорят `linked or inactive entity`, поэтому не считать их подтверждением успешной управляемой высадки;
- во время активного боя найдено 122 `can't spawn entity` для 42 разных entity names. Успешный `OnGameSpawn` не гарантирует, что все внутренние бойцы/состав squad созданы;
- текущий лог не содержит координатного трека squad, фактической дистанции, точки остановки или точного route. Для следующего теста нужна трассировка `squadId + unit + position + target + passengers + order state`.

Эти факты считать контрольной моделью поведения v1.0.0 при разработке следующих версий.

## 2026-09-17 — поиск прямого приказа движения

В `MocKBu41/Men-of-War-Assault-Squad-2` выполнены targeted Ghidra + независимый PE pointer-table pass для `ENGINE_BINARIES/mowas_2.exe`.

Подтверждено:
- строка `Move` существует в нескольких местах, но не подтверждена как Lua `BotApi.Commands:Move`; не использовать такой вызов без runtime-доказательства;
- реальные таблицы обработчиков найдены для `drop_orders`, `move_forward`, `move_backward`, `user_squad`, `eLeave`; tuple рядом со строкой указывает handler addresses/RVA: `drop_orders -> 0x3C2850`, `move_forward -> 0x3D1900`, `move_backward -> 0x3D1920`, `user_squad -> 0x3D1F10`, `eLeave -> 0x4D7660`; `attackhere` имеет соседний handler candidate `0x386874`;
- НЕ ставить INT3 hooks на эти RVA пока не проверены runtime-байты: on-disk `.text` защищён/обфусцирован. Ghidra по этим адресам показывает bad instruction data/невозможный control flow, поэтому статическая декомпиляция не подтверждает function entry/signature;
- в строках движка присутствует `eOrderMovement.cpp`, поэтому внутренний Order::Movement слой существует и является главным кандидатом для восстановления координатного приказа;
- создан `RUNTIME_IMAGE_DUMP` в репозитории оригинальной игры: Win32 DLL + injector перестраивают только основной runtime-образ `mowas_2.exe` (~13 МБ) в `%TEMP%/MOWAS2_RUNTIME_REBUILT_<PID>.exe`, без полного process dump на 3.5 ГБ. GitHub Actions build `MOWAS2-Runtime-Image-Dump-Win32` успешно проходит.

Следующий шаг: запустить runtime dumper на оригинальной игре в главном меню/локальном матче, получить `MOWAS2_RUNTIME_REBUILT_<PID>.exe` + `.txt`, затем повторить Ghidra/XREF по уже runtime-коду для `eOrderMovement`, handler RVA и восстановления сигнатуры/аргументов координатного движения.