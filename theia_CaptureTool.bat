@echo off

REM --------------------------------------------
REM Initialize default variables
REM --------------------------------------------

REM  dxName : the folder to store the images
set dxName=.
set exp=33333
set sgain=1024
set igain=1024
set /A num=1
set flgClear="false"
set flgDelLocal="false"
set camDir=/data/vendor/camera_dump
set autoAE="false"


if "%1"=="--help" (
	@echo.
	@echo Usage: cam_CaptureTool.bat [dxName] [-exp ms] [-sgain G1024] [igain G1024] [-num N] [-clear]
	@echo.
	@echo Descriptions
	@echo   To capture and dump YUV images from Theia camera.
	@echo   The captured images will go to /data/vendor/camera_dump folder at camera.
	@echo   All pictures in camera will be pulled back once all capture tasks finish.
	@echo.
	@echo   dxName : the local directory to store captured images
	@echo.
	@echo   -num : the number of images to be captured
	@echo.
	@echo   -exp : Optional, to specify the shutter time in ms.
	@echo.
	@echo   -sgain : Optional, to specify the sensor gain in 1024 based value.
	@echo.
	@echo   -igain : Optional, to specify the ISP gain in 1024 based value.
	@echo.
	@echo   -clear : Optional. If specified, the camera folder will be clear before taking images.
	@echo.
	@echo   -del_local : Optional. If specified, both the local image folder will be clear before taking images.
	@echo.
	@echo.
	goto :_exit
)



:loop_args
if not "%1"=="" (
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

	if "%1"=="-num" (
		set /A num=%2
		shift
		goto :next_arg
	)

	if "%1"=="-clear" (
		set flgClear="true"
		REM @echo Deleting %camDir%/*.jpg
		REM adb shell rm -f %camDir%/*.jpg
		goto :next_arg
	)

	if "%1"=="-del_local" (
		set flgDelLocal="true"
		REM @echo Deleting %camDir%/*.jpg
		REM adb shell rm -f %camDir%/*.jpg
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


REM DEBUG ONLY
goto :roll_up_sleeves
echo dxName = %dxName%
echo exp = %exp%
echo sgain = %sgain%
echo igain = %igain%
goto :_exit


REM ----------------------------------------
REM Main Section
REM ----------------------------------------
:roll_up_sleeves


if %flgClear%=="true" (
	@echo Deleting %camDir%/*.jpg
	adb shell rm -f %camDir%/*.jpg
)

@echo ++++++++++++++++++++++++++++++++++++
@echo + Setting Manual AE params ...
@echo ++++++++++++++++++++++++++++++++++++
REM adb shell setprop debug.mapping_mgr.enable 3
REM adb shell "echo 4 4 > /proc/sys/kernel/printk"

if %autoAE%=="false" (
    echo "Manual AE"
	adb shell setprop vendor.debug.ae_mgr.enable 1
	adb shell setprop vendor.debug.ae_mgr.preview.update 1
	adb shell setprop vendor.debug.ae_mgr.shutter %exp%
	adb shell setprop vendor.debug.ae_mgr.sensorgain %sgain%
	adb shell setprop vendor.debug.ae_mgr.ispgain %igain%
	adb shell setprop vendor.debug.camera.dump.JpegNode 1
	adb shell setprop vendor.debug.capture.forceZsd 1

	REM adb shell setprop vendor.debug.isp_mgr_awb.enable 1
	REM adb shell setprop debug.cam.drawid 1 
) else (
    echo "Setting Auto-AE ..."
    adb shell setprop vendor.debug.ae_mgr.enable 0
    adb shell setprop vendor.debug.ae_mgr.preview.update 1
    adb shell setprop vendor.debug.camera.dump.JpegNode 1
    adb shell setprop vendor.debug.capture.forceZsd 1
)



for /L %%a in (1 1 %num%) do (
	@echo ++++++++++++++++++++++++++++++++++++
	@echo + Capturing image %%a ...
	@echo ++++++++++++++++++++++++++++++++++++
	adb shell capture_tool
	REM timeout 5
)


@echo ++++++++++++++++++++++++++++++++++++
@echo + Pull back images to %dxName% ...
@echo ++++++++++++++++++++++++++++++++++++


goto :skip001
if %flgDelLocal%=="true" (
	if not "%dxName%"=="." (
		if exist %dxName% (
			@echo Deleting %dxName%\*.jpg
			del %dxName%\*.jpg
		)
	)
)

if not exist %dxName% (
	@echo +++++ Creating directory %dxName% ...
	mkdir %dxName%
)
:skip001

adb pull %camDir% %dxName%

@echo.
REM dir %dxName%


:_exit
