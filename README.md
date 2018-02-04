gluon-ssid-changer
==================

This package adds a script to change the SSID to an Offline-SSID when there is
no connection to any gateway.
This SSID can be generated from the nodes hostname with the first
and last part of the nodename or the mac address, to allow observers to 
recognise which node is down. The script is called once a minute by micron.d
and it will change from online to offline-SSID maximum once every (definable)
timeframe.

You can enable/disable it in the config mode.

Once every timeframe it checks if there's still a gateway reachable. There can be
selected two algorithms to analyze if a gateway is reacheable:

- `tq_limit` enabled: define an upper and lower limit to turn the offline_ssid 
  on and off in-between these two values the SSID will never be changed to
  prevent it from toggeling every minute.
- `tq_limit` disabled: there will be only checked, if the gateway is reachable
  with:

        batctl gwl -H

Depending on the connectivity, it will be decided if a change of the SSID is 
necessary: There is a variable `switch_timeframe` (for ex.  1440 = 24h) that 
defines a time interval after which a successful check that detects an offline
state will result in a single change of the SSID to "FF_Offline_$node_hostname".
Only the first few minutes (also definable in a variable `first`) the 
OFFLINE_SSID may also be set. All other minutes a checks will just be counted
and reported in the log and whenever an online state is detected the SSID will
be set back immediately back to normal. when the timeframe is reached, there
will be checked if the node was offline at least half the timeframe, only then
the SSID will be changed.

site.conf
=========

Adapt and add this block to your site.conf: 

```
ssid_changer = {
  enabled = true,
  switch_timeframe = 30,    -- only once every timeframe (in minutes) the SSID will change to the Offline-SSID 
                            -- set to 1440 to change once a day
                            -- set to 1 minute to change every time the router gets offline
  first = 5,                -- the first few minutes directly after reboot within which an Offline-SSID always may be activated (must be <= switch_timeframe)
  prefix = 'FF_Offline_',   -- use something short to leave space for the nodename (no '~' allowed!)
  suffix = 'nodename',      -- generate the SSID with either 'nodename', 'mac' or to use only the prefix: 'none'
  
  tq_limit_enabled = false, -- if false, the offline SSID will only be set if there is no gateway reacheable
                            -- upper and lower limit to turn the offline_ssid on and off
                            -- in-between these two values the SSID will never be changed to prevent it from toggeling every minute.
  tq_limit_max = 45,        -- upper limit, above that the online SSID will be used
  tq_limit_min = 35         -- lower limit, below that the offline SSID will be used
},
```

Commandline options
===================

You can configure the ssid-changer on the commandline with `uci`, for example 
disable it with:

    uci set ssid-changer.settings.enabled='0'

Or set the timeframe to every three minutes with

    uci set ssid-changer.settings.switch_timeframe='3'
    uci set ssid-changer.settings.first='3'

Manual installation
===================

If you don't have ssid-changer in your firmware, you can still install it
manually on a node and set the desired settings that should differ from default:

```
ROUTER_IP='your:node::ip6'
LOGIN="root@[$ROUTER_IP]"
git clone https://github.com/Freifunk-Nord/gluon-ssid-changer.git ssid-changer
cd ssid-changer/gluon-ssid-changer/
git checkout lede
scp -r files/* $LOGIN:/
scp luasrc/lib/gluon/upgrade/500-ssid-changer $LOGIN:/lib/gluon/upgrade/
ssh $ROUTER_IP "/lib/gluon/upgrade/500-ssid-changer;" \
  "uci set ssid-changer.settings.switch_timeframe='3';" \
  "uci set ssid-changer.settings.first='3';" \
  "uci commit ssid-changer;" \
  "uci show ssid-changer;" \
  "/etc/init.d/micrond reload;"
```

Alternative: gluon-ssid-notifier
================================
If you just need the Offline-SSID for administrative purposes, there is a better solution,
that will just add an extra SSID if a node is offline:
https://github.com/freifunk-kiel/gluon-ssid-notifier/


Gluon versions
==============
This branch of the script contains the ssid-changer version for the gluon 
master branch (lede).

Implement this package in your firmware
=======================================
Create a file "modules" with the following content in your site directory:

```
GLUON_SITE_FEEDS="ssidchanger"
PACKAGES_SSIDCHANGER_REPO=https://github.com/ffac/gluon-ssid-changer.git
PACKAGES_SSIDCHANGER_COMMIT=263d9530ecd29ff9e232bbafd99500c3d47e76fb # <-- set the newest commit ID here
PACKAGES_SSIDCHANGER_BRANCH=lede
```

With this done you can add the package `gluon-ssid-changer` to your `site.mk`

History
=======
*The Lede Branch of the gluon-ssid-changer contains multible new features created in the fork https://github.com//gluon-ssid-changer and https://github.com/Freifunk-Nord/gluon-ssid-changer.*
