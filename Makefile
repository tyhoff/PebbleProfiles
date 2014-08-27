TARGET =: clang

# 32bit and 64bit, but only advised if keeping 7.0+ compatibility
ARCHS = armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = PebbleProfiles
PebbleProfiles_FILES = Tweak.xm
PebbleProfiles_CFLAGS = -fobjc-arc
PebbleProfiles_LIBRARIES = applist

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 BTLEServer SpringBoard"

