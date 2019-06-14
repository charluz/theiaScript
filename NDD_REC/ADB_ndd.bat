@echo off

set cameraNDD_script=camera_ndd.sh
set outDir="NDD"

if not "%1"=="" (
    set outDir=%1
)

REM ---------------------------------------------------------------
REM --- Push ndd script to camera
REM ---------------------------------------------------------------
adb push %cameraNDD_script% /tmp
adb shell chmod +x /tmp/%cameraNDD_script%

REM ---------------------------------------------------------------
REM --- Start NDD
REM ---------------------------------------------------------------
echo '##### Starting NDD ...'
adb shell "cd /tmp && ./%cameraNDD_script%"

REM timeout 1

REM -- Pull back NDD data
echo "##### Pulling back NDD data into %outDir% ..."
rmdir /S /Q %outDir%
REM timeout 1
mkdir %outDir%

adb pull /data/vendor/camera_dump %outDir%

REM goto :_skip
REM mkdir %outDir%\tsf
REM adb pull /sdcard/camera_dump %outDir%\tsf
REM
REM mkdir %outDir%\log
REM adb pull /var/log %outDir%\log
REM
REM :_skip
REM echo ''Bye, Bye'
