//
//  PostViewControllerViewController.h
//  topstories
//
//  Created by Nathan Jones on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"

@interface PostViewControllerViewController : UIViewController <UIWebViewDelegate, UIGestureRecognizerDelegate>

@property(nonatomic,strong) Post *post;

@end