//
//  SKID_ApplicationFilters.h
//  Skid
//
//  Created by Brad Allred on 12/3/11.
//  Copyright (c) 2011 For Every Body. All rights reserved.
//

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
