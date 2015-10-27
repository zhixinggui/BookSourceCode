//
//  ShareArticlesOperationXML.h
//  topstories
//
//  Created by Nathan Jones on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseOperation.h"

@interface ShareArticlesOperationXML : BaseOperation

@property(nonatomic,strong) NSMutableArray      *posts;
@property(nonatomic,assign) PayloadShareType    shareType;

@end