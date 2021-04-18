@echo off
set sourcedir=%~1
set sourcedrv=%sourcedir:~0,2%
set srcpathonly=%sourcedir:~3%
set destdir=%~2
set myerr=0

rem config
rem change paths to the binaries if desired
set dism=%systemroot%\system32\dism.exe
set vshadow=%~dp0\vshadow.exe
rem set up a custom scratch directory here, otherwise it will be pulled from the third parameter passed and if not the DISM default is used
set scratchdir=%~3
rem set dellogonsuccess to 0 if you wish to keep the log file even when the operation ran successful
set dellogonsuccess=1

rem validation
net session >nul 2>&1
IF NOT ERRORLEVEL 0 (
  ECHO You need administrative permissions to run this script.
  EXIT /B 1
)
IF NOT EXIST %dism% >NUL 2>&1 (
  set dism=dism.exe
  IF NOT EXIST %dism% >NUL 2>&1 (
    ECHO Could not find DISM anywhere.
    EXIT /B 2
  )
)
IF NOT EXIST "%vshadow%" >NUL 2>&1 (
  ECHO Could not find vshadow.exe anywhere.
  EXIT /B 3
)
IF NOT DEFINED destdir (
  ECHO Please specify the destination path.
  EXIT /B 4
)
IF NOT EXIST "%destdir%" >NUL 2>&1 (
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
IF %srcpathonly:~-1%==\ (
  ECHO Path must not end with a backslash.
  EXIT /B 12
)
IF NOT EXIST "%sourcedir%" >NUL 2>&1 (
  ECHO Source path is not accessible.
  EXIT /B 8
)

rem creating the shadow copy
echo Determining free drive letter for the volume shadow copy...
for %%l in (P Q R S T U V W X Y Z D E F G H I J K L M N O) do (  
  set scd=%%l
  mountvol %%l: /L >nul
  if errorlevel 1 (
    subst | findstr /B "%%l:" >nul
    if errorlevel 1 (
      net use %%l: >nul 2>&1
      if errorlevel 1 goto end
    )
  )
)
:end

echo Will use %scd%...
echo Creating shadow copy of drive %sourcedrv%...
set hr=%time:~0,2%
if "%hr:~0,1%" equ " " set hr=0%hr:~1,1%
set fn=%date:~-4,4%%date:~-7,2%%date:~-10,2%%hr%%time:~3,2%%time:~6,2%
set ifn="%destdir%\%fn%.WIM"
set log="%destdir%\%fn%.TXT"
%vshadow% -p -script="%destdir%\vshadowtemp.cmd" %sourcedrv% >>%log%
IF NOT ERRORLEVEL 0 (
  ECHO An error occured while preparing the shadow copy.
  set myerr=9
  GOTO delshdw
)
call "%destdir%\vshadowtemp.cmd" >nul 2>nul
IF NOT ERRORLEVEL 0 (
  ECHO An error occured while importing the shadow copy GUIDs.
  set myerr=10
  GOTO delshdw
)
%vshadow% -el=%SHADOW_ID_1%,%scd%: >>%log%
IF NOT ERRORLEVEL 0 (
  ECHO An error occured while creating the shadow copy.
  set myerr=11
  GOTO delshdw
)

rem creating the backup image using DISM
echo Creating backup image...
echo Image file name: %ifn%
rem disabled dism options: /checkintegrity /verify
IF NOT DEFINED scratchdir (
  %dism% /Capture-Image /imagefile:%ifn% /capturedir:"%scd%:\\%srcpathonly%" /name:"%date:~6,4%-%date:~3,2%-%date:~0,2% %time:~0,5% %computername%" /description:"BACKUP" 2>>%log%
) else (
  %dism% /Capture-Image /imagefile:%ifn% /capturedir:"%scd%:\\%srcpathonly%" /name:"%date:~6,4%-%date:~3,2%-%date:~0,2% %time:~0,5% %computername%" /description:"BACKUP" /scratchdir:"%scratchdir%" 2>>%log%
)
IF NOT ERRORLEVEL 0 (
  ECHO An error occured while creating the image file using DISM.
  set myerr=12
  GOTO delshdw
)

:delshdw
rem removing shadow copy when script ends or when an error ocurred
%vshadow% -ds=%SHADOW_ID_1% >>%log%
del "%destdir%\vshadowtemp.cmd" >nul 2>nul
IF dellogonsuccess EQU 1 (
  IF %myerr% EQU 0 del %log% >nul 2>nul
)
EXIT /B %myerr%