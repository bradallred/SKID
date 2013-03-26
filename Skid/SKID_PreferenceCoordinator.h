//
//  SKID_PreferenceCoordinator.h
//  Skid
//
//  Created by Brad Allred on 11/13/11.
//  Copyright (c) 2011 For Every Body. All rights reserved.
//
#include "SKID_GLOBALS.h"

#import <Foundation/Foundation.h>

#import "SKID_ApplicationFilters.h"

@interface SKID_PreferenceCoordinator : NSObject
{
@private
	BOOL _standardFnKeys;
	NSUserDefaults* _userDefaults;
	NSDictionary* _systemHotKeys; //holds both keyboard and mouse shortcuts.
	
	NSMutableDictionary* _SKIDPrefs;
}
@property(readonly, getter = standardFnKeys) BOOL _standardFnKeys;
+ (SKID_PreferenceCoordinator*)sharedCoordinator;

- (void)writePreferences;
- (void)reloadPreferences;

- (NSDictionary*)SKIDPreferences;

- (SKID_ApplicationFilters*)filtersForRunningApp:(NSRunningApplication*)app;
- (SKID_ApplicationFilters*)filtersForAppWithIdentifier:(NSString*)identifier;
- (void)setFilters:(SKID_ApplicationFilters*)filters;

- (MouseButtonFlags)MouseButtonForSymbolicKey:(NSString*)key;
- (MouseButtonFlags)MouseButtonForMissionControl;
- (MouseButtonFlags)MouseButtonForApplicationWindows;
- (MouseButtonFlags)MouseButtonForDesktop;
- (MouseButtonFlags)MouseButtonForDashboard;
- (MouseButtonFlags)AllMissionControlMouseButtons;
@end
