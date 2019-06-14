#!/bin/sh

#-- NDD dump
setprop vendor.debug.camera.dump.p2.debuginfo 1
setprop vendor.debug.camera.dump.lsc2 1
setprop vendor.debug.camera.SttBufQ.enable 60
setprop vendor.debug.camera.AAO.dump 1
setprop vendor.debug.camera.ufo_off 1
setprop vendor.debug.camera.p2.dump 1
setprop vendor.debug.camera.dump.JpegNode 1

if false; then
    #-- for TSF Dump
    setprop vendor.debug.lsc_mgr.log 256

    mkdir -p /sdcard/camera_dump
    chmod -R 755 /sdcard
fi


# cct_camera_server &
# sleep 1

rm -f /data/vendor/camera_dump/*
#rm -f /sdcard/camera_dump/*
#sleep 2

cct_camera_cmd startCamera
sleep 1

cct_camera_cmd startCapture
sleep 1

cct_camera_cmd stopCamera
sleep 1

ls -l /data/vendor/camera_dump
# ls -l /sdcard/camera_dump

###################################################################
# Workaround: for bug which 2nd camera capture failure
###################################################################

cct_camera_cmd startCamera
sleep 1

cct_camera_cmd startCapture
sleep 1

cct_camera_cmd stopCamera
sleep 1
