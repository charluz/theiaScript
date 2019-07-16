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
set exp=33333
set sgain=1024
set igain=1024
set aviName=theia
set autoAE="false"

if "%1"=="--help" (
    @echo.
    @echo Usage: gstAVI_record.bat [aviName] [-crop]
    @echo.
    @echo Descriptions
    @echo   To record and dump video clips from Theia camera.
    @echo.
    @echo   aviName : name of the video clip
    @echo      Optional. If aviName is not specified, the dafault avi name is theia_1080p.
    @echo.
    @echo   -exp X : Optional, to specify the shutter time in ms.
    @echo.
    @echo   -sgain SG : Optional, to specify the sensor gain in 1024 based value.
    @echo.
    @echo   -igain IG : Optional, to specify the ISP gain in 1024 based value.
    @echo.
    goto :_exit
)



:loop_args
if not "%1"=="" (
    if "%1"=="-crop" (
        set fstOrderSizeW=1920
        set fstOrderSizeH=1080
        goto :next_arg
    )

    if "%1"=="-exp" (
        set exp=%2
        shift
        goto :next_arg
    )

    if "%1"=="-sgain" (
        set sgain=%2
        shift
        goto :next_arg
    )

    if "%1"=="-igain" (
        set igain=%2
        shift
        goto :next_arg
    )

    if "%1"=="-ae" (
        set autoAE="true"
        goto :next_arg
    )

    set aviName=%1

:next_arg
    shift
    goto :loop_args
)


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

rem adb shell setprop debug.mapping_mgr.enable 3

if %autoAE%=="false" (
    echo "Manual AE"
    adb shell setprop vendor.debug.ae_mgr.enable 1
    adb shell setprop vendor.debug.ae_mgr.preview.update 1
    adb shell setprop vendor.debug.ae_mgr.shutter %exp%
    adb shell setprop vendor.debug.ae_mgr.sensorgain %sgain%
    adb shell setprop vendor.debug.ae_mgr.ispgain %igain%
    adb shell setprop vendor.debug.camera.dump.JpegNode 1
    adb shell setprop vendor.debug.capture.forceZsd 1
) else (
    echo "Setting Auto-AE ..."
    adb shell setprop vendor.debug.ae_mgr.enable 0
    adb shell setprop vendor.debug.ae_mgr.preview.update 1
    adb shell setprop vendor.debug.camera.dump.JpegNode 1
    adb shell setprop vendor.debug.capture.forceZsd 1
)


adb shell mkdir -p %camDir%
adb shell rm -f %camDir%/*
@echo on
adb shell gst-launch-1.0 -v v4l2src device="/dev/video3" !^
video/x-raw,format=YUY2,width=%fstOrderSizeW%,height=%fstOrderSizeH%, framerate=30/1 !^
aspectratiocrop aspect-ratio=16/9 ! \^
mtkmdp width=%sizeW% height=%sizeH% ! video/x-raw,format=I420 ! \^
v4l2mtkh264enc bitrate=9000000 gop=8 ! \^
avimux ! filesink location=%camDir%/%aviName%.avi
@echo off

:_exit
