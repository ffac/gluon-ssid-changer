ssid-changer.sh
===============

This script changes the SSID when there is no connection to the selected Gateway.

Once a minute it checks if there is a gateway reacheable with `batctl gwl -H` and
decides if a change of the SSID is necessary.

*It is a fork of https://github.com/ffac/gluon-ssid-changer that doesn't check
the tx value any more. It will be in use in Freifunk Nord*

Gluon versions
==============
This branch of the skript contains the the ssid-changer version for the gluon 2016.1.x. It might probably not work in 2016.2 yet.

Implement this package in your firmware
=======================================
Create a file "modules" with the following content in your site directory:

```
GLUON_SITE_FEEDS="ssidchanger"
PACKAGES_SSIDCHANGER_REPO=https://github.com/freifunk-nord/gluon-ssid-changer.git
PACKAGES_SSIDCHANGER_COMMIT=bc81df8a5a3e19c524f0ea9ede3ae4ab79bb01fd
PACKAGES_SSIDCHANGER_BRANCH=master
```

With this done you can add the package gluon-ssid-changer to your site.mk
