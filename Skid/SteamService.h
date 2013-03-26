//
//  SteamService.h
//  Skid
//
//  Created by Brad Allred on 12/2/11.
//  Copyright (c) 2011 For Every Body. All rights reserved.
//

#import <Foundation/Foundation.h>

#define STEAM_SERVICE_NAME @"SteamLookupService"

typedef NSUInteger SteamID;

@protocol SteamService <NSObject>
- (oneway void)start;
- (oneway void)stop;

- (BOOL)steamIsRunning;
- (BOOL)isDLC:(SteamID)steamID;
- (NSString*)nameForSteamID:(SteamID)steamID;
@end
