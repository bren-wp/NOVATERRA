# NOVATERRA for Windows

Windows-specific launch and packaging files live here. Shared gameplay is in `../games/novaterra`.

## Development launch

Install Luanti for Windows, then run `windows/Launch-NOVATERRA.ps1` from PowerShell. The launcher checks common installation locations and `PATH`, validates the game directory, and starts the engine with `--gameid novaterra`.

Optional explicit engine path:

```powershell
.\windows\Launch-NOVATERRA.ps1 -LuantiExe "C:\Program Files\Luanti\bin\luanti.exe"
```

## Build status

**No Windows EXE or installer is published yet.** The PowerShell launcher requires an existing Luanti installation. A redistributable Windows build must bundle a compatible engine, game content, dependencies and license notices, and must pass a launch smoke test before release.
