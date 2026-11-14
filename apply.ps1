<#
Copies the Copilot setup (.github instructions, skills, prompts) into a Mendix project folder.
Usage:  .\apply.ps1 -Project C:\path\to\MyMendixApp [-Force]
Existing files are kept unless -Force is given. Nothing else in the project is touched.
#>
param(
  [Parameter(Mandatory)][string]$Project,
  [switch]$Force
)
$ErrorActionPreference = 'Stop'
$src = Join-Path $PSScriptRoot '.github'
if (-not (Test-Path $Project -PathType Container)) { throw "Project folder not found: $Project" }
if (-not (Get-ChildItem $Project -Filter *.mpr -File)) { Write-Warning "No .mpr in $Project - is this the Mendix project root?" }
if (-not (Get-Command mxcli -ErrorAction SilentlyContinue)) { Write-Warning "mxcli is not on PATH; the instructions assume it is." }

$copied = 0; $skipped = 0
Get-ChildItem $src -Recurse -File | ForEach-Object {
  $rel = $_.FullName.Substring($src.Length).TrimStart('\')
  $dst = Join-Path $Project (Join-Path '.github' $rel)
  if ((Test-Path $dst) -and -not $Force) { Write-Host "skip  $rel (exists)"; $script:skipped++; return }
  New-Item -ItemType Directory -Force (Split-Path $dst) | Out-Null
  Copy-Item $_.FullName $dst -Force
  Write-Host "copy  $rel"; $script:copied++
}
"Done: $copied copied, $skipped skipped. Open $Project in VS Code and start Copilot Chat in Agent mode."
