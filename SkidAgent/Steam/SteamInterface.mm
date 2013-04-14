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

#import "SteamInterface.h"

#define IPCSERVER_MACH_SERVICE_NAME @"com.valvesoftware.steam.ipctool"
#define STEAMWORKS_CLIENT_INTERFACES

#include "OSW/SteamAPI.h"
#include "OSW/SteamclientAPI.h"

@implementation SteamInterface
#pragma mark singleton inmplemetation
// use singleton design pattern
static SteamInterface *sharedInterface = nil;

+ (SteamInterface*)sharedInterface
{
    @synchronized(self) {
        if (sharedInterface == nil) {
            [[self alloc] init];
        }
    }
    return sharedInterface;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedInterface == nil) {
            return [super allocWithZone:zone];
        }
    }
    return sharedInterface;
}

- (id)init
{
    Class myClass = [self class];
    @synchronized(myClass) {
        if (sharedInterface == nil) {
            if (self = [super init]) {
				NSLog(@"Creating shared steam interface.");

				// check if the steam libraries are loaded
				CSteamAPILoader* loader = new CSteamAPILoader();
				CreateInterfaceFn factory = loader->GetSteam3Factory();
				delete loader;
				if (SteamAPI_Init == NULL || factory == NULL) {
					NSLog(@"steam libraries not loaded!");
					// call super implementation because this class is a singleton
					// but we want this attempt to dealloc without leaking
					[super release];
					return nil;
				}
				// WARNING: even with IPC server running
				// setup will fail if steam isnt running
				[self pingIPCServer];

				_clientEngine = (IClientEngine *)factory( CLIENTENGINE_INTERFACE_VERSION, NULL );

				// set SteamAppId to a known app ID (440=TF2)
				// valve IPC server will only talk to us if we can trick it into
				// thinking we are a steam app
				BOOL envSet = setenv("SteamAppId", "440", YES);
				if (envSet != 0) NSLog(@"couldnt set app id");
				//set up communication with IPC server
				if (!SteamAPI_Init()) {
					NSLog(@"steam api initialization failed!");
				}
				//dont need to pose as this app anymore
				unsetenv("SteamAppId");
				
				//[self nameForSteamID:440];
				
				_serviceConnection = [NSConnection new];
				[_serviceConnection setRootObject:self];
				
				if (![_serviceConnection registerName:STEAM_SERVICE_NAME]){
					NSLog(@"Unable to register steam lookup service.");
					// call super implementation because this class is a singleton
					// but we want this attempt to dealloc without leaking
					[super release];
					return nil;
				}
				sharedInterface = self;
            }
        }
    }
    return sharedInterface;
}

- (void)dealloc
{
	SteamAPI_Shutdown();
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone { return self; }

- (id)retain { return self; }

- (unsigned)retainCount { return UINT_MAX; }

- (oneway void)release {}

- (id)autorelease { return self; }

- (void)pingIPCServer
{
//TODO: maybe retain the connecction so we can test it and only set up a new one if the old one is invalid
	
	// we don't actually do anythin with the IPC server.
	// we just need to make sure it is running and launchd will start it if
	// it's not just by asking for a port to the service
	setenv("SteamAppId", "440", YES);
	//remember to fake a steam id
	NSMachBootstrapServer* machServer = [NSMachBootstrapServer sharedInstance];
	NSPort* ipcport = [machServer servicePortWithName:IPCSERVER_MACH_SERVICE_NAME];
	[ipcport invalidate];
	unsetenv("SteamAppId");
}

#pragma mark service methods
- (oneway void)start
{
	
}

- (oneway void)stop
{
	
}

- (BOOL)isDLC:(SteamID)steamID
{
	if(_clientEngine){
		IClientApps* apps = _clientEngine->GetIClientApps(SteamAPI_GetHSteamUser(),
														  SteamAPI_GetHSteamPipe(),
														  CLIENTAPPS_INTERFACE_VERSION);

		if (apps) {
			char type[255] = "";
			apps->GetAppData(steamID, "type", type, 255);
			if (strcasecmp(type, "DLC") == 0) {
				return YES;
			}
		}else{
			NSLog(@"Steam interface not responding.");
		}
	}
	return NO;
}

- (BOOL)steamIsRunning
{
	return (_clientEngine != NULL);
}

- (NSString*)nameForSteamID:(SteamID)steamID
{
	//[self pingIPCServer];
	NSString* ret = [NSString stringWithFormat:@"%i", steamID];
	if(_clientEngine){
		IClientApps* apps = _clientEngine->GetIClientApps(SteamAPI_GetHSteamUser(), SteamAPI_GetHSteamPipe(), CLIENTAPPS_INTERFACE_VERSION);

		if (apps) {
			char gamename[255] = "";
			apps->GetAppData(steamID, "name", gamename, 255);
			
			ret = [NSString stringWithCString:gamename encoding:NSASCIIStringEncoding];
		}else{
			NSLog(@"Steam interface not responding.");
		}
	}
	NSLog(@"%i = %@", steamID, ret);
	return ret;
}
@end
