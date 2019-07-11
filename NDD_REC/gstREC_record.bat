@echo off

REM --------------------------------------------
REM Initialize default variables
REM --------------------------------------------

REM  dxName : to create a sub-folder in /tmp to collect JPG files.
set dxName=gstREC
set fstOrderSizeW=2688
set fstOrderSizeH=1944
set sizeW=1920
set sizeH=1080
set bitRate=9000000
set aviName=theia
set /A recFrames=300

if "%1"=="--help" (
    @echo.
    @echo Usage: gstAVI_record.bat [aviName] [-crop]
    @echo.
    @echo Descriptions
    @echo   To record and dump video clips from Theia camera.
    @echo       aviName : name of the video clip
    @echo           Optional. If aviName is not specified, the dafault avi name is theia_1080p.
    goto :_exit
)



:loop_args
if not "%1"=="" (
    if "%1"=="-T" (
        set /A recFrames=%2*30
        shift
        goto :next_arg
    )

    set aviName=%1

:next_arg
    shift
    goto :loop_args
)
echo "aviName= %aviName% ..."
echo "recFrames= %recFrames% ..."

REM DEBUG ONLY
goto :roll_up_sleeves
echo dxName = %dxName%
echo aviName=%aviName%
echo sizeW = %sizeW%
echo sizeH = %sizeH%
goto :_exit


REM ----------------------------------------
REM Main Section
REM ----------------------------------------
:roll_up_sleeves
set camDir=/tmp/%dxName%

@echo.
@echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
@echo "Recording %sizeW%x%sizeH% video to %camDir%/ ..."
@echo Press Ctrl-C to stop video record.
@echo Issue command : "adb pull %camDir%" to download vdieo files from camera.
@echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
@echo.

REM adb shell setprop debug.mapping_mgr.enable 3

echo "Setting Auto-AE ..."
adb shell setprop vendor.debug.ae_mgr.enable 0
adb shell setprop vendor.debug.ae_mgr.preview.update 1
adb shell setprop vendor.debug.camera.dump.JpegNode 1
adb shell setprop vendor.debug.capture.forceZsd 1


adb shell mkdir -p %camDir%
adb shell rm -f %camDir%/*
@echo on
adb shell gst-launch-1.0 -v v4l2src device="/dev/video3" num-buffers=%recFrames% ! video/x-raw,format=YUY2,width=%fstOrderSizeW%,height=%fstOrderSizeH%, framerate=30/1 ! mtkmdp width=%sizeW% height=%sizeH% ! video/x-raw,format=I420 ! v4l2mtkh264enc bitrate=9000000 gop=8 ! avimux ! filesink location=%camDir%/%aviName%.avi
@echo off

:_exit
