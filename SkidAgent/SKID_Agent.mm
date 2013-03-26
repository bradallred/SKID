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
