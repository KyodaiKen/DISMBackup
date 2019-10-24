**[Deutsch](LIESMICH.md)**

# Introduction to DISMBackup
This is a tool for creating backups using (almost) only Windows 7 or Windows 10 board tools. It makes it easier to create and restore backups with simple commands. It is written in the regular Windows batch script language, which makes it possible to also use those in the Windows PE (pre environment) such as the Windows Setup or Windows boot media.

# Table of contents
* [Installation](#Installation)
* [Usage](#Usage)
    * [Backing up your currently running Windows image](<#Backing up your currently running Windows image>)
    * [Backup a simple partition or directory](<#Backup a simple partition or directory>)
    * [Restore complete Windows drive and make it boot](<#Restore complete Windows drive and make it boot>)
    * [Restore simple data](<#Restore simple data>)

# Installation
1. You choose any directory on your PC or boot media and place the scripts there. Then you go ahead and download [Microsoft Windows Volume Shadow Copy Service SDK](https://www.microsoft.com/en-us/download/details.aspx?id=23490). It is not that big, don't worry.
2. Install the SDK to the default installation location
3. After setup, you go to the directory `C:\Program Files (x86)\Microsoft\VSSSDK72\TestApps\vshadow\bin\obj-chk\amd64` and copy the file `vshadow.exe` into the same directory as the DISMBackup scripts.
4. Optional: Add your DISMBackup directory to the PATH variable for easier access
5. Optional: Uninstall the SDK from the Apps & Features control panel
6. That's it. You've successfully installed the DISMBackup scripts!

# Usage
## Backing up your currently running Windows image
To create a backup, just enter this in an administrator privileged console:
```
backup <driveletter to backup>: <destination path>
```
**Example:**
```
backup c: B:\Backup\MyBackup
```
This will create a backup with a unique file name in it. The file name is composited by the current date and time without spaces and extra characters. The backup file is a .WIM file which can be opened using the file archiver [7-zip](ttps://www.7-zip.org/)
## Backup a simple partition or directory
To create a backup, just enter this in an administrator privileged console:
```
backup-ns <path to backup> <destination path>
```
**Example:**
```
backup-ns d:\git B:\Backup\git
```
## Restore complete Windows drive and make it boot
---
**IMPORTANT NOTE: Disclaimer - This procedure is data destructive. By following along with this you do so at your own risk!**
---
First you need to be booted up in an environment where you are able to format and repopulate the drive where you want to restore your Windows. This could be the Windows Setup (SHIFT+F10 opens the admin console) or another Windows that is booted up.

1. Format the destination partition using the format statement:
```
format <driveletter> /FS:NTFS /q /Y
```
---
**/!\ WARNING - THIS DELETES ALL DATA ON THAT PARTITION OF THE DRIVE /!\\**
---
2. Run the restore_data script with the following syntax:
```
restore_backup <image file path and name> <drive letter>:
```
**Example:**
```
restore_backup B:\Backups\MyBackup\1234567890.WIM E:\
```
3. After the restore has finished, you need to rebuild the boot environment of Windows like this:
```
<driveletter>\windows\system32\bcdboot <driveletter>\windows /l <language code like en-US or de-DE>
```
Example:
```
E:\windows\system32\bcdboot E:\windows /l de-DE
```
## Restore simple data
To restore a backup, just enter this in an administrator privileged console:
```
restore_backup <image file path and name> <path where the image file is restored>
```
Example
```
restore_backup B:\Backups\MyBackup\1234567890.WIM D:\OldFiles
```
Please note, it's like extracting an archive. You may want to clear your destination directory or format your destination drive.