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

#import <AppKit/NSRunningApplication.h>
#import <Foundation/Foundation.h>

@interface SKID_ApplicationFilters : NSObject
{
	@private
	NSMutableDictionary* _mouseFilters;
	NSMutableDictionary* _keyboardFilters;
	NSString* _appIdentifier;//usually a bundle identifier
}
@property(readonly, getter = applicationName) NSString* _appIdentifier;

- (id)initWithFilters:(NSDictionary*)filters ForApplication:(NSString*)identifier;

- (BOOL)filteringMouseEventsForButton:(NSUInteger)buttonNumber;
- (BOOL)filteringKeyboardEventsForKeyCode:(UInt16)keyCode;

- (NSDictionary*)dictionaryRepresentation;
@end
