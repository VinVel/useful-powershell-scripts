# ================== Konfiguration ==================
$RepoApiUrl   = "https://api.github.com/repos/BtbN/FFmpeg-Builds/releases/latest"
$AssetName    = "ffmpeg-master-latest-win64-gpl-shared.zip"
$BinTarget    = "C:\Users\vinvel\usr-bin"
$StateFile    = "$PSScriptRoot\last_release.txt"
$TempDir      = "$PSScriptRoot\ffmpeg_tmp"
$ZipPath      = "$TempDir\$AssetName"

# GitHub mag User-Agent
$Headers = @{ "User-Agent" = "PowerShell" }

# ================== Vorbereitung ==================
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
New-Item -ItemType Directory -Path $BinTarget -Force | Out-Null

# ================== Release abrufen ==================
$release = Invoke-RestMethod -Uri $RepoApiUrl -Headers $Headers

$releaseId = $release.id

if (Test-Path $StateFile) {
    $lastReleaseId = Get-Content $StateFile
    if ($lastReleaseId -eq $releaseId) {
        Write-Host "Kein neuer Release. Alles bleibt wie es ist."
        exit 0
    }
}

# ================== Asset finden ==================
$asset = $release.assets | Where-Object { $_.name -eq $AssetName }

if (-not $asset) {
    throw "Release gefunden, aber Asset '$AssetName' existiert nicht."
}

# ================== Download ==================
Write-Host "Neuer Release erkannt. Lade FFmpeg herunter..."

Invoke-WebRequest `
    -Uri $asset.browser_download_url `
    -OutFile $ZipPath `
    -Headers $Headers

# ================== Entpacken ==================
Expand-Archive -Path $ZipPath -DestinationPath $TempDir -Force

# ================== EXE-Dateien kopieren ==================
$exeFiles = Get-ChildItem -Path $TempDir -Recurse -Filter *.exe

foreach ($exe in $exeFiles) {
    Copy-Item $exe.FullName -Destination $BinTarget -Force
}

# ================== Aufräumen ==================
if (Test-Path $TempDir) {
    Remove-Item $TempDir -Recurse -Force
}

# ================== Release-Stand speichern ==================
Set-Content -Path $StateFile -Value $releaseId

Write-Host "FFmpeg erfolgreich aktualisiert."
