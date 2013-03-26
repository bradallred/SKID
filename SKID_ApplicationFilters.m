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

#import "SKID_GLOBALS.h"

#import "SKID_ApplicationFilters.h"

#define KEY_MOUSE_FILTERS	@"mouseFilters"
#define KEY_KBOARD_FILTERS	@"keyboardFilters"

@implementation SKID_ApplicationFilters

static NSDictionary* functionKeyLookup = nil;

@synthesize _appIdentifier;

#pragma mark class methods
+ (void)initialize
{
	[super initialize];
	functionKeyLookup = [[NSDictionary alloc] initWithObjectsAndKeys:SKID_EV_DATA_F1, @"F1", SKID_EV_DATA_F2, @"F2",
						 S(SKID_KEY_EXPOSE), @"F3", S(SKID_KEY_DASHBOARD), @"F4",
						 SKID_EV_DATA_F5, @"F5", SKID_EV_DATA_F6, @"F6",
						 SKID_EV_DATA_F7, @"F7", SKID_EV_DATA_F8, @"F8", 
						 SKID_EV_DATA_F9, @"F9", SKID_EV_DATA_F10, @"F10",
						 SKID_EV_DATA_F11, @"F11", SKID_EV_DATA_F12, @"F12", nil];
}

#pragma mark instance methods
- (id)initWithFilters:(NSDictionary*)filters ForApplication:(NSString*)identifier
{
	self = [super init];
	if (self) {
		_appIdentifier = [identifier copy];
		_mouseFilters = [[NSMutableDictionary dictionaryWithDictionary:[filters valueForKey:KEY_MOUSE_FILTERS]] retain];
		_keyboardFilters = [[NSMutableDictionary dictionaryWithDictionary:[filters valueForKey:KEY_KBOARD_FILTERS]] retain];
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
	[_appIdentifier release];
	[_mouseFilters release];
	[_keyboardFilters release];
}

- (BOOL)filteringMouseEventsForButton:(NSUInteger)buttonNumber
{
	// buttonNumber is from a 0 based index, but the filters are written as a 1 based index
	NSNumber* search = [NSNumber numberWithUnsignedInteger:buttonNumber+1];
	NSLog(@"searching mouse filters for:%@", search);
	return [[_mouseFilters allValues] containsObject:search];
}

- (BOOL)filteringKeyboardEventsForKeyCode:(UInt16)keyCode
{
	NSString* search = [NSString stringWithFormat:@"0x%04X", keyCode];//[NSNumber numberWithUnsignedShort:keyCode];
	NSLog(@"searching key filters for:%@ found=%i", search, [[_keyboardFilters allValues] containsObject:search]);
	return [[_keyboardFilters allValues] containsObject:search];
}

// this method is somewhat expensive
// only call it when you really must
- (NSDictionary*)dictionaryRepresentation
{
	NSDictionary* mouseFiltersDict = [NSDictionary dictionaryWithDictionary:_mouseFilters];
	NSDictionary* keyboardDict = [NSDictionary dictionaryWithDictionary:_keyboardFilters];
	NSDictionary* filterDict = [NSDictionary dictionaryWithObjectsAndKeys:mouseFiltersDict, KEY_MOUSE_FILTERS, 
																		  keyboardDict, KEY_KBOARD_FILTERS, nil];
	return [NSDictionary dictionaryWithObject:filterDict forKey:_appIdentifier];
}

#pragma mark KVC method overrides
+ (BOOL)accessInstanceVariablesDirectly
{
	return NO;
}

- (id)valueForKey:(NSString *)key
{
	//test mouse buttons first
	id val = [_mouseFilters valueForKey:key];
	if (!val) val = [_keyboardFilters valueForKey:key];
	return val;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	//this is tricky. i guess we substring key into prefix and numeric suffix???
	NSString* prefix = [key substringToIndex:1];
	NSString* suffix = [key substringFromIndex:1];
	
	BOOL state = [value boolValue];
	
	if ([prefix isEqualToString:@"M"] && [suffix integerValue] > 0) { //mouse buttons
		if (state) {
			NSInteger mouseBtn = [suffix integerValue];
			[_mouseFilters setValue:[NSNumber numberWithInteger:mouseBtn] forKey:key];
		}else{
			[_mouseFilters setValue:nil forKey:key];//delete from dict
		}
	}else if ([prefix isEqualToString:@"F"]){ //function keys
		if (state) {
			//need to lookup the keycode for the function key
			NSLog(@"%@=%@", key, [functionKeyLookup valueForKey:key]);
			[_keyboardFilters setValue:[functionKeyLookup valueForKey:key] forKey:key];
		}else{
			[_keyboardFilters setValue:nil forKey:key];//delete from dict
		}
	}else{
		if ([super respondsToSelector:@selector(setValue:forKey:)]) {
			[super setValue:value forKey:key];
		}else{
			//throw an exception?
			[NSException raise:NSGenericException format:@"%@ is not key value coding compliant for key:%@", [self description], key];
		}
	}
}
@end
