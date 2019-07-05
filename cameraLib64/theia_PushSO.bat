
@echo off

cd .\%1\lib64
adb shell mount -o remount,rw /

for %%f in (libCamera_ov5a20mipiraw_*.so) do (
    @echo %%f
    @adb push %%f /usr/lib64/
)

@adb push libov5a20_mipi_raw_tuning.so /usr/lib64/
@adb push libov5a20_mipi_raw_IdxMgr.so /usr/lib64/
@adb push libcamdrv_tuning_mgr.so /usr/lib64/
@adb push libmtk_platform_log.so /usr/lib64/

@adb push libcam.hal3a.v3.lscMgr.so /usr/lib64/
@adb push libcam.hal3a.v3.lsctbl.50.so /usr/lib64/

@adb shell sync

cd ..\..

pause "Please re-cycle power of Theia ..."

REM ######################################################
REM # Origin scripts from Ben
REM ######################################################
REM
REM adb shell killall cct_camera_server
REM adb shell systemctl stop v4l2d.service
REM adb shell sleep 1
REM
REM cd build\tmp\work\aarch64-poky-linux\mtkcam3\1.0-r0\sysroot-destdir\usr\lib64\
REM adb shell mount -o remount,rw /
REM
REM for %%f in (libCamera_ov5a20mipiraw_*.so) do (
REM     echo %%f
REM     adb push %%f /usr/lib64/
REM )
REM
REM adb push libov5a20_mipi_raw_tuning.so /usr/lib64/
REM adb push libov5a20_mipi_raw_IdxMgr.so /usr/lib64/
REM adb push libcamdrv_tuning_mgr.so /usr/lib64/
REM adb push libmtk_platform_log.so /usr/lib64/
REM adb shell sync
REM
REM
REM adb shell systemctl start v4l2d.service
REM
REM pause
