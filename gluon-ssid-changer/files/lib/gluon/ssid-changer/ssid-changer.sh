#!/bin/sh

# only once every timeframe the SSID will change to OFFLINE (set to 1 minute to change every time the router gets offline)
MINUTES="$(uci -q get ssid-changer.settings.switch_timeframe)"
# the first few minutes directly after reboot within which an Offline-SSID always may be activated
: ${MINUTES:=1}

FIRST="$(uci -q get ssid-changer.settings.first)"
# use something short to leave space for the nodename (no '~' allowed!)
: ${FIRST:=5}

PREFIX="$(uci -q get ssid-changer.settings.prefix)"
# the Offline-SSID will start with this prefix
: ${PREFIX:='FF_OFFLINE_'}

if [ "$(uci -q get ssid-changer.settings.enabled)" = '0' ]; then 
	DISABLED='1'
else
	DISABLED='0'
fi

SETTINGS_SUFFIX="$(uci -q get ssid-changer.settings.suffix)"
# generate the ssid with either 'nodename', 'mac' or to use only the prefix set to 'none'
: ${SETTINGS_SUFFIX:='nodename'}

if [ $SETTINGS_SUFFIX = 'nodename' ]; then
	SUFFIX="$(uname -n)"
	# 32 would be possible as well
	if [ ${#SUFFIX} -gt $((30 - ${#PREFIX})) ]; then
		# calculate the length of the first part of the node identifier in the offline-ssid
		HALF=$(( (28 - ${#PREFIX} ) / 2 ))
		# jump to this charakter for the last part of the name
		SKIP=$(( ${#SUFFIX} - $HALF ))
		# use the first and last part of the nodename for nodes with long name
		SUFFIX=${SUFFIX:0:$HALF}...${SUFFIX:$SKIP:${#SUFFIX}}
	fi
elif [ $SETTINGS_SUFFIX = 'mac' ]; then
	SUFFIX="$(uci -q get network.bat0.macaddr)"
else
	# 'none'
	SUFFIX=''
fi

OFFLINE_SSID="$PREFIX$SUFFIX"

ONLINE_SSID="$(uci -q get wireless.client_radio0.ssid)"
# if for whatever reason ONLINE_SSID is NULL
: ${ONLINE_SSID:="FREIFUNK"}

TQ_LIMIT_ENABLED="$(uci -q get ssid-changer.settings.tq_limit_enabled)"
# if true, the offline ssid will only be set if there is no gateway reacheable
# upper and lower limit to turn the offline_ssid on and off
# in-between these two values the SSID will never be changed to preven it from toggeling every Minute.
: ${TQ_LIMIT_ENABLED:='0'}

if [ $TQ_LIMIT_ENABLED = 1 ]; then
	TQ_LIMIT_MAX="$(uci -q get ssid-changer.settings.tq_limit_max)"
	#  upper limit, above that the online SSID will be used
	: ${TQ_LIMIT_MAX:='55'}
	TQ_LIMIT_MIN="$(uci -q get ssid-changer.settings.tq_limit_min)"
	#  lower limit, below that the offline SSID will be used
	: ${TQ_LIMIT_MIN:='45'}
	# grep the connection quality of the currently used gateway
	GATEWAY_TQ=$(batctl gwl | grep -e "^=>" -e "^\*" | awk -F '[('')]' '{print $2}' | tr -d " ")
	if [ ! $GATEWAY_TQ ]; then
		# there is no gateway
		GATEWAY_TQ=0
	fi
	
	MSG="TQ is $GATEWAY_TQ, "
	
	if [ $GATEWAY_TQ -gt $TQ_LIMIT_MAX ]; then
		CHECK=1
	elif [ $GATEWAY_TQ -lt $TQ_LIMIT_MIN ]; then
		CHECK=0
	else
		# this is just get a clean run if we are in-between the grace periode
		echo "TQ is $GATEWAY_TQ, do nothing"
		exit
	fi
else
	MSG=""
	
	CHECK="$(batctl gwl -H|grep -v "gateways in range"|wc -l)"
fi


HUP_NEEDED=0
if [ "$CHECK" -gt 0 ] || [ "$DISABLED" = '1' ]; then
	echo "node is online"
	# check status for all physical devices
	for HOSTAPD in $(ls /var/run/hostapd-phy*); do
		CURRENT_SSID="$(grep "^ssid=$ONLINE_SSID" $HOSTAPD | cut -d"=" -f2)"
		if [ "$CURRENT_SSID" = "$ONLINE_SSID" ]; then
			echo "SSID $CURRENT_SSID is correct, nothing to do"
			break
		fi
		CURRENT_SSID="$(grep "^ssid=$OFFLINE_SSID" $HOSTAPD | cut -d"=" -f2)"
		if [ "$CURRENT_SSID" = "$OFFLINE_SSID" ]; then
			logger -s -t "gluon-ssid-changer" -p 5 $MSG"SSID is $CURRENT_SSID, change to $ONLINE_SSID"
			sed -i "s~^ssid=$CURRENT_SSID~ssid=$ONLINE_SSID~" $HOSTAPD
			# HUP here would be to early for dualband devices
			HUP_NEEDED=1
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
				logger -s -t "gluon-ssid-changer" -p 5 $MSG"SSID is $CURRENT_SSID, change to $OFFLINE_SSID"
				sed -i "s~^ssid=$ONLINE_SSID~ssid=$OFFLINE_SSID~" $HOSTAPD
				HUP_NEEDED=1
			else
				logger -s -t "gluon-ssid-changer" -p 5 "could not set to offline state: did neither find SSID '$ONLINE_SSID' nor '$OFFLINE_SSID'. Please reboot"
			fi
		done
	fi
fi

if [ $HUP_NEEDED = 1 ]; then
	# send HUP to all hostapd to load the new SSID
	killall -HUP hostapd
	HUP_NEEDED=0
	echo "HUP!"
fi
