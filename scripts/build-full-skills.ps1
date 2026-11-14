<#
Builds variants/full-skills: the lean setup plus ALL stock mxcli skills, adapted for GitHub Copilot.
Source skills come from any project that ran `mxcli init` (default: Atlas_Light's .claude/skills).
Re-run after `mxcli init --sync-skills` to refresh. Output is deterministic, so diffs show real changes.

Usage: .\scripts\build-full-skills.ps1 [-Source <path to .claude\skills>]
#>
param(
  [string]$Source = 'C:\Users\DELL\Mendix\Atlas_Light\.claude\skills'
)
$ErrorActionPreference = 'Stop'
$root  = Split-Path $PSScriptRoot -Parent
$out   = Join-Path $root 'variants\full-skills\.github'
$lean  = Join-Path $root '.github'
$utf8  = New-Object Text.UTF8Encoding($false)

if (-not (Test-Path $Source)) { throw "Source skills not found: $Source" }
if (Test-Path $out) { Remove-Item $out -Recurse -Force }
New-Item -ItemType Directory -Force $out | Out-Null

# 1. Everything from the lean setup except the condensed domain skills (the originals replace those)
$keepLeanSkills = 'mendix-explore','mendix-write-mdl','mendix-review'
Get-ChildItem $lean -Recurse -File | ForEach-Object {
  $rel = $_.FullName.Substring($lean.Length).TrimStart('\')
  if ($rel -like 'skills\*') {
    $skill = ($rel -split '\\')[1]
    if ($keepLeanSkills -notcontains $skill) { return }
  }
  $dst = Join-Path $out $rel
  New-Item -ItemType Directory -Force (Split-Path $dst) | Out-Null
  Copy-Item $_.FullName $dst
}

# 2. Original skills, adapted
$sedHint = "``sed -n '<from>,<to>p' SKILL.md`` one section rather than reading the file;"
$sedNew  = "read only the line range of one section (see the table) rather than the whole file;"
$count = 0; $skipped = @()
Get-ChildItem $Source -Directory | ForEach-Object {
  if (-not (Test-Path (Join-Path $_.FullName 'SKILL.md'))) { $skipped += $_.Name; return }   # e.g. mxcli-companion (Claude Code UI plugin)
  $count++
  Get-ChildItem $_.FullName -Recurse -File | ForEach-Object {
    $relInSkill = $_.FullName.Substring($Source.TrimEnd('\').Length + 1)   # <skill>\...
    $dst = Join-Path $out ("skills\" + $relInSkill)
    New-Item -ItemType Directory -Force (Split-Path $dst) | Out-Null
    if ($_.Extension -eq '.md') {
      $t = [IO.File]::ReadAllText($_.FullName, [Text.Encoding]::UTF8)         # strips the BOM
      $t = $t -replace '\./bin/mxcli', 'mxcli' -replace '\./mxcli', 'mxcli'   # mxcli is on PATH
      $t = $t.Replace($sedHint, $sedNew)
      [IO.File]::WriteAllText($dst, $t, $utf8)
    } else {
      Copy-Item $_.FullName $dst
    }
  }
}
"skills built: $count; skipped (no SKILL.md): $($skipped -join ', ')"
