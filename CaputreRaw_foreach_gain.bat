@echo off

REM --------------------------------------------
REM Initialize default variables
REM --------------------------------------------

REM  dxName : the folder to store the images
set dxName=.
set exp=33333
set sgain=1024
set igain=1024
set /A mtkGainUnit=1024
set /A num=4
set camDir=/data/vendor/camera_dump
REM about delay expansion: https://stackoverflow.com/questions/12118810/arithmetic-inside-a-for-loop-batch-file
REM variable defined in for-loop should use delay expansion !var_in_loop!
setlocal enableDelayedExpansion


REM ----------------------------------------
REM Main Section
REM ----------------------------------------

@echo ++++++++++++++++++++++++++++++++++++
@echo + Setting Manual AE params ...
@echo ++++++++++++++++++++++++++++++++++++

for /L %%a in (1 1 %num%) do (
    set /A mtkGain=%%a*%mtkGainUnit%
    @echo mtkgain=!mtkGain!
    set subdir=%dxName%\gain!mtkGain!
	@echo ++++++++++++++++++++++++++++++++++++
	@echo + Capturing image with gain !mtkGain! ...
	@echo ++++++++++++++++++++++++++++++++++++
 
    adb shell rm -rf /data/vendor/camera_dump/*
    adb shell mkdir -p /data/vendor/camera_dump/target
    adb shell setprop vendor.debug.ae_mgr.enable 1
    adb shell setprop vendor.debug.ae_mgr.preview.update 1
    adb shell setprop vendor.debug.ae_mgr.shutter %exp%
    adb shell setprop vendor.debug.ae_mgr.sensorgain !mtkGain!
    adb shell setprop vendor.debug.ae_mgr.ispgain %igain%
    adb shell setprop vendor.debug.camera.dump.en 1
    adb shell setprop vendor.debug.camera.dump.p1.imgo 1
    adb shell setprop vendor.debug.capture.forceZsd 1
    adb shell getprop vendor.debug.ae_mgr.sensorgain !mtkGain!
    REM pause
    
    REM dump 3+6 p1 image 
    adb shell v4l2_camera -d /dev/video3 -c 3 -n 6 -p 2 -f 2688*1944 -r /tmp/dummy.yuv
    
    REM use latest image to make sure gain setting is correct
    adb shell mv /data/vendor/camera_dump/*0008* /data/vendor/camera_dump/target
    @echo +++++ Creating directory !subdir! ...
    mkdir !subdir!

    @echo ++++++++++++++++++++++++++++++++++++
    @echo + Pull back images to !subdir! ...
    @echo ++++++++++++++++++++++++++++++++++++
    adb pull /data/vendor/camera_dump/target !subdir!
)

pause
