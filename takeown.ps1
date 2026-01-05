#!/usr/bin/env pwsh
#if there is an issue with ownership of a folder use this script

param (
    [string]$Target
)

if (-not $Target) {
    $Target = Read-Host "Bitte Pfad zur Datei oder zum Ordner eingeben"
}

if (-not (Test-Path -LiteralPath $Target)) {
    Write-Error "Pfad existiert nicht: $Target"
    exit 1
}

if ($IsWindows) {
    Write-Host "Windows erkannt. Übernehme Besitzrechte."
	if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
	).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Dieses Skript muss als Administrator ausgeführt werden."
    exit 1
	}
	else {& takeown /f "$Target" /r /d J}

    if ($LASTEXITCODE -ne 0) {
        Write-Error "takeown ist fehlgeschlagen."
        exit 1
    }
}
else {
    Write-Host "Unix-System erkannt. Setze Ownership auf aktuellen Benutzer."

    $user = whoami

    & sudo chown -R "$user" "$Target"

    if ($LASTEXITCODE -ne 0) {
        Write-Error "chown ist fehlgeschlagen."
        exit 1
    }
}

Write-Host "Vorgang abgeschlossen."
