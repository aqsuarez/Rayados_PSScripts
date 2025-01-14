Write-Host  -ForegroundColor Yellow "Starting Rayados' Custom OSDCloud ..."
cls
Write-Host "===================== Main Menu =======================" -ForegroundColor Yellow
Write-Host "================== www.Rayados.pro ====================" -ForegroundColor Yellow
Write-Host "=======================@asuarez =======================" -ForegroundColor Yellow
Write-Host "=======================================================" -ForegroundColor Yellow
Write-Host "1: Zero-Touch Win11 23H2 | English    | Enterprise"-ForegroundColor Yellow
Write-Host "2: Zero-Touch Win11 23H2 | Spanish    | Enterprise" -ForegroundColor Yellow
Write-Host "3: Zero-Touch Win11 23H2 | French     | Enterprise" -ForegroundColor Yellow
Write-Host "4: Zero-Touch Win11 23H2 | Portuguese | Enterprise" -ForegroundColor Yellow
Write-Host "5: Azure OSDCloud        | Enterprise" -ForegroundColor Yellow
Write-Host "6: I'll select it myself"-ForegroundColor Yellow
Write-Host "7: Exit`n"-ForegroundColor Yellow
$input = Read-Host "Please make a selection"

Write-Host  -ForegroundColor Yellow "Loading OSDCloud..."

Import-Module OSD -Force
Install-Module OSD -Force

switch ($input)
{
    '1' { Start-OSDCloud -OSLanguage en-us -OSBuild 23H2 -OSEdition Enterprise -ZTI } 
    '2' { Start-OSDCloud -OSLanguage es-Mx -OSBuild 23H2 -OSEdition Enterprise -ZTI } 
    '3' { Start-OSDCloud -OSLanguage fr-CA -OSBuild 23H2 -OSEdition Enterprise -ZTI } 
    '4' { Start-OSDCloud -OSLanguage pt-BR -OSBuild 23H2 -OSEdition Enterprise -ZTI } 
    '5' { powershell.exe iex (irm az.osdcloud.com) } 
    '6' { Start-OSDCloud	} 
    '7' { Exit		}
}

wpeutil reboot
