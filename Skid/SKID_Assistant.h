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

#import <AppKit/NSEvent.h>
#import <Foundation/Foundation.h>

#import "SKID_AssistantProtocol.h"
#import "SKID_PreferenceCoordinator.h"

typedef CFMachPortRef EventTap;

@interface SKID_Assistant : NSObject <SKID_AssistantProtocol>
{
	@private
	//event tap to capture system input
	EventTap _eventTap;
	CGEventMask _eventMask; //mask of events we are interested in.
	CFRunLoopSourceRef _runLoopSource;
	
	// Skid Daemon will vend itself as a service.
	NSConnection* _vendorConnection;
	
	//we need our own autoreleasepool since we are not using an NSRunLoop
	NSAutoreleasePool* _arPool;
	
	SKID_PreferenceCoordinator* _prefCoordinator;
	
	NSDictionary* _functionKeyLookup;
}
+ (SKID_Assistant*)sharedAssistant;
- (BOOL)tapEvents;
- (void)listen; //blocking call;

- (BOOL)processEvent:(CGEventRef)cgEvent;

- (SKID_ApplicationFilters*)filtersForActiveApplication:(NSRunningApplication**)activeApp;
@end
