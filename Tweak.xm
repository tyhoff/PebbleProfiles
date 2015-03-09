#import "headers.h"

static BOOL hasReceivedLockComplete;
static BOOL isDeviceLocked;
static BOOL enabled;
NSMutableArray *disabled_apps;
NSMutableArray *enabled_apps;

#define GET_BOOL(key, default) (prefs[key] ? ((NSNumber *)prefs[key]).boolValue : default)


%hook ANCService
- (void)alertAdded:(ANCAlert *)alert isSilent:(_Bool)isSilent
{
    NSString *app_id = [alert appIdentifier];

    // do not allow applications that are not "enabled" to push a message
    if ([disabled_apps containsObject:app_id]) {
        return;
    }


    // if the device is locked or we are not enabled, then push a message
	if (isDeviceLocked || !enabled || [enabled_apps containsObject:app_id]) 
	{
		%orig;
	}
}

- (void)alertAdded:(id)alert isSilent:(_Bool)isSilent isPreExisting:(_Bool)arg3 {
    NSString *app_id = [alert appIdentifier];

    // do not allow applications that are not "enabled" to push a message
    if ([disabled_apps containsObject:app_id]) {
        return;
    }


    // if the device is locked or we are not enabled, then push a message
    if (isDeviceLocked || !enabled || [enabled_apps containsObject:app_id])
    {
        %orig;
    }
}
- (void)alertRemoved:(id)arg1 isSilent:(_Bool)arg2{

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

    NSDictionary *apps = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.tyhoff.pebbleprofiles.applist.plist"];
    disabled_apps = [[NSMutableArray alloc] init];

    // run through the App List and check for disabled applications in lockscreen. 
    // If enabled, save them to global disabled_apps array
    for (NSString *key in apps) {
        bool app_disabled = [[apps objectForKey:key] boolValue];

        if (app_disabled) {
            [disabled_apps addObject:key];
        }
    }
    NSLog(@"Disabled Applications: %@", disabled_apps);

    NSDictionary *apps2 = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.tyhoff.pebbleprofiles.applist2.plist"];
    enabled_apps = [[NSMutableArray alloc] init];

    // run through the App List and check for enabled applications. 
    // If enabled, save them to global enabled_apps array
    for (NSString *key in apps2) {
        bool app_enabled = [[apps2 objectForKey:key] boolValue];

        if (app_enabled) {
            [enabled_apps addObject:key];
        }
    }
    NSLog(@"Enabled Applications: %@", enabled_apps);
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

	/* subscribe to preference changed notification */
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
