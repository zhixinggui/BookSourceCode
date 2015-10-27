//
//  FetchTweetProfileImageOperation.h
//  topstories
//
//  Created by Nathan Jones on 5/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseOperation.h"

@interface FetchTweetProfileImageOperation : BaseOperation

@property(nonatomic,strong) Tweet *tweet;

@end