# --- PARAMETERS ---
$backupPath = Get-Location
$gpoListFile = "GPO_List.txt"

# Replace invalid characters
function Remove-InvalidFileNameChars {
    param ([string]$filename)
    $invalidChars = [System.IO.Path]::GetInvalidFileNameChars()
    $escapedInvalidChars = [Regex]::Escape([string]::Join("", $invalidChars))
    $pattern = "[$escapedInvalidChars]"
    return [Regex]::Replace($filename, $pattern, "_")
}

# Read GPO name and import it
$gpoNames = Get-Content -Path $gpoListFile
foreach ($gpoName in $gpoNames) {
    $cleanGpoName = Remove-InvalidFileNameChars -filename $gpoName
    $gpoBackupPath = Join-Path -Path $backupPath -ChildPath $cleanGpoName
    if (Test-Path $gpoBackupPath) {
        Write-Output "Importing GPO: $gpoName from $gpoBackupPath"
        try {
            Import-GPO -BackupGpoName $gpoName -Path $gpoBackupPath -CreateIfNeeded -TargetName $gpoName
            Write-Output "Successfully imported GPO: $gpoName"
        } catch {
            Write-Output "Failed to import GPO: $gpoName. Error: $_"
        }
    } else {
        Write-Output "Backup for GPO: $gpoName not found at path: $gpoBackupPath"
    }
}

Write-Output "GPO import process completed."
