<#
.SYNOPSIS
    Optimizes External Drive Indexing & Explorer Performance.

.DESCRIPTION
    This script performs several optimizations to fix system bottlenecks, reduce lag, and ensure stable video thumbnail performance
    for external drives. It addresses:
    1. Search Indexing (Restart Service & Disable Drive Indexing)
    2. Folder Templates (Force 'General Items')
    3. Cache Maintenance (Flush History & Thumbnails)
    4. Permanent Thumbnail Cache (Disable SilentCleanup & Registry Tweak)
    5. Icaros Integration instructions.

.NOTES
    Run this script as Administrator.
#>

# Check for Administrator privileges
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You do not have Administrator rights to run this script. Please run it as Administrator."
    Break
}

# --- Part 1: System Optimization ---

# 0. Prompt for External Drive Letter
$driveInput = Read-Host -Prompt "Enter the External Drive Letter (e.g., E)"
# Validate input
if ([string]::IsNullOrWhiteSpace($driveInput)) {
    Write-Error "No drive letter entered."
    Exit
}

$driveLetter = $driveInput.Trim().Substring(0,1).ToUpper() + ":"

if (!(Test-Path $driveLetter)) {
    Write-Error "Drive $driveLetter not found. Please check the drive letter and try again."
    Exit
}

Write-Host "Optimizing Drive: $driveLetter" -ForegroundColor Cyan

# 1. Rebuild Search Index (Restart Service)
Write-Host "Stopping Windows Search Service..." -ForegroundColor Yellow
Stop-Service -Name "wsearch" -Force -ErrorAction SilentlyContinue

# 2. Exclusion Logic: Disable Indexing on the External Drive
Write-Host "Disabling Indexing on $driveLetter..." -ForegroundColor Yellow
try {
    $vol = Get-WmiObject -Class Win32_Volume -Filter "DriveLetter='$driveLetter'"
    if ($vol) {
        $vol.IndexingEnabled = $false
        $vol.Put() | Out-Null
        Write-Host "Indexing disabled for $driveLetter." -ForegroundColor Green
    } else {
        Write-Warning "Could not find volume info for $driveLetter."
    }
} catch {
    Write-Error "Failed to disable indexing: $_"
}

# 3. Folder Template: Set to 'General Items'
Write-Host "Setting Folder Template to 'General Items' (Generic)..." -ForegroundColor Yellow
$desktopIniPath = Join-Path $driveLetter "desktop.ini"
try {
    # Create or overwrite desktop.ini to force Generic type
    $iniContent = "[ViewState]`r`nFolderType=Generic"
    Set-Content -Path $desktopIniPath -Value $iniContent -Force

    # Set attributes to Hidden and System
    $fileItem = Get-Item -Path $desktopIniPath
    $fileItem.Attributes = "Hidden, System"
    Write-Host "Folder template set to Generic." -ForegroundColor Green
} catch {
    Write-Warning "Failed to set folder template: $_"
}

# 4. Cache Maintenance: Flush File Explorer history and thumbnail cache
Write-Host "Flushing File Explorer Cache..." -ForegroundColor Yellow

# We need to stop Explorer to delete locked cache files
Write-Host "Stopping Windows Explorer..." -ForegroundColor Red
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue

Start-Sleep -Seconds 2

# Delete Thumbnail and Icon Caches
$localAppData = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"
if (Test-Path $localAppData) {
    Get-ChildItem -Path $localAppData -Filter "thumbcache_*.db" | Remove-Item -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path $localAppData -Filter "iconcache_*.db" | Remove-Item -Force -ErrorAction SilentlyContinue
    Write-Host "Thumbnail and Icon caches cleared." -ForegroundColor Green
}

# --- Part 2: Permanent Thumbnail Cache ---

# 1. Disable SilentCleanup
Write-Host "Disabling SilentCleanup task..." -ForegroundColor Yellow
try {
    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\DiskCleanup\" -TaskName "SilentCleanup" -ErrorAction SilentlyContinue | Out-Null
    Write-Host "SilentCleanup task disabled." -ForegroundColor Green
} catch {
    Write-Warning "Could not disable SilentCleanup task. It might not exist or you lack permissions."
}

# 2. Registry Tweak for Thumbnail Cache Autorun
Write-Host "Applying Registry Tweak for Thumbnail Cache..." -ForegroundColor Yellow
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache"
try {
    if (Test-Path $regPath) {
        Set-ItemProperty -Path $regPath -Name "Autorun" -Value 0 -Force
        Write-Host "Registry tweak applied (Autorun=0)." -ForegroundColor Green
    } else {
        Write-Warning "Registry path not found: $regPath"
    }
} catch {
    Write-Error "Failed to apply registry tweak: $_"
}

# Restart Windows Search Service
Write-Host "Restarting Windows Search Service..." -ForegroundColor Yellow
Start-Service -Name "wsearch" -ErrorAction SilentlyContinue

# Restart Explorer
Write-Host "Restarting Windows Explorer..." -ForegroundColor Yellow
Start-Process explorer.exe

# 3. Icaros Integration Explanation
Write-Host "`n--- Icaros Integration Instructions ---" -ForegroundColor Cyan
Write-Host "To ensure faster and more stable thumbnail generation for large video libraries:"
Write-Host "1. Download and install 'Icaros' (a shell extension)."
Write-Host "2. Open Icaros Config."
Write-Host "3. Enable 'Thumbnailing' for desired video formats (MKV, MP4, AVI, etc.)."
Write-Host "4. Enable 'Cache' in Icaros settings to use its own local cache, independent of Windows Explorer."
Write-Host "   This prevents Windows from constantly regenerating thumbnails."
Write-Host "---------------------------------------`n"

Write-Host "Optimization Complete!" -ForegroundColor Green
