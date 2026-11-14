<#
Copies a Copilot setup variant into a Mendix project folder.
Usage:  .\apply.ps1 -Project C:\path\to\MyMendixApp [-Variant lean|full-skills] [-Force]
  lean         13 condensed skills (default, ~1.3k tokens always on)
  full-skills  all stock mxcli skills adapted for Copilot + skill map (~7k tokens always on)
Existing files are kept unless -Force is given. Nothing else in the project is touched.
Switching variants in one project: use -Force, and delete .github\skills first so no skills from the other variant linger.
#>
param(
  [Parameter(Mandatory)][string]$Project,
  [ValidateSet('lean','full-skills')][string]$Variant = 'lean',
  [switch]$Force
)
$ErrorActionPreference = 'Stop'
$src = if ($Variant -eq 'lean') { Join-Path $PSScriptRoot '.github' } else { Join-Path $PSScriptRoot 'variants\full-skills\.github' }
if (-not (Test-Path $src)) { throw "Variant not found: $src" }
if (-not (Test-Path $Project -PathType Container)) { throw "Project folder not found: $Project" }
if (-not (Get-ChildItem $Project -Filter *.mpr -File)) { Write-Warning "No .mpr in $Project - is this the Mendix project root?" }
if (-not (Get-Command mxcli -ErrorAction SilentlyContinue)) { Write-Warning "mxcli is not on PATH; the instructions assume it is." }
if ((Test-Path (Join-Path $Project '.github\skills')) -and $Force) { Write-Warning "Existing .github\skills found; skills from another variant may remain. Delete the folder first for a clean switch." }

$copied = 0; $skipped = 0
Get-ChildItem $src -Recurse -File | ForEach-Object {
  $rel = $_.FullName.Substring($src.Length).TrimStart('\')
  $dst = Join-Path $Project (Join-Path '.github' $rel)
  if ((Test-Path $dst) -and -not $Force) { $script:skipped++; return }
  New-Item -ItemType Directory -Force (Split-Path $dst) | Out-Null
  Copy-Item $_.FullName $dst -Force
  $script:copied++
}
"[$Variant] $copied copied, $skipped skipped into $Project. Open it in VS Code and start Copilot Chat in Agent mode."
