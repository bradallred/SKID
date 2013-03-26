//
//  SKID_AssistantProtocol.h
//  Skid
//
//  Created by Brad Allred on 11/14/11.
//  Copyright (c) 2011 For Every Body. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SKID_AssistantProtocol <NSObject>
- (oneway void)terminate; //oneway call doesnt block
- (BOOL)tapActive;
@end
