# NEU Agent

Windows GUI-агент для локальной разработки **Nobody Except Us / NEU**.

## Что умеет

- выбирает локальную папку проекта;
- запускает OpenAI Codex CLI в режиме `workspace-write`;
- перед задачей может автоматически создавать Git snapshot;
- анализирует последний файл в `LOG` и сравнивает его с предыдущими логами;
- отдельные кнопки `git pull`, `git push`, `Git snapshot`;
- журнал вывода Codex прямо в окне;
- останавливает текущую задачу;
- не передаёт Codex право записи за пределами выбранной папки проекта.

## Требования на ПК

1. Windows 11 x64.
2. Git в `PATH`.
3. OpenAI Codex CLI в `PATH` и выполненный вход в Codex.

Проверка:

```powershell
git --version
codex --version
```

## Сборка

```powershell
dotnet publish .\NEUAgent\NEUAgent.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true
```

Готовый EXE будет в каталоге:

`NEUAgent\bin\Release\net8.0-windows\win-x64\publish\NEU-Agent.exe`

Также репозиторий содержит GitHub Actions workflow, который собирает ZIP с EXE на Windows runner.

## Безопасность

Codex запускается non-interactive с `--sandbox workspace-write` и `--ask-for-approval never`. Это позволяет агенту автономно работать внутри проекта, не давая ему запись по всему диску. Сетевые Git-операции вынесены в отдельные кнопки интерфейса.
