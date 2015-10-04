#!/bin/sh



#Is there an active Gateway
GATEWAY_TQ=`batctl gwl | grep "^=>" | cut -d" " -f3 | tr -d "()"`
if [ $GATEWAY_TQ > 50 ];
then
	echo "Gateway TQ is $GATEWAY_TQ node is online"
	for RADIO in $(iw dev | grep client | cut -d" " -f2); do
		CURRENT_SSID=`iw dev $RADIO info | grep ssid | cut -d" " -f2`
		# Use Freifunk for now, get it from /lib/gluon/site.conf in futre version
		if [ $CURRENT_SSID == 'Freifunk' ]
		then
			echo "SSID $CURRENT_SSID is correct, noting to do"
		else
			NUM=`echo $RADIO | tail -c 2`
			`uci set wireless.client_radio$NUM.ssid="Freifunk"`
			wifi
		fi
	done

else
	echo "Gateway TQ is $GATEWAY_TQ node is considered offline"
	NODENAME=`uname -n`
	OFFLINE_SSID=`echo "Freifunk_OFFLINE_$NODENAME" | cut -b -30`
	for RADIO in $(iw dev | grep client | cut -d" " -f2); do
		CURRENT_SSID=`iw dev $RADIO info | grep ssid | cut -d" " -f2`
		if [ $CURRENT_SSID == $OFFLINE_SSID ]
		then
			echo "SSID $CURRENT_SSID is correct, noting to do"
		else
			NUM=`echo $RADIO | tail -c 2`
			`uci set wireless.client_radio$NUM.ssid="$OFFLINE_SSID"`
			wifi
		fi

	done
fi

