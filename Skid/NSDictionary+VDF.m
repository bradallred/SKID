//
//  NSDictionary+VDF.m
//  PASEDO
//
//  Created by Brad Allred on 5/18/11.
//  Copyright 2011 For Every Body. All rights reserved.
//

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
			}else{
				[vdfKeyValues setObject:[NSNull null] forKey:key];
			}
		}else{
			NSObject* objValue = [NSNull null];
			NSInteger intVal;
			
			if ([sentinal rangeOfString:@"\"\""].location == NSNotFound) {
				//probably should make support for additional formats....
				if([vdfParser scanInteger:&intVal]){
					objValue = [NSNumber numberWithInteger:intVal];
				}else {
					[vdfParser scanUpToString:@"\"" intoString:(NSString**)&objValue];
				}
			}
			
			//NSLog(@"found value:%@", [objValue description]);
			[vdfKeyValues setObject:objValue forKey:key];
			
		}
	}
	return [vdfKeyValues autorelease];
}

@end
