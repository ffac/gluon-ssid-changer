#!/bin/sh

# maximum simplyfied, no more ttvn rating
check=$(batctl gwl -H|grep -v "gateways in range"|wc -l)
name=$(nodename status|tail -c 21)
offline="FF_OFFLINE_"
default="freiburg.freifunk.net"
offi=$offline$name

if [ $check -eq 0 ] ; then
        if [ "$(uci get wireless.client_radio0.ssid)" == "$offi" ] ; then echo "$0 - still on $offi"|logger ; exit 0 ; fi
        echo "$0 change ssid to $offi" | logger
        uci set wireless.client_radio0.ssid="$offi"
        killall -HUP hostapd
fi
if [ $check -gt 0 ] ; then
        if [ "$(uci get wireless.client_radio0.ssid)" == "$default" ] ; then echo "$0 - still on $default"|logger ; exit 0 ; fi
        echo "$0 change ssid to $default"| logger
        uci set wireless.client_radio0.ssid=freiburg.freifunk.net
        killall -HUP hostapd
fi
