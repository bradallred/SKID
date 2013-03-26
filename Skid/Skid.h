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
