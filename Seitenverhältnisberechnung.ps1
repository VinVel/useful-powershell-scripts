#!/usr/bin/env pwsh

function Berechnung {
    param(
        [int]$Breite,
        [int]$Hoehe,
        [int]$BVL,
        [int]$HVL
    )

    # Berechnung der neuen Werte
    $Neue_Breite = [int]($Hoehe * ($BVL / $HVL))
    $Neue_Hoehe = [int]($Breite * ($HVL / $BVL))

    # Rückgabe als Array
    return $Neue_Breite, $Neue_Hoehe
}

# Eingabe der Werte durch den Benutzer
$Breite = [int](Read-Host "Breite: ")
$Hoehe = [int](Read-Host "Höhe: ")
$BVL = [int](Read-Host "Breitenverhältnislänge: ")
$HVL = [int](Read-Host "Höhenverhältnislänge: ")

# Aufruf der Funktion und Ausgabe des Ergebnisses
$Ergebnis = Berechnung -Breite $Breite -Hoehe $Hoehe -BVL $BVL -HVL $HVL
Write-Output "Errechnung der Breite x Höhe: $Ergebnis"   