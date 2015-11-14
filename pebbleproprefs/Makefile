include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PebbleProPrefs
PebbleProPrefs_FILES = PPPrefsRootListController.m
PebbleProPrefs_INSTALL_PATH = /Library/PreferenceBundles
PebbleProPrefs_FRAMEWORKS = UIKit
PebbleProPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PebbleProPrefs.plist$(ECHO_END)
