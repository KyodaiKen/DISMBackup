@echo off
set imagefile=%1
set path=%2
if NOT DEFINED imagefile goto stop1
if NOT DEFINED driveletter goto stop2
dism.exe /apply-image /imagefile:%imagefile% /index:1 /applydir:%path%\
goto ende
:stop1
echo Please specify the image file
goto ende
:stop2
echo Please specify a drive letter as the destination drive
:ende