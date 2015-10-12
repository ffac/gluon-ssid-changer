ssid-changer
============

Script to change the SSID when there is no suffic sufficient connection to the selected Gateway.

It is quite basic, it just checks the Quality of the Connection and decides if a change of the SSID is necessary.

Add the following lines to the modules file in your gluon directory:

PACKAGES_SSIDCHANGER_REPO=https://github.com/ffac/gluon-ssid-changer.git
PACKAGES_SSIDCHANGER_COMMIT=06bdf6fc6149af9cbb4564aac82cadd56a98a8b2

Add ssidchanger to GLUON_FEEDS at the top of the modules file.

With this done you can add the package gluon-ssid-changer to your site.mk
