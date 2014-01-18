#import "headers.h"

static BOOL hasReceivedLockComplete;
static BOOL isDeviceLocked;
static BOOL enabled;

#define GET_BOOL(key, default) (prefs[key] ? ((NSNumber *)prefs[key]).boolValue : default)

%hook ANCService
- (void)updateDataSource:(id)arg1 central:(id)arg2 
{ 
	%log; 
	if (isDeviceLocked || !enabled) 
	{
		%orig;
	}

}
%end

/* Notification received callback */
static void displayStatusChanged(CFNotificationCenterRef center, 
								 void *observer, 
								 CFStringRef name, 
								 const void *object, 
								 CFDictionaryRef userInfo)
{
    // the "com.apple.springboard.lockcomplete" notification will always come after the "com.apple.springboard.lockstate" notification
    NSString *lockState = (__bridge NSString *)name;
    

    if([lockState isEqualToString:@"com.apple.springboard.lockcomplete"])
    {
        NSLog(@"[Pebble Profiles] - DEVICE LOCKED");
        isDeviceLocked = YES;
        hasReceivedLockComplete = YES;
    }
    else
    {
    	if (!hasReceivedLockComplete) 
    	{
    		NSLog(@"[Pebble Profiles] - DEVICE UNLOCKED");
    		isDeviceLocked = NO;
    	}
    	else
    	{
    		hasReceivedLockComplete = NO;
    	}
    }
}

/* called when a change to the preferences has been made */
static void LoadSettings()
{
  	NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.tyhoff.pebbleprofiles.plist"];
  	enabled = GET_BOOL(@"enabled", YES);
}

/* called when a change to the preferences has been made */
static void ChangeNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
  	LoadSettings();
}


/* constructor of tweak */
%ctor
{
	hasReceivedLockComplete = NO;
	isDeviceLocked = YES;

	/* subsribe to preference changed notification */
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, ChangeNotification, CFSTR("com.tyhoff.pebbleprofiles.preferencechanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
  	LoadSettings();

  	/* subscribe to lock notificatins */
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), //center
                                    NULL, // observer
                                    displayStatusChanged, // callback
                                    CFSTR("com.apple.springboard.lockcomplete"), // event name
                                    NULL, // object
                                    CFNotificationSuspensionBehaviorDeliverImmediately);

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), //center
                                    NULL, // observer
                                    displayStatusChanged, // callback
                                    CFSTR("com.apple.springboard.lockstate"), // event name
                                    NULL, // object
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
}