//
//  BaseOperation.m
//  topstories
//
//  Created by Nathan Jones on 5/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseOperation.h"

@implementation BaseOperation

static NSString *activityIndicatorLock = @"activityIndicatorLock";
static NSInteger activityIndicatorCount = 0;

- (void)enqueueOperation {
    [[Model sharedModel] enqueueOperation:self];
}

- (void)postNotification:(NSString*)notificationName {
    // post the notification to the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                            object:nil
                                                          userInfo:nil];
    });
}

- (void)startNetworkActivityIndicator {
    @synchronized(activityIndicatorLock) {
        if (activityIndicatorCount == 0) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        }
        activityIndicatorCount++;
    }
}

- (void)stopNetworkActivityIndicator {
    @synchronized(activityIndicatorLock) {
        activityIndicatorCount--;
        if (activityIndicatorCount < 1) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            activityIndicatorCount = 0;
        }
        
    }
}

@end