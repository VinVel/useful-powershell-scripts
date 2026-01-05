#!/usr/bin/env pwsh
#filters out any videos shorter than one minute or longer than five minutes

# Ordner mit MKV-Dateien
$folder = "F:/Videos/YT-DLP/Ronn Dances"

# Dauer-Grenzen in Sekunden
$minDuration = 60
$maxDuration = 300

Get-ChildItem -Path $folder -Filter *.mkv | ForEach-Object {

    $file = $_.FullName

    # ffprobe: Dauer in Sekunden (Float)
    $duration = & ffprobe `
        -v error `
        -select_streams v:0 `
        -show_entries format=duration `
        -of default=noprint_wrappers=1:nokey=1 `
        "$file"

    # Falls ffprobe Müll zurückgibt
    if (-not $duration) {
        Write-Host "Übersprungen (keine Dauer ermittelbar): $($_.Name)"
        return
    }

    $duration = [double]$duration

    if ($duration -lt $minDuration -or $duration -gt $maxDuration) {
        Write-Host "Gelöscht: $($_.Name) ($([math]::Round($duration,2)) s)"
        Remove-Item "$file" -Force
    }
    else {
        Write-Host "Behalten: $($_.Name) ($([math]::Round($duration,2)) s)"
    }
}
