#!/bin/sh

# set some sysctl
# see kernel.org/doc/Documentation/sysctl/vm.txt
# sysctl -w vm.panic_on_oom=0 # deact reboot on oom
# sysctl -w kernel.panic=80 # 80s after panic reboot
# sysctl -w vm.overcommit_memory=2 # calc if enough mem is avail mmaloc
# echo 100 > /proc/sys/vm/overcommit_ratio # max % useable mem
# echo 0 > /proc/sys/vm/user_reserve_kbytes # only root need reserve
# echo 128 > /proc/sys/vm/lowmem_reserve_ratio

# raise prob. of proc to kill
# echo 10 > /proc/$(cat /var/run/fastd.mesh_vpn.pid)/oom_adj # deprecated
echo 700 > /proc/$(pgrep fastd)/oom_score_adj # fastd
echo 900 > /proc/$(pgrep ntp)/oom_score_adj # ntp
echo 950 > /proc/$(pgrep /usr/sbin/batadv-vis)/oom_score_adj # batvis

# if we see bat GW just exit
netz=$(batctl gwl -H|grep -v "gateways in range"|wc -l)
if [ $netz -ne 0 ] ; then 
        echo "$0 found GW in network, exiting"|logger
        echo 0 > /tmp/emergency
        exit 0
fi

# see ath9k for stopped
# cat /sys/kernel/debug/ieee80211/phy0/ath9k/queues

# simple counter 
touch /tmp/emergency
counter=$(cat /tmp/emergency)
if [ -z $counter ] ; then counter=0 ; fi
if [ $counter -lt 10 ]
        then 
		let counter+=1
		echo $counter > /tmp/emergency
		if [ $counter -eq 3 ]; then echo "$0 - 3 min offline - try wifi"|logger; wifi ; fi
		if [ $counter -eq 5 ]; then echo "$0 - 5 min offline - try restart fastd"|logger; /etc/init.d/fastd restart ; fi
		if [ $counter -eq 7 ]; then echo "$0 - 5 min offline - try restart network"|logger; /etc/init.d/network restart ; fi
        else reboot
fi 
echo $counter
