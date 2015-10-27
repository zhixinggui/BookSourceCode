//
//  BrowserViewController.h
//  topstories
//
//  Created by Nathan Jones on 5/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrowserViewController : UIViewController <UIWebViewDelegate>

@property(nonatomic,strong) NSURL *url;

@end