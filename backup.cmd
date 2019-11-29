@echo off
set dism=%systemroot%\system32\dism.exe
IF NOT EXIST %dism% (
  set dism=dism.exe
  IF NOT EXIST %dism% GOTO stop3
)
rem config
set vshadow=vshadow.exe
set sourcedrv=%1
set destdir=%2
set scratchdir=%3
if NOT DEFINED destdir goto stop1
if NOT DEFINED sourcedrv goto stop2
echo Detemining free drive letter for the volume shadow copy...
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
if errorlevel 1 goto error1
call %destdir%\vshadowtemp.cmd >nul 2>nul
if errorlevel 1 goto error1
%vshadow% -el=%SHADOW_ID_1%,%scd%: >>%log%
if errorlevel 1 goto error1
echo Creating backup image...
echo Image file name: %ifn%
rem disabled dism options: /checkintegrity /verify
IF NOT DEFINED scratchdir (
  %dism% /Capture-Image /imagefile:%ifn% /capturedir:%scd%: /name:"%date:~6,4%-%date:~3,2%-%date:~0,2% %time:~0,5% %computername%" /description:"SYSTEM" 2>>%log%
) else (
  %dism% /Capture-Image /imagefile:%ifn% /capturedir:%scd%: /name:"%date:~6,4%-%date:~3,2%-%date:~0,2% %time:~0,5% %computername%" /description:"SYSTEM" /scratchdir:%scratchdir% 2>>%log%
)
if errorlevel 1 goto error1
%vshadow% -ds=%SHADOW_ID_1% >>%log%
del %destdir%\vshadowtemp.cmd >nul 2>nul
goto ende
:error1
echo An error occured while creating the shadow copy, see log!
%vshadow% -ds=%SHADOW_ID_1% >>%log%
del %destdir%\vshadowtemp.cmd >nul 2>nul
goto ende
:stop1
echo Please specify the destination path
goto ende
:stop2
echo Please specify a drive letter as the source drive
goto ende
:stop3
echo Could not find DISM anywhere. Please make sure you're in the right path.
:ende