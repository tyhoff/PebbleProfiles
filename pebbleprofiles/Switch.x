#import "FSSwitchDataSource.h"
#import "FSSwitchPanel.h"
#include <CoreFoundation/CFNotificationCenter.h>
#import <Foundation/NSUserDefaults.h>
#import <Foundation/NSString.h>
#import <notify.h>
@interface NSUserDefaults (UFS_Category)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

static NSString *domainString = @"/var/mobile/Library/Preferences/com.tyhoff.pebbleprofiles.plist";
static NSString *notificationString = @"com.tyhoff.pebbleprofiles.preferencechanged";

@interface PebbleProfilesSwitch : NSObject <FSSwitchDataSource>
@end

@implementation PebbleProfilesSwitch

- (NSString *)titleForSwitchIdentifier:(NSString *)switchIdentifier {
	return @"Pebble Profiles";
}

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
	NSNumber *n = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"enabled" inDomain:domainString];
	BOOL enabled = (n)? [n boolValue]:YES;
	return (enabled) ? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {
	switch (newState) {
	case FSSwitchStateIndeterminate:
		break;
	case FSSwitchStateOn:
		[[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"enabled" inDomain:domainString];
		[[NSUserDefaults standardUserDefaults] synchronize];
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)notificationString, NULL, NULL, YES);
		break;
	case FSSwitchStateOff:
		[[NSUserDefaults standardUserDefaults] setObject:@NO forKey:@"enabled" inDomain:domainString];
		[[NSUserDefaults standardUserDefaults] synchronize];
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)notificationString, NULL, NULL, YES);
	}
	notify_post("com.tyhoff.pebbleprofiles.preferencechanged");
}

@end