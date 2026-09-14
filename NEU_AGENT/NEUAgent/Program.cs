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
    private readonly TextBox workspaceBox = new() { Dock = DockStyle.Fill };
    private readonly TextBox taskBox = new() { Dock = DockStyle.Fill, Multiline = true, ScrollBars = ScrollBars.Vertical };
    private readonly RichTextBox outputBox = new() { Dock = DockStyle.Fill, ReadOnly = true, Font = new Font("Consolas", 9F) };
    private readonly Label statusLabel = new() { AutoSize = true, Text = "Готов" };
    private readonly CheckBox snapshotCheck = new() { Text = "Git snapshot перед задачей", Checked = true, AutoSize = true };
    private readonly Button runButton = new() { Text = "▶ Выполнить задачу", AutoSize = true };
    private readonly Button stopButton = new() { Text = "■ Стоп", AutoSize = true, Enabled = false };
    private Process? activeProcess;
    private readonly string settingsPath;

    public MainForm()
    {
        Text = "NEU Agent";
        Width = 1100;
        Height = 760;
        MinimumSize = new Size(850, 600);
        StartPosition = FormStartPosition.CenterScreen;

        settingsPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "NEUAgent", "settings.json");

        var root = new TableLayoutPanel { Dock = DockStyle.Fill, RowCount = 5, ColumnCount = 1, Padding = new Padding(10) };
        root.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        root.RowStyles.Add(new RowStyle(SizeType.Absolute, 150));
        root.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        root.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        root.RowStyles.Add(new RowStyle(SizeType.AutoSize));

        var pathRow = new TableLayoutPanel { Dock = DockStyle.Fill, AutoSize = true, ColumnCount = 4 };
        pathRow.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        pathRow.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        pathRow.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        pathRow.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        pathRow.Controls.Add(new Label { Text = "Папка проекта:", AutoSize = true, Anchor = AnchorStyles.Left }, 0, 0);
        pathRow.Controls.Add(workspaceBox, 1, 0);
        var browse = new Button { Text = "Обзор…", AutoSize = true };
        browse.Click += (_, _) => BrowseWorkspace();
        pathRow.Controls.Add(browse, 2, 0);
        var check = new Button { Text = "Проверить", AutoSize = true };
        check.Click += async (_, _) => await CheckEnvironmentAsync();
        pathRow.Controls.Add(check, 3, 0);
        root.Controls.Add(pathRow, 0, 0);

        var taskPanel = new GroupBox { Text = "Задача агенту", Dock = DockStyle.Fill, Padding = new Padding(8) };
        taskPanel.Controls.Add(taskBox);
        taskBox.Text = "Проанализируй текущий проект NEU, используй существующие наработки и логи из папки LOG. Внеси нужные исправления, не переписывай рабочие части с нуля. После изменений проверь код и кратко опиши, что изменено.";
        root.Controls.Add(taskPanel, 0, 1);

        var buttons = new FlowLayoutPanel { Dock = DockStyle.Fill, AutoSize = true, WrapContents = true };
        runButton.Click += async (_, _) => await RunAgentAsync();
        stopButton.Click += (_, _) => StopActiveProcess();
        buttons.Controls.Add(runButton);
        buttons.Controls.Add(stopButton);
        buttons.Controls.Add(snapshotCheck);

        AddButton(buttons, "Анализ последнего боя", async () => await AnalyzeLatestLogAsync());
        AddButton(buttons, "Git snapshot", async () => await GitSnapshotAsync("manual snapshot"));
        AddButton(buttons, "Git pull", async () => await RunGitAsync("pull --ff-only"));
        AddButton(buttons, "Git push", async () => await RunGitAsync("push"));
        AddButton(buttons, "Открыть LOG", () => { OpenSubfolder("LOG"); return Task.CompletedTask; });
        AddButton(buttons, "Открыть проект", () => { OpenFolder(CurrentWorkspace); return Task.CompletedTask; });
        root.Controls.Add(buttons, 0, 2);

        var outputPanel = new GroupBox { Text = "Журнал", Dock = DockStyle.Fill, Padding = new Padding(8) };
        outputPanel.Controls.Add(outputBox);
        root.Controls.Add(outputPanel, 0, 3);

        var statusRow = new FlowLayoutPanel { Dock = DockStyle.Fill, AutoSize = true };
        statusRow.Controls.Add(new Label { Text = "Статус:", AutoSize = true, Font = new Font(Font, FontStyle.Bold) });
        statusRow.Controls.Add(statusLabel);
        root.Controls.Add(statusRow, 0, 4);

        Controls.Add(root);
        Load += async (_, _) => { LoadSettings(); await CheckEnvironmentAsync(); };
        FormClosing += (_, _) => { SaveSettings(); StopActiveProcess(); };
    }

    private string CurrentWorkspace => workspaceBox.Text.Trim().Trim('"');

    private static void AddButton(FlowLayoutPanel panel, string text, Func<Task> action)
    {
        var b = new Button { Text = text, AutoSize = true };
        b.Click += async (_, _) => await action();
        panel.Controls.Add(b);
    }

    private void BrowseWorkspace()
    {
        using var dlg = new FolderBrowserDialog { Description = "Выберите корневую папку NEU", UseDescriptionForTitle = true };
        if (Directory.Exists(CurrentWorkspace)) dlg.SelectedPath = CurrentWorkspace;
        if (dlg.ShowDialog(this) == DialogResult.OK)
        {
            workspaceBox.Text = dlg.SelectedPath;
            SaveSettings();
        }
    }

    private async Task CheckEnvironmentAsync()
    {
        Append("=== Проверка окружения ===");
        var git = await CaptureAsync("git", "--version", Environment.CurrentDirectory);
        Append(git.Success ? $"Git: {git.StdOut.Trim()}" : "Git: НЕ НАЙДЕН");
        var codex = await CaptureAsync("codex", "--version", Environment.CurrentDirectory);
        Append(codex.Success ? $"Codex: {codex.StdOut.Trim()}" : "Codex: НЕ НАЙДЕН. Установите официальный Codex CLI и выполните вход.");
        if (Directory.Exists(CurrentWorkspace))
            Append($"Проект: OK — {CurrentWorkspace}");
        else
            Append("Проект: выберите существующую папку.");
    }

    private async Task RunAgentAsync()
    {
        if (!ValidateWorkspace()) return;
        if (string.IsNullOrWhiteSpace(taskBox.Text)) { MessageBox.Show("Введите задачу."); return; }

        SaveSettings();
        if (snapshotCheck.Checked)
            await GitSnapshotAsync("auto snapshot before agent task");

        string prompt = BuildPrompt(taskBox.Text.Trim());
        Append("\n=== Запуск Codex ===");
        Append($"Рабочая папка: {CurrentWorkspace}");
        SetBusy(true, "Codex выполняет задачу…");

        try
        {
            var psi = new ProcessStartInfo("codex")
            {
                WorkingDirectory = CurrentWorkspace,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true
            };
            psi.ArgumentList.Add("--cd");
            psi.ArgumentList.Add(CurrentWorkspace);
            psi.ArgumentList.Add("--ask-for-approval");
            psi.ArgumentList.Add("never");
            psi.ArgumentList.Add("--sandbox");
            psi.ArgumentList.Add("workspace-write");
            psi.ArgumentList.Add("exec");
            psi.ArgumentList.Add(prompt);

            activeProcess = new Process { StartInfo = psi, EnableRaisingEvents = true };
            activeProcess.OutputDataReceived += (_, e) => { if (e.Data != null) Append(e.Data); };
            activeProcess.ErrorDataReceived += (_, e) => { if (e.Data != null) Append("[ERR] " + e.Data); };
            activeProcess.Start();
            activeProcess.BeginOutputReadLine();
            activeProcess.BeginErrorReadLine();
            await activeProcess.WaitForExitAsync();
            Append($"=== Codex завершён, код {activeProcess.ExitCode} ===");
        }
        catch (Exception ex)
        {
            Append("Ошибка запуска Codex: " + ex.Message);
            MessageBox.Show("Не удалось запустить Codex. Проверьте, что команда 'codex' доступна в PATH.", "NEU Agent", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
        finally
        {
            activeProcess?.Dispose();
            activeProcess = null;
            SetBusy(false, "Готов");
        }
    }

    private string BuildPrompt(string userTask)
    {
        return $"""
Ты работаешь локально над проектом NEU / nobody-except-us-2.0.26.

Правила работы:
1. Сначала изучи существующий код и структуру проекта. Не переписывай рабочий код с нуля без необходимости.
2. Папка LOG является историей испытаний. При анализе боя сравнивай новый лог с предыдущими логами, если это полезно.
3. Сохраняй обратную совместимость с текущей логикой бота, если задача явно не требует её изменить.
4. Перед правками найди связанные файлы и места вызовов.
5. После правок выполни доступные локальные проверки/тесты. Не утверждай, что проверка прошла, если её не запускал.
6. Не удаляй пользовательские файлы и не меняй ничего за пределами текущего workspace.
7. Git push не выполняй: публикация делается отдельной кнопкой NEU Agent.
8. В конце дай краткий отчёт: изменённые файлы, причина изменений, результат проверки и что проверить в следующем игровом тесте.

Задача пользователя:
{userTask}
""";
    }

    private async Task AnalyzeLatestLogAsync()
    {
        if (!ValidateWorkspace()) return;
        string logDir = Path.Combine(CurrentWorkspace, "LOG");
        if (!Directory.Exists(logDir))
        {
            MessageBox.Show("В проекте нет папки LOG.");
            return;
        }
        var latest = new DirectoryInfo(logDir).GetFiles("*", SearchOption.TopDirectoryOnly)
            .OrderByDescending(f => f.LastWriteTimeUtc).FirstOrDefault();
        if (latest == null)
        {
            MessageBox.Show("Папка LOG пустая.");
            return;
        }
        taskBox.Text = $"Проанализируй последний бой по файлу LOG/{latest.Name}. Сравни его с предыдущими логами в LOG. Найди ошибки загрузки, отсутствие точек/линий движения, остановки отрядов, проблемы вызова пехоты, высадки и выбора целей. Если причина находится в коде проекта — исправь её минимальными изменениями и подготовь список того, что нужно проверить в следующем бою.";
        await RunAgentAsync();
    }

    private async Task GitSnapshotAsync(string reason)
    {
        if (!ValidateWorkspace(silent: true)) return;
        var inside = await CaptureAsync("git", "rev-parse --is-inside-work-tree", CurrentWorkspace);
        if (!inside.Success) { Append("Git snapshot: папка не является Git-репозиторием."); return; }

        var status = await CaptureAsync("git", "status --porcelain", CurrentWorkspace);
        if (!status.Success || string.IsNullOrWhiteSpace(status.StdOut))
        {
            Append("Git snapshot: изменений нет.");
            return;
        }

        await RunGitAsync("add -A", quietSuccess: true);
        string stamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
        var commit = await CaptureAsync("git", $"commit -m \"NEU Agent: {reason} {stamp}\"", CurrentWorkspace);
        Append(commit.Success ? "Git snapshot создан." : "Git snapshot: " + (commit.StdErr + commit.StdOut).Trim());
    }

    private async Task RunGitAsync(string args, bool quietSuccess = false)
    {
        if (!ValidateWorkspace()) return;
        Append($"> git {args}");
        var r = await CaptureAsync("git", args, CurrentWorkspace);
        if (!quietSuccess || !r.Success)
        {
            if (!string.IsNullOrWhiteSpace(r.StdOut)) Append(r.StdOut.TrimEnd());
            if (!string.IsNullOrWhiteSpace(r.StdErr)) Append("[ERR] " + r.StdErr.TrimEnd());
        }
        if (r.Success && !quietSuccess) Append("OK");
    }

    private static async Task<(bool Success, string StdOut, string StdErr)> CaptureAsync(string file, string args, string cwd)
    {
        try
        {
            var psi = new ProcessStartInfo(file, args)
            {
                WorkingDirectory = cwd,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true
            };
            using var p = Process.Start(psi)!;
            string stdout = await p.StandardOutput.ReadToEndAsync();
            string stderr = await p.StandardError.ReadToEndAsync();
            await p.WaitForExitAsync();
            return (p.ExitCode == 0, stdout, stderr);
        }
        catch (Exception ex) { return (false, "", ex.Message); }
    }

    private bool ValidateWorkspace(bool silent = false)
    {
        if (Directory.Exists(CurrentWorkspace)) return true;
        if (!silent) MessageBox.Show("Сначала выберите существующую папку проекта.", "NEU Agent");
        return false;
    }

    private void StopActiveProcess()
    {
        try
        {
            if (activeProcess is { HasExited: false })
            {
                activeProcess.Kill(entireProcessTree: true);
                Append("Процесс остановлен пользователем.");
            }
        }
        catch { }
    }

    private void SetBusy(bool busy, string status)
    {
        if (InvokeRequired) { BeginInvoke(() => SetBusy(busy, status)); return; }
        runButton.Enabled = !busy;
        stopButton.Enabled = busy;
        statusLabel.Text = status;
    }

    private void Append(string text)
    {
        if (InvokeRequired) { BeginInvoke(() => Append(text)); return; }
        outputBox.AppendText($"[{DateTime.Now:HH:mm:ss}] {text}{Environment.NewLine}");
        outputBox.SelectionStart = outputBox.TextLength;
        outputBox.ScrollToCaret();
    }

    private void OpenSubfolder(string name)
    {
        if (!ValidateWorkspace()) return;
        var path = Path.Combine(CurrentWorkspace, name);
        if (!Directory.Exists(path)) Directory.CreateDirectory(path);
        OpenFolder(path);
    }

    private static void OpenFolder(string path)
    {
        if (!Directory.Exists(path)) return;
        Process.Start(new ProcessStartInfo("explorer.exe", $"\"{path}\"") { UseShellExecute = true });
    }

    private void LoadSettings()
    {
        try
        {
            if (!File.Exists(settingsPath)) return;
            var s = JsonSerializer.Deserialize<SettingsModel>(File.ReadAllText(settingsPath));
            if (s == null) return;
            workspaceBox.Text = s.Workspace;
            snapshotCheck.Checked = s.AutoSnapshot;
        }
        catch { }
    }

    private void SaveSettings()
    {
        try
        {
            Directory.CreateDirectory(Path.GetDirectoryName(settingsPath)!);
            var s = new SettingsModel { Workspace = CurrentWorkspace, AutoSnapshot = snapshotCheck.Checked };
            File.WriteAllText(settingsPath, JsonSerializer.Serialize(s, new JsonSerializerOptions { WriteIndented = true }));
        }
        catch { }
    }
}
