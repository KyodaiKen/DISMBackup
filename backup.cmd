@echo off
rem config
set vshadow=vshadow.exe
set sourcedrv=%1
set workdir=%2
REM set scratchdir=T:\DISM_SCRATCHDIR
if NOT DEFINED workdir goto stop1
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
set ifn="%workdir%\%date:~-4,4%%date:~-7,2%%date:~-10,2%%hr%%time:~3,2%%time:~6,2%.WIM"
mkdir %workdir%\LOGS
set log="%workdir%\LOGS\%date:~-4,4%%date:~-7,2%%date:~-10,2%%hr%%time:~3,2%%time:~6,2%"
%vshadow% -p -script=%workdir%\vshadowtemp.cmd %sourcedrv% >>%log%-stdout.log 2>>%log%-stderr.log
if errorlevel 1 goto error1
call %workdir%\vshadowtemp.cmd >nul 2>nul
if errorlevel 1 goto error1
%vshadow% -el=%SHADOW_ID_1%,%scd%: >>%log%-stdout.log 2>>%log%-stderr.log
if errorlevel 1 goto error1
echo Creating backup image...
echo Image file name: %ifn%
rem disabled dism options: /checkintegrity /verify /scratchdir:%scratchdir%
%windir%\system32\dism /Capture-Image /imagefile:%ifn% /capturedir:%scd%: /name:"%date:~6,4%-%date:~3,2%-%date:~0,2% %time:~0,5% %computername%" /description:"SYSTEM" 2>>%log%-stderr.log
if errorlevel 1 goto error1
%vshadow% -ds=%SHADOW_ID_1% >>%log%-stdout.log 2>>%log%-stderr.log
del %workdir%\vshadowtemp.cmd >nul 2>nul
goto ende
:error1
echo An error occured while creating the shadow copy, see log!
%vshadow% -ds=%SHADOW_ID_1% >>%log%-stdout.log 2>>%log%-stderr.log
rem rd %scratchdir%
del %workdir%\vshadowtemp.cmd >nul 2>nul
goto ende
:stop1
echo Please specify the image file
goto ende
:stop2
echo Please specify a drive letter as the source drive
:ende