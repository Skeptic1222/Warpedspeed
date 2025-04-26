@echo off
echo Creating auto-backup.ps1 script...

echo # Warped Speed Auto-Backup Script > scripts\auto-backup.ps1
echo # This script performs automatic backups to GitHub >> scripts\auto-backup.ps1
echo. >> scripts\auto-backup.ps1
echo # Configuration >> scripts\auto-backup.ps1
echo $backupFrequency = "daily" # Options: hourly, daily, weekly >> scripts\auto-backup.ps1
echo $createBranch = $true >> scripts\auto-backup.ps1
echo $createTag = $true >> scripts\auto-backup.ps1
echo $pushToRemote = $true >> scripts\auto-backup.ps1
echo. >> scripts\auto-backup.ps1
echo # Ensure we are in the right directory >> scripts\auto-backup.ps1
echo $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path >> scripts\auto-backup.ps1
echo $repoRoot = (Get-Item $scriptPath).Parent.FullName >> scripts\auto-backup.ps1
echo Set-Location $repoRoot >> scripts\auto-backup.ps1
echo. >> scripts\auto-backup.ps1
echo # Create timestamp >> scripts\auto-backup.ps1
echo $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss" >> scripts\auto-backup.ps1
echo $dateOnly = Get-Date -Format "yyyy-MM-dd" >> scripts\auto-backup.ps1
echo. >> scripts\auto-backup.ps1
echo # Run the backup process >> scripts\auto-backup.ps1
echo Write-Host "Running backup for $dateOnly" >> scripts\auto-backup.ps1
echo. >> scripts\auto-backup.ps1
echo # Make sure we are on the main branch >> scripts\auto-backup.ps1
echo git checkout main >> scripts\auto-backup.ps1
echo. >> scripts\auto-backup.ps1
echo # Pull latest changes >> scripts\auto-backup.ps1
echo git pull >> scripts\auto-backup.ps1
echo. >> scripts\auto-backup.ps1
echo # Create a backup tag >> scripts\auto-backup.ps1
echo $tagName = "backup/$timestamp" >> scripts\auto-backup.ps1
echo git tag $tagName >> scripts\auto-backup.ps1
echo git push origin $tagName >> scripts\auto-backup.ps1
echo. >> scripts\auto-backup.ps1
echo # Create backup branch (weekly) >> scripts\auto-backup.ps1
echo $dayOfWeek = (Get-Date).DayOfWeek >> scripts\auto-backup.ps1
echo if ($dayOfWeek -eq "Sunday") { >> scripts\auto-backup.ps1
echo     $branchName = "backup/milestone-$dateOnly" >> scripts\auto-backup.ps1
echo     git checkout -b $branchName >> scripts\auto-backup.ps1
echo     git push -u origin $branchName >> scripts\auto-backup.ps1
echo     git checkout main >> scripts\auto-backup.ps1
echo } >> scripts\auto-backup.ps1
echo. >> scripts\auto-backup.ps1
echo # Log the backup >> scripts\auto-backup.ps1
echo $logFile = ".\.backup-reports\backup-log.md" >> scripts\auto-backup.ps1
echo if (-not (Test-Path ".\.backup-reports")) { >> scripts\auto-backup.ps1
echo     New-Item -Path ".\.backup-reports" -ItemType Directory -Force >> scripts\auto-backup.ps1
echo } >> scripts\auto-backup.ps1
echo if (-not (Test-Path $logFile)) { >> scripts\auto-backup.ps1
echo     "# Backup Log" | Out-File -FilePath $logFile >> scripts\auto-backup.ps1
echo } >> scripts\auto-backup.ps1
echo "- $timestamp: Created backup tag and pushed to remote" | Out-File -FilePath $logFile -Append >> scripts\auto-backup.ps1
echo. >> scripts\auto-backup.ps1
echo Write-Host "Backup completed successfully: $timestamp" >> scripts\auto-backup.ps1

echo Script created successfully.
echo To run it, type: powershell -File scripts\auto-backup.ps1 