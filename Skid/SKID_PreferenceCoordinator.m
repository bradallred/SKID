/* SKID - System Key Intercept and Dispatch
 * Copyright (C) 2013 Brad Allred
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 */

#import "SKID_PreferenceCoordinator.h"

#define SYMBOLIC_KEY_MC			@"38"
#define SYMBOLIC_KEY_APP_WIN	@"39"
#define SYMBOLIC_KEY_DESKTOP	@"42"
#define SYMBOLIC_KEY_DASHBOARD	@"66"

@implementation SKID_PreferenceCoordinator
@synthesize _standardFnKeys;

#pragma mark singleton inmplemetation
// use singleton design pattern
static SKID_PreferenceCoordinator *sharedPreferenceCoordinator = nil;

+ (SKID_PreferenceCoordinator*)sharedCoordinator
{
    @synchronized(self) {
        if (sharedPreferenceCoordinator == nil) {
            [[self alloc] init];
        }
    }
    return sharedPreferenceCoordinator;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedPreferenceCoordinator == nil) {
            return [super allocWithZone:zone];
        }
    }
    return sharedPreferenceCoordinator;
}

- (id)init
{
    Class myClass = [self class];
    @synchronized(myClass) {
        if (sharedPreferenceCoordinator == nil) {
            if (self = [super init]) {
				NSLog(@"Preference coordinator: initializing...");
				_SKIDPrefs = nil;
				_systemHotKeys = nil;
				_userDefaults = [NSUserDefaults standardUserDefaults];//no retain needed

				sharedPreferenceCoordinator = self;

				// not sure if we should automatically call reload here.
				[self reloadPreferences];
            }
        }
    }
    return sharedPreferenceCoordinator;
}

- (id)copyWithZone:(NSZone *)zone { return self; }

- (id)retain { return self; }

- (NSUInteger)retainCount { return UINT_MAX; }

- (oneway void)release {}

- (id)autorelease { return self; }

- (void)dealloc
{
	// make sure verything is synchronized before deallocating.
	[self writePreferences];

	[super dealloc];
	[_userDefaults release];
	[_systemHotKeys release];
	[_SKIDPrefs release];
}

- (void)writePreferences
{
	@synchronized(_userDefaults){
		//NSLog(@"setting domain prefs:\n%@", [_SKIDPrefs description]);
		NSLog(@"writing filters out to disk.");
		[_userDefaults setPersistentDomain:_SKIDPrefs forName:SKID_DOMAIN];
		[_userDefaults synchronize]; //synchronize with files on disk
	}
	NSDistributedNotificationCenter* dnc = [NSDistributedNotificationCenter notificationCenterForType:NSLocalNotificationCenterType];
	[dnc postNotificationName:@"SKID_FiltersChanged" object:[NSString stringWithFormat:@"0x%08X", self]];
}

- (void)reloadPreferences
{
	// currently this method suffers from "double call" syndrome
	// init is calling it and it is called everytime the event tap gets created
	// as well as everytime the preference view is displayed
	@synchronized(_userDefaults){
		NSLog(@"Preference coordinator: loading preferences...");
		[_SKIDPrefs release];
		_SKIDPrefs = [NSMutableDictionary dictionaryWithDictionary:[_userDefaults persistentDomainForName:SKID_DOMAIN]];
		[_SKIDPrefs retain];

		// Always reload the symbolic hot keys here in case the user has changed them
		[_systemHotKeys release];
		_systemHotKeys = [[[_userDefaults persistentDomainForName:@"com.apple.symbolichotkeys"] valueForKey:@"AppleSymbolicHotKeys"] retain];
		//NSLog(@"symbolic hotkeys:\n%@", [_systemHotKeys description]);
		// are function keys set to be standard function keys?
		_standardFnKeys = [[[_userDefaults persistentDomainForName:NSGlobalDomain] valueForKey:@"com.apple.keyboard.fnState"] boolValue];
	}

	NSDistributedNotificationCenter* dnc = [NSDistributedNotificationCenter notificationCenterForType:NSLocalNotificationCenterType];
	[dnc postNotificationName:@"SKID_SystemKeysChanged" object:[NSString stringWithFormat:@"0x%08X", self]];
}

- (NSDictionary*)SKIDPreferences
{
	// dont return the mutable dictionary.
	return [NSDictionary dictionaryWithDictionary:_SKIDPrefs];
}

- (SKID_ApplicationFilters*)filtersForRunningApp:(NSRunningApplication*)app
{
	// not all applications have a bundle identifier. we cn lookup and store by name in
	// these situations.
	NSString* identifier = app.bundleIdentifier;
	if (!identifier) identifier = app.localizedName;
	return [self filtersForAppWithIdentifier:identifier];
}

- (SKID_ApplicationFilters*)filtersForAppWithIdentifier:(NSString*)identifier
{
	NSDictionary* appFilterPrefs = [_SKIDPrefs valueForKeyPath:[NSString stringWithFormat:@"applicationFilters.%@", identifier]];
	SKID_ApplicationFilters* filters = nil;
	if (appFilterPrefs) {
		filters = [[SKID_ApplicationFilters alloc] initWithFilters:appFilterPrefs ForApplication:identifier];
	}
	return [filters autorelease];
}

- (void)setFilters:(SKID_ApplicationFilters*)filters
{
	NSDictionary* filterDict = [filters dictionaryRepresentation];
	
	NSMutableDictionary* appFilters = [NSMutableDictionary dictionaryWithDictionary:[_SKIDPrefs objectForKey:@"applicationFilters"]];
	if (!appFilters) {
		appFilters = [NSMutableDictionary dictionaryWithObject:[[filterDict allValues] objectAtIndex:0] forKey:@"applicationFilters"];
	}else{
		[appFilters addEntriesFromDictionary:filterDict]; 
	}
	[_SKIDPrefs setValue:appFilters forKey:@"applicationFilters"];
	//NSLog(@"skid prefs:\n%@", _SKIDPrefs);
	//[_SKIDPrefs setValue:[[filterDict allValues] objectAtIndex:0] forKeyPath:[NSString stringWithFormat:@"applicationFilters.%@", appName]];
	//NSDictionary* filters = [[filters dictionaryRepresentation] objectForKey:@"applicationFilters"];
	//[_SKIDPrefs setValue:[filters dictionaryRepresentation] forKey:<#(NSString *)#>
}

- (MouseButtonFlags)MouseButtonForSymbolicKey:(NSString*)key
{
	NSDictionary* hotKey = [_systemHotKeys valueForKey:key];
	//NSLog(@"%@\n%@", _systemHotKeys, hotKey);
	if ([[hotKey valueForKey:@"enabled"] boolValue]) {
		//NSLog(@"Button for %@=%ld", key, [[[hotKey valueForKeyPath:@"value.parameters"] objectAtIndex:0] integerValue]);
		return [[[hotKey valueForKeyPath:@"value.parameters"] objectAtIndex:0] integerValue];
	}
	return 0;
}

- (MouseButtonFlags)MouseButtonForMissionControl
{
	return [self MouseButtonForSymbolicKey:SYMBOLIC_KEY_MC];
}

- (MouseButtonFlags)MouseButtonForApplicationWindows
{
	return [self MouseButtonForSymbolicKey:SYMBOLIC_KEY_APP_WIN];
}

- (MouseButtonFlags)MouseButtonForDesktop
{
	return [self MouseButtonForSymbolicKey:SYMBOLIC_KEY_DESKTOP];
}

- (MouseButtonFlags)MouseButtonForDashboard
{
	return [self MouseButtonForSymbolicKey:SYMBOLIC_KEY_DASHBOARD];
}

- (MouseButtonFlags)AllMissionControlMouseButtons
{
	return ([self MouseButtonForMissionControl] | 
			[self MouseButtonForApplicationWindows] | 
			[self MouseButtonForDesktop] | 
			[self MouseButtonForDashboard]);
}

@end
