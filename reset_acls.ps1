#!/usr/bin/env pwsh
#if there is an issue with acls of a folder use this script


param (
    [string]$Target,
    [string]$User
)

if (-not $Target) {
    $Target = Read-Host "Pfad zur Datei oder zum Ordner"
}

if (-not (Test-Path -LiteralPath $Target)) {
    Write-Error "Pfad existiert nicht: $Target"
    exit 1
}

if ($IsWindows) {

    if (-not $User) {
        $User = "$env:USERDOMAIN\$env:USERNAME"
    }

    Write-Host "Windows erkannt. Setze NTFS-Rechte für $User"

    & icacls "$Target" /grant "$User:F" /t /c

    if ($LASTEXITCODE -ne 0) {
        Write-Error "icacls fehlgeschlagen."
        exit 1
    }
}
else {

    if (-not $User) {
        $User = (whoami)
    }

    Write-Host "Unix-System erkannt. Setze rwx-Rechte für Benutzer $User"

    & sudo chmod -R u+rwX "$Target"

    if ($LASTEXITCODE -ne 0) {
        Write-Error "chmod fehlgeschlagen."
        exit 1
    }
}

Write-Host "Rechte erfolgreich gesetzt."
