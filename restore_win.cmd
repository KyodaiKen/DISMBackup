@echo off
echo --> Partitioning and formatting disk
(echo sel dis %1
echo conv gpt
echo cre par efi size 256
echo form fs fat32 quick
echo ass letter w
echo cre par pri
echo form quick
echo ass letter z
) | diskpart
echo --> Restoring Windows partition
dism /apply-image /imagefile:%2 /index:1 /applydir:z:\
echo --> Installing boot environment
bcdboot z:\windows /s w:
echo Before we reboot, check the backlog for errors and
pause
echo --> Rebooting
wpeutil reboot