ssid-changer
============

Script to change the SSID when there is no suffic sufficient connection to the selected Gateway.

It is quite basic, it just checks the Quality of the Connection and decides if a change of the SSID is necessary.

Create a file "modules" with the following content in your <a href="https://github.com/ffac/site/tree/offline-ssid"> site directory:</a>

GLUON_SITE_FEEDS="ssidchanger"<br>
PACKAGES_SSIDCHANGER_REPO=https://github.com/ffac/gluon-ssid-changer.git<br>
PACKAGES_SSIDCHANGER_COMMIT=e756679307ed5f9008b0e4ac1a486a67ca08719c<br>
PACKAGES_SSIDCHANGER_BRANCH=chaos-calmer<br>

With this done you can add the package gluon-ssid-changer to your site.mk

This branch of the skript contains the the ssid-changer version for the current master based on openwrt chaos-calmer (upcoming 2016.1)
