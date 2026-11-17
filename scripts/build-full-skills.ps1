<#
Refreshes the stock mxcli skills in .github\skills, adapted for GitHub Copilot.
Source: the .claude\skills folder of any project that ran `mxcli init` (or `mxcli init --sync-skills`).
Only skill folders that exist in the source are replaced. Skills that exist only here
(mendix-*, mendix-e2e-strategy, ...) and everything else in .github are left alone.

Usage: .\scripts\build-full-skills.ps1 -Source C:\path\to\App\.claude\skills [-WhatIf]
Review `git diff` afterwards; output is deterministic, so diffs show real changes.
#>
param(
  [Parameter(Mandatory)][string]$Source,
  [switch]$WhatIf
)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$out  = Join-Path $root '.github\skills'
$utf8 = New-Object Text.UTF8Encoding($false)

if (-not (Test-Path $Source -PathType Container)) { throw "Source skills not found: $Source" }
$stock = Get-ChildItem $Source -Directory | Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') }
if (-not $stock) { throw "No skill folders with a SKILL.md in $Source - refusing to continue (nothing would be refreshed)." }
$skipped = (Get-ChildItem $Source -Directory | Where-Object { -not (Test-Path (Join-Path $_.FullName 'SKILL.md')) }).Name

$sedHint = "``sed -n '<from>,<to>p' SKILL.md`` one section rather than reading the file;"
$sedNew  = "read only the line range of one section (see the table) rather than the whole file;"
$count = 0
foreach ($skill in $stock) {
  $count++
  $dstSkill = Join-Path $out $skill.Name
  if ($WhatIf) { "would refresh $($skill.Name)"; continue }
  if (Test-Path $dstSkill) { Remove-Item $dstSkill -Recurse -Force }   # drop files removed upstream
  Get-ChildItem $skill.FullName -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring($skill.FullName.TrimEnd('\').Length + 1)
    $dst = Join-Path $dstSkill $rel
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

# Re-apply our one edit to a stock skill: test-app links to mendix-e2e-strategy
$testApp = Join-Path $out 'test-app\SKILL.md'
if ((-not $WhatIf) -and (Test-Path $testApp)) {
  $t = [IO.File]::ReadAllText($testApp, [Text.Encoding]::UTF8)
  $link = '- [mendix-e2e-strategy](../mendix-e2e-strategy/SKILL.md) - **full Playwright suite** with self-supplied, database-independent test data'
  $anchor = '- [test-microflows](../test-microflows/SKILL.md)'
  if ($t -notmatch 'mendix-e2e-strategy' -and $t.Contains($anchor)) {
    [IO.File]::WriteAllText($testApp, $t.Replace($anchor, "$link`n$anchor"), $utf8)
  }
}

# Re-apply our fixes to stock skills (a refresh overwrites them)
$noAuto = 'migrate-design-prototype','migrate-k2-nintex','migrate-oracle-forms','assess-migration','connect-rapidminer-graph','record-narrated-demo','bootstrap-app','live-edit-with-studio-pro','debug-bson'
$fixes = @(
  @('.claude/skills/mendix/scheduled-events-and-queues','the `scheduled-events-and-queues` skill'),
  @('.claude/skills/mendix/catalog-search','the `catalog-search` skill'),
  @('.claude/skills/mendix/browse-integrations','the `browse-integrations` skill'),
  @('.claude/skills/mendix/odata-data-sharing','the `odata-data-sharing` skill'),
  @('.claude/skills/mendix/platform-auth.md','`mxcli auth login`'),
  @('.claude/skills/mendix/agents','the `agents` skill'),
  @('.claude/skills/verify-in-runtime.md','the `test-app` skill'),
  @('.claude/skills/diagnose-ce0463.md','the CE0463 entry in `cheatsheet-errors`'),
  @('.ai-context/skills/widgets/SKILL.md','the `widgets` skill'),
  @('.ai-context/skills/project-brain/SKILL.md','the `project-brain` skill'),
  @('.ai-context/skills/assess-quality/SKILL.md','the `assess-quality` skill'),
  @('cat .claude/skills/write-microflows/SKILL.md','read the `write-microflows` skill'),
  @('cat .claude/skills/overview-pages/SKILL.md','read the `overview-pages` skill')
)
foreach ($skill in $stock) {
  $f = Join-Path $out "$($skill.Name)\SKILL.md"
  if ($WhatIf -or -not (Test-Path $f)) { continue }
  $t = [IO.File]::ReadAllText($f, [Text.Encoding]::UTF8); $orig = $t
  foreach ($x in $fixes) { $t = $t.Replace('`' + $x[0] + '`', $x[1]).Replace($x[0], $x[1]) }   # backticked form first, so no nested backticks
  if (($noAuto -contains $skill.Name) -and ($t -notmatch '(?m)^disable-model-invocation:')) {
    $t = [regex]::Replace($t, '(?m)^(description:.*)$', "`$1`ndisable-model-invocation: true", 1)
  }
  if ($t -ne $orig) { [IO.File]::WriteAllText($f, $t, $utf8) }
}


"skills refreshed: $count; skipped (no SKILL.md): $($skipped -join ', ')"
