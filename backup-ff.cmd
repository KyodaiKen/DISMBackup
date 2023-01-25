@echo off
set myerr=0
set destdir=%~1

rem config
rem change firefox profiles directory if desired
set sourcedir=%appdata%\Mozilla\Firefox
rem change paths to the binaries if desired
set dism=%systemroot%\system32\dism.exe
set vshadow=%~dp0\vshadow.exe
set seven="%PROGRAMFILES%\7-zip\7z.exe"
rem set dellogonsuccess to 0 if you wish to keep the log file even when the operation ran successful
set dellogonsuccess=1
rem end config

set sourcedrv=%sourcedir:~0,2%
set srcpathonly=%sourcedir:~3%

rem validation
net session >nul 2>&1
IF NOT ERRORLEVEL 0 (
  ECHO You need administrative permissions to run this script.
  EXIT /B 1
)
IF NOT EXIST %seven% (
  ECHO Could not find 7z.exe in "%PROGRAMFILES%\7-zip\"! Please install 7-zip in this location.
  EXIT /B 3
)
IF NOT EXIST "%vshadow%" (
  ECHO Could not find vshadow.exe in script path.
  EXIT /B 3
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
  ECHO Network paths are not allowed. Try mapping a network drive and use the drive letter.
  EXIT /B 7
)
IF %srcpathonly:~-1%==\ (
  ECHO Path must not end with a backslash.
  EXIT /B 12
)
IF NOT EXIST "%sourcedir%" (
  ECHO Source path is not accessible.
  EXIT /B 8
)

rem Finding free drive letter
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

rem Creation of shadow copy
echo Please wait while Windows is creating a temporary shadow copy of %sourcedrv% as %scd%:
set hr=%time:~0,2%
if "%hr:~0,1%" equ " " set hr=0%hr:~1,1%
set fn=%date:~-4,4%%date:~-7,2%%date:~-10,2%%hr%%time:~3,2%%time:~6,2%
set ifn="%destdir%\%fn%.7z"
set log="%destdir%\%fn%.TXT"
%vshadow% -p -script="%destdir%\vshadowtemp.cmd" %sourcedrv% >>%log%
IF NOT ERRORLEVEL 0 (
  ECHO An error occurred while preparing the shadow copy.
  set myerr=9
  GOTO delshdw
)
call "%destdir%\vshadowtemp.cmd" >nul 2>nul
IF NOT ERRORLEVEL 0 (
  ECHO An error occurred while importing the shadow copy GUIDs.
  set myerr=10
  GOTO delshdw
)
%vshadow% -el=%SHADOW_ID_1%,%scd%: >>%log%
IF NOT ERRORLEVEL 0 (
  ECHO An error occurred while creating the shadow copy.
  set myerr=11
  GOTO delshdw
)

rem Backing up Firefox profiles
set shadowsrc="%scd%:\%srcpathonly%\"
echo Backing up Firefox profiles from shadow copy on: %shadowsrc%
echo Archive file name: %ifn%
%seven% a %ifn% %shadowsrc% -bsp1 -bso0
IF NOT ERRORLEVEL 0 (
  ECHO An error occurred while creating the archive.
  set myerr=12
  GOTO delshdw
)

:delshdw
rem Removing shadow copy when script ends or when an error ocurred
%vshadow% -ds=%SHADOW_ID_1% >>%log%
del "%destdir%\vshadowtemp.cmd" >nul 2>nul
IF dellogonsuccess EQU 1 (
  IF %myerr% EQU 0 del %log% >nul 2>nul
)
EXIT /B %myerr%