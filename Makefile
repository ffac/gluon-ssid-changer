include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-ssid-changer
PKG_VERSION:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-ssid-changer
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=SSID Changer
  DEPENDS:=+gluon-core
endef

define Build/Prepare
        mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-ssid-changer/install
        $(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-ssid-changer))

