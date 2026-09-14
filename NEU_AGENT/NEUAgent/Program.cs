using System.Diagnostics;
using System.Text.Json;

namespace NEUAgent;

internal sealed class SettingsModel
{
    public string Workspace { get; set; } = "";
    public bool AutoSnapshot { get; set; } = true;
}

internal static class Program
{
    [STAThread]
    static void Main()
    {
        ApplicationConfiguration.Initialize();
        Application.Run(new MainForm());
    }
}

internal sealed class MainForm : Form
{
    private const string AppVersion = "0.2.0";
    private readonly TextBox workspaceBox = new() { Dock = DockStyle.Fill };
    private readonly TextBox taskBox = new() { Dock = DockStyle.Fill, Multiline = true, ScrollBars = ScrollBars.Vertical };
    private readonly RichTextBox outputBox = new() { Dock = DockStyle.Fill, ReadOnly = true, Font = new Font("Consolas", 9F) };
    private readonly Label statusLabel = new() { AutoSize = true, Text = "Готов" };
    private readonly Label environmentLabel = new() { AutoSize = true, Text = "Окружение ещё не проверено", Padding = new Padding(4, 7, 4, 4) };
    private readonly CheckBox snapshotCheck = new() { Text = "Git snapshot перед задачей", Checked = true, AutoSize = true };
    private readonly Button runButton = new() { Text = "▶ Выполнить задачу", AutoSize = true };
    private readonly Button stopButton = new() { Text = "■ Стоп", AutoSize = true, Enabled = false };
    private readonly Button setupButton = new() { Text = "⬇ Установить Node.js + Codex", AutoSize = true };
    private readonly Button loginButton = new() { Text = "Войти в ChatGPT", AutoSize = true };
    private readonly Button envCheckButton = new() { Text = "Проверить окружение", AutoSize = true };
    private Process? activeProcess;
    private readonly string settingsPath;
    private string? resolvedCodexPath;
    private string? resolvedNpmPath;

    public MainForm()
    {
        Text = $"NEU Agent v{AppVersion}";
        Width = 1160; Height = 800; MinimumSize = new Size(900, 640); StartPosition = FormStartPosition.CenterScreen;
        settingsPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "NEUAgent", "settings.json");
        var root = new TableLayoutPanel { Dock = DockStyle.Fill, RowCount = 6, ColumnCount = 1, Padding = new Padding(10) };
        root.RowStyles.Add(new RowStyle(SizeType.AutoSize)); root.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        root.RowStyles.Add(new RowStyle(SizeType.Absolute, 150)); root.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        root.RowStyles.Add(new RowStyle(SizeType.Percent, 100)); root.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        var pathRow = new TableLayoutPanel { Dock = DockStyle.Fill, AutoSize = true, ColumnCount = 3 };
        pathRow.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize)); pathRow.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100)); pathRow.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        pathRow.Controls.Add(new Label { Text = "Папка проекта:", AutoSize = true, Anchor = AnchorStyles.Left }, 0, 0); pathRow.Controls.Add(workspaceBox, 1, 0);
        var browse = new Button { Text = "Обзор…", AutoSize = true }; browse.Click += (_, _) => BrowseWorkspace(); pathRow.Controls.Add(browse, 2, 0); root.Controls.Add(pathRow, 0, 0);
        var setupPanel = new GroupBox { Text = "Первоначальная настройка", Dock = DockStyle.Fill, AutoSize = true, Padding = new Padding(8) };
        var setupFlow = new FlowLayoutPanel { Dock = DockStyle.Fill, AutoSize = true, WrapContents = true };
        setupButton.Click += async (_, _) => await InstallEnvironmentAsync(); loginButton.Click += async (_, _) => await LoginChatGptAsync(); envCheckButton.Click += async (_, _) => await CheckEnvironmentAsync();
        setupFlow.Controls.Add(setupButton); setupFlow.Controls.Add(loginButton); setupFlow.Controls.Add(envCheckButton); setupFlow.Controls.Add(environmentLabel); setupPanel.Controls.Add(setupFlow); root.Controls.Add(setupPanel, 0, 1);
        var taskPanel = new GroupBox { Text = "Задача агенту", Dock = DockStyle.Fill, Padding = new Padding(8) }; taskPanel.Controls.Add(taskBox);
        taskBox.Text = "Проанализируй текущий проект NEU, используй существующие наработки и логи из папки LOG. Внеси нужные исправления, не переписывай рабочие части с нуля. После изменений проверь код и кратко опиши, что изменено."; root.Controls.Add(taskPanel, 0, 2);
        var buttons = new FlowLayoutPanel { Dock = DockStyle.Fill, AutoSize = true, WrapContents = true };
        runButton.Click += async (_, _) => await RunAgentAsync(); stopButton.Click += (_, _) => StopActiveProcess(); buttons.Controls.Add(runButton); buttons.Controls.Add(stopButton); buttons.Controls.Add(snapshotCheck);
        AddButton(buttons, "Анализ последнего боя", AnalyzeLatestLogAsync); AddButton(buttons, "Git snapshot", () => GitSnapshotAsync("manual snapshot")); AddButton(buttons, "Git pull", () => RunGitAsync("pull --ff-only")); AddButton(buttons, "Git push", () => RunGitAsync("push"));
        AddButton(buttons, "Открыть LOG", () => { OpenSubfolder("LOG"); return Task.CompletedTask; }); AddButton(buttons, "Открыть проект", () => { OpenFolder(CurrentWorkspace); return Task.CompletedTask; }); root.Controls.Add(buttons, 0, 3);
        var outputPanel = new GroupBox { Text = "Журнал", Dock = DockStyle.Fill, Padding = new Padding(8) }; outputPanel.Controls.Add(outputBox); root.Controls.Add(outputPanel, 0, 4);
        var statusRow = new FlowLayoutPanel { Dock = DockStyle.Fill, AutoSize = true }; statusRow.Controls.Add(new Label { Text = "Статус:", AutoSize = true, Font = new Font(Font, FontStyle.Bold) }); statusRow.Controls.Add(statusLabel); statusRow.Controls.Add(new Label { Text = $"   NEU Agent v{AppVersion}", AutoSize = true }); root.Controls.Add(statusRow, 0, 5);
        Controls.Add(root); Load += async (_, _) => { LoadSettings(); await CheckEnvironmentAsync(); }; FormClosing += (_, _) => { SaveSettings(); StopActiveProcess(); };
    }

    private string CurrentWorkspace => workspaceBox.Text.Trim().Trim('"');
    private static void AddButton(FlowLayoutPanel p, string t, Func<Task> a) { var b = new Button { Text = t, AutoSize = true }; b.Click += async (_, _) => await a(); p.Controls.Add(b); }
    private void BrowseWorkspace() { using var d = new FolderBrowserDialog { Description = "Выберите корневую папку NEU", UseDescriptionForTitle = true }; if (Directory.Exists(CurrentWorkspace)) d.SelectedPath = CurrentWorkspace; if (d.ShowDialog(this) == DialogResult.OK) { workspaceBox.Text = d.SelectedPath; SaveSettings(); } }

    private async Task CheckEnvironmentAsync()
    {
        RefreshProcessPath(); Append("=== Проверка окружения ===");
        var git = await CaptureAsync("git", "--version", Environment.CurrentDirectory); Append(git.Success ? $"Git: {git.Out.Trim()}" : "Git: НЕ НАЙДЕН");
        resolvedNpmPath = await ResolveNpmAsync(); string node = "npm: НЕ НАЙДЕН";
        if (resolvedNpmPath != null) { var n = await CaptureAsync(resolvedNpmPath, "--version", Environment.CurrentDirectory); node = n.Success ? $"npm {n.Out.Trim()}" : "npm найден, но не запускается"; Append(node); } else Append("Node.js/npm: НЕ НАЙДЕН. Нажмите «Установить Node.js + Codex».");
        resolvedCodexPath = await ResolveCodexAsync(); string codex = "Codex: НЕ НАЙДЕН", auth = "Вход: недоступен";
        if (resolvedCodexPath != null) { var v = await CaptureAsync(resolvedCodexPath, "--version", Environment.CurrentDirectory); codex = v.Success ? v.Out.Trim() : "Codex найден, но не запускается"; Append("Codex: " + codex); var l = await CaptureAsync(resolvedCodexPath, "login status", Environment.CurrentDirectory); string s = (l.Out + l.Err).Trim(); auth = l.Success ? s.Replace(Environment.NewLine, " ") : "НЕ ВЫПОЛНЕН"; Append(l.Success ? "Авторизация: " + auth : "Авторизация: НЕ ВЫПОЛНЕНА. Нажмите «Войти в ChatGPT»."); }
        else Append("Codex: НЕ НАЙДЕН. Нажмите «Установить Node.js + Codex».");
        environmentLabel.Text = $"Git: {(git.Success ? "OK" : "нет")} | {node} | {codex} | {auth}"; Append(Directory.Exists(CurrentWorkspace) ? $"Проект: OK — {CurrentWorkspace}" : "Проект: выберите существующую папку.");
    }

    private async Task InstallEnvironmentAsync()
    {
        SetSetupBusy(true, "Установка окружения…");
        try
        {
            RefreshProcessPath(); Append("=== Автоматическая установка Node.js + Codex ==="); resolvedNpmPath = await ResolveNpmAsync();
            if (resolvedNpmPath == null)
            {
                var wg = await CaptureAsync("winget", "--version", Environment.CurrentDirectory);
                if (!wg.Success) { Append("WinGet не найден. Открываю официальный сайт Node.js."); if (MessageBox.Show("WinGet не найден. Открыть страницу Node.js?", "NEU Agent", MessageBoxButtons.YesNo) == DialogResult.Yes) OpenUrl("https://nodejs.org/en/download"); return; }
                Append("Устанавливаю Node.js LTS через WinGet…");
                int code = await StreamAsync("winget", "install --id OpenJS.NodeJS.LTS -e --source winget --accept-source-agreements --accept-package-agreements --silent", Environment.CurrentDirectory, "Установка Node.js LTS…");
                RefreshProcessPath(); resolvedNpmPath = await ResolveNpmAsync(); if (code != 0 || resolvedNpmPath == null) { MessageBox.Show("Node.js не удалось обнаружить после установки. Посмотрите журнал."); return; }
            }
            Append("Устанавливаю/обновляю OpenAI Codex CLI…");
            int ci = await StreamAsync(resolvedNpmPath, "install -g @openai/codex", Environment.CurrentDirectory, "Установка Codex CLI…"); RefreshProcessPath(); resolvedCodexPath = await ResolveCodexAsync();
            if (ci != 0 || resolvedCodexPath == null) { MessageBox.Show("Не удалось установить Codex CLI. Посмотрите журнал."); return; }
            var v = await CaptureAsync(resolvedCodexPath, "--version", Environment.CurrentDirectory); Append(v.Success ? "Codex установлен: " + v.Out.Trim() : "Codex установлен, но версия не определена."); await CheckEnvironmentAsync();
            var l = await CaptureAsync(resolvedCodexPath, "login status", Environment.CurrentDirectory); if (!l.Success && MessageBox.Show("Codex установлен. Войти в ChatGPT сейчас?", "NEU Agent", MessageBoxButtons.YesNo) == DialogResult.Yes) await LoginChatGptAsync();
        }
        finally { SetSetupBusy(false, "Готов"); }
    }

    private async Task LoginChatGptAsync()
    {
        RefreshProcessPath(); resolvedCodexPath = await ResolveCodexAsync(); if (resolvedCodexPath == null) { MessageBox.Show("Сначала установите Codex кнопкой «Установить Node.js + Codex»."); return; }
        var old = await CaptureAsync(resolvedCodexPath, "login status", Environment.CurrentDirectory); if (old.Success) { Append("Codex уже авторизован: " + (old.Out + old.Err).Trim()); MessageBox.Show("Codex уже вошёл в ChatGPT."); return; }
        Append("=== Вход в ChatGPT ==="); Append("Codex откроет браузер. Завершите вход в аккаунт ChatGPT."); SetSetupBusy(true, "Вход в ChatGPT…");
        try { int code = await StreamAsync(resolvedCodexPath, "login", Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), "Вход в ChatGPT…"); var c = await CaptureAsync(resolvedCodexPath, "login status", Environment.CurrentDirectory); if (code == 0 && c.Success) MessageBox.Show("Вход выполнен. NEU Agent готов к работе."); else MessageBox.Show("Вход не подтверждён. Нажмите «Войти в ChatGPT» ещё раз."); await CheckEnvironmentAsync(); }
        finally { SetSetupBusy(false, "Готов"); }
    }

    private async Task RunAgentAsync()
    {
        if (!ValidateWorkspace() || string.IsNullOrWhiteSpace(taskBox.Text)) return; RefreshProcessPath(); resolvedCodexPath = await ResolveCodexAsync(); if (resolvedCodexPath == null) { MessageBox.Show("Codex не установлен. Используйте кнопку установки."); return; }
        var l = await CaptureAsync(resolvedCodexPath, "login status", Environment.CurrentDirectory); if (!l.Success) { if (MessageBox.Show("Codex не авторизован. Войти сейчас?", "NEU Agent", MessageBoxButtons.YesNo) == DialogResult.Yes) await LoginChatGptAsync(); l = await CaptureAsync(resolvedCodexPath, "login status", Environment.CurrentDirectory); if (!l.Success) return; }
        SaveSettings(); if (snapshotCheck.Checked) await GitSnapshotAsync("auto snapshot before agent task"); string prompt = BuildPrompt(taskBox.Text.Trim()); Append("=== Запуск Codex ==="); SetBusy(true, "Codex выполняет задачу…");
        try { string args = $"--cd {Q(CurrentWorkspace)} --ask-for-approval never --sandbox workspace-write exec {Q(prompt)}"; int code = await StreamAsync(resolvedCodexPath, args, CurrentWorkspace, "Codex выполняет задачу…"); Append($"=== Codex завершён, код {code} ==="); }
        finally { SetBusy(false, "Готов"); }
    }

    private string BuildPrompt(string task) => $"""
Ты работаешь локально над проектом NEU / nobody-except-us-2.0.26.
Сначала изучи существующий код и структуру. Не переписывай рабочие части с нуля без необходимости.
Папка LOG — история испытаний; при анализе боя сравнивай новый лог с предыдущими.
Правь только текущий workspace, выполняй доступные проверки, не делай git push.
В конце перечисли изменённые файлы, причины, результат проверки и что проверить в следующем игровом тесте.
Задача пользователя: {task}
""";

    private async Task AnalyzeLatestLogAsync()
    {
        if (!ValidateWorkspace()) return; string dir = Path.Combine(CurrentWorkspace, "LOG"); if (!Directory.Exists(dir)) { MessageBox.Show("В проекте нет папки LOG."); return; }
        var f = new DirectoryInfo(dir).GetFiles("*").OrderByDescending(x => x.LastWriteTimeUtc).FirstOrDefault(); if (f == null) { MessageBox.Show("Папка LOG пустая."); return; }
        taskBox.Text = $"Проанализируй последний бой по LOG/{f.Name}. Сравни с предыдущими логами. Найди ошибки, отсутствие точек/линий движения, остановки отрядов, проблемы вызова пехоты, высадки и выбора целей. Если причина в коде — исправь минимально и подготовь проверку следующего боя."; await RunAgentAsync();
    }

    private async Task GitSnapshotAsync(string reason)
    {
        if (!ValidateWorkspace(true)) return; var inside = await CaptureAsync("git", "rev-parse --is-inside-work-tree", CurrentWorkspace); if (!inside.Success) { Append("Git snapshot: это не Git-репозиторий."); return; }
        var st = await CaptureAsync("git", "status --porcelain", CurrentWorkspace); if (!st.Success || string.IsNullOrWhiteSpace(st.Out)) { Append("Git snapshot: изменений нет."); return; }
        await RunGitAsync("add -A", true); var c = await CaptureAsync("git", $"commit -m \"NEU Agent: {reason} {DateTime.Now:yyyy-MM-dd HH:mm:ss}\"", CurrentWorkspace); Append(c.Success ? "Git snapshot создан." : "Git snapshot: " + (c.Err + c.Out).Trim());
    }

    private async Task RunGitAsync(string args, bool quiet = false)
    {
        if (!ValidateWorkspace()) return; Append("> git " + args); var r = await CaptureAsync("git", args, CurrentWorkspace); if (!quiet || !r.Success) { if (!string.IsNullOrWhiteSpace(r.Out)) Append(r.Out.TrimEnd()); if (!string.IsNullOrWhiteSpace(r.Err)) Append("[ERR] " + r.Err.TrimEnd()); } if (r.Success && !quiet) Append("OK");
    }

    private async Task<int> StreamAsync(string file, string args, string cwd, string status)
    {
        try { var psi = PSI(file, args, cwd, true); activeProcess = new Process { StartInfo = psi }; activeProcess.OutputDataReceived += (_, e) => { if (e.Data != null) Append(e.Data); }; activeProcess.ErrorDataReceived += (_, e) => { if (e.Data != null) Append("[ERR] " + e.Data); }; SetBusy(true, status); activeProcess.Start(); activeProcess.BeginOutputReadLine(); activeProcess.BeginErrorReadLine(); await activeProcess.WaitForExitAsync(); return activeProcess.ExitCode; }
        catch (Exception ex) { Append("Ошибка запуска: " + ex.Message); return -1; }
        finally { activeProcess?.Dispose(); activeProcess = null; }
    }

    private static async Task<(bool Success, string Out, string Err)> CaptureAsync(string file, string args, string cwd)
    {
        try { using var p = Process.Start(PSI(file, args, cwd, true))!; string o = await p.StandardOutput.ReadToEndAsync(), e = await p.StandardError.ReadToEndAsync(); await p.WaitForExitAsync(); return (p.ExitCode == 0, o, e); } catch (Exception ex) { return (false, "", ex.Message); }
    }

    private static ProcessStartInfo PSI(string file, string args, string cwd, bool redirect)
    {
        if (file.EndsWith(".cmd", StringComparison.OrdinalIgnoreCase) || file.EndsWith(".bat", StringComparison.OrdinalIgnoreCase)) { string cmd = $"\"{file}\"" + (string.IsNullOrWhiteSpace(args) ? "" : " " + args); return new ProcessStartInfo("cmd.exe", $"/d /s /c \"{cmd}\"") { WorkingDirectory = cwd, UseShellExecute = false, RedirectStandardOutput = redirect, RedirectStandardError = redirect, CreateNoWindow = true }; }
        return new ProcessStartInfo(file, args) { WorkingDirectory = cwd, UseShellExecute = false, RedirectStandardOutput = redirect, RedirectStandardError = redirect, CreateNoWindow = true };
    }

    private static string Q(string v) => "\"" + v.Replace("\"", "\\\"") + "\"";
    private async Task<string?> ResolveNpmAsync() => await ResolveAsync(new[] { "npm.cmd", "npm" }, new[] { Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles), "nodejs", "npm.cmd"), Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "Programs", "nodejs", "npm.cmd") });
    private async Task<string?> ResolveCodexAsync() => await ResolveAsync(new[] { "codex.cmd", "codex.exe", "codex" }, new[] { Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "npm", "codex.cmd"), Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "npm", "codex.exe") });
    private static async Task<string?> ResolveAsync(string[] commands, string[] candidates) { foreach (var c in commands) { var r = await CaptureAsync("where.exe", c, Environment.CurrentDirectory); if (r.Success) foreach (var line in r.Out.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries)) { var p = line.Trim().Trim('"'); if (File.Exists(p)) return p; } } return candidates.FirstOrDefault(File.Exists); }
    private static void RefreshProcessPath() { try { string m = Environment.GetEnvironmentVariable("PATH", EnvironmentVariableTarget.Machine) ?? "", u = Environment.GetEnvironmentVariable("PATH", EnvironmentVariableTarget.User) ?? "", p = Environment.GetEnvironmentVariable("PATH", EnvironmentVariableTarget.Process) ?? ""; Environment.SetEnvironmentVariable("PATH", string.Join(';', (m + ";" + u + ";" + p).Split(';', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries).Distinct(StringComparer.OrdinalIgnoreCase)), EnvironmentVariableTarget.Process); } catch { } }
    private bool ValidateWorkspace(bool silent = false) { if (Directory.Exists(CurrentWorkspace)) return true; if (!silent) MessageBox.Show("Сначала выберите существующую папку проекта."); return false; }
    private void StopActiveProcess() { try { if (activeProcess is { HasExited: false }) { activeProcess.Kill(true); Append("Процесс остановлен пользователем."); } } catch { } }
    private void SetBusy(bool busy, string status) { if (InvokeRequired) { BeginInvoke(() => SetBusy(busy, status)); return; } runButton.Enabled = !busy; stopButton.Enabled = busy; statusLabel.Text = status; }
    private void SetSetupBusy(bool busy, string status) { setupButton.Enabled = !busy; loginButton.Enabled = !busy; envCheckButton.Enabled = !busy; SetBusy(busy, status); }
    private void Append(string text) { if (InvokeRequired) { BeginInvoke(() => Append(text)); return; } outputBox.AppendText($"[{DateTime.Now:HH:mm:ss}] {text}{Environment.NewLine}"); outputBox.SelectionStart = outputBox.TextLength; outputBox.ScrollToCaret(); }
    private void OpenSubfolder(string name) { if (!ValidateWorkspace()) return; var p = Path.Combine(CurrentWorkspace, name); Directory.CreateDirectory(p); OpenFolder(p); }
    private static void OpenFolder(string p) { if (Directory.Exists(p)) Process.Start(new ProcessStartInfo("explorer.exe", $"\"{p}\"") { UseShellExecute = true }); }
    private static void OpenUrl(string u) => Process.Start(new ProcessStartInfo(u) { UseShellExecute = true });
    private void LoadSettings() { try { if (!File.Exists(settingsPath)) return; var s = JsonSerializer.Deserialize<SettingsModel>(File.ReadAllText(settingsPath)); if (s != null) { workspaceBox.Text = s.Workspace; snapshotCheck.Checked = s.AutoSnapshot; } } catch { } }
    private void SaveSettings() { try { Directory.CreateDirectory(Path.GetDirectoryName(settingsPath)!); File.WriteAllText(settingsPath, JsonSerializer.Serialize(new SettingsModel { Workspace = CurrentWorkspace, AutoSnapshot = snapshotCheck.Checked }, new JsonSerializerOptions { WriteIndented = true })); } catch { } }
}
