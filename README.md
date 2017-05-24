ssid-changer.sh
===============

This script changes the SSID when there is no connection to the selected Gateway.

Once a minute it checks if there's still a gateway reachable with 

    batctl gwl -H

and then decides if a change of the SSID is necessary: There is a variable
MINUTES (default 1440 = 24h) at the top of the script `files/lib/gluon/ssid-changer/ssid-changer.sh`
that defines a time interval in which a successful check that detects an offline
state is allowed to change the SSID once to "FF_OFFLINE_$node_hostname". Only the
first few (also definable in a variable FIRST) minutes the OFFLINE_SSID may also
be set. All other minutes a checks will just be reported in the log and whenever
an online state is detected the SSID will be set back immediately back to normal. 

Gluon versions
==============
This branch of the script contains the ssid-changer version for the gluon 2016.2.x.

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
