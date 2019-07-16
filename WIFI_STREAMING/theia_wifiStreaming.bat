@echo OFF


REM --------------------------------------------------------------
REM 第一次執行時:
REM 1. 先確認 PC 的 IP address，修改底下的變數 pcIP
REM 2. 開啟附帶的 play.sdp，修改裡面的 IP (theia IP address)
REM --------------------------------------------------------------
REM play.sdp 的內容如下:
REM v=0
REM m=video 5000 RTP/AVP 96
REM c=IN IP4 192.168.1.24
REM a=rtpmap:96 H264/90000
REM ---------------------------------------------------------------

set pcIP="192.168.1.9"
set /A bitRate=9000000
set /A gop=8
set is720p="false"

REM ------------------------------------------------------------------------------
REM ----- Parse program arguments
REM ------------------------------------------------------------------------------
:loop_args
if not "%1"=="" (
    if "%1"=="-br" (
		REM Setting bitrate
        set /A bitRate = %2
        shift
        REM echo "bitRate= %bitRate%"
        goto :next_arg
    )

    if "%1"=="-gop" (
		REM Setting GOP
        set /A gop = %2
        shift
        REM echo "GOP= %gop%"
        goto :next_arg
    )

    if "%1"=="-720p" (
		REM Setting GOP
        set is720p="true"
        goto :next_arg
    )

:next_arg
    shift
    goto :loop_args
)


echo "bitRate= %bitRate%   GOP= %gop%  is720p= %is720p%"
REM goto :_exit

REM --------------------------------------------------------------
REM AE Debug
REM --------------------------------------------------------------

goto :_skip_debug
adb shell setprop persist.mtk.camera.log_level 3
adb shell setprop debug.cam.drawid 1
adb shell setprop vendor.debug.ae_loge.enable 1
:_skip_debug



REM --------------------------------------------------------------
REM Configure and Connect WiFi
REM --------------------------------------------------------------
adb push theia_connect_wifi.sh /tmp
adb shell "cd /tmp && chmod +x theia_connect_wifi.sh && ./theia_connect_wifi.sh"
@echo On
pause "Is %pcIP% your PC IP ? Yes(Enter), No(Ctrl-C) ..."
@echo OFF



REM --------------------------------------------------------------
REM Start Streaming
REM --------------------------------------------------------------
if %is720p% == "false" (
	echo "Streaming 1080p ..."
	adb push theia-rtp-send-FullSize.sh /data/
	adb shell chmod a+x /data/theia-rtp-send-FullSize.sh
	adb shell "cd /data && bash theia-rtp-send-FullSize.sh %pcIP% %bitRate% %gop%"
)
else (
	echo "Streaming 720p ..."
	adb push theia-rtp-send-720p.sh /data/
	adb shell chmod a+x /data/theia-rtp-send-720p.sh
	adb shell "cd /data && bash theia-rtp-send-720p.sh %pcIP% %bitRate% %gop%"
)
:_exit
