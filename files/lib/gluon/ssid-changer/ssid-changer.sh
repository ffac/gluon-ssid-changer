#!/bin/sh

# only once every timeframe the SSID will change to OFFLINE (set to 1 minute to change every time the router gets offline)
MINUTES="$(uci get ssid-changer.settings.switch_timeframe -q)"
# the first few minutes directly after reboot within which an Offline-SSID always may be activated
: ${MINUTES:=1}

FIRST="$(uci get ssid-changer.settings.first -q)"
# use something short to leave space for the nodename (no '~' allowed!)
: ${FIRST:=5}

PREFIX="$(uci get ssid-changer.settings.prefix -q)"
# generate the ssid with either 'nodename', 'mac' or to use only the prefix: 'none'
: ${PREFIX:='FF_OFFLINE_'}

if [ "$(uci get ssid-changer.settings.enabled -q)" = '0' ]; then 
	DISABLED='1'
else
	DISABLED='0'
fi

SETTINGS_SUFFIX="$(uci get ssid-changer.settings.suffix -q)"

if [ $SETTINGS_SUFFIX = 'nodename' ]; then
	SUFFIX="$(uname -n)"
	if [ ${#SUFFIX} -gt $((30 - ${#PREFIX})) ]; then # 32 would be possible as well
		HALF=$(( (28 - ${#PREFIX} ) / 2 )) # calculate the length of the first part of the node identifier in the offline-ssid
		SKIP=$(( ${#SUFFIX} - $HALF )) # jump to this charakter for the last part of the name
		SUFFIX=${SUFFIX:0:$HALF}...${SUFFIX:$SKIP:${#SUFFIX}} # use the first and last part of the nodename for nodes with long name
	fi
elif [ $SETTINGS_SUFFIX = 'mac' ]; then
	SUFFIX="$(uci get network.bat0.macaddr -q)"
else # 'none'
	SUFFIX=''
fi

OFFLINE_SSID="$PREFIX$SUFFIX"

# TODO: ffac tq limits has to be implemented here if enabled

ONLINE_SSID="$(uci get wireless.client_radio0.ssid -q)"
: ${ONLINE_SSID:="FREIFUNK"} # if for whatever reason ONLINE_SSID is NULL

CHECK="$(batctl gwl -H|grep -v "gateways in range"|wc -l)"
HUP_NEEDED=0
if [ "$CHECK" -gt 0 ] || [ "$DISABLED" = '1' ]; then
	echo "node is online"
	for HOSTAPD in $(ls /var/run/hostapd-phy*); do # check status for all physical devices
	CURRENT_SSID="$(grep "^ssid=$ONLINE_SSID" $HOSTAPD | cut -d"=" -f2)"
	if [ "$CURRENT_SSID" = "$ONLINE_SSID" ]
	then
		echo "SSID $CURRENT_SSID is correct, nothing to do"
		break
	fi
	CURRENT_SSID="$(grep "^ssid=$OFFLINE_SSID" $HOSTAPD | cut -d"=" -f2)"
	if [ "$CURRENT_SSID" = "$OFFLINE_SSID" ]; then
		logger -s -t "gluon-ssid-changer" -p 5 "SSID is $CURRENT_SSID, change to $ONLINE_SSID"
		sed -i "s~^ssid=$CURRENT_SSID~ssid=$ONLINE_SSID~" $HOSTAPD
		HUP_NEEDED=1 # HUP here would be to early for dualband devices
	else
		logger -s -t "gluon-ssid-changer" -p 5 "could not set to online state: did neither find SSID '$ONLINE_SSID' nor '$OFFLINE_SSID'. Please reboot"
	fi
done
elif [ "$CHECK" -eq 0 ]; then
	echo "node is considered offline"
	UP=$(cat /proc/uptime | sed 's/\..*//g')
	if [ $(($UP / 60)) -lt $FIRST ] || [ $(($UP / 60 % $MINUTES)) -eq 0 ]; then
		for HOSTAPD in $(ls /var/run/hostapd-phy*); do
  		CURRENT_SSID="$(grep "^ssid=$OFFLINE_SSID" $HOSTAPD | cut -d"=" -f2)"
  		if [ "$CURRENT_SSID" = "$OFFLINE_SSID" ]; then
  			echo "SSID $CURRENT_SSID is correct, nothing to do"
  			break
  		fi
  		CURRENT_SSID="$(grep "^ssid=$ONLINE_SSID" $HOSTAPD | cut -d"=" -f2)"
  		if [ "$CURRENT_SSID" = "$ONLINE_SSID" ]; then
  			logger -s -t "gluon-ssid-changer" -p 5 "SSID is $CURRENT_SSID, change to $OFFLINE_SSID"
  			sed -i "s~^ssid=$ONLINE_SSID~ssid=$OFFLINE_SSID~" $HOSTAPD
  			HUP_NEEDED=1
  		else
  			logger -s -t "gluon-ssid-changer" -p 5 "could not set to offline state: did neither find SSID '$ONLINE_SSID' nor '$OFFLINE_SSID'. Please reboot"
  		fi
		done
	fi
fi

if [ $HUP_NEEDED = 1 ]; then
	killall -HUP hostapd # send HUP to all hostapd to load the new SSID
	HUP_NEEDED=0
	echo "HUP!"
fi
