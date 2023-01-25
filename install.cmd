@echo off
if %COMPUTERNAME% NEQ MINWINPC GOTO protect:
set wsize=%2
set image=%3
IF %wsize% EQU 0 (
    set wsize=
    set strsize=fills disk 
) ELSE (
    set wsize=size %2
    set strsize=size is %2 MB
)
echo --^> Partitioning and formatting disk %1, Win partition %strsize%
IF /i %4 EQU --skip-oobe echo --^> Will use skip_oobe.xml to skip OOBE after installation
echo You can cancel this operation using CTRL+C, then confirming with y, or you can
pause
(echo sel dis %1
echo conv gpt
echo cre par efi size 512
echo form fs fat32 quick
echo ass letter w
echo cre par pri %wsize%
echo form quick
echo ass letter z
) | diskpart
echo --^> Installing Windows from install image %3
dism /apply-image /imagefile:%3 /index:1 /applydir:z:\
echo --^> Installing boot environment
bcdboot z:\windows /s w:

rem Skip OOBE (EXPERIMENTAL!)
IF /i %4 EQU --skip-oobe (
    echo --^> Modifying the extracted image to enable unattended mode to skip OOBE
    echo - Creating "Panther" directory under z:\Windows
    mkdir z:\Windows\Panther
    echo - Copying the answer file into the previously created Panther directory
    copy %~dp0\skip_oobe.xml z:\Windows\Panther\unattend.xml
)

echo Before we reboot, check the backlog for errors, then either cancel the reboot using CTRL+C or
pause
echo --^> Rebooting
wpeutil reboot

:protect
echo ^/^!^\ PROTECTION FAULT: This script is only intended to run the Windows PE Setup environment^!