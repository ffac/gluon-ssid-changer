include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-ssid-changer
PKG_VERSION:=4

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(TOPDIR)/../package/gluon.mk

PKG_CONFIG_DEPENDS += $(GLUON_I18N_CONFIG)


define Package/gluon-ssid-changer
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=changes the SSID to an Offline-SSID so clients don't connect to an offline WiFi
  DEPENDS:=+gluon-core +micrond
endef

define Package/gluon-ssid-changer/description
  Script to change the SSID to an Offline-SSID when there is no connection to
  any gateway. This SSID can be generated from the nodes hostname with the first
  and last part of the nodename or the mac address, to allow observers to 
  recognise which node is down. The script is called once a minute by micron.d
  and it will change from online to offline-SSID maximum once every (definable)
  timeframe.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
	$(call GluonBuildI18N,gluon-ssid-changer,i18n)
	$(call GluonSrcDiet,./luasrc,$(PKG_BUILD_DIR)/luadest/)
endef

define Package/gluon-ssid-changer/install
	$(CP) ./files/* $(1)/
	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/
	./gluonShellDiet.sh $(1)/lib/gluon/ssid-changer/ssid-changer.sh
	$(call GluonInstallI18N,gluon-ssid-changer,$(1))
endef

define Package/gluon-ssid-changer/postinst
#!/bin/sh
$(call GluonCheckSite,check_site.lua)
endef

$(eval $(call BuildPackage,gluon-ssid-changer))
