ssid-changer.sh
===============

This script changes the SSID when there is no connection to the selected Gateway.

Once a minute it checks if there's still a gateway reachable with 

site.conf
=========

Adapt and add this block to your site.conf: 

```
ssid_changer = {
  switch_timeframe = 1,   -- only once every timeframe (in minutes) the SSID will change to OFFLINE 
                          -- set to 1440 to change once a day
                          -- set to 1 minute to change every time the router gets offline
  first = 5,              -- the first few minutes directly after reboot within which an Offline-SSID always may be activated
  prefix = 'FF_OFFLINE_', -- use something short to leave space for the nodename (no '~' allowed!)
  suffix = 'nodename',    -- generate the SSID with either 'nodename', 'mac' or to use only the prefix: 'none'
  
  tq_limit_enabled = 0,   -- if false, the offline SSID will only be set if there is no gateway reacheable
                          -- upper and lower limit to turn the offline_ssid on and off
                          -- in-between these two values the SSID will never be changed to prevent it from toggeling every minute.
  tq_limit_max = '45',    -- upper limit, above that the online SSID will be used
  tq_limit_min = '35'     -- lower limit, below that the offline SSID will be used
},
```

if tq_limit is disabled, then it will be only checked, if the gateway is reachable with

    batctl gwl -H


Depending on the connectivity, it will be decided if a change of the SSID is 
necessary: There is a variable `switch_timeframe` (for ex.  1440 = 24h) that 
defines a time interval after which a successful check that detects an offline
state will result in a single change of the SSID to "FF_OFFLINE_$node_hostname".
Only the first few (also definable in a variable `first`) minutes the 
OFFLINE_SSID may also be set. All other minutes a checks will just be reported
in the log and whenever an online state is detected the SSID will be set back
immediately back to normal. 

Commandline options
===================

You can configure the ssid-changer on the commandline with `uci`, for example 
disable it with:

    uci set ssid-changer.settings.enabled='0'


Gluon versions
==============
This branch of the script contains the ssid-changer version for the gluon 
master branch (lede).

Implement this package in your firmware
=======================================
Create a file "modules" with the following content in your site directory:

```
GLUON_SITE_FEEDS="ssidchanger"
PACKAGES_SSIDCHANGER_REPO=https://github.com/freifunk-nord/gluon-ssid-changer.git
PACKAGES_SSIDCHANGER_COMMIT=614d2f5ac45a424057d7171f80716acf6cad63e1 # <-- set the newest commit ID here
PACKAGES_SSIDCHANGER_BRANCH=master
```

With this done you can add the package `gluon-ssid-changer` to your `site.mk`


*This is a fork of https://github.com/ffac/gluon-ssid-changer that doesn't check
the tx value any more. It is now in use in Freifunk Nord*
