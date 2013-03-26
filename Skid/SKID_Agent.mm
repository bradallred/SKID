//
//  SKID_Daemon.m
//  Skid
//
//  Created by Brad Allred on 11/13/11.
//  Copyright (c) 2011 For Every Body. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "SKID_Assistant.h"
#import "SteamInterface.h"

int main(int __unused argc, char * __unused argv[])
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSLog(@"Skid agent started.");
	//set up the SKID assistant interface
	if (YES) { // TODO: make a preference for wether or not to use Steam Apps
		//set up a service for looking up steam ids
		SteamInterface* steam = [SteamInterface sharedInterface];
		[steam start];
	}

	SKID_Assistant* assistant = [SKID_Assistant sharedAssistant];
	[assistant tapEvents];
	[assistant listen];//blocking call.
	NSLog(@"Skid agent terminated.");

	[pool release];
    return 0;
}
