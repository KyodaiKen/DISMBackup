@echo off
set dism=%systemroot%\system32\dism.exe
IF NOT EXIST %dism% (
    set dism=dism.exe
    IF NOT EXIST %dism% GOTO stop3
)

set imagefile=%1
set adir=%2
set scratchdir=%3

if NOT DEFINED imagefile goto stop1
if NOT DEFINED adir goto stop2
IF NOT DEFINED scratchdir (
    %dism% /apply-image /imagefile:%imagefile% /index:1 /applydir:%adir%
) ELSE (
    %dism% /apply-image /imagefile:%imagefile% /index:1 /applydir:%adir% /scratchdir:%scratchdir%
)

goto ende
:stop1
echo Please specify the image file
goto ende
:stop2
echo Please specify a drive letter as the destination drive like this: x:\
goto ende
:stop3
echo Could not find DISM anywhere. Please make sure you're in the right path.
:ende