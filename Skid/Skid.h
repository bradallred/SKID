//
//  Skid.h
//  Skid
//
//  Created by Brad Allred on 11/13/11.
//  Copyright (c) 2011 For Every Body. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>
#import "SKID_AssistantProtocol.h"
#import "SteamService.h"

enum LIST_NODE_TYPE {
	NODE_UNDEFINED = 0x00,
	NODE_DIRECTORY = 0x01,
	NODE_APPLICATION = 0x02,
	NODE_OTHER = 0x03
};

@class SKID_PreferenceCoordinator;

@interface Skid : NSPreferencePane <NSOutlineViewDataSource, NSOutlineViewDelegate>
{
	@private
	NSMutableArray* _applicationSources;
	
	NSMatrix* _functionKeyMatrix;
	NSMatrix* _mouseButtonMatrix;
	
	NSOutlineView* _applicationSourcesOutlineView;
	
	SKID_PreferenceCoordinator* _preferenceCoordinator;
	id <SKID_AssistantProtocol> _agent;//NSDistantObject but we can use it as if it were an instance of SKID_Assistant
}
@property(readonly, atomic, getter = agent) id <SKID_AssistantProtocol> _agent;
@property(retain, atomic, getter = applicationSources, setter = setApplicationSources:) NSMutableArray* _applicationSources;
//IBOutlets
@property(retain, getter = functionKeyMatrix, setter = setFunctionKeyMatrix:)
		 IBOutlet NSMatrix* _functionKeyMatrix;
@property(retain, getter = mouseButtonMatrix, setter = setMouseButtonMatrix:)
		 IBOutlet NSMatrix* _mouseButtonMatrix;
@property(retain, getter = applicationSourceOutlineView, setter = setApplicationSourceOutlineView:)
		 IBOutlet NSOutlineView* _applicationSourcesOutlineView;

- (IBAction)updateFilter:(id)sender;

- (void)agentConnect;
- (void)agentDisconnect;
@end
