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
set initWIFI="true"

REM ------------------------------------------------------------------------------
REM ----- Parse program arguments
REM ------------------------------------------------------------------------------
:loop_args
if not "%1"=="" (
    if "%1"=="-init" (
		REM Initialize WiFi first
        set initWIFI= "true"
        goto :next_arg
    )
:next_arg
    shift
    goto :loop_args
)


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
if %initWIFI% == "true" (
	adb push theia_connect_wifi.sh /tmp
	adb shell "cd /tmp && chmod +x theia_connect_wifi.sh && ./theia_connect_wifi.sh"
	@echo On
	pause "Is %pcIP% your PC IP ? Yes(Enter), No(Ctrl-C) ..."
	@echo OFF
)


REM --------------------------------------------------------------
REM Start Streaming
REM --------------------------------------------------------------
adb push theia-rtp-send-FullSize.sh /data/
adb shell chmod a+x /data/theia-rtp-send-FullSize.sh
adb shell "cd /data && bash theia-rtp-send-FullSize.sh %pcIP%"
