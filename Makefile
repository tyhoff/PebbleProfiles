include theos/makefiles/common.mk

TWEAK_NAME = PebbleProfiles
PebbleProfiles_FILES = Tweak.xm
PebbleProfiles_FRAMEWORKS = UIKit Foundation
PebbleProfiles_LIBRARIES = applist Flipswitch

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 BTLEServer SpringBoard"

SUBPROJECTS += pebbleprofiles
SUBPROJECTS += pebblednd
include $(THEOS_MAKE_PATH)/aggregate.mk
