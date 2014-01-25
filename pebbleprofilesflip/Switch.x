#import "FSSwitchDataSource.h"
#import "FSSwitchPanel.h"
#import <notify.h>

#ifndef GSEVENT_H
extern void GSSendAppPreferencesChanged(CFStringRef bundleID, CFStringRef key);
#endif

#define PebbleProfilesPlist @"/var/mobile/Library/Preferences/com.tyhoff.pebbleprofiles.plist"
#define PebbleProfilesEnabledKey @"enabled"

@interface PebbleProfilesFlipSwitch : NSObject <FSSwitchDataSource>
@end

@implementation PebbleProfilesFlipSwitch

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier
{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PebbleProfilesPlist];
    BOOL enabled = ([dict objectForKey:PebbleProfilesEnabledKey] && [[dict valueForKey:PebbleProfilesEnabledKey] boolValue]);

    return enabled;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier
{
	if (newState == FSSwitchStateIndeterminate)
		return;


	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:PebbleProfilesPlist] ?: [[NSMutableDictionary alloc] init];
    NSNumber *value = [NSNumber numberWithBool:newState];
    [dict setValue:value forKey:PebbleProfilesEnabledKey];
    [dict writeToFile:PebbleProfilesPlist atomically:YES];
    [dict release];

    notify_post("com.tyhoff.pebbleprofiles.preferencechanged");
    GSSendAppPreferencesChanged(CFSTR("com.tyhoff.pebbleprofiles"), (CFStringRef)PebbleProfilesEnabledKey);
}

@end