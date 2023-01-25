@echo off
IF NOT DEFINED %2 ( set wsize= ) ELSE ( set wsize=size %2 )
echo --> Partitioning and formatting disk %1, Win partition size %2 MB
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
echo --> Installing Windows from install image %3
dism /apply-image /imagefile:%3 /index:1 /applydir:z:\
echo --> Installing boot environment
bcdboot z:\windows /s w:
echo Before we reboot, check the backlog for errors and
pause
echo --> Rebooting
wpeutil reboot