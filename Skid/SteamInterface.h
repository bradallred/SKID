//
//  SteamInterface.h
//  Skid
//
//  Created by Brad Allred on 11/28/11.
//  Copyright (c) 2011 For Every Body. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SteamService.h"

// this is actually a C++ class
// I was having compile problems trying to actually use C++ syntax
struct CSteamAPIContext;
typedef struct CSteamAPIContext CSteamAPIContext;
//class CSteamAPIContext;

@interface SteamInterface : NSObject <SteamService>
{
	@private
	NSConnection* _serviceConnection;
	//C++
	CSteamAPIContext* g_SteamContext;
}
+ (SteamInterface*)sharedInterface;

- (void)pingIPCServer;
@end
