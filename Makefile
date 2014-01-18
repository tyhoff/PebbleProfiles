# IP of the iPhone on the network 
export THEOS_DEVICE_IP=192.168.1.149

TARGET =: clang

# 32bit and 64bit, but only advised if keeping 7.0+ compatibility
ARCHS = armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = PebbleProfiles
PebbleProfiles_FILES = Tweak.xm
PebbleProfiles_FRAMEWORKS = Foundation 
PebbleProfiles_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/mine.mk

after-install::
	install.exec "killall -9 BTLEServer"