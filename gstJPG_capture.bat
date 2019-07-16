@echo off

REM --------------------------------------------
REM Initialize default variables
REM --------------------------------------------

REM  dxName : to create a sub-folder in /tmp to collect JPG files.
set dxName=gstJPG
set sizeW=2688
set sizeH=1944
set exp=33333
set sgain=1024
set igain=1024
set autoAE="false"
set /A recFrames=5

if "%1"=="--help" (
    @echo.
    @echo Usage: gstJPG_capture.bat [dxName] [-crop]
    @echo.
    @echo Descriptions
    @echo   To capture and dump YUV images from Theia camera.
    @echo.
    @echo   dxName : name of the sub-folder
    @echo      For the sake of pull all captured JPG files, a sub-folder will be created in camera under /tmp directory.
    @echo      If the sub-folder name is not specified, it will use "gstJPG" as default name of the sub-folder.
    @echo.
    @echo   -crop : the crop size to capture.
    @echo      Optional. If the option, "-crop W H", is given, the output image is cropped from the full size image.
    @echo.
    @echo   -exp X : Optional, to specify the shutter time in ms.
    @echo.
    @echo   -sgain SG : Optional, to specify the sensor gain in 1024 based value.
    @echo.
    @echo   -igain IG : Optional, to specify the ISP gain in 1024 based value.
    @echo.
    @echo   -ae : Optional, to enable autoAE.
    @echo.
    goto :_exit
)



:loop_args
if not "%1"=="" (
    if "%1"=="-crop" (
        set sizeW=%2
        set sizeH=%3
        shift & shift
        goto :next_arg
    )

    if "%1"=="-N" (
        set /A recFrames=%2
        shift
        goto :next_arg
    )

    if "%1"=="-exp" (
        set exp=%2
        shift
		echo %1
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

    set dxName=%1

:next_arg
    shift
    goto :loop_args
)



REM ----------------------------------------
REM Main Section
REM ----------------------------------------
set camDir=/tmp/%dxName%

@echo.
@echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
@echo "Capturing %sizeW%x%sizeH% JPEG image to %camDir%/ ..."
@echo Press Ctrl-C to stop JPG capture.
@echo Issue command : "adb pull %camDir%" to download JPGs from camera.
@echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
@echo.

rem adb shell setprop debug.mapping_mgr.enable 3

if %autoAE%=="false" (
    echo "Setting Manual AE ..."
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
echo nun-bufers=%recFrames%
adb shell gst-launch-1.0 -v v4l2src device="/dev/video3" num-buffers=%recFrames% !^
video/x-raw,format=YUY2,width=%sizeW%,height=%sizeH% !^
jpegenc ! multifilesink location="%camDir%/test1%%03d.jpeg"

if exist %dxName%\ (
	cd %dxName%
	del test*.jpeg
	cd ..
)

adb pull /tmp/gstJPG %dxName%


:_exit
