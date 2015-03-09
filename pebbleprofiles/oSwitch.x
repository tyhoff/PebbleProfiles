#import "FSSwitchDataSource.h"
#import "FSSwitchPanel.h"
#include <CoreFoundation/CFNotificationCenter.h>
#import <notify.h>
NSString *path = @"/var/mobile/Library/Preferences/com.tyhoff.pebbleprofiles.plist";
static NSString * const kSwitchKey = @"enabled";
static NSString *notificationString = @"com.tyhoff.pebbleprofiles.preferencechanged";

@interface PebbleProfilesSwitch : NSObject <FSSwitchDataSource>
@end

@implementation PebbleProfilesSwitch

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier
{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    id enable = [dict objectForKey:kSwitchKey];
    BOOL isEnabled = enable ? [enable boolValue] : YES;
    return isEnabled ? FSSwitchStateOn : FSSwitchStateOff;
}
// Set a new state for the switch.
- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSMutableDictionary *mutableDict = dict ? [[dict mutableCopy] autorelease] : [NSMutableDictionary dictionary];
    switch (newState) {
        case FSSwitchStateIndeterminate:
            return;
        case FSSwitchStateOn:
            [mutableDict setValue:@YES forKey:kSwitchKey];
            break;
        case FSSwitchStateOff:
            [mutableDict setValue:@NO forKey:kSwitchKey];
            break;
    }
    [mutableDict writeToFile:path atomically:YES];
    notify_post()
}
 
// Provide a proper title instead of its bundle ID:
- (NSString *)titleForSwitchIdentifier:(NSString *)switchIdentifier {
	return @"PebbleProfiles";
}

@end