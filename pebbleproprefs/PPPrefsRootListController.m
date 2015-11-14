#import <Preferences/Preferences.h>

@interface PPPrefsRootListController: PSListController {
}
@end

@implementation PPPrefsRootListController

	- (NSArray *)specifiers {
		if (!_specifiers) {
			_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
		}

		return _specifiers;
	}
	-(void)donate {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.me/joemerlino"]];
	}

@end
