[CmdletBinding()]
param(
    [string]$LuantiExe = "",
    [string]$WorldPath = "",
    [switch]$Server
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$gameDir = Join-Path $repoRoot "games\novaterra"
if (-not (Test-Path -LiteralPath (Join-Path $gameDir "game.conf") -PathType Leaf)) {
    throw "NOVATERRA game.conf was not found at: $gameDir"
}
$candidates = @()
if ($LuantiExe) { $candidates += $LuantiExe }
foreach ($name in @("luanti.exe", "minetest.exe")) {
    $command = Get-Command $name -ErrorAction SilentlyContinue
    if ($command) { $candidates += $command.Source }
}
foreach ($base in @($env:ProgramFiles, [Environment]::GetFolderPath("LocalApplicationData"))) {
    if (-not $base) { continue }
    foreach ($relative in @("Luanti\bin\luanti.exe", "Luanti\luanti.exe", "Minetest\bin\minetest.exe")) {
        $candidates += (Join-Path $base $relative)
    }
}
$engine = $null
foreach ($candidate in $candidates) {
    if (Test-Path -LiteralPath $candidate -PathType Leaf) {
        $engine = (Resolve-Path -LiteralPath $candidate).Path
        break
    }
}
if (-not $engine) {
    throw "Luanti executable not found. Install Luanti or provide -LuantiExe."
}
$argsList = @("--gameid", "novaterra")
$env:LUANTI_GAME_PATH = Join-Path $repoRoot "games"
if ($WorldPath) {
    $argsList += @("--world", $WorldPath)
}
if ($Server) { $argsList += "--server" }
Write-Host "NOVATERRA: $engine"
& $engine @argsList
exit $LASTEXITCODE
