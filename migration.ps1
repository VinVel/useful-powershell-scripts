#!/usr/bin/env pwsh
#ever changed out an external drive? this way you can migrate everything, it will overwrite other files in the destination

param (
    [string]$Source,
    [string]$Destination,
    [string]$LogFile = "~/Desktop/Purge.log",
    [int]$ShutdownDelay = 30
)

# --- Interaktive Eingabe, falls vergessen ---
if (-not $Source) {
    $Source = Read-Host "Pfad zum Quellordner: "
}

if (-not $Destination) {
    $Destination = Read-Host "Pfad zum Zielordner: "
}

# --- Überprüfe ob Path existiert ---
foreach ($path in @($Source, $Destination)) {
	if (-not (Test-Path -LiteralPath $path)) {
		Write-Error "Pfad existiert nicht: $path"
		exit 1
	}
}

Write-Host "Starte Migration"
Write-Host "Quelle: $Source"
Write-Host "Ziel: $Destination"
Write-Host "Log: $LogFile"

if ($IsWindows) {
	# --- Robocopy ---
	$robocopyArgs = @(
		$Source
		$Destination
		"/NP"
		"/E"
		"/ZB"
		"/COPYALL"
		"/R:2"
		"/W:5"
		"/TEE"
		"/MIR"
		"/LOG+:$LogFile"
	)

	& robocopy @robocopyArgs

	$rc = $LASTEXITCODE

	# Robocopy Exitcodes < 8 gelten als Erfolg
	if ($rc -ge 8) {
		Write-Error "Robocopy fehlgeschlagen (Exitcode $rc). Kein Shutdown."
		exit 1
	}
	else {
		Write-Host "Migration abgeschlossen (Exitcode $rc)."

		# --- Shutdown ---
		Write-Host "System fährt in $ShutdownDelay Sekunden herunter."
		shutdown /s /f /t $ShutdownDelay
	}
}
else {
	# --- Validierung für rsync ---
	if (-not (Get-Command rsync -ErrorAction SilentlyContinue)) {
		Write-Error "rsync nicht gefunden. Abbruch."
		exit 1
	}
	# --- rsync ---
	$rsyncArgs = @(
		"-a"
		"--delete"
		"--human-readable"
		"--progress"
		"--partial"
		"--log-file=$LogFile"
		"$Source/"
		"$Destination/"
	)

	& rsync @rsyncArgs
	$exitCode = $LASTEXITCODE

	if ($exitCode -ne 0) {
		Write-Error "rsync fehlgeschlagen (Exitcode $exitCode). Kein Shutdown."
		exit 1
	}
	else {
		Write-Host "Migration erfolgreich abgeschlossen."

		# --- Shutdown ---
		Write-Host "System fährt in $ShutdownDelay Sekunden herunter."
		sudo shutdown -h +0
	}
}