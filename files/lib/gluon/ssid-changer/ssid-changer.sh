#!/bin/sh

# maximum simplyfied, no more ttvn rating
check=$(batctl gwl -H|wc -l)
name=$(nodename status|tail -c 21)
OFFLINE_PREFIX="FF_OFFLINE_"
default="freiburg.freifunk.net"
offi="$offline$name"

if [ $check -eq 0 ] ; then
	if [ $(uci get wireless.client_radio0.ssid) -eq "$offi" ] ; then exit 0 ; fi
	uci set wireless.client_radio0.ssid='$OFFLINE_PREFIX$name'
	killall -HUP hostapd
fi
if [ $check -gt 0 ] ; then
	if [ $(uci get wireless.client_radio0.ssid) -eq "$default" ] ; then exit 0 ; fi
	wireless.client_radio0.ssid='freiburg.freifunk.net'
        killall -HUP hostapd
fi
