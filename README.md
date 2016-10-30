ssid-changer.sh
===============

This script changes the SSID when there is no connection to the selected Gateway.

Once a minute it checks if there is a gateway reacheable with `batctl gwl -H` and
decides if a change of the SSID is necessary.

*It is a simplified rewrite of https://github.com/ffac/gluon-ssid-changer that doesn't check
the tx value any more. It is in use in Freifunk Freiburg*

emergency.sh
============
this repository also includes an emergency script which checks for a working batman-adv
gateway connection. If no Gateway connection exists some countermeasures are started:

 - 3 min offline - call `wifi`
 - 5 min offline - restart fastd
 - 7 min offline - restart networking

If no countermeasure works bringing the node online again, the router will be enforced
to reboot after 10 minutes.

*Note: this script may cause a problem for users, that use the node on purposes intended
to work without functioning gateway connectivity, for example as a switch (disable
the cronjob there).*

Gluon versions
==============
This branch of the skript contains the the ssid-changer version for the gluon 2016.1.x
based on openwrt `chaos-calmer`. There is also a pre 2016.1 (barrier braker based)
version in the branch `master`. It will probably not work in 2016.2 yet.

Implement this package in your firmware
=======================================
Create a file "modules" with the following content in your
<a href="https://github.com/ffac/site/tree/offline-ssid"> site directory:</a>

GLUON_SITE_FEEDS="ssidchanger"<br>
PACKAGES_SSIDCHANGER_REPO=https://github.com/ffac/gluon-ssid-changer.git<br>
PACKAGES_SSIDCHANGER_COMMIT=1146ff354ff0bb99a100d6b067fc410068e7521d<br>
PACKAGES_SSIDCHANGER_BRANCH=chaos-calmer<br>

With this done you can add the package gluon-ssid-changer to your site.mk
