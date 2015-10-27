//
//  FetchPostContentOperation.h
//  topstories
//
//  Created by Nathan Jones on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseOperation.h"

@interface FetchPostContentOperation : BaseOperation

@property(nonatomic,strong) Post *post;

@end