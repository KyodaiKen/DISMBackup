# Install Windows from WIM Backup using the restore_win scripts
## Requirements
1. Destination drive must be clean (new, or cleaned using diskpart clean command or wiped using DBAN, etc.)
2. You are in the Windows setup command input (cmd.eve SHIFT+F10 to open it).
3. Navigate to your DISM toolchain script path using `cd /d path`.
4. Use Diskpart `list disk` command to determine the disk you want to use.

## Running the script
### Fill disk with Windows OS
```
resotre_win diskid wimimage
```

Example:

```
restore_win 0 mybackup.wim
```

Resulting disk layout:

```
 256MB rest of disk
-------------------------------------
| EFI | OS                          |
-------------------------------------
```

### Install Windows backup in sized partition
```
resotre_win diskid partsize wimimage
```

Example:

```
restore_win 0 524288 mybackup.wim
```

Resulting disk layout:

```
 256MB  524288MB       rest 
-------------------------------------
| EFI | OS            | unallocated |
-------------------------------------
```

# Manually install Windows from WIM Backup / How does the script work?
## Requirements
1. Destination drive must be clean (new, or cleaned using diskpart clean command or wiped using DBAN, etc.)
2. You are in the Windows setup command input (cmd.eve SHIFT+F10 to open it).

## Setting up the boot enviromnent
```cmd
diskpart
sel dis 0
conv gpt
cre par efi size 100
form fs fat32 quick
ass letter w
cre par pri size 524288
form quick
ass letter z
exit
```

## "Installing" your backed up Windows image

```cmd
dism /apply-image /imagefile:c:\mybackup.wim /index:1 /applydir:z:\
bcdboot z:\windows /s w:
```

This installs Windows from your image into a 512 GByte large OS partition.

## Partition size for OS

You can change the size in the line  

```cmd
cre par pri size your_size_in_mbyte_here
```

on drive 0 from the image c:\mybackup.wim.

## Rebooting

```cmd
wpeutil reboot
```

And there we are! Your restored Windows image is now booting!