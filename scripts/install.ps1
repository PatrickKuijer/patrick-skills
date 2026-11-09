<#
.SYNOPSIS
  Link this repo's skills and agents into ~/.claude, backing up whatever they replace.

.DESCRIPTION
  - Every folder in skills/ becomes a directory junction at ~/.claude/skills/<name>
    (junctions need no admin rights, unlike symlinks).
  - ~/.claude/agents becomes a junction to agents/ in this repo.
  - Every name in skills/RETIRED.txt is removed from ~/.claude/skills (it is
    superseded by a skill in this repo).
  - Anything replaced or retired is moved to ~/.claude/skill-backups/<timestamp>/,
    never deleted. Junctions are unlinked (their target is untouched) and recorded
    in the backup's manifest.txt.
  Idempotent: links that already point into this repo are left alone.

.EXAMPLE
  pwsh scripts/install.ps1 -WhatIf   # dry run
  pwsh scripts/install.ps1
#>
[CmdletBinding(SupportsShouldProcess)]
param()

$ErrorActionPreference = 'Stop'
$repo     = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$claude   = Join-Path $HOME '.claude'
$skillDir = Join-Path $claude 'skills'
$stamp    = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup   = Join-Path $claude "skill-backups\$stamp"
$manifest = [System.Collections.Generic.List[string]]::new()

function Get-LinkTarget($path) {
    $item = Get-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue
    if ($item -and $item.LinkType) { return [string]($item.Target | Select-Object -First 1) }
    return $null
}

function Clear-Slot($path, $label) {
    # Make $path free: unlink a junction, or move a real folder/file to the backup.
    if (-not (Test-Path -LiteralPath $path)) { return }
    $target = Get-LinkTarget $path
    if ($target) {
        if ($PSCmdlet.ShouldProcess($path, "unlink ($label, was -> $target)")) {
            cmd /c rmdir "$path" | Out-Null
            $manifest.Add("unlinked`t$path`t$target")
        }
    } else {
        $dest = Join-Path $backup ($path.Substring($claude.Length).TrimStart('\'))
        if ($PSCmdlet.ShouldProcess($path, "move to backup ($label)")) {
            New-Item -ItemType Directory -Force (Split-Path $dest) | Out-Null
            Move-Item -LiteralPath $path -Destination $dest
            $manifest.Add("moved`t$path`t$dest")
        }
    }
}

function Set-Junction($link, $target) {
    $current = Get-LinkTarget $link
    if ($current -and ((Resolve-Path $current).Path -eq (Resolve-Path $target).Path)) {
        Write-Host "ok      $link"
        return
    }
    Clear-Slot $link 'replaced'
    if ($PSCmdlet.ShouldProcess($link, "junction -> $target")) {
        New-Item -ItemType Junction -Path $link -Target $target | Out-Null
        Write-Host "linked  $link -> $target"
    }
}

New-Item -ItemType Directory -Force $skillDir | Out-Null

# 1. Retire superseded skills.
$retired = Join-Path $repo 'skills\RETIRED.txt'
if (Test-Path $retired) {
    Get-Content $retired | Where-Object { $_ -and -not $_.StartsWith('#') } | ForEach-Object {
        $name = ($_ -split '\s+')[0]
        $path = Join-Path $skillDir $name
        if (Test-Path -LiteralPath $path) { Clear-Slot $path 'retired'; Write-Host "retired $name" }
    }
}

# 2. Link every skill in this repo.
Get-ChildItem (Join-Path $repo 'skills') -Directory | ForEach-Object {
    Set-Junction (Join-Path $skillDir $_.Name) $_.FullName
}

# 3. Link the agents folder.
Set-Junction (Join-Path $claude 'agents') (Join-Path $repo 'agents')

if ($manifest.Count -gt 0 -and -not $WhatIfPreference) {
    New-Item -ItemType Directory -Force $backup | Out-Null
    $manifest | Set-Content (Join-Path $backup 'manifest.txt')
    Write-Host "`nBackup + manifest: $backup"
    Write-Host "Restore: move folders back from the backup, re-create unlinked junctions from manifest.txt."
}
