@echo off
set imagefile=%1
set adir=%2
if NOT DEFINED imagefile goto stop1
if NOT DEFINED adir goto stop2
dism.exe /apply-image /imagefile:%imagefile% /index:1 /applydir:%adir%
goto ende
:stop1
echo Please specify the image file
goto ende
:stop2
echo Please specify a drive letter as the destination drive like this: x:\
:ende