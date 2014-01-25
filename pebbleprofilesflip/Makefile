TARGET =: clang

# 32bit and 64bit, but only advised if keeping 7.0+ compatibility
ARCHS = armv7 arm64

include theos/makefiles/common.mk

BUNDLE_NAME = PebbleProfilesFlip
PebbleProfilesFlip_FILES = Switch.x
PebbleProfilesFlip_FRAMEWORKS = UIKit
PebbleProfilesFlip_PRIVATE_FRAMEWORKS = GraphicsServices
PebbleProfilesFlip_LIBRARIES = flipswitch
PebbleProfilesFlip_INSTALL_PATH = /Library/Switches

include $(THEOS_MAKE_PATH)/bundle.mk