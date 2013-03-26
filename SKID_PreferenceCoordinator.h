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
