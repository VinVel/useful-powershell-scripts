#!/usr/bin/env pwsh

param (
    [string]$InputDir,
    [string]$PrimaryOutputDir,
    [string]$FallbackOutputDir,
    [int]$MinFreeSpaceGB = 50
)

# --- Interaktive Eingaben ---
if (-not $InputDir) {$InputDir = Read-Host "Pfad zum Eingabeordner"}

if (-not $PrimaryOutputDir) {$PrimaryOutputDir = Read-Host "Primärer Ausgabeordner"}

if (-not $FallbackOutputDir) {$FallbackOutputDir = Read-Host "Fallback-Ausgabeordner"}

# --- Validierung ---
foreach ($path in @($InputDir, $PrimaryOutputDir, $FallbackOutputDir)) {
    if (-not (Test-Path -LiteralPath $path)) {
        Write-Error "Pfad existiert nicht: $path"
        exit 1
    }
}

# --- Freien Speicher prüfen (am Laufwerk des PrimaryOutputDir) ---
function Get-FreeSpaceGB {
    param (
        [Parameter(Mandatory)]
        [string]$Path
    )

    $resolvedPath = Resolve-Path -LiteralPath $Path

    if ($IsWindows) {
        $drive = (Get-Item $resolvedPath).PSDrive
        return [math]::Floor($drive.Free / 1GB)
    }
    else {
        # Unix-like Systeme: df benutzen
        $dfOutput = df -Pk $resolvedPath.Path | Select-Object -Last 1
        $availableKB = ($dfOutput -split '\s+')[3]
        return [math]::Floor($availableKB / 1MB)
    }
}

$freeSpaceGB = Get-FreeSpaceGB -Path $PrimaryOutputDir

if ($freeSpaceGB -lt $MinFreeSpaceGB) {
    Write-Warning "Nur $freeSpaceGB GB frei. Nutze Fallback-Ziel."
    $OutputRoot = $FallbackOutputDir
} 
else {
    Write-Host "Genug Speicher vorhanden ($freeSpaceGB GB). Nutze primäres Ziel."
    $OutputRoot = $PrimaryOutputDir
}

# --- Dateien rekursiv verarbeiten ---
$videoFiles = Get-ChildItem -Path $InputDir -Recurse -File |
    Where-Object { $_.Extension -match '\.mkv$' }

if ($videoFiles.Count -eq 0) {
    Write-Warning "Keine MKV-Dateien gefunden."
    exit 0
}

foreach ($file in $videoFiles) {
    # Relativen Pfad berechnen
    $relativePath = $file.Directory.FullName.Substring($InputDir.Length).TrimStart('/')

    $targetDir = Join-Path $OutputRoot $relativePath
    $targetFile = Join-Path $targetDir ($file.BaseName + ".mkv")

    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir | Out-Null
    }

    Write-Host "Konvertiere:`n$file -> $targetFile"

    & ffmpeg `
        -hwaccel_device qsv `
        -i $file.FullName `
        -map 0:v:0 `
        -map 0:a `
        -map 0:s? `
		-map_chapters 0 `
        -c:v av1_qsv `
        -q:v 20 `
        -preset slower `
        -g 600 `
        -pix_fmt p010le `
        -c:a copy `
        -c:s copy `
        $targetFile

    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Fehler bei: $($file.FullName)"
    }
}

Write-Host "Konvertierung abgeschlossen."