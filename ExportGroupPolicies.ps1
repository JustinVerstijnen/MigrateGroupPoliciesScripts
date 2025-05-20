# --- PARAMETERS ---
$backupPath = Get-Location
$gpoListFile = "$backupPath\GPO_List.txt"

# Check location on errors
if (-Not (Test-Path $backupPath)) {
    New-Item -ItemType Directory -Path $backupPath
}

$gpos = Get-GPO -All | Where-Object { $_.DisplayName -notmatch "Default Domain( Controllers)? Policy" }

function Remove-InvalidFileNameChars {
    param ([string]$filename)
    $invalidChars = [System.IO.Path]::GetInvalidFileNameChars()
    $escapedInvalidChars = [Regex]::Escape([string]::Join("", $invalidChars))
    $pattern = "[$escapedInvalidChars]"
    return [Regex]::Replace($filename, $pattern, "_")
}

# Save GPO names for displaynames exporting and importing
$gpoList = @()

foreach ($gpo in $gpos) {
    $cleanGpoName = Remove-InvalidFileNameChars -filename $gpo.DisplayName
    $gpoBackupPath = Join-Path -Path $backupPath -ChildPath $cleanGpoName
    if (-Not (Test-Path $gpoBackupPath)) {
        New-Item -ItemType Directory -Path $gpoBackupPath
    }
    Write-Output "Backing up GPO: $($gpo.DisplayName) to $gpoBackupPath"
    try {
        Backup-GPO -Name $gpo.DisplayName -Path $gpoBackupPath
        $gpoList += $gpo.DisplayName
    } catch {
        Write-Output "Failed to backup GPO: $($gpo.DisplayName). Error: $_"
    }
}

$gpoList | Out-File -FilePath $gpoListFile

Write-Output "Selected GPOs have been backed up to $backupPath and names saved to $gpoListFile."
