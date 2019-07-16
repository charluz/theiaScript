@echo off

rem Initialize default variables
set dxName=theia
set sizeW=2688
set sizeH=1944
set exp=16666
set sgain=1024
set igain=1024
set /A numPic=2

if "%1"=="--help" (
	@echo.
	@echo Usage: captureYUV_v4l2.bat [yuvFileName] [-full] [-n N]
	@echo.
	@echo Descriptions
	@echo   To capture and dump YUV images from Theia camera.
	@echo   The captured YUV image is stored in camera's /tmp folder.
	@echo.
	@echo   yuvFileName : the name of output YUV file.
	@echo      optional, if not specifed, the output YUV image is named as theia.yuv by default.
	@echo.
	@echo   -exp X : Optional, to specify the shutter time in ms.
	@echo.
	@echo   -sgain SG : Optional, to specify the sensor gain in 1024 based value.
	@echo.
	@echo   -igain IG : Optional, to specify the ISP gain in 1024 based value.
	@echo.
	@echo   -n N : specify the number "(N)" of images to be encapsulated in the output file.
	@echo      optional, 2 images are saved by default.
	@echo.
	goto :_exit
)


:loop_args
if not "%1"=="" (
	if "%1"=="-n" (
		set /A numPic=%2
		shift
		if %numPic% lss 1 ( set /A numPic=1 )
		if %numPic% gtr 200 ( set /A numPic=200 )
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

	set dxName=%1

:next_arg
	shift
	goto :loop_args
)


rem DEBUG ONLY
goto :roll_up_sleeves
echo dxName = %dxName%
echo numPic = %numPic%
echo sizeW = %sizeW%
echo sizeH = %sizeH%
goto :_exit


:roll_up_sleeves
REM set camDir=/data/vendor/camera_dump
REM set camDir=/tmp

@echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
@echo Configuring capture parameters ...
@echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
rem adb shell setprop debug.mapping_mgr.enable 3

adb shell setprop vendor.debug.ae_mgr.enable 1
adb shell setprop vendor.debug.ae_mgr.preview.update 1
adb shell setprop vendor.debug.ae_mgr.shutter %exp%
adb shell setprop vendor.debug.ae_mgr.sensorgain %sgain%
adb shell setprop vendor.debug.ae_mgr.ispgain %igain%
adb shell setprop vendor.debug.camera.dump.JpegNode 1
adb shell setprop vendor.debug.capture.forceZsd 1

adb shell debug.cam.drawid 1

@echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
@echo "Capturing %numPic% %sizeW%x%sizeH% YUV into /tmp/%dxName%.yuv..."
@echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

adb shell rm -f 
adb shell v4l2_camera -d /dev/video3 -c %numPic% -n 6 -f %sizeW%*%sizeH% -p 2 -r /tmp/%dxName%.yuv

@echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
@echo "Pulling /tmp/%dxName%.yuv back , size %sizeW%x%sizeH%, numPic= %numPic% ..."
@echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
adb pull /tmp/%dxName%.yuv

@echo "Capture YUV ~~ Done !"

:_exit
