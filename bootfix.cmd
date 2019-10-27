@echo off
set drive=%1
set lang=%2
if NOT DEFINED drive goto stop1
if NOT DEFINED lang set lang="de-DE"
%drive%\windows\system32\bcdboot %drive%\windows /l %lang%
goto ende
:stop1
echo Please specify the drive letter including colon
goto ende
:ende