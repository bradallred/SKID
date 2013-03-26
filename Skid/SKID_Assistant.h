//
//  SKID_Assistant.h
//  Skid
//
//  Created by Brad Allred on 11/13/11.
//  Copyright (c) 2011 For Every Body. All rights reserved.
//

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
