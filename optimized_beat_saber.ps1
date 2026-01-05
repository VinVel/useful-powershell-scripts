#windows only, optimize beat saber for youtube and youtube shorts with quick cuts

$InputFile = Read-Host "Pfad zur Eingabedatei"
$Start = Read-Host "Startzeit Full (HH:MM:SS)"
$Duration = Read-Host "Dauer Full (HH:MM:SS)"
$StartShort = Read-Host "Startzeit Short (HH:MM:SS)"
$DurationShort = Read-Host "Dauer Short (HH:MM:SS)"
$OutputName = Read-Host "Basisname der Ausgabedateien"
$OutputPath = "F:\Videos\Aufnahmen\Beat Saber Optimized"

if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath | Out-Null
}

# --- Validierung ---
if (-not (Test-Path -LiteralPath $InputFile)) {
    Write-Error "Eingabedatei existiert nicht."
    exit 1
}

if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Error "ffmpeg nicht im PATH."
    exit 1
}

# --- Full Video ---
$fullOutput = Join-Path $OutputPath "$OutputName.mkv"

Write-Host "Erzeuge Full Video:"
Write-Host $fullOutput

& ffmpeg `
    -hwaccel_device qsv `
    -i $InputFile `
    -ss $Start `
    -t $Duration `
    -vf "scale=3840:2160" `
    -c:v av1_qsv `
    -q:v 14 `
    -preset slow `
    -pix_fmt p010le `
    -c:a copy `
    $fullOutput

if ($LASTEXITCODE -ne 0) {
    Write-Error "Fehler beim Full-Encode."
    exit 1
}

# --- Short ---
$shortOutput = Join-Path $OutputPath "$OutputName Short.mkv"

Write-Host "Erzeuge Short:"
Write-Host $shortOutput

& ffmpeg `
    -hwaccel_device qsv `
    -i $InputFile `
    -ss $StartShort `
    -t $DurationShort `
    -vf "crop=607:1080:706:1080,scale=2160:3840" `
    -c:v av1_qsv `
    -q:v 14 `
    -preset slow `
    -pix_fmt p010le `
    -c:a copy `
    $shortOutput

if ($LASTEXITCODE -ne 0) {
    Write-Error "Fehler beim Short-Encode."
    exit 1
}

Write-Host "Beide Encodes abgeschlossen."