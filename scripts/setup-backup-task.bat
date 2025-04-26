@echo off
echo Setting up scheduled backup task for Warped Speed

REM Create the backup script first
call scripts\create-backup-script.bat

REM Get current directory
set SCRIPT_PATH=%~dp0auto-backup.ps1
set FULL_PATH=%CD%\scripts\auto-backup.ps1

echo Creating scheduled task for daily backups...

REM Create a task that runs daily at midnight
schtasks /create /tn "WarpedSpeedBackup" /tr "powershell.exe -ExecutionPolicy Bypass -File \"%FULL_PATH%\"" /sc daily /st 00:00 /ru System

IF %ERRORLEVEL% EQU 0 (
    echo Task successfully created!
    echo Backup will run daily at midnight.
) ELSE (
    echo Failed to create task. Please run this script as administrator.
)

echo.
echo To run a backup manually, type: powershell -ExecutionPolicy Bypass -File scripts\auto-backup.ps1
echo. 