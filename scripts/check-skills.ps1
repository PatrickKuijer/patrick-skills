<#
.SYNOPSIS
  Lint the skills and agents in this repo. Exit 1 on any failure.
  - every skills/<name>/SKILL.md has frontmatter with name == folder and a description (<= 1024 chars)
  - every agents/<name>.md has frontmatter with name == file name and a description
  - SKILL.md stays under 250 lines (detail belongs in references/)
  - every phrase in tests/contracts.txt is still present in its file
#>
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$fail = [System.Collections.Generic.List[string]]::new()

function Get-Frontmatter($path) {
    $lines = Get-Content -LiteralPath $path
    if ($lines.Count -lt 3 -or $lines[0] -ne '---') { return $null }
    $end = [Array]::IndexOf($lines, '---', 1)
    if ($end -lt 0) { return $null }
    $fm = @{}
    foreach ($l in $lines[1..($end - 1)]) {
        if ($l -match '^([A-Za-z-]+):\s*(.*)$') { $fm[$Matches[1]] = $Matches[2].Trim('"') }
    }
    $fm['__lines'] = $lines.Count
    return $fm
}

Get-ChildItem (Join-Path $repo 'skills') -Directory | ForEach-Object {
    $file = Join-Path $_.FullName 'SKILL.md'
    if (-not (Test-Path $file)) { $fail.Add("$($_.Name): SKILL.md missing"); return }
    $fm = Get-Frontmatter $file
    if (-not $fm) { $fail.Add("$($_.Name): no frontmatter"); return }
    if ($fm.name -ne $_.Name) { $fail.Add("$($_.Name): name '$($fm.name)' != folder") }
    if (-not $fm.description) { $fail.Add("$($_.Name): description missing") }
    elseif ($fm.description.Length -gt 1024) { $fail.Add("$($_.Name): description > 1024 chars") }
    if ($fm.__lines -ge 250) { $fail.Add("$($_.Name): SKILL.md has $($fm.__lines) lines (limit 250)") }
}

Get-ChildItem (Join-Path $repo 'agents') -Filter *.md | ForEach-Object {
    $fm = Get-Frontmatter $_.FullName
    if (-not $fm) { $fail.Add("agent $($_.Name): no frontmatter"); return }
    if ($fm.name -ne $_.BaseName) { $fail.Add("agent $($_.Name): name '$($fm.name)' != file") }
    if (-not $fm.description) { $fail.Add("agent $($_.Name): description missing") }
}

Get-Content (Join-Path $repo 'tests\contracts.txt') | Where-Object { $_ -and -not $_.StartsWith('#') } | ForEach-Object {
    $file, $phrase = $_ -split '\|', 2
    $path = Join-Path $repo $file
    if (-not (Test-Path $path)) { $fail.Add("contract: $file missing"); return }
    if (-not (Select-String -LiteralPath $path -SimpleMatch -Quiet -Pattern $phrase)) {
        $fail.Add("contract: '$phrase' gone from $file")
    }
}

if ($fail.Count) { $fail | ForEach-Object { Write-Host "FAIL $_" }; exit 1 }
Write-Host "ok: all skills, agents and contracts pass"
