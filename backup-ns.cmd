@echo off
set dism=%systemroot%\system32\dism.exe
IF NOT EXIST %dism% (
    set dism=dism.exe
    IF NOT EXIST %dism% GOTO stop3
)

set sourcedrv=%1
set destdir=%2
set scratchdir=%3

if NOT DEFINED destdir goto stop1
if NOT DEFINED sourcedrv goto stop2
set hr=%time:~0,2%
if "%hr:~0,1%" equ " " set hr=0%hr:~1,1%
set ifn="%destdir%\%date:~-4,4%%date:~-7,2%%date:~-10,2%%hr%%time:~3,2%%time:~6,2%.WIM"

IF NOT DEFINED scratchdir (
    %dism% /Capture-Image /imagefile:%ifn% /capturedir:%sourcedrv% /name:"%date:~6,4%-%date:~3,2%-%date:~0,2% %time:~0,5% %computername%" /description:"backup"
) ELSE (
    %dism% /Capture-Image /imagefile:%ifn% /capturedir:%sourcedrv% /name:"%date:~6,4%-%date:~3,2%-%date:~0,2% %time:~0,5% %computername%" /description:"backup" /scratchdir:%scratchdir%
)

:stop1
echo Please specify the destination path
goto ende
:stop2
echo Please specify a drive letter as the source drive
:stop3
echo Could not find DISM anywhere. Please make sure you're in the right path.
:ende