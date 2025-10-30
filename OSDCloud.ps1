# =========================
# LP Intune OSDCloud Menu
# =========================

$ErrorActionPreference = 'Stop'

function Set-Console {
    try { $host.UI.RawUI.WindowTitle = "LP Intune · OSDCloud Launcher" } catch {}
    Clear-Host
}

function Write-BoxHeader {
    param([string]$TitleLeft = "Louisiana-Pacific Corporation",
          [string]$TitleRight = "Intune · OSDCloud")

    $line = '═' * 56
    Write-Host "╔$line╗" -ForegroundColor Yellow
    Write-Host ("║{0,-56}║" -f "  $TitleLeft") -ForegroundColor Yellow
    Write-Host ("║{0,-56}║" -f "  $TitleRight") -ForegroundColor Yellow
    Write-Host "╚$line╝" -ForegroundColor Yellow
    Write-Host ""
}

function Write-Menu {
    $items = @(
        @{ Id = 1; Text = "Zero-Touch Win11 23H2  | English     | Enterprise" }
        @{ Id = 2; Text = "Zero-Touch Win11 23H2  | Spanish     | Enterprise" }
        @{ Id = 3; Text = "Zero-Touch Win11 23H2  | French      | Enterprise" }
        @{ Id = 4; Text = "Zero-Touch Win11 23H2  | Portuguese  | Enterprise" }
        @{ Id = 5; Text = "Azure OSDCloud         | Enterprise" }
        @{ Id = 6; Text = "I'll select it myself" }
        @{ Id = 7; Text = "Exit" }
    )

    Write-Host "Select an option:" -ForegroundColor White
    foreach ($i in $items) {
        Write-Host ("  {0}: " -f $i.Id) -NoNewline -ForegroundColor Cyan
        Write-Host $i.Text -ForegroundColor Yellow
    }
    Write-Host ""
}

function Read-MenuSelection {
    param([int[]]$Valid = (1..7), [int]$Default = 7)
    while ($true) {
        $choice = Read-Host ("Enter choice [{0}]" -f ($Valid -join ","))

        if ([string]::IsNullOrWhiteSpace($choice)) {
            return $Default
        }
        if ($choice -as [int] -and ($Valid -contains [int]$choice)) {
            return [int]$choice
        }
        Write-Host "Invalid selection. Please enter: $($Valid -join ', ')." -ForegroundColor Red
    }
}

function Ensure-OSDModule {
    # Import first (fast path), then try install if needed
    if (Get-Module -ListAvailable -Name OSD | Select-Object -First 1) {
        Import-Module OSD -Force
        return
    }
    try {
        # Gallery path (may be blocked in WinPE—safe to try)
        Install-Module OSD -Force -Scope CurrentUser -AllowClobber -ErrorAction Stop | Out-Null
        Import-Module OSD -Force
    } catch {
        Write-Host "OSD module not found and cannot install from Gallery." -ForegroundColor Red
        Write-Host "Copy a known-good 'OSD' module to a modules path and rerun." -ForegroundColor Yellow
        throw
    }
}

# ---------------- Main ----------------

Set-Console
Write-Host "Starting LP Intune Custom OSDCloud..." -ForegroundColor Yellow
Write-BoxHeader
Write-Menu

$selection = Read-MenuSelection
Write-Host ""
Write-Host "Loading OSDCloud..." -ForegroundColor Yellow

# Ensure module is available
Ensure-OSDModule

switch ($selection) {
    1 { Start-OSDCloud -OSLanguage en-US -OSBuild 23H2 -OSEdition Enterprise -ZTI }
    2 { Start-OSDCloud -OSLanguage es-MX -OSBuild 23H2 -OSEdition Enterprise -ZTI }
    3 { Start-OSDCloud -OSLanguage fr-CA -OSBuild 23H2 -OSEdition Enterprise -ZTI }
    4 { Start-OSDCloud -OSLanguage pt-BR -OSBuild 23H2 -OSEdition Enterprise -ZTI }
    5 {
        # Prefer the cmdlet if present; otherwise use the original line
        if (Get-Command -Name Start-OSDCloudAzure -ErrorAction SilentlyContinue) {
            Start-OSDCloudAzure -OSEdition Enterprise
        } else {
            powershell.exe start-oscloudazure
        }
    }
    6 { Start-OSDCloud }  # Interactive (I'll select it myself)
    7 { Write-Host "Exiting..." -ForegroundColor Yellow; wpeutil reboot; return }
}

# After any deployment completes, reboot WinPE to continue
Write-Host ""
Write-Host "Deployment action finished. Rebooting WinPE..." -ForegroundColor Yellow
wpeutil reboot
