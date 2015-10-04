ssid-changer
============

Script to change the SSID when ther is no suffic sufficient connection in the mesh.

It is quite basic, just check the TQ of the Connection and decide if a change of the SSID is necessary.

Add the following lines to the modules file in your gluon directory:

PACKAGES_SSIDCHANGER_REPO=https://github.com/ffac/gluon-ssid-changer.git
PACKAGES_SSIDCHANGER_COMMIT=tbd

With this done you can add the package gluon-ssid-changer to your site.mk
# gluon-ssid-changer
