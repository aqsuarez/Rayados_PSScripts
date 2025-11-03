#requires -Version 5.1
# Single-file WinForms GUI for OSDCloud / OSDCloudAzure
# Works in WinPE. Arrow/Tab friendly. Brand: Rayados.pro / @asuarez

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.Encoding]::UTF8

function Import-OSDModule {
    Write-Host "Loading OSD/OSDCloud..." -ForegroundColor Yellow
    $candidates = @(
        (Join-Path $PSScriptRoot 'Modules\OSD\OSD.psd1'),
        'C:\Program Files\WindowsPowerShell\Modules\OSD\OSD.psd1',
        'C:\Program Files\PowerShell\Modules\OSD\OSD.psd1',
        'C:\OSDCloud\Modules\OSD\OSD.psd1'
    )
    foreach ($p in $candidates) {
        if (Test-Path $p) { Import-Module $p -Force -ErrorAction Stop; return }
    }
    try {
        $repo = Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue
        if ($repo) { Set-PSRepository PSGallery -InstallationPolicy Trusted -ErrorAction SilentlyContinue }
        Install-Module OSD -Force -Scope CurrentUser -AllowClobber -ErrorAction Stop
        Import-Module OSD -Force -ErrorAction Stop
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Could not import OSD module. Pre-copy a known-good OSD folder to .\Modules\OSD and retry.`r`n`r`n$($_.Exception.Message)",
            "OSDCloud", 'OK', 'Error'
        ) | Out-Null
        throw
    }
}

# ---------- Form + Theme ----------
$Form                = New-Object System.Windows.Forms.Form
$Form.Text           = "Rayados' Custom OSDCloud"
$Form.Size           = New-Object System.Drawing.Size(680, 420)
$Form.StartPosition  = 'CenterScreen'
$Form.TopMost        = $false

$hdr = New-Object System.Windows.Forms.Label
$hdr.Text      = "OSDCloud  —  Rayados.pro    @asuarez"
$hdr.AutoSize  = $false
$hdr.Dock      = 'Top'
$hdr.Height    = 40
$hdr.TextAlign = 'MiddleCenter'
$hdr.Font      = New-Object System.Drawing.Font('Segoe UI Semibold', 12)
$hdr.BackColor = [System.Drawing.Color]::FromArgb(255, 25, 118, 210)
$hdr.ForeColor = [System.Drawing.Color]::White
$Form.Controls.Add($hdr)

$Tabs = New-Object System.Windows.Forms.TabControl
$Tabs.Dock = 'Fill'
$Form.Controls.Add($Tabs)

# ---------- Tab 1: Azure (like the screenshot) ----------
$tabAzure = New-Object System.Windows.Forms.TabPage
$tabAzure.Text = "Azure"
$Tabs.TabPages.Add($tabAzure)

function New-Row([string]$labelText, [int]$top) {
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = $labelText
    $lbl.Left = 24; $lbl.Top = $top+3; $lbl.Width = 140
    $lbl.Font = New-Object System.Drawing.Font('Segoe UI', 10)
    $ctl = New-Object System.Windows.Forms.ComboBox
    $ctl.Left = 170; $ctl.Top = $top; $ctl.Width = 420
    $ctl.Font = New-Object System.Drawing.Font('Segoe UI', 10)
    $ctl.DropDownStyle = 'DropDown' # allow typing or choosing
    return ,@($lbl,$ctl)
}

$y = 24
$lblSA, $cbSA = New-Row "Storage Account" $y;       $tabAzure.Controls.AddRange(@($lblSA,$cbSA)); $y+=44
$lblCT, $cbCT = New-Row "Container" $y;             $tabAzure.Controls.AddRange(@($lblCT,$cbCT)); $y+=44
$lblBL, $cbBL = New-Row "Blob" $y;                  $tabAzure.Controls.AddRange(@($lblBL,$cbBL)); $y+=44
$lblIX, $cbIX = New-Row "Index" $y;                 $tabAzure.Controls.AddRange(@($lblIX,$cbIX)); $y+=44
$lblDP, $cbDP = New-Row "Driver Pack" $y;           $tabAzure.Controls.AddRange(@($lblDP,$cbDP)); $y+=60

$cbIX.Items.AddRange(@('Auto','1','2','3','4','5','6','7','8','9','10'))
$cbIX.Text = 'Auto'

$cbDP.Items.AddRange(@(
    'Microsoft Update Catalog',
    'Dell','HP','Lenovo','Surface','Nutanix','USB','*'
))
$cbDP.SelectedIndex = 0

# Helpful presets (optional; you can edit to your own)
$cbSA.Items.AddRange(@('azosdclouddev','lpcmgstorage01'))
$cbCT.Items.AddRange(@('images','wim','media'))
$cbBL.Items.AddRange(@('20220512_Win11_English_x64.wim','Win11_23H2_Enterprise_en-us.wim'))

$btnStartAzure = New-Object System.Windows.Forms.Button
$btnStartAzure.Text = "Start"
$btnStartAzure.Width = 120; $btnStartAzure.Height = 36
$btnStartAzure.Left = 470; $btnStartAzure.Top = $y
$btnStartAzure.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 10)
$tabAzure.Controls.Add($btnStartAzure)

# ---------- Tab 2: Presets (your ZTI menu) ----------
$tabPresets = New-Object System.Windows.Forms.TabPage
$tabPresets.Text = "Zero-Touch Presets"
$Tabs.TabPages.Add($tabPresets)

$lblInfo = New-Object System.Windows.Forms.Label
$lblInfo.Text = "Choose a Zero-Touch preset (Win11 23H2 Enterprise):"
$lblInfo.Left = 24; $lblInfo.Top = 24; $lblInfo.Width = 500
$lblInfo.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$tabPresets.Controls.Add($lblInfo)

function New-PresetButton([string]$text,[int]$left,[int]$top,[scriptblock]$onClick){
    $b = New-Object System.Windows.Forms.Button
    $b.Text = $text
    $b.Left = $left; $b.Top = $top; $b.Width = 280; $b.Height = 40
    $b.Font = New-Object System.Drawing.Font('Segoe UI', 10)
    $b.Add_Click($onClick)
    return $b
}

$btnEN = New-PresetButton "EN-US  (ZTI)" 24 70 { Start-OSDCloud -OSLanguage en-US -OSBuild 23H2 -OSEdition Enterprise -ZTI }
$btnES = New-PresetButton "ES-MX  (ZTI)" 24 120 { Start-OSDCloud -OSLanguage es-MX -OSBuild 23H2 -OSEdition Enterprise -ZTI }
$btnFR = New-PresetButton "FR-CA  (ZTI)" 24 170 { Start-OSDCloud -OSLanguage fr-CA -OSBuild 23H2 -OSEdition Enterprise -ZTI }
$btnPT = New-PresetButton "PT-BR  (ZTI)" 24 220 { Start-OSDCloud -OSLanguage pt-BR -OSBuild 23H2 -OSEdition Enterprise -ZTI }
$btnAZ = New-PresetButton "Azure OSDCloud" 330 70 { powershell.exe Start-OSDCloudAzure }
$btnIN = New-PresetButton "Interactive (I’ll pick)" 330 120 { Start-OSDCloud }

$tabPresets.Controls.AddRange(@($btnEN,$btnES,$btnFR,$btnPT,$btnAZ,$btnIN))

# ---------- Actions ----------
# Import OSD on load
$Form.Add_Shown({
    try { Import-OSDModule } catch { $Form.Close() }
})

$btnStartAzure.Add_Click({
    try {
        Import-OSDModule

        # Collect values
        $sa = $cbSA.Text.Trim()
        $ct = $cbCT.Text.Trim()
        $bl = $cbBL.Text.Trim()
        $ix = $cbIX.Text.Trim()
        $dp = $cbDP.Text.Trim()

        # Build params loosely (fallback to no params if binding fails)
        $params = @{}
        if ($sa) { $params['StorageAccount'] = $sa }
        if ($ct) { $params['Container']      = $ct }
        if ($bl) { $params['Blob']           = $bl }
        if ($ix -and $ix -ne 'Auto') { $params['Index'] = [int]$ix }
        if ($dp) { $params['DriverPack']     = $dp }

        Write-Host "Launching Start-OSDCloudAzure with parameters:" -ForegroundColor Cyan
        $params.GetEnumerator() | ForEach-Object { Write-Host ("  - {0}: {1}" -f $_.Key,$_.Value) -ForegroundColor DarkCyan }

        try {
            Start-OSDCloudAzure @params
        } catch {
            # If parameter names differ in your OSD version, fall back to interactive
            Write-Host "Falling back to Start-OSDCloudAzure (no params): $($_.Exception.Message)" -ForegroundColor DarkYellow
            Start-OSDCloudAzure
        }
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Azure launch failed:`r`n$($_.Exception.Message)",
            "OSDCloud Azure", 'OK', 'Error'
        ) | Out-Null
    }
})

# ---------- Footer buttons ----------
$panel = New-Object System.Windows.Forms.Panel
$panel.Dock = 'Bottom'
$panel.Height = 50
$Form.Controls.Add($panel)

$btnReboot = New-Object System.Windows.Forms.Button
$btnReboot.Text = "Reboot"
$btnReboot.Width = 120; $btnReboot.Height = 32
$btnReboot.Left = 24; $btnReboot.Top = 9
$btnReboot.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$btnReboot.Add_Click({ wpeutil reboot })
$panel.Controls.Add($btnReboot)

$btnExit = New-Object System.Windows.Forms.Button
$btnExit.Text = "Exit"
$btnExit.Width = 120; $btnExit.Height = 32
$btnExit.Left = 520; $btnExit.Top = 9
$btnExit.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$btnExit.Add_Click({ $Form.Close() })
$panel.Controls.Add($btnExit)

# ---------- Run ----------
[void]$Form.ShowDialog()
