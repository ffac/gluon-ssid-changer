#!/bin/sh

# at first some Definitions:
MINUTES=1440 # only once every timeframe the SSID will change to OFFLINE (set to 1 minute to change every time the router gets offline)
OFFLINE_PREFIX='FF_OFFLINE_' # use something short to leave space for the nodename (no '~' allowed!)

# if the router started less than 10 minutes ago, exit
[ $(cat /proc/uptime | sed 's/\..*//g') -gt 600 ] || exit

ONLINE_SSID="$(uci get wireless.client_radio0.ssid -q)"
: ${ONLINE_SSID:="FREIFUNK"} # if for whatever reason ONLINE_SSID is NULL

# Generate an Offline SSID with the first and last part of the nodename to allow owner to recognise wich node is down
NODENAME="$(uname -n)"
if [ ${#NODENAME} -gt $((30 - ${#OFFLINE_PREFIX})) ]; then # 32 would be possible as well
	HALF=$(( (28 - ${#OFFLINE_PREFIX} ) / 2 )) # calculate the length of the first part of the node identifier in the offline-ssid
	SKIP=$(( ${#NODENAME} - $HALF )) # jump to this charakter for the last part of the name
	OFFLINE_SSID=$OFFLINE_PREFIX${NODENAME:0:$HALF}...${NODENAME:$SKIP:${#NODENAME}} # use the first and last part of the nodename for nodes with long name
else
	OFFLINE_SSID="$OFFLINE_PREFIX$NODENAME" # great! we are able to use the full nodename in the offline ssid
fi

# maximum simplified, no more ttvn rating
CHECK=$(batctl gwl -H|grep -v "gateways in range"|wc -l)
HUP_NEEDED=0
if [ $CHECK -gt 0 ]; then
	echo "node is online"
	for HOSTAPD in $(ls /var/run/hostapd-phy*); do # check status for all physical devices
	CURRENT_SSID="$(grep "^ssid=$ONLINE_SSID" $HOSTAPD | cut -d"=" -f2)"
	if [ "$CURRENT_SSID" == "$ONLINE_SSID" ]
	then
		echo "SSID $CURRENT_SSID is correct, noting to do"
		break
	fi
	CURRENT_SSID="$(grep "^ssid=$OFFLINE_SSID" $HOSTAPD | cut -d"=" -f2)"
	if [ "$CURRENT_SSID" == "$OFFLINE_SSID" ]; then
		logger -s -t "gluon-offline-ssid" -p 5 "SSID is $CURRENT_SSID, change to $ONLINE_SSID"
		sed -i "s~^ssid=$CURRENT_SSID~ssid=$ONLINE_SSID~" $HOSTAPD
		HUP_NEEDED=1 # HUP here would be to early for dualband devices
	else
		echo "There is something wrong, did not find SSID $ONLINE_SSID or $OFFLINE_SSID"
	fi
done
elif [ $CHECK -eq 0 ]; then
	echo "node is considered offline"
	if [ $(expr $(date "+%s") / 60 % $MINUTES) -eq 0 ]; then
		for HOSTAPD in $(ls /var/run/hostapd-phy*); do
  		CURRENT_SSID="$(grep "^ssid=$OFFLINE_SSID" $HOSTAPD | cut -d"=" -f2)"
  		if [ "$CURRENT_SSID" == "$OFFLINE_SSID" ]; then
  			echo "SSID $CURRENT_SSID is correct, noting to do"
  			break
  		fi
  		CURRENT_SSID="$(grep "^ssid=$ONLINE_SSID" $HOSTAPD | cut -d"=" -f2)"
  		if [ "$CURRENT_SSID" == "$ONLINE_SSID" ]; then
  			logger -s -t "gluon-offline-ssid" -p 5 "SSID is $CURRENT_SSID, change to $OFFLINE_SSID"
  			sed -i "s~^ssid=$ONLINE_SSID~ssid=$OFFLINE_SSID~" $HOSTAPD
  			HUP_NEEDED=1
  		else
  			echo "There is something wrong: did neither find SSID '$ONLINE_SSID' nor '$OFFLINE_SSID'"
  		fi
		done
	fi
fi

if [ $HUP_NEEDED == 1 ]; then
	killall -HUP hostapd # send HUP to all hostapd to load the new SSID
	HUP_NEEDED=0
	echo "HUP!"
fi
