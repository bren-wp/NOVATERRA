[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$game = Join-Path $root "games\novaterra"
$required = @(
    "game.conf",
    "mods\nv_core\mod.conf",
    "mods\nv_core\init.lua",
    "mods\nv_survival\mod.conf",
    "mods\nv_survival\init.lua",
    "mods\nv_ui\mod.conf",
    "mods\nv_ui\init.lua",
    "mods\nv_world\mod.conf",
    "mods\nv_world\init.lua",
    "mods\nv_world\furnace.lua",
    "mods\nv_core\textures\nv_stone.png"
)
$missing = @($required | Where-Object { -not (Test-Path -LiteralPath (Join-Path $game $_) -PathType Leaf) })
if ($missing.Count -gt 0) {
    Write-Error ("Missing game files:`n" + ($missing -join "`n"))
    exit 1
}
Write-Host "NOVATERRA Windows source layout: PASS"
