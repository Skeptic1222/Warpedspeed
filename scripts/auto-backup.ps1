# Warped Speed Auto-Backup Script
# This script performs automatic backups to GitHub using GitHub CLI

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

# Check for GitHub CLI
try {
    $ghVersion = gh --version
    Write-Host "Using GitHub CLI: $ghVersion"
} catch {
    Write-Host "GitHub CLI not found. Please install it with: winget install GitHub.cli"
    Write-Host "Then authenticate with: gh auth login"
    exit 1
}

# Verify GitHub CLI authentication
$authStatus = gh auth status 2>&1
if ($authStatus -match "not logged") {
    Write-Host "Not logged in to GitHub. Please run: gh auth login"
    exit 1
}

# Make sure we're on the main branch
gh repo sync

# Create a backup directory if it doesn't exist
$backupDir = ".\.backup-reports"
if (-not (Test-Path $backupDir)) {
    New-Item -Path $backupDir -ItemType Directory | Out-Null
}

# Generate backup report
$reportFile = "$backupDir\backup-$dateOnly.md"
Set-Content -Path $reportFile -Value "# Backup Report: $dateOnly`n"
Add-Content -Path $reportFile -Value "## Files Included`n```"
Get-ChildItem -Path $repoRoot -Recurse -File -Exclude ".*" | ForEach-Object { $_.FullName.Replace($repoRoot, "").TrimStart("\") } | Sort-Object | Add-Content -Path $reportFile
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
        # Push the branch using GitHub CLI
        gh repo sync
    }
    
    # Return to main branch
    git checkout main
}

# Create backup tag if enabled
if ($createTag) {
    $tagName = "backup/$timestamp"
    git tag $tagName
    
    if ($pushToRemote) {
        # Push the tag using GitHub CLI
        gh repo sync
    }
}

# Push changes to main
if ($pushToRemote) {
    gh repo sync
}

Write-Host "Backup completed successfully: $timestamp"

# Schedule this script to run regularly
$taskName = "WarpedSpeedAutoBackup"
$taskExists = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

# Only create the task if it doesn't exist already
if (-not $taskExists) {
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$scriptPath\auto-backup.ps1`""
    
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