**[English](README.md)**

# Einführung in DISMBackup
Dies ist ein Werkzeug zur Erstellung von Backups unter Verwendung von (fast) ausschließlich Werkzeugen, die von Windows bereit gestellt werden. Es wurde mittels der Batchscript-Sprache von Windows geschrieben, damit es auch in einer PE-Umgebung (zum Beispiel Windows Setup) funktioniert.

Diese Skriptsammung funktioniert ab Windows Vista bis zur neusten Windows 10 Version!

Die Abbilder werden in Microsoft's eigenen WIM-Format abgespeichert. Sie sind komprimiert und können mit dem Datei-Archivierer [7-zip](https://www.7-zip.org/) wie ein ZIP-Archiv geöffnet werden.

# Inhaltsverzeichnis
* [Installation](#Installation)
* [Verwendung](#Verwendung)
    * [Das aktuell ausgeführte Windows-System sichern](<#Das-aktuell-ausgeführte-Windows-System-sichern>)
    * [Backup einer einfachen Partition oder eines Verzeichnisses](<#Backup-einer-einfachen-Partition-oder-eines-Verzeichnisses>)
    * [Eine komplette Windows-Sicherheitskopie wiederherstellen und wieder bootfähig machen](<#Eine-komplette-Windows-Sicherheitskopie-wiederherstellen-und-wieder-bootfähig-machen>)
    * [Wiederherstellung einfacher Datensicherungen](<#Wiederherstellung-einfacher-Datensicherungen>)
    * [Optionale Parameter](#optionale-parameter)

# Installation
1. Man wählt sich ein beliebiges Installationsverzeichnis aus und kopiert die drei Scriptdateien in dieses.
2. Anschließend muss das [Microsoft Windows Volume Shadow Copy Service SDK](https://www.microsoft.com/en-us/download/details.aspx?id=23490) herungergeladen und ohne den Installationspfad zu verändern installiert werden. Keine Sorge, es ist recht klein.
3. Nach der Installation muss die Datei `vshadow.exe` aus dem Installationspfad `C:\Program Files (x86)\Microsoft\VSSSDK72\TestApps\vshadow\bin\obj-chk\amd64` (oder einfach die Windows-XP version nutzen für 32-bit) in das Verzeichnis mit in dem DISMBackup installiert ist kopiert werden.
4. Wer will, kann selbstverständlich den DISMBackup-Installationspfad zur PATH-Variable hinzufügen. Anleitung findet sich [hier](http://techmixx.de/windows-10-umgebungsvariablen-bearbeiten/) und für Windows 7 [hier](https://www.pctipp.ch/tipps-tricks/kummerkasten/windows-7/artikel/windows-path-aendern-50647/).
5. Das Volume Shadow Copy Service SDK kann auch ganz normal über Software oder "Apps & Features" deinstalliert werden.
6. Das war's auch schon! DISMBackup ist bereit.

# Verwendung
## Das aktuell ausgeführte Windows-System sichern
Um loszulegen muss zunächst eine Eingabeaufforderung mit administrativen Rechten geöffnet werden.
Wir geben fall folgendes ein:
```
backup <Pfad zum Sichern> <Zielpfad>
```
**Beispiel:**
```
backup c:\ B:\Backup\MyBackup
```
Dies erstell ein Sicherungsabbild mit einem eindeutigen Dateinamen, welcher aus dem aktuellen Datum und der Uhrzeit ohne Trennzeichen gebildet wird. Die Dateiendung lautet .WIM und diese Dateien können auch mit dem Datei-Archivierer [7-zip](https://www.7-zip.org/) wie ein ZIP-Archiv geöffnet werden.

## Backup einer einfachen Partition oder eines Verzeichnisses
Wie oben brauchen wir auch hier eine Eingabeaufforderung mit Administrator-Rechten.
Eingegeben wird jedoch:
```
backup-ns <Pfad zum Sichern> <Zielpfad>
```
**Beispiel:**
```
backup-ns d:\git B:\Backup\git
```
## Eine komplette Windows-Sicherheitskopie wiederherstellen und wieder bootfähig machen

> **WICHTIG: Haftungsausschluss! - Diese Prozedur kann wichtige Daten zerstören, wenn nicht korrekt angewendet. Für etwaige Folgen übernehme ich keinerlei Haftung. Wer dieser Anleitung folgt, tut dies auf eigene Verantwortung!**

Zuerst startet man von einem Bootmedium auf dem Windows läuft oder von dem originalen Windows-Installationsmedium, bei dem man eine Administrator-Eingabeaufforderung mit UMSCHALT+F10 öffnen kann.
1. Die Zielpartition mit folgendem Befehl formatieren:
    ```
    format <Laufwerksbuchstabe> /FS:NTFS /q /Y
    ```
    > **/!\ ACHTUNG - DIES LÖSCHT ALLE DATEN VON DER PARTITION! /!\\**

2. Mit folgendem Befehl wird die Wiederherstellung gestartet:
    ```
    restore_backup <Pfad mit Dateiname des Sicherungsabbildes> <Ziel-Laufwerksbuchstabe>:
    ```
    **Beispiel:**
    ```
    d:\restore_backup B:\Backups\MyBackup\1234567890.WIM E:\
    ```
3. Nachdem der Vorgang beendet wurde muss man noch die Startumgebung von Windows wieder aufbauen. Dies geschieht mit folgendem Befehl:
    ```
    bootfix <Laufwerksbuchstabe> <Sprachschlüssel wie zum Beispiel en-US or de-DE>
    ```
    Beispiel:
    ```
    d:\bootfix E: de-DE
    ```
## Wiederherstellung einfacher Datensicherungen
Wie vorhin bei der Erstellung eines Backups brauchen wir auch hier eine Eingabeaufforderung mit Administrator-Rechten und führt folgenden Befehl darin aus:
```
restore_backup <Pfad mit Dateiname des Sicherungsabbildes> <Pfad in dem die Daten wiederhergestellt werden sollen>
```
**Beispiel:**
```
restore_backup B:\Backups\MyBackup\1234567890.WIM D:\OldFiles
```
Anmerkung: Dies ist wie das Entpacken eines Archives. Falls alte Daten gelöscht werden sollen, muss man dies vorher selbst tun. Entweder durch Formatieren oder Löschen/Leeren des Zielordners.

## Optionale Parameter
Jedem Skript (bis auf `bootfix`) kann ein dritter Parameter angehängt werden, um das *Scratch Directory* von DISM anzugeben. Dieses Verzeichnis wird dazu genutzt um temporäre Dateien während der Verarbeitung abzulegen.

Beispiele:
> `t:\temp` ist in disen Beispielen der *Scratch Directory*-Parameter.

```
backup x: b:\backup\x t:\temp
backup-ns x:\ b:\backup\x t:\temp
restore_backup b:\backup\x x:\ t:\temp
```
