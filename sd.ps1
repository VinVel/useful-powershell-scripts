#!/usr/bin/env pwsh
#quick shutdown

if ($IsWindows) {
    Write-Host "Windows erkannt. Fahre System sofort herunter."
    shutdown /s /f /t 0
}
else {
    Write-Host "Unix-System erkannt. Fahre System sofort herunter."
    sudo shutdown -h now
}
