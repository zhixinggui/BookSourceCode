//
//  BaseOperation.h
//  topstories
//
//  Created by Nathan Jones on 5/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"
#import "Utils.h"

@interface BaseOperation : NSOperation

- (void)enqueueOperation;

- (void)postNotification:(NSString*)notificationName;

- (void)startNetworkActivityIndicator;

- (void)stopNetworkActivityIndicator;

@end