<#
Copies this Copilot setup (.github folder) into a Mendix project folder.
Usage:  .\apply.ps1 -Project C:\path\to\MyMendixApp [-Force]
Existing files are kept unless -Force is given. Nothing else in the project is touched.
#>
param(
  [Parameter(Mandatory)][string]$Project,
  [switch]$Force
)
$ErrorActionPreference = 'Stop'
$src = Join-Path $PSScriptRoot '.github'
if (-not (Test-Path $src)) { throw "Setup folder not found: $src" }
if (-not (Test-Path $Project -PathType Container)) { throw "Project folder not found: $Project" }
if (-not (Get-ChildItem $Project -Filter *.mpr -File)) { Write-Warning "No .mpr in $Project - is this the Mendix project root?" }
if (-not (Get-Command mxcli -ErrorAction SilentlyContinue)) { Write-Warning "mxcli is not on PATH; the instructions assume it is." }
if (Test-Path (Join-Path $Project '.claude\skills')) { Write-Warning "$Project\.claude\skills exists (written by mxcli init). VS Code Copilot also scans it, so skills may load twice (about 6k extra tokens, possibly older versions). Delete it or keep only one copy." }

$copied = 0; $skipped = 0
Get-ChildItem $src -Recurse -File | ForEach-Object {
  $rel = $_.FullName.Substring($src.Length).TrimStart('\')
  $dst = Join-Path $Project (Join-Path '.github' $rel)
  if ((Test-Path $dst) -and -not $Force) { $script:skipped++; return }
  New-Item -ItemType Directory -Force (Split-Path $dst) | Out-Null
  Copy-Item $_.FullName $dst -Force
  $script:copied++
}
"$copied copied, $skipped skipped into $Project. Open it in VS Code and start Copilot Chat in Agent mode."
