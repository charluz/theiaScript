@echo off
REM setlocal EnableDelayedExpansion
REM -----------------------------------------------------------------
REM - 整合 Theia NDD 以及 gStreamer 錄影功能。
REM -----------------------------------------------------------------
REM - Usages:
REM -   theia_nddREC.bat [-T n] [-S] [projDIR]
REM -
REM - 指令執行後會先做一次 NDD Dump，NDD 預設輸出目錄為 nddREC 。
REM -     指定 projDIR 參數可以變更 output directory。
REM -
REM - NDD 完成後，緊接著會錄一段 Video，預設錄影長度為 10 秒。
REM -     Video 會被存到 Output directory， named as theia.avi
REM -     指定 -T n 參數可以變更錄影長度，Example, -T 20 為 20 秒。
REM -
REM - 為了方便查看結果，NDD jpg 以及 video 會被 copy 一份到現行目錄下，
REM -     檔案名稱會以 output directory 相同的名稱冠名。
REM -     Example: theia_nddREC.bat test1
REM -        NDD jpg 以及 video 會被冠名為 test1.jpg 以及 test1.avi。
REM -     -S 參數可以取消自動 Copy 的功能，可以節省空間以及時間。
REM -------------------------------------------------------------------

set projDIR=nddREC
set /A recTime= 3
set dontCopy= "false"
set dontREC= "false"
set dontNDD="false"

REM ------------------------------------------------------------------------------
REM ----- Parse program arguments
REM ------------------------------------------------------------------------------
:loop_args
if not "%1"=="" (
    if "%1"=="-T" (
        set /A recTime=%2
        shift
        goto :next_arg
    )

    if "%1"=="-S" (
        set dontCopy= "true"
        goto :next_arg
    )

    if "%1"=="-XR" (
        set dontREC= "true"
        goto :next_arg
    )

    if "%1"=="-XN" (
        set dontNDD= "true"
        goto :next_arg
    )

    set projDIR=%1

:next_arg
    shift
    goto :loop_args
)

REM echo "projDir= %projDIR% ..."
REM echo "recTime= %recTime% ..."

REM ------------------------------------------------------------------------------
REM ----- Create/Check output directory
REM ------------------------------------------------------------------------------
if not exist %projDIR%\ (
    REM echo "Driectory %projDIR% not exists, creating ..."
    mkdir %projDIR%
)

REM ------------------------------------------------------------------------------
REM ----- NDD Dump
REM ------------------------------------------------------------------------------
REM goto :_skip_nddDump

if %dontNDD% == "false" (
	call ADB_ndd.bat %projDIR%
)


if %dontCopy% == "false" (
    cd %projDIR%
    for /R %%f in (*.jpg) do (
        @copy /Y %%f ..\%projDIR%.jpg
    )
    cd ..
)
:_skip_nddDump

if %dontREC% == "true" (goto :_skip_REC)

REM ------------------------------------------------------------------------------
REM ----- Record gstream video
REM ------------------------------------------------------------------------------
call gstREC_record.bat -T %recTime%
timeout 1

REM ------------------------------------------------------------------------------
REM ----- Pull back video clip
REM ------------------------------------------------------------------------------
adb pull /tmp/gstREC %projDIR%

:_skip_REC

if %dontCopy% == "false" (
    copy %projDIR%\theia.avi .\%projDIR%.avi
)


:_exit
