# NEU GEM2 Bot Command Probe

Диагностический набор для выяснения, какие команды и функции доступны боту через скрипты GEM2 / Men of War: Assault Squad 2.

## Файлы

- `script/multiplayer/bot.command_probe.lua` — runtime-пробник внутри игры.
- `tools/scan_bot_commands.py` — офлайн-сканер распакованных скриптов игры/модов.

## Что делает runtime-пробник

1. Пытается перечислить видимые поля `BotApi`, `BotApi.Commands`, `BotApi.Scene`, `BotApi.Instance` и их доступные metatable/`__index` таблицы.
2. Ищет интересные глобальные функции по именам: `Squad`, `Actor`, `Entity`, `Vehicle`, `Move`, `Order`, `Attack`, `Capture`, `Spawn`, `Target`, `Formation`, `Stance`, `Load/Unload`, `Crew` и т.п.
3. Статически проверяет известные Lua-файлы NEU и записывает найденные вызовы API.
4. Пытается безопасно обернуть доступные функции `BotApi.Commands`, чтобы каждый реальный вызов бота появился в `game.log` как:

```text
[NEU-CMD-PROBE] CALL BotApi.Commands:CaptureFlag(...)
[NEU-CMD-PROBE] CALL BotApi.Commands:Spawn(...)
```

5. Никогда автоматически не запускает неизвестную команду. Это важно, потому что неизвестный вызов может изменить состояние боя или привести к ошибке движка.

## Подключение

В точке входа бота перед загрузкой основной логики:

```lua
local okProbe, probe = pcall(require, [[/script/multiplayer/bot.command_probe]])
if okProbe and type(probe) == 'table' and type(probe.install) == 'function' then
    pcall(probe.install)
end
```

После этого обычный бот продолжает загружаться как раньше.

## Что искать в game.log

Фильтр:

```text
NEU-CMD-PROBE
```

Основные строки:

- `FOUND` — обнаруженный API/member/global.
- `HOOKED` — функция `BotApi.Commands`, которую удалось обернуть для трассировки.
- `CALL` — реальный вызов команды ботом во время боя.
- `COMMAND NAMES` — сводный список обнаруженных команд.
- `ENUM unavailable` — объект движка является userdata/закрытым объектом и не разрешает перечисление из Lua.

Даже если `BotApi.Commands` нельзя полностью перечислить, статический скан и обнаруженные metatable/global-функции всё равно останутся в логе.

## Офлайн-скан всех распакованных скриптов

Для максимального покрытия нужно сканировать не только NEU, но и распакованные скрипты оригинальной игры и Cold War.

Пример:

```powershell
python tools\scan_bot_commands.py D:\GPT_NEU --out D:\GPT_NEU\gem2_command_scan
python tools\scan_bot_commands.py D:\COLDWAR-MOD- --out D:\COLDWAR-MOD-\gem2_command_scan
```

Результат:

- `gem2_command_scan.json` — машинный каталог команд с файлами и строками.
- `gem2_command_scan.txt` — удобный текстовый отчёт.

Сканер ищет `BotApi.Commands:*`, `BotApi.Scene:*`, `BotApi.Instance:*`, `md*`, `Squad*`, `Actor*`, `Entity*`, `Vehicle*`, `NEU_Engine*` и похожие функции движения/приказов.

## Ручное испытание конкретной найденной команды

Runtime-модуль содержит функцию:

```lua
NEU_COMMAND_PROBE.test("ИмяКоманды", аргумент1, аргумент2)
```

Она предназначена только для осознанного теста уже найденной функции. Пробник сам её не вызывает.

## Ограничение

Lua-скрипт не может гарантированно показать нативные C++ функции, которые движок вообще не экспортирует в Lua. Поэтому полный поиск делается в два этапа: runtime Lua probe + статический поиск по распакованным игровым скриптам. Если функция существует только внутри `mowas_2.exe`, для неё нужен отдельный низкоуровневый trace/bridge.
