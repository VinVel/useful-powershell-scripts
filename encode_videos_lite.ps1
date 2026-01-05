#!/usr/bin/env pwsh

param (
    [string]$Origin,
    [string]$Output
)

# --- Interaktive Eingabe, falls vergessen ---
if (-not $Origin) {
    $Origin = Read-Host "Pfad zum Quellordner mit Videos"
}

if (-not $Output) {
    $Output = Read-Host "Pfad zum Zielordner für encodierte Videos"
}

# --- Validierung ---
if (-not (Test-Path -LiteralPath $Origin -PathType Container)) {
    Write-Error "$Origin existiert nicht"
    exit 1
}

if (-not (Test-Path -LiteralPath $Output)) {
    Write-Host "Zielordner existiert nicht. Erstelle: $Output"
    New-Item -ItemType Directory -Path $Output | Out-Null
}

# --- Videodateien suchen ---
Write-Host "Suche Videodateien in:`n$Origin"

$videoFiles = Get-ChildItem -Path $Origin -File |
    Where-Object { $_.Extension -match '\.(mkv|mp4)$' }

if ($videoFiles.Count -eq 0) {
    Write-Warning "Keine Videodateien gefunden."
    exit 0
}

# --- Verarbeitung ---
foreach ($file in $videoFiles) {
    Write-Host "Konvertiere: $($file.Name)"

    $outputFile = Join-Path $Output ($file.BaseName + ".mkv")

    & ffmpeg `
        -hwaccel_device qsv `
        -i $file.FullName `
        -map 0:v:0 `
        -map 0:a `
        -map 0:s `
        -c:v av1_qsv `
        -q:v 35 `
        -preset medium `
        -g 240 `
        -pix_fmt p010le `
        -c:a copy `
        -c:s copy `
        $outputFile

    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Fehler bei Datei: $($file.Name)"
    }
}

Write-Host "Alle Dateien verarbeitet."