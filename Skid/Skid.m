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

#import "Skid.h"
#import "SKID_PreferenceCoordinator.h"
#import "NSDictionary+VDF.h"

#define NUM_MATRIX_CELLS_PER_ROW 6

@implementation Skid
//ivar properties
@synthesize _agent, _applicationSources;
//outlet properties
@synthesize _functionKeyMatrix, _mouseButtonMatrix, _applicationSourcesOutlineView;

#pragma mark Action Methods
- (IBAction)updateFilter:(id)sender
{
	if (sender){//sender cannot be nil
		if ([sender class] == [NSMatrix class]){
			sender = [sender selectedCell];
		}
		//first cancel any pending requests for the pref coordinator to reload.
		[SKID_PreferenceCoordinator cancelPreviousPerformRequestsWithTarget:_preferenceCoordinator selector:@selector(writePreferences) object:nil];
		
		NSString* selectedAppIdentifier = [[[_applicationSourcesOutlineView itemAtRow:[_applicationSourcesOutlineView selectedRow]] representedObject] objectForKey:@"identifier"];
		
		SKID_ApplicationFilters* filters = [_preferenceCoordinator filtersForAppWithIdentifier:selectedAppIdentifier];
		if (!filters) {
			// this application is new here :)
			NSLog(@"creating new filters for %@", selectedAppIdentifier);
			filters = [[SKID_ApplicationFilters alloc] initWithFilters:nil ForApplication:selectedAppIdentifier];
			[filters autorelease];
			
			// since this is a new entry we automatically know we need to add this to the filtered applications
			// source as long as [sender state] == NSStateOn (I dont know how it wouldnt be)
			if ([sender state] == NSOnState) {
				/*
				NSDictionary* appNode = [NSDictionary dictionaryWithObjectsAndKeys:selectedAppIdentifier, @"identifier",
																					, @"name"
																					[NSNumber numberWithInt:NODE_APPLICATION], @"nodeType", 
																					nil];
				 */
				/*
				NSMutableDictionary* filteredApps = [_applicationSources valueForKey:@"Filtered Applications"];
				NSMutableArray* appNames = [[filteredApps valueForKey:@"children"] mutableCopy];
				[appNames addObject:appNode];
				[filteredApps setValue:filteredApps forKey:@"children"];
				[appNames release];
				*/
				//[[_applicationSources valueForKeyPath:@"Filtered Applications.children"] addObject:appNode];
				[_applicationSourcesOutlineView reloadItem:[_applicationSources valueForKey:@"Filtered Applications"] reloadChildren:YES];
			}	
		}else{
			//TODO: check to see if we should remove from the filtered applications list.
		}
		
		//update the filters to match the sender
		NSLog(@"setting %@ for %@ to %ld", [sender title], selectedAppIdentifier, [sender state]);
		[filters setValue:[NSNumber numberWithBool:(BOOL)[sender state]] forKey:[sender title]];
		[_preferenceCoordinator setFilters:filters];

		//give enough of a delay that seting multiple filters in quick succession wont spam reload messages
		[_preferenceCoordinator performSelector:@selector(writePreferences) withObject:nil afterDelay:2.0];
	}
}

#pragma mark NSOutlineView data source methods
//nothing yet
#pragma mark NSOutlineView delegate methods
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
	enum LIST_NODE_TYPE type = [[[item representedObject] objectForKey:@"nodeType"] intValue];
	BOOL ret = (type == NODE_APPLICATION);
	if (ret) {
		// need to update the matricies to reflect the filters for selected item.
		SKID_ApplicationFilters* filters = [_preferenceCoordinator filtersForAppWithIdentifier:[[item representedObject] objectForKey:@"identifier"]];
		NSMutableArray* filterCells = [NSMutableArray arrayWithArray:[_functionKeyMatrix cells]];
		[filterCells addObjectsFromArray:[_mouseButtonMatrix cells]];

		for (NSButtonCell* cell in filterCells) {
			if ([filters valueForKey:[cell title]]) {
				cell.state = NSOnState;
			}else{
				cell.state = NSOffState;
			}
		}
	}
	return ret;
}

#pragma mark SKID methods
- (id)initWithBundle:(NSBundle *)bundle
{
	self = [super initWithBundle:bundle];
	if (self)
	{
		_agent = nil;
		_preferenceCoordinator = [[SKID_PreferenceCoordinator alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[self agentDisconnect];
	[super dealloc];
}

- (void)displayAlertSheet:(NSAlert*)sheet
{
	[sheet beginSheetModalForWindow:[NSApp keyWindow] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
	[sheet release];
}

//should run in background thread
- (void)loadSteamApplicationSource
{
	id steamAgent = (id <SteamService>)[NSConnection rootProxyForConnectionWithRegisteredName:STEAM_SERVICE_NAME host:nil];
	[(NSDistantObject *)steamAgent setProtocolForProxy:@protocol(SteamService)];

	if (steamAgent && [steamAgent steamIsRunning]) {
		NSLog(@"Steam Connection established.");

		NSString* appSupportPath = @"~/Library/Application Support";
		NSDictionary* steamApps = [[NSDictionary dictionaryWithContentsOfVDFFile:[NSString stringWithFormat:@"%@/Steam/registry.vdf", appSupportPath]]  valueForKeyPath:@"Registry.HKCU.Software.Valve.Steam.apps"];

		//NSLog(@"Steam apps:\n%@", [steamApps description]);
		NSMutableArray* steamAppSource = [NSMutableArray array];
		for (NSString* appIDKey in steamApps) {
			SteamID appID = [appIDKey integerValue];
			if ([[steamApps valueForKeyPath:[NSString stringWithFormat:@"%@.Installed", appIDKey]] boolValue] && ![steamAgent isDLC:appID]) {
				
				
				NSLog(@"looking up name for %lu", appID);
				NSString* appName = [steamAgent nameForSteamID:appID];
				NSString* identifier = nil;
				switch (appID) {//valve apps all have low ids
					// FIXME: temporary hack until I can reverse engineer a way to
					// lookup the app developer.
					// valve has an annoying way of building mac apps. all their games
					// run the same hl2_osx or portal2_osx binary depending on the
					// engine said game uses.
					case 220://HL2
					case 240://CSS
					case 300://DoD
					case 320://HL2:DM
					case 380://HL2:E1
					case 400://Portal
					case 420://HL2:E2
					case 440://TF2
					case 500://L4D
					case 550://L4D2
					case 4000://Gary's Mod
						identifier = [NSString stringWithFormat:@"hl2_osx"];
						break;
					case 620://Portal 2
						identifier = [NSString stringWithFormat:@"portal2_osx"];
						break;
					default:
					identifier = [[appName retain] autorelease];
				}

				
				NSDictionary* appNode = [NSDictionary dictionaryWithObjectsAndKeys:appName, @"name",
										 identifier, @"identifier",
										 [NSNumber numberWithInt:NODE_APPLICATION], @"nodeType",
										 nil];
				[steamAppSource addObject:appNode];
			}
		}
		NSArray* sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
		[steamAppSource sortUsingDescriptors:sortDescriptors];

		[_applicationSources addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Steam Applications", @"name",
							   steamAppSource, @"children",
							   [NSNumber numberWithInt:NODE_OTHER], @"nodeType", nil]];

		[self setApplicationSources:_applicationSources];
		[_applicationSourcesOutlineView reloadData];
	}else{
		//steam isnt running. for now just ignore.
	}
}

#pragma mark NSPreferencePane Methods
// mainViewDidLoad is called only after the nib is loaded
// unlike didSelect which is called any time the pane is selected
// use this like awakeFromNib
- (void)mainViewDidLoad
{
	//setup the mouse button matrix
	NSInteger numMouseBtns = 12;//TODO: find the actual number of mouse buttons for the attached mouse
	for (NSInteger i = 1; i <= numMouseBtns; i++) {
		NSInteger numCols = [_mouseButtonMatrix numberOfColumns];
		NSInteger numRows = [_mouseButtonMatrix numberOfRows];
		if ( (NSInteger)ceil((double)i / (double)NUM_MATRIX_CELLS_PER_ROW) > numRows ) {
			NSLog(@"adding matrix row.");
			[_mouseButtonMatrix addRow];
		} else if (i > (numCols * numRows)) {
			NSLog(@"adding matrix column.");
			[_mouseButtonMatrix addColumn];
		}
		[[[_mouseButtonMatrix cells] objectAtIndex:i - 1] setTitle:[NSString stringWithFormat:@"M%i", i]];
	}
	//TODO: loop though the diffrece of i and numCells to disable and hide the unused cells
	[_mouseButtonMatrix sizeToCells];

	[_mouseButtonMatrix setEnabled:NO];
	[_functionKeyMatrix setEnabled:NO];
}

- (void)didSelect
{
	[_preferenceCoordinator reloadPreferences];
	// don't halt the gui while waiting for the connection.
	[self performSelectorInBackground:@selector(agentConnect) withObject:nil];
	
	//get a list of all applications
	NSFileManager* fm = [NSFileManager defaultManager];
	NSWorkspace* ws = [NSWorkspace sharedWorkspace];
	NSArray* searchDirs = NSSearchPathForDirectoriesInDomains(NSAllApplicationsDirectory,  NSAllDomainsMask, TRUE);
	NSEnumerator* dirs = [searchDirs objectEnumerator];
	NSString* appDir;
	
	NSMutableArray* filteredApps = [NSMutableArray array];
	NSMutableArray* appSources = [NSMutableArray arrayWithCapacity:[searchDirs count] + 1 + 1];// +1 for steam apps, +1 for filtered apps
	[appSources addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Filtered Applications", @"name",
																	 filteredApps, @"children",
																	 [NSNumber numberWithInt:NODE_OTHER], @"nodeType", nil]];
	while (appDir = [dirs nextObject]){
		NSLog(@"scanning %@", appDir);
		NSArray* dirItems = [fm contentsOfDirectoryAtPath:appDir error:nil];
		NSMutableArray* apps = [NSMutableArray arrayWithCapacity:[dirItems count]];
		for (NSString* itemName in dirItems){
			if ( [ws isFilePackageAtPath:[NSString stringWithFormat:@"%@/%@", appDir, itemName]] ) {
				NSString* bundleIdentifier = [[NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/%@", appDir, itemName]] bundleIdentifier];
				NSLog(@"found app: %@=%@", itemName, bundleIdentifier);
				NSDictionary* appInfo = [NSDictionary dictionaryWithObjectsAndKeys:[itemName stringByDeletingPathExtension], @"name",
																					bundleIdentifier, @"identifier",
																				   [NSNumber numberWithInt:NODE_APPLICATION], @"nodeType", nil];
				[apps addObject:appInfo];
				if ([_preferenceCoordinator filtersForAppWithIdentifier:bundleIdentifier]) {
					[filteredApps addObject:appInfo];
				}
			}
		}
		if ([apps count] > 0)
			[appSources addObject:[NSDictionary dictionaryWithObjectsAndKeys:appDir, @"name", 
																			 apps, @"children", 
																			 [NSNumber numberWithInt:NODE_DIRECTORY], @"nodeType", nil]];
	}

	[self setApplicationSources:appSources];//do this to trigger the KVO bindings
	[_applicationSourcesOutlineView reloadData];
	
	if (YES) { //TODO: make preference or autodetection for steam.
		//this will take awhile...
		[self performSelectorInBackground:@selector(loadSteamApplicationSource) withObject:nil];
	}
}

- (void)didUnselect
{
	[_preferenceCoordinator writePreferences];
	[self agentDisconnect];
	[self setApplicationSources:nil];
}

#pragma mark agent methods
- (void)agentStart
{
	// run on background thread
	// if already running treat this as a restart.
	@synchronized(_agent){
		if (_agent) {
			[_agent terminate];
		}
	}
	NSLog(@"Launching Agent...");
	NSString* agentPath = [[self bundle] pathForAuxiliaryExecutable:SKID_AGENT_NAME];
	// we need to set DYLD_LIBRARY_PATH environment variable to
	// wherever libsteamapi.dylib is located in order to use steam
	// NSTask inherits its environment
	
	//FIXME: hardcoded path for now until i can come up with a more dynamic solution
	NSString* libsteamPath = [@"~/Library/Application Support/Steam/SteamApps/error_500/team fortress 2/bin/" stringByExpandingTildeInPath];
	//NSString* libsteamPath = [@"~/Developer/PASEDO/" stringByExpandingTildeInPath];

	int envSet = setenv("DYLD_LIBRARY_PATH", [libsteamPath cStringUsingEncoding:NSASCIIStringEncoding], YES);
	if (envSet == 0) {
		NSLog(@"DYLD_LIBRARY_PATH was set to %@", libsteamPath);
	}else{
		NSLog(@"Unable to set DYLD_LIBRARY_PATH!");
	}

	//cant use nil for arguments
	[NSTask launchedTaskWithLaunchPath:agentPath arguments:[NSArray arrayWithObject:@""]];
	//wait for the agent to start completely
	//maybe i should loop here instead
	[self performSelector:@selector(agentConnect) withObject:nil afterDelay:2.0];
}

- (void)agentDisconnect
{
	@synchronized(_agent){
		if (!_agent) return;
		NSLog(@"Disconnecting from agent...");
		NSConnection* con = [(NSDistantObject *)_agent connectionForProxy];
		if ([con isValid]) {
			[con invalidate];// sends notification to ConnectionChanged
		} else {
			[_agent release];
			_agent = nil;
		}
	}
}

- (void)agentConnect
{
	// run on background thread
	@synchronized(_agent) {
		if (_agent) return;//already connected

		NSLog(@"Connecting to agent...");
		// connect to the agent server
		_agent = (id <SKID_AssistantProtocol>)[NSConnection rootProxyForConnectionWithRegisteredName:SKID_AGENT_NAME host:nil];
		[(NSDistantObject *)_agent setProtocolForProxy:@protocol(SKID_AssistantProtocol)];
		if (_agent) {
			NSLog(@"Connection established.");
			[_agent retain];
			//Subscribe to NSConnection notifications for the agent connection only
			[[NSNotificationCenter defaultCenter]
			 addObserver: self
			 selector: @selector(agentConnectionChanged:)
			 name: NSConnectionDidDieNotification
			 object: [(NSDistantObject *)_agent connectionForProxy]];
			//NSConnectionDidInitializeNotification
			
			//check if the event tap is running
			if (![_agent tapActive]) {
				NSAlert* tapAlert = [[NSAlert alloc] init];
				[tapAlert addButtonWithTitle:@"OK"];
				[tapAlert setMessageText:@"Skid Agent cannot tap events."];
				[tapAlert setInformativeText:@"Skid agent was unable to create the event tap. Please ensure that 'Access for assistive devices' is enabled."];
				[tapAlert setAlertStyle:NSWarningAlertStyle];
				// do NOT do GUI tasks on background threads! must execute on main thread and release there.
				[self performSelectorOnMainThread:@selector(displayAlertSheet:) withObject:tapAlert waitUntilDone:NO];
			}
		} else {
			NSLog(@"Unable to connect to skid agent.");
			//if ([self isSelected]){
				// the Agent process isn't running. lets ask the user if they want to start it.
				NSAlert* agentAlert = [[NSAlert alloc] init];
				[agentAlert addButtonWithTitle:@"Start"];
				[agentAlert addButtonWithTitle:@"Automatically Start"];
				[agentAlert addButtonWithTitle:@"Don't Start"];
				[agentAlert setMessageText:@"Skid Agent is not running."];
				[agentAlert setInformativeText:@"Skid agent needs to be running in order for keyboard or ouse events to be intercepted. We reccomend you allow Skid Agent to start automatically at login or you will have to start the agent manually."];
				[agentAlert setAlertStyle:NSWarningAlertStyle];
				// do NOT do GUI tasks on background threads! must execute on main thread and release there.
				[self performSelectorOnMainThread:@selector(displayAlertSheet:) withObject:agentAlert waitUntilDone:NO];
			//}
		}
	}
}

- (void)agentConnectionChanged:(NSNotification*)notice
{
	// either connection just completed or has been terminated.
	if (![[notice object] isValid]) {
		// disconnect
		NSLog(@"Connection closed.");
		@synchronized(_agent){
			[_agent release];
			_agent = nil;
		}
	}else{
		// connected
		NSLog(@"Connection opened.");
	}
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *) __unused contextInfo
{	
	NSLog(@"Dismiss alert with button:%ld", returnCode);
	switch (returnCode) {
		case 1001:{//start a new scope
			//Add to login items
			
			/*
			 TODO: adding to startup items in this way won't work well at all unfortunately.
			 
			 we must make a launchd plist so that we can start as an agent without a terminal window opening
			 as well as to setup the environment with DYLD_LIBRARY_PATH so the agent to connect to steam.
			 */
			
			CFURLRef agentURL = (CFURLRef)[[self bundle] URLForAuxiliaryExecutable:SKID_AGENT_NAME];
			LSSharedFileListItemRef myItem = NULL;
			
			LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
			if (loginItems) {
				UInt32 seed = 0U;
				NSArray *currentLoginItems = [NSMakeCollectable(LSSharedFileListCopySnapshot(loginItems, &seed)) autorelease];
				for (id itemObject in currentLoginItems) {
					LSSharedFileListItemRef item = (LSSharedFileListItemRef)itemObject;
					
					UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
					CFURLRef URL = NULL;
					OSStatus err = LSSharedFileListItemResolve(item, resolutionFlags, &URL, /*outRef*/ NULL);
					if (err == noErr) {
						Boolean foundIt = CFEqual(URL, agentURL);
						CFRelease(URL);
						
						if (foundIt) {
							myItem = item;
							break;
						}
					}
				}
				
				if (myItem == NULL) {
					// wasnt found so add it
					myItem = LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemBeforeFirst,
												  NULL, NULL, agentURL, NULL, NULL);

					if (myItem) {
						NSLog(@"Sucessfully added SkidAgent to startup items.");
						CFRelease(myItem);
					}
				}
				CFRelease(loginItems);
			}
			if (!myItem) {
				NSLog(@"Unable to add agent to startup items.");
			}
		}// dont break: we need to start the agent.
		case 1000://Start Agent
			[self performSelectorInBackground:@selector(agentStart) withObject:nil];
			break;
	}
}

@end
