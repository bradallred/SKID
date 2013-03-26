//
//  SteamInterface.m
//  Skid
//
//  Created by Brad Allred on 11/28/11.
//  Copyright (c) 2011 For Every Body. All rights reserved.
//

#import "SteamInterface.h"

#define IPCSERVER_MACH_SERVICE_NAME @"com.valvesoftware.steam.ipctool"
#define VERSION_SAFE_STEAM_API_INTERFACES
#include "steam_sdk/steam_api.h"
#include "ISteamApps001.h"

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
				//check if the steam api lib is loaded

				if (SteamAPI_InitSafe == NULL) {
					NSLog(@"steam library not loaded!");
					[self dealloc];
					return nil;
				}
				// WARNING: even with IPC server running
				// setup will fail if steam isnt running
				[self pingIPCServer];
				
				// set SteamAppId to a known app ID (440=TF2)
				// valve IPC server will only talk to us if we can trick it into
				// thinking we are a steam app
				BOOL envSet = setenv("SteamAppId", "440", YES);
				if (envSet != 0) NSLog(@"couldnt set app id");
				//set up communication with IPC server
				g_SteamContext = new CSteamAPIContext();
				SteamAPI_InitSafe();
				//dont need to pose as this app anymore
				unsetenv("SteamAppId");
				
				//[self nameForSteamID:440];
				
				_serviceConnection = [NSConnection new];
				[_serviceConnection setRootObject:self];
				
				if (![_serviceConnection registerName:STEAM_SERVICE_NAME]){
					NSLog(@"Unable to register steam lookup service.");
					[self dealloc];
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
	delete g_SteamContext;
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
	// FIXME: this is a hack. I honestly have no idea
	// how to actually determine this.
	return (steamID % 10 != 0);
}

- (BOOL)steamIsRunning
{
	return (SteamClient() != NULL);
}

- (NSString*)nameForSteamID:(SteamID)steamID
{
	//[self pingIPCServer];
	NSString* ret = [NSString stringWithFormat:@"%i", steamID];
	if(g_SteamContext->Init()){
		ISteamApps001 * steamApps001 = (ISteamApps001 *)SteamClient()->GetISteamApps( SteamAPI_GetHSteamUser(), SteamAPI_GetHSteamPipe(), "STEAMAPPS_INTERFACE_VERSION001" );
		if (steamApps001) {
			char gamename[255] = "";
			steamApps001->GetAppData(steamID, "name", gamename, 255);
			
			ret = [NSString stringWithCString:gamename encoding:NSASCIIStringEncoding];
		}else{
			NSLog(@"Steam interface not responding.");
		}
		g_SteamContext->Clear();
	}
	NSLog(@"%i = %@", steamID, ret);
	return ret;
}
@end
