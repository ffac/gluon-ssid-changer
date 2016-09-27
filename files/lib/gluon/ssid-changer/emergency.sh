#!/bin/sh

# set some sysctl
sysctl -w vm.panic_on_oom=0 # deact reboot on oom
sysctl -w kernel.panic=80 # 80s after panic reboot
sysctl -w vm.overcommit_memory=2 # calc if enough mem is avail mmaloc

# raise prob. of proc to kill
# echo 10 > /proc/$(cat /var/run/fastd.mesh_vpn.pid)/oom_adj # deprecated
echo 700 > /proc/$(pgrep fastd)/oom_score_adj # fastd
echo 900 > /proc/$(pgrep ntp)/oom_score_adj # ntp
echo 950 > /proc/$(pgrep /usr/sbin/batadv-vis)/oom_score_adj # batvis

# if we see bat GW just exit
netz=$(batctl gwl -H|wc -l)
if [ $netz -ne 0 ] ; then 
        logger "emergency found network, exiting"
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
        then let counter+=1; echo $counter > /tmp/emergency 
        else reboot
fi 
echo $counter

