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

#define STEAM_SERVICE_NAME @"SteamLookupService"

typedef NSUInteger SteamID;

@protocol SteamService <NSObject>
- (oneway void)start;
- (oneway void)stop;

- (BOOL)steamIsRunning;
- (BOOL)isDLC:(SteamID)steamID;
- (NSString*)nameForSteamID:(SteamID)steamID;
@end
