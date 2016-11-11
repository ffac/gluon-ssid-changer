#!/bin/sh

# at first some Definitions:
MINUTES=1440 # only once every timeframe the SSID will change to OFFLINE (set to 1 minute to change every time the router gets offline)
OFFLINE_PREFIX='FF_OFFLINE_' # use something short to leave space for the nodename (no '~' allowed!)

ONLINE_SSID=$(uci get wireless.client_radio0.ssid -q)
: ${ONLINE_SSID:="FREIFUNK"} # if for whatever reason ONLINE_SSID is NULL

# Generate an Offline SSID with the first and last part of the nodename to allow owner to recognise wich node is down
NODENAME=`uname -n`
if [ ${#NODENAME} -gt $((30 - ${#OFFLINE_PREFIX})) ] ; then # 32 would be possible as well
	HALF=$(( (28 - ${#OFFLINE_PREFIX} ) / 2 )) # calculate the length of the first part of the node identifier in the offline-ssid
	SKIP=$(( ${#NODENAME} - $HALF )) # jump to this charakter for the last part of the name
	OFFLINE_SSID=$OFFLINE_PREFIX${NODENAME:0:$HALF}...${NODENAME:$SKIP:${#NODENAME}} # use the first and last part of the nodename for nodes with long name
else
	OFFLINE_SSID="$OFFLINE_PREFIX$NODENAME" # great! we are able to use the full nodename in the offline ssid
fi
# maximum simplyfied, no more ttvn rating
CHECK=$(batctl gwl -H|grep -v "gateways in range"|wc -l)

if [ $CHECK -eq 0 ] ; then
  if [ $(expr $(date "+%s") / 60 % $MINUTES) -eq 0 ]; then
    if [ "$(uci get wireless.client_radio0.ssid)" == "$OFFLINE_SSID" ]; then
      echo "$0 - still on $OFFLINE_SSID"
      exit 0
    fi
    echo "$0 change ssid to $OFFLINE_SSID" | logger
    uci set wireless.client_radio0.ssid="$OFFLINE_SSID"
    sed -i s~^ssid=$ONLINE_SSID~ssid=$OFFLINE_SSID~ /var/run/hostapd-phy0.conf
    killall -HUP hostapd
  fi
fi
if [ $CHECK -gt 0 ] ; then
  if [ "$(uci get wireless.client_radio0.ssid)" == "$ONLINE_SSID" ]; then
    echo "$0 - still on $ONLINE_SSID"
    exit 0
  fi
  echo "$0 change ssid to $ONLINE_SSID"| logger
  uci set wireless.client_radio0.ssid="$ONLINE_SSID"
  sed -i s~^ssid=$OFFLINE_SSID~ssid=$ONLINE_SSID~ /var/run/hostapd-phy0.conf
  killall -HUP hostapd
fi
