using System.Diagnostics;
using System.Windows.Forms;

namespace Novaterra.Launcher;

internal static class Program
{
    [STAThread]
    private static int Main(string[] args)
    {
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);

        try
        {
            var root = FindProjectRoot(AppContext.BaseDirectory);
            if (root is null)
            {
                MessageBox.Show(
                    "NOVATERRA game files were not found. Place the games folder next to the application.",
                    "NOVATERRA", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return 2;
            }

            var engine = FindEngine(root);
            if (engine is null)
            {
                MessageBox.Show(
                    "Luanti engine was not found. Install Luanti for Windows or bundle its executable alongside NOVATERRA.",
                    "NOVATERRA", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return 3;
            }

            var gamePath = Path.Combine(root, "games", "novaterra");
            if (!File.Exists(Path.Combine(gamePath, "game.conf")))
                throw new FileNotFoundException("NOVATERRA game.conf is missing.");
            var start = new ProcessStartInfo(engine)
            {
                UseShellExecute = false,
                WorkingDirectory = Path.GetDirectoryName(engine)!,
            };
            start.ArgumentList.Add("--gameid");
            start.ArgumentList.Add("novaterra");
            // Use the engine-supported game search path; --gamepath is not a Luanti CLI option.
            start.Environment["LUANTI_GAME_PATH"] = Path.Combine(root, "games");
            start.Environment["MINETEST_GAME_PATH"] = Path.Combine(root, "games");
            foreach (var argument in args)
                start.ArgumentList.Add(argument);

            using var process = Process.Start(start)
                ?? throw new InvalidOperationException("Luanti could not be started.");
            process.WaitForExit();
            return process.ExitCode;
        }
        catch (Exception ex)
        {
            MessageBox.Show(ex.Message, "NOVATERRA startup error",
                MessageBoxButtons.OK, MessageBoxIcon.Error);
            return 1;
        }
    }

    private static string? FindProjectRoot(string baseDirectory)
    {
        var directory = new DirectoryInfo(baseDirectory);
        while (directory is not null)
        {
            var config = Path.Combine(directory.FullName, "games", "novaterra", "game.conf");
            if (File.Exists(config))
                return directory.FullName;
            directory = directory.Parent;
        }
        return null;
    }

    private static string? FindEngine(string root)
    {
        var candidates = new List<string>
        {
            Path.Combine(root, "engine", "bin", "luanti.exe"),
            Path.Combine(root, "engine", "luanti.exe"),
            Path.Combine(root, "luanti.exe"),
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles), "Luanti", "bin", "luanti.exe"),
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "Luanti", "bin", "luanti.exe"),
        };

        var path = Environment.GetEnvironmentVariable("PATH") ?? "";
        foreach (var folder in path.Split(Path.PathSeparator, StringSplitOptions.RemoveEmptyEntries))
            candidates.Add(Path.Combine(folder, "luanti.exe"));

        return candidates.FirstOrDefault(File.Exists);
    }
}
