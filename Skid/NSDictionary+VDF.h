//
//  NSDictionary+VDF.h
//  PASEDO
//
//  Created by Brad Allred on 5/18/11.
//  Copyright 2011 For Every Body. All rights reserved.
//

@interface NSDictionary (VDF) 
+ (NSDictionary*) dictionaryWithContentsOfVDFFile:(NSString*)path;
+ (NSDictionary*) dictionaryFromVDFString:(NSString*)data;
@end
