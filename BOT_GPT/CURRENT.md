# Текущая версия NEU BOT

Текущая версия для следующего игрового теста: **`BOT_GPT/v2_0_1/`**.

Статус: **НУЖЕН ТЕСТ**.

`BOT_GPT/v2_0/` признан ошибочным по `LOG/game_bot 2.0.log`: потеряны подписки `BotApi.Events:Subscribe(...)`, поэтому игровая логика не запускалась. Также пакет потерял визуализатор и координатные данные.

В 2.0.1 возвращены lifecycle subscriptions, `bot_visualizer.html`, `_flag_points_final.json`, `_map_points_index.json`, `_spawn_points_index.json`.

Перед любым изменением поведения читать `BOT_MEMORY/BOT_LOGIC_CURRENT.json` и вносить изменение туда одновременно с кодом.
