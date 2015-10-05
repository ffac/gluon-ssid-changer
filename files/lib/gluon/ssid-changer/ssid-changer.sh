#!/bin/sh


#Is there an active Gateway
GATEWAY_TQ=`batctl gwl | grep "^=>" | cut -d" " -f3 | tr -d "()"`
if [ $GATEWAY_TQ > 50 ];
then
	echo "Gateway TQ is $GATEWAY_TQ node is online"
	for RADIO in $(iw dev | grep client | cut -d" " -f2); do
		CURRENT_SSID=`iw dev $RADIO info | grep ssid | cut -d" " -f2`
		# Use Freifunk for now, get it from /lib/gluon/site.conf in future version
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
	#There is a limit auf 32 charakters for the ssid + 'FF_OFFLINE_' leves us 21 maximum SSID length
	if [ ${#NODENAME} > 20 ] ; then
			OFFLINE_SSID=`echo "FF_OFFLINE_${STRING:0:9}...${STRING:(-9)}"` # use the first and last part of the nodename for nodes with long prefix
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

