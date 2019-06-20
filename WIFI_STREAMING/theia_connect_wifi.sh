#!/bin/sh

wpa_cli -i wlan0 -p /tmp/wpa_supplicant remove_network all
wpa_cli -i wlan0 -p /tmp/wpa_supplicant add_network
wpa_cli -i wlan0 -p /tmp/wpa_supplicant set_network 0 ssid '"B21F-2V0X-VIT"'
wpa_cli -i wlan0 -p /tmp/wpa_supplicant set_network 0 key_mgmt WPA-PSK
wpa_cli -i wlan0 -p /tmp/wpa_supplicant set_network 0 psk '"vit@123456"'
wpa_cli -i wlan0 -p /tmp/wpa_supplicant select_network 0

dhcpcd wlan0

ifconfig
