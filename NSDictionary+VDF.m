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

#import "NSDictionary+VDF.h"

@implementation NSDictionary (VDF)

+ (NSDictionary*) dictionaryWithContentsOfVDFFile:(NSString*)path
{
	return [NSDictionary dictionaryFromVDFString:[NSString stringWithContentsOfFile:[path stringByExpandingTildeInPath]
																	   usedEncoding:nil 
																			  error:NULL]];
}

+ (NSDictionary*) dictionaryFromVDFString:(NSString*)data
{
	if(!data){
		NSLog(@"no vdf data");
		return nil;
	}
	
	NSCharacterSet* vdfSpecialCharacters = [NSCharacterSet characterSetWithCharactersInString:@"\"{} \t\n\r"];
	NSScanner* vdfParser = [NSScanner scannerWithString:data];
	
	NSString* key = nil;
	NSString* sentinal = nil;
	
	NSMutableDictionary* vdfKeyValues = [[NSMutableDictionary alloc] initWithCapacity:1];
	
	while (![vdfParser isAtEnd]) {
		key = nil;
		[vdfParser scanUpToCharactersFromSet:[vdfSpecialCharacters invertedSet] intoString:NULL];
		[vdfParser scanUpToString:@"\"" intoString:&key];
		if (key == nil) {
			continue;
		}
		//NSLog(@"scanned key:%@", key);
		[vdfParser scanUpToCharactersFromSet:[vdfSpecialCharacters invertedSet] intoString:&sentinal];
		NSInteger sentinalLoc = [sentinal rangeOfString:@"{"].location;
		if (sentinalLoc != NSNotFound) {
			NSString* subStr = nil;
			//invert the sentinal (switch { to } so we can skip to the end of the block)
			//trim off anything after the new '}'
			//this method relies on the VDF file being properly indented
			NSMutableString* endBlock = [sentinal mutableCopy];
			[endBlock deleteCharactersInRange:NSMakeRange(sentinalLoc + 1, [endBlock length] - (sentinalLoc + 1))];
			[endBlock replaceOccurrencesOfString:@"\"" withString:@"" options:0 range:NSMakeRange(0, [endBlock length])];
			[endBlock replaceOccurrencesOfString:@"{" withString:@"}" options:0 range:NSMakeRange(0, [endBlock length])];
			
			[vdfParser scanUpToString:endBlock intoString:&subStr];
			[endBlock release];
			
			NSDictionary* subDict = [NSDictionary dictionaryFromVDFString:subStr];
			if (subDict != nil) {
				[vdfKeyValues setObject:subDict
								 forKey:key];
			} else {
				[vdfKeyValues setObject:[NSNull null] forKey:key];
			}
			continue;
		}
		NSObject* objValue = nil;
		sentinalLoc = [sentinal rangeOfString:@"\t"].location;
		if (sentinalLoc != NSNotFound) {
			[vdfParser scanUpToString:@"\"" intoString:(NSString**)&objValue]; // starting "
			NSLog(@"found single value:%@", objValue);
			//[vdfParser scanUpToString:@"\"" intoString:(NSString**)&objValue];
		} else {
			if ([sentinal rangeOfString:@"\"\""].location == NSNotFound) {
				NSInteger intVal;
				//probably should make support for additional formats....
				if([vdfParser scanInteger:&intVal]){
					objValue = [NSNumber numberWithInteger:intVal];
				} else {
					[vdfParser scanUpToString:@"\"" intoString:(NSString**)&objValue];
				}
			}
		}
		if (!objValue) {
			objValue = [NSNull null];
		}
		NSLog(@"found value:%@ for key:%@", objValue, key);
		[vdfKeyValues setObject:objValue forKey:key];
	}
	NSLog(@"VDF data: %@", vdfKeyValues);
	return [vdfKeyValues autorelease];
}

@end
