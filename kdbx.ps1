#!/usr/bin/env pwsh
#creates three copies of my password manager safe

$source = "G:\Meine Ablage\Passwörter.kdbx"
$destinations = @("M:\", "N:\", "F:\Privat")
$destinations | ForEach-Object { Copy-Item -Path $source -Destination (Join-Path $_ "Passwörter.kdbx") -Verbose}