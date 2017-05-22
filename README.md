ssid-changer.sh
===============

This script changes the SSID when there is no connection to the selected Gateway.

Once a minute it checks if there's still a gateway reacheable with 

    batctl gwl -H

and then decides if a change of the SSID is necessary: There is a variable
MINUTES (default 1440 = 24h) at the top of the script `files/lib/gluon/ssid-changer/ssid-changer.sh`
that defines after how many minutes offline the SSID will be changed to 
"FF_OFFLINE_$node_hostname". 

*This is a fork of https://github.com/ffac/gluon-ssid-changer that doesn't check
the tx value any more. It is now in use in Freifunk Nord*

Gluon versions
==============
This branch of the skript contains the ssid-changer version for the gluon 2016.2.x.

Implement this package in your firmware
=======================================
Create a file "modules" with the following content in your site directory:

```
GLUON_SITE_FEEDS="ssidchanger"
PACKAGES_SSIDCHANGER_REPO=https://github.com/freifunk-nord/gluon-ssid-changer.git
PACKAGES_SSIDCHANGER_COMMIT=aa7aba3c2d013528545b40cc92a0e353adc21c66
PACKAGES_SSIDCHANGER_BRANCH=master
```

With this done you can add the package `gluon-ssid-changer` to your `site.mk`
