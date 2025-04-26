# Warped Speed Auto-Backup Script
# This script performs automatic backups to GitHub

# Configuration
$backupFrequency = "daily" # Options: hourly, daily, weekly
$createBranch = $true
$createTag = $true
$pushToRemote = $true

# Ensure we're in the right directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Get-Item $scriptPath).Parent.FullName
Set-Location $repoRoot

# Create timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$dateOnly = Get-Date -Format "yyyy-MM-dd"

# Configure Git if needed
git config --get user.name > $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Git username not configured. Please run:"
    Write-Host "git config --global user.name 'Your Name'"
    Write-Host "git config --global user.email 'your.email@example.com'"
    exit 1
}

# Make sure we're on the main branch
git checkout main

# Pull latest changes
git pull

# Create a backup directory if it doesn't exist
$backupDir = ".\.backup-reports"
if (-not (Test-Path $backupDir)) {
    New-Item -Path $backupDir -ItemType Directory | Out-Null
}

# Generate backup report
$reportFile = "$backupDir\backup-$dateOnly.md"
Set-Content -Path $reportFile -Value "# Backup Report: $dateOnly`n"
Add-Content -Path $reportFile -Value "## Files Included`n```"
Get-ChildItem -Path $repoRoot -Recurse -File -Exclude ".*" | ForEach-Object { $_.FullName.Replace($repoRoot, '').TrimStart('\') } | Sort-Object | Add-Content -Path $reportFile
Add-Content -Path $reportFile -Value "````n"
Add-Content -Path $reportFile -Value "## Git Status`n```"
git log -n 10 --pretty=format:"%h - %an, %ar : %s" | Add-Content -Path $reportFile
Add-Content -Path $reportFile -Value "```"

# Commit the report
git add $reportFile
git commit -m "Backup report for $dateOnly"

# Create backup branch if enabled
if ($createBranch) {
    $branchName = "backup/milestone-$dateOnly"
    git checkout -b $branchName
    
    if ($pushToRemote) {
        git push -u origin $branchName
    }
    
    # Return to main branch
    git checkout main
}

# Create backup tag if enabled
if ($createTag) {
    $tagName = "backup/$timestamp"
    git tag $tagName
    
    if ($pushToRemote) {
        git push origin $tagName
    }
}

# Push changes to main
if ($pushToRemote) {
    git push
}

Write-Host "Backup completed successfully: $timestamp"

# Schedule this script to run regularly
$taskName = "WarpedSpeedAutoBackup"
$taskExists = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

# Only create the task if it doesn't exist already
if (-not $taskExists) {
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$scriptPath\auto-backup.ps1`""
    
    switch ($backupFrequency) {
        "hourly" {
            $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Hours 1)
        }
        "daily" {
            $trigger = New-ScheduledTaskTrigger -Daily -At "00:00"
        }
        "weekly" {
            $trigger = New-ScheduledTaskTrigger -Weekly -At "00:00" -DaysOfWeek Sunday
        }
    }
    
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Description "Automated backup for Warped Speed project"
    Write-Host "Scheduled task created for $backupFrequency backups"
} 