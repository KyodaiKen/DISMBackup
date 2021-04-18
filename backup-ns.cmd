@echo off
set sourcedir=%1
set destdir=%~2
set myerr=0

rem config
rem change path to the binary if desired
set dism=%systemroot%\system32\dism.exe
rem set up a custom scratch directory here, otherwise it will be pulled from the third parameter passed and if not the DISM default is used
set scratchdir=%~3

rem validation
net session >nul 2>&1
IF NOT ERRORLEVEL 0 (
  ECHO You need administrative permissions to run this script.
  EXIT /B 1
)
IF NOT EXIST %dism% (
  set dism=dism.exe
  IF NOT EXIST %dism% (
    ECHO Could not find DISM anywhere.
    EXIT /B 2
  )
)
IF NOT DEFINED destdir (
  ECHO Please specify the destination path.
  EXIT /B 4
)
IF NOT EXIST "%destdir%" (
  ECHO Destination path is not accessible.
  EXIT /B 5
)
IF NOT DEFINED sourcedir (
  ECHO Please specify a source path.
  EXIT /B 6
)
IF %sourcedir:~0,2%==\\ (
  ECHO Network paths are not allowed.
  EXIT /B 7
)
IF NOT EXIST %sourcedir% (
  ECHO Source path is not accessible.
  EXIT /B 8
)

set hr=%time:~0,2%
if "%hr:~0,1%" equ " " set hr=0%hr:~1,1%
set ifn="%destdir%\%date:~-4,4%%date:~-7,2%%date:~-10,2%%hr%%time:~3,2%%time:~6,2%.WIM"

IF NOT DEFINED scratchdir (
    %dism% /Capture-Image /imagefile:%ifn% /capturedir:%sourcedir% /name:"%date:~6,4%-%date:~3,2%-%date:~0,2% %time:~0,5% %computername%" /description:"backup"
) ELSE (
    %dism% /Capture-Image /imagefile:%ifn% /capturedir:%sourcedir% /name:"%date:~6,4%-%date:~3,2%-%date:~0,2% %time:~0,5% %computername%" /description:"backup" /scratchdir:%scratchdir%
)
IF NOT ERRORLEVEL 0 (
  ECHO An error occured while creating the image file using DISM.
  EXIT /B 12
)
