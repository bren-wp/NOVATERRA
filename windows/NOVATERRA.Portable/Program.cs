using System.Diagnostics;
using System.Drawing;
using System.IO.Compression;
using System.Reflection;
using System.Security.Cryptography;
using System.Windows.Forms;

namespace Novaterra.Portable;

/// <summary>
/// Self-contained game bundle. Unpacks the verified embedded Luanti runtime on
/// first launch and keeps game saves outside of the replaceable runtime folder.
/// </summary>
internal static class Program
{
    [STAThread]
    private static int Main(string[] args)
    {
        ApplicationConfiguration.Initialize();
        using var window = new StartupWindow(args);
        Application.Run(window);
        return window.ExitCode;
    }
}

internal sealed class StartupWindow : Form
{
    private readonly string[] _args;
    private readonly Label _status;
    private readonly ProgressBar _progress;

    public int ExitCode { get; private set; } = 1;

    public StartupWindow(string[] args)
    {
        _args = args;
        Text = "NOVATERRA";
        ClientSize = new Size(560, 240);
        StartPosition = FormStartPosition.CenterScreen;
        FormBorderStyle = FormBorderStyle.FixedDialog;
        MaximizeBox = false;
        MinimizeBox = false;
        ShowIcon = false;
        BackColor = Color.FromArgb(12, 25, 32);
        ForeColor = Color.FromArgb(240, 222, 186);

        var brand = new Label
        {
            Text = "NOVATERRA",
            Font = new Font("Segoe UI", 29, FontStyle.Bold),
            ForeColor = Color.FromArgb(229, 193, 123),
            Location = new Point(32, 25),
            AutoSize = true,
        };
        Controls.Add(brand);
        Controls.Add(new Label
        {
            Text = "BUILD  ·  EXPLORE  ·  SURVIVE  ·  THRIVE",
            Font = new Font("Segoe UI", 10, FontStyle.Regular),
            ForeColor = Color.FromArgb(192, 210, 205),
            Location = new Point(36, 92),
            AutoSize = true,
        });
        _status = new Label
        {
            Text = "Preparing your adventure...",
            Font = new Font("Segoe UI", 10),
            ForeColor = Color.WhiteSmoke,
            Location = new Point(36, 145),
            Width = 490,
            Height = 24,
        };
        Controls.Add(_status);
        _progress = new ProgressBar
        {
            Minimum = 0,
            Maximum = 100,
            Style = ProgressBarStyle.Continuous,
            Location = new Point(36, 186),
            Size = new Size(486, 11),
        };
        Controls.Add(_progress);
        Shown += async (_, _) => await LaunchAsync();
    }

    private async Task LaunchAsync()
    {
        try
        {
            var root = ChooseWritableRoot();
            var progress = new Progress<int>(value =>
            {
                if (!IsDisposed)
                {
                    _progress.Value = Math.Clamp(value, 0, 100);
                    _status.Text = value < 100 ? $"Preparing game files... {value}%" : "Launching NOVATERRA...";
                }
            });

            string runtime = await Task.Run(() => PrepareBundle(root, progress));
            var saves = Path.Combine(root, "Data");
            Directory.CreateDirectory(saves);

            string launcher = Path.Combine(runtime, "NOVATERRA.exe");
            var info = new ProcessStartInfo(launcher)
            {
                UseShellExecute = false,
                WorkingDirectory = runtime,
            };
            // Worlds/saves survive a portable game update.
            info.Environment["MINETEST_USER_PATH"] = saves;
            info.Environment["LUANTI_USER_PATH"] = saves;
            foreach (var argument in _args)
                info.ArgumentList.Add(argument);

            using var process = Process.Start(info) ??
                throw new InvalidOperationException("The bundled NOVATERRA launcher could not start.");

            // A short execution (including --version and a crash) reports a real code.
            // The normal game stays running after this splash window closes.
            if (await Task.Run(() => process.WaitForExit(1500)))
                ExitCode = process.ExitCode;
            else
                ExitCode = 0;

            if (ExitCode != 0)
                throw new InvalidOperationException($"NOVATERRA exited during startup (code {ExitCode}).");
        }
        catch (Exception ex)
        {
            ExitCode = 1;
            MessageBox.Show(this, ex.Message, "NOVATERRA startup error",
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
        finally
        {
            Close();
        }
    }

    private static string ChooseWritableRoot()
    {
        string local = Path.Combine(AppContext.BaseDirectory, "NOVATERRA-Portable-Data");
        if (CanWrite(AppContext.BaseDirectory))
            return local;
        string appData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
        if (string.IsNullOrWhiteSpace(appData))
            throw new IOException("No writable folder available for portable game data.");
        return Path.Combine(appData, "NOVATERRA", "Portable-Data");
    }

    private static bool CanWrite(string directory)
    {
        try
        {
            var probe = Path.Combine(directory, $".novaterra-{Guid.NewGuid():N}.tmp");
            using (var file = new FileStream(probe, FileMode.CreateNew, FileAccess.Write, FileShare.None))
                file.WriteByte(1);
            File.Delete(probe);
            return true;
        }
        catch (UnauthorizedAccessException) { return false; }
        catch (IOException) { return false; }
    }

    private static string PrepareBundle(string root, IProgress<int> progress)
    {
        string runtime = Path.Combine(root, "Runtime");
        string marker = Path.Combine(root, "bundle.sha256");
        Directory.CreateDirectory(root);

        using Stream resource = Assembly.GetExecutingAssembly().GetManifestResourceStream("NOVATERRA.GameBundle")
            ?? throw new InvalidDataException("The portable executable has no embedded game archive.");
        using var bytes = new MemoryStream();
        resource.CopyTo(bytes);
        byte[] archiveBytes = bytes.ToArray();
        string checksum = Convert.ToHexString(SHA256.HashData(archiveBytes));

        bool cached = File.Exists(marker)
            && string.Equals(File.ReadAllText(marker).Trim(), checksum, StringComparison.OrdinalIgnoreCase)
            && File.Exists(Path.Combine(runtime, "NOVATERRA.exe"))
            && File.Exists(Path.Combine(runtime, "engine", "bin", "luanti.exe"))
            && File.Exists(Path.Combine(runtime, "games", "novaterra", "game.conf"));

        if (cached)
        {
            progress.Report(100);
            return runtime;
        }

        string staging = Path.Combine(root, ".stage-" + Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(staging);
        try
        {
            using var archive = new ZipArchive(new MemoryStream(archiveBytes), ZipArchiveMode.Read);
            if (archive.Entries.Count == 0)
                throw new InvalidDataException("Bundled NOVATERRA archive is empty.");

            string prefix = Path.GetFullPath(staging) + Path.DirectorySeparatorChar;
            int index = 0;
            foreach (var entry in archive.Entries)
            {
                string path = Path.GetFullPath(Path.Combine(staging,
                    entry.FullName.Replace('/', Path.DirectorySeparatorChar)));
                if (!path.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
                    throw new InvalidDataException("Unsafe path in the bundled game archive.");

                if (string.IsNullOrEmpty(entry.Name))
                {
                    Directory.CreateDirectory(path);
                }
                else
                {
                    Directory.CreateDirectory(Path.GetDirectoryName(path)!);
                    using var input = entry.Open();
                    using var output = new FileStream(path, FileMode.CreateNew, FileAccess.Write);
                    input.CopyTo(output);
                }
                progress.Report(++index * 100 / archive.Entries.Count);
            }

            if (!File.Exists(Path.Combine(staging, "NOVATERRA.exe"))
                || !File.Exists(Path.Combine(staging, "engine", "bin", "luanti.exe"))
                || !File.Exists(Path.Combine(staging, "games", "novaterra", "game.conf")))
                throw new InvalidDataException("Essential game files are missing from the archive.");

            // Never put saves under Runtime: updating the game must not delete worlds.
            if (Directory.Exists(runtime))
                Directory.Delete(runtime, recursive: true);
            Directory.Move(staging, runtime);
            File.WriteAllText(marker, checksum);
            return runtime;
        }
        finally
        {
            if (Directory.Exists(staging))
                Directory.Delete(staging, recursive: true);
        }
    }
}
