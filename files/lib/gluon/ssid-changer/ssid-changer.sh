
#!/bin/sh

# At first some Definitions:

ONLINE_SSID='Freifunk'
OFFLINE_PREFIX='FF_OFFLINE_' # Use something short to leave space for the nodename

#Is there an active Gateway
GATEWAY_TQ=`batctl gwl | grep "^=>" | cut -d" " -f3 | tr -d "()"`
if [ $GATEWAY_TQ -gt 50 ];
then
	echo "Gateway TQ is $GATEWAY_TQ node is online"
	for RADIO in $(iw dev | grep client | cut -d" " -f2); do
		CURRENT_SSID=`iw dev $RADIO info | grep ssid | cut -d" " -f2` # Is there a better way to fetch the SSID wich is active?
		if [ $CURRENT_SSID == $ONLINE_SSID ]
		then
			echo "SSID $CURRENT_SSID is correct, noting to do"
		else
			echo "SSID is $CURRENT_SSID, change to $ONLINE_SSID"
			NUM=`echo $RADIO | tail -c 2`
			`uci set wireless.client_radio$NUM.ssid=$ONLINE_SSID`
			wifi
		fi
	done

else
	echo "Gateway TQ is $GATEWAY_TQ node is considered offline"
	NODENAME=`uname -n`
	if [ ${#NODENAME} > 30-${#OFFLINE_PREFIX} ] ; then #32 would be possible as well
		HALF=$(( (28 - ${#OFFLINE_PREFIX} ) / 2 ))
		SKIP=$(( ${#NODENAME} - $HALF ))
		OFFLINE_SSID=$OFFLINE_PREFIX${NODENAME:0:$HALF}...${NODENAME:$SKIP:${#NODENAME}} # use the first and last part of the nodename for nodes with long name
		else
			OFFLINE_SSID=`$OFFLINE_PREFIX$NODENAME`
		fi
	for RADIO in $(iw dev | grep client | cut -d" " -f2); do
		CURRENT_SSID=`iw dev $RADIO info | grep ssid | cut -d" " -f2`
		if [ $CURRENT_SSID == $OFFLINE_SSID ]
		then
			echo "SSID $CURRENT_SSID is correct, noting to do"
		else
			echo "SSID is $CURRENT_SSID, change to $OFFLINE_SSID"
			NUM=`echo $RADIO | tail -c 2`
			`uci set wireless.client_radio$NUM.ssid="$OFFLINE_SSID"`
			wifi
		fi

	done
fi
