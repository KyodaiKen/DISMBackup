**[Deutsch](LIESMICH.md)**

# Introduction to DISMBackup
This is a tool for creating backups using (almost) only Windows board tools. It makes it easier to create and restore backups with simple commands. It is written in the regular Windows batch script language, which makes it possible to also use those in the Windows PE (pre environment) such as the Windows Setup or Windows boot media.

This script collection works from Windows Vista until the latest Windows 10 version.

The file format of the images is Microsoft's WIM-Format, which can be opened using the file archiver [7-zip](https://www.7-zip.org/).

# Table of contents
* [Installation](#Installation)
* [Usage](#Usage)
    * [Backing up your currently running Windows image](#backing-up-your-currently-running-windows-image)
    * [Backup a simple partition or directory](#backup-a-simple-partition-or-directory)
    * [Restore complete Windows drive and make it boot](#restore-complete-windows-drive-and-make-it-boot)
    * [Restore simple data](#restore-simple-data)
    * [Optional parameters](#optional-parameters)

# Installation
1. You choose any directory on your PC or boot media and place the scripts there. Then you go ahead and download [Microsoft Windows Volume Shadow Copy Service SDK](https://www.microsoft.com/en-us/download/details.aspx?id=23490). It is not that big, don't worry.
2. Install the SDK to the default installation location
3. After setup, you go to the directory `C:\Program Files (x86)\Microsoft\VSSSDK72\TestApps\vshadow\bin\obj-chk\amd64` and copy the file `vshadow.exe` into the same directory as the DISMBackup scripts.
4. Optional: Add your DISMBackup directory to the PATH variable for easier access
5. Optional: Uninstall the SDK from the Apps & Features control panel
6. Optional: Add DISM.EXE as an exception to Windows Defender or other anti virus, it will speed it up a lot!
7. That's it. You've successfully installed the DISMBackup scripts!

# Usage
## Backing up your currently running Windows image
To create a backup, just enter this in an administrator privileged console:
```
backup <full path to backup WITHOUT BACKSLASH AT THE END> <destination path>
```
**Example:**
```
backup c:\ B:\Backup\MyBackup
```
This will create a backup with a unique file name in it. The file name is composited by the current date and time without spaces and extra characters. The backup file is a .WIM file which can be opened using the file archiver [7-zip](https://www.7-zip.org/)
## Backup a simple partition or directory
To create a backup, just enter this in an administrator privileged console:
```
backup-ns <path to backup> <destination path>
```
**Example:**
```
backup-ns d:\git B:\Backup\git
```
## Restore a complete Windows installation and make it boot

See [Install Windows from WIM Backup using the restore_win scripts](install_windows_from_backup.md)

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
## Optional parameters
### Scratch directory
All scripts except of course the `bootfix` script support a third parameter to specify the DISM scratch directory. This is useful if you want to use a RAMDISK for it or a specific drive.

In case you don't know what the scratch directory is: DISM uses a directory to store some temporary files while processing.

Examples:
> Where `t:\temp` is the scratch directory in the above examples.
```
backup x: b:\backup\x t:\temp
backup-ns x:\ b:\backup\x t:\temp
restore_backup b:\backup\x x:\ t:\temp
```
