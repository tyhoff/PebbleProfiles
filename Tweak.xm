#import "headers.h"
#import "pebbleprofiles/FSSwitchPanel.h"

static BOOL hasReceivedLockComplete;
static BOOL isDeviceLocked;
static BOOL enabled;
static BOOL dnd;
static BOOL DNDEnabled;
static BOOL pebblednd;
static BOOL whitelist;

NSMutableArray *disabled_apps;
NSMutableArray *enabled_apps;
NSMutableDictionary *blacklisted_words;

%hook ANCService
- (void)alertAdded:(ANCAlert *)alert isSilent:(_Bool)isSilent
{
    if ([[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.do-not-disturb"] == 0){
        DNDEnabled = NO;
    }
    else if ([[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.do-not-disturb"] == 1){
        DNDEnabled = YES;
    }
    NSString *app_id = [alert appIdentifier];

    // do not allow applications that are not "enabled" to push a message
    if ([disabled_apps containsObject:app_id] || (dnd && DNDEnabled) || (pebblednd && !whitelist)) {
        return;
    }

    // if the device is locked or we are not enabled, then push a message
	if ((isDeviceLocked && !pebblednd) || !enabled || [enabled_apps containsObject:app_id]) 
	{
        NSString *black_word = [blacklisted_words objectForKey:app_id];
        if(black_word == nil || ([[alert title] rangeOfString:black_word options:NSCaseInsensitiveSearch].location == NSNotFound && [[alert message] rangeOfString:black_word options:NSCaseInsensitiveSearch].location == NSNotFound)) {
            %orig;
        }
	}
}

- (void)alertAdded:(id)alert isSilent:(_Bool)isSilent isPreExisting:(_Bool)arg3 {
    if ([[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.do-not-disturb"] == 0){
        DNDEnabled = NO;
    }
    else if ([[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.do-not-disturb"] == 1){
        DNDEnabled = YES;
    }
    NSString *app_id = [alert appIdentifier];

    // do not allow applications that are not "enabled" to push a message
    if ([disabled_apps containsObject:app_id] || (dnd && DNDEnabled) || (pebblednd && !whitelist)) {
        return;
    }

    //pebblednd && whitelist -> push messages because isDeviceLocked
    // if the device is locked or we are not enabled, then push a message
    if ((isDeviceLocked && !pebblednd) || !enabled || [enabled_apps containsObject:app_id])
    {
        NSString *black_word = [blacklisted_words objectForKey:app_id];
        if(black_word == nil || ([[alert title] rangeOfString:black_word options:NSCaseInsensitiveSearch].location == NSNotFound && [[alert message] rangeOfString:black_word options:NSCaseInsensitiveSearch].location == NSNotFound)) {
            %orig;
        }
    }
}

- (void)alertRemoved:(id)arg1 isSilent:(_Bool)arg2{
    %orig;
}
- (void)alertRemoved:(id)fp8{
    %orig;
}
- (void)alertAdded:(id)alert isPreExisting:(_Bool)arg2{
    if ([[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.do-not-disturb"] == 0){
        DNDEnabled = NO;
    }
    else if ([[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.do-not-disturb"] == 1){
        DNDEnabled = YES;
    }
    NSString *app_id = [alert appIdentifier];
    
    // do not allow applications that are not "enabled" to push a message
    if ([disabled_apps containsObject:app_id] || (dnd && DNDEnabled) || (pebblednd && !whitelist)) {
        return;
    }
    
    //pebblednd && whitelist -> push messages because isDeviceLocked
    // if the device is locked or we are not enabled, then push a message
    if ((isDeviceLocked && !pebblednd) || !enabled || [enabled_apps containsObject:app_id])
    {
        NSString *black_word = [blacklisted_words objectForKey:app_id];
        if(black_word == nil || ([[alert title] rangeOfString:black_word options:NSCaseInsensitiveSearch].location == NSNotFound && [[alert message] rangeOfString:black_word options:NSCaseInsensitiveSearch].location == NSNotFound)) {
            %orig;
        }
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
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/private/var/mobile/Library/Preferences/com.tyhoff.pebbleprofiles.plist"];
    enabled = ([prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : YES);
    dnd = ([prefs objectForKey:@"dnd"] ? [[prefs objectForKey:@"dnd"] boolValue] : NO);
    pebblednd = ([prefs objectForKey:@"pebblednd"] ? [[prefs objectForKey:@"pebblednd"] boolValue] : NO);
    if ([[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.do-not-disturb"] == 0){
        DNDEnabled = NO;
    }
    else if ([[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.do-not-disturb"] == 1){
        DNDEnabled = YES;
    }
    whitelist = ([prefs objectForKey:@"whitelist"] ? [[prefs objectForKey:@"whitelist"] boolValue] : NO);
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
    
    NSDictionary *apps3 = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.tyhoff.pebbleprofiles.applist3.plist"];
    blacklisted_words = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in apps3) {
        NSString *value = [apps3 objectForKey:key];
        if([value length] > 0) {
            [blacklisted_words setObject:value forKey:key];
        }
    }
    
    NSLog(@"[PEBBLEPROFILES] status:%d dndsetting:%d pebblednd:%d whitelist:%d",enabled,dnd,pebblednd,whitelist);
    NSLog(@"[PEBBLEPROFILES] Disabled Applications: %@", disabled_apps);
    NSLog(@"[PEBBLEPROFILES] Enabled Applications: %@", enabled_apps);
    NSLog(@"[PEBBLEPROFILES] Blacklisted words: %@", blacklisted_words);

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

  	/* subscribe to lock notifications */
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
