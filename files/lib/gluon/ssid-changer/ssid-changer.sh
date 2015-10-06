#!/bin/sh

# At first some Definitions:

ONLINE_SSID='Freifunk'
OFFLINE_PREFIX='FF_OFFLINE_' # Use something short to leave space for the nodename

# Generate an Offline SSID with the first and last Part of the nodename to allow owner to recognise wich node is down
NODENAME=`uname -n`
if [ ${#NODENAME} > $(30-${#OFFLINE_PREFIX}) ] ; then #32 would be possible as well
	HALF=$(( (28 - ${#OFFLINE_PREFIX} ) / 2 ))
	SKIP=$(( ${#NODENAME} - $HALF ))
	OFFLINE_SSID=$OFFLINE_PREFIX${NODENAME:0:$HALF}...${NODENAME:$SKIP:${#NODENAME}} # use the first and last part of the nodename for nodes with long name
else
	OFFLINE_SSID="$OFFLINE_PREFIX$NODENAME"
fi

#Is there an active Gateway?
GATEWAY_TQ=`batctl gwl | grep "^=>"| cut -d"(" -f2 | cut -d")" -f1 | tr -d " "`
if [ $GATEWAY_TQ -gt 50 ];
then
	echo "Gateway TQ is $GATEWAY_TQ node is online"
	for HOSTAPD in $(ls /var/run/hostapd-phy*); do
		CURRENT_SSID=`grep '^ssid=' $HOSTAPD | cut -d"=" -f2`
		if [ $CURRENT_SSID == $ONLINE_SSID ]
		then
			echo "SSID $CURRENT_SSID is correct, noting to do"
			HUP_NEEDED=0
		else
			echo "SSID is $CURRENT_SSID, change to $ONLINE_SSID"
			sed -i s/^ssid=.*/ssid=$ONLINE_SSID/ $HOSTAPD
			HUP_NEEDED=1 # HUP here would be to early for dualband devices
		fi
	done
	
else
	echo "Gateway TQ is $GATEWAY_TQ node is considered offline"
	for HOSTAPD in $(ls /var/run/hostapd-phy*); do
		CURRENT_SSID=`grep '^ssid=' $HOSTAPD | cut -d"=" -f2`
		if [ $CURRENT_SSID == $OFFLINE_SSID ]
		then
			echo "SSID $CURRENT_SSID is correct, noting to do"
			HUP_NEEDED=0
		else
			echo "SSID is $CURRENT_SSID, change to $OFFLINE_SSID"
			sed -i "s/^ssid=.*/ssid=$OFFLINE_SSID/" $HOSTAPD
			HUP_NEEDED=1 # HUP here would be to early for dualband devices
		fi
	done
fi

if [ $HUP_NEEDED == 1 ]; then
	killall -HUP hostapd # Send HUP to all hostapd um die neue SSID zu laden
	HUP_NEEDED=0
	echo "HUP!"
fi
