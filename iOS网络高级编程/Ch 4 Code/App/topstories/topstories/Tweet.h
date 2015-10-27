//
//  Tweet.h
//  topstories
//
//  Created by Nathan Jones on 5/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Tweet : NSObject

@property(nonatomic,strong) NSString *identifier;
@property(nonatomic,strong) NSString *fromUser;
@property(nonatomic,strong) NSString *fromUserDisplay;
@property(nonatomic,strong) NSString *profileImageURL;
@property(nonatomic,strong) NSString *text;
@property(nonatomic,strong) NSDate   *createdDate;
@property(nonatomic,strong) UIImage  *profileImage;

- (id)initWithDictionary:(NSDictionary*)tweetData;

@end