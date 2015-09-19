//
//  FKViewController.h
//  MoviePlayerTest
//
//  Created by yeeku on 13-8-7.
//  Copyright (c) 2013年 crazyit.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FKViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *movieView;

@property (weak, nonatomic) IBOutlet UIView *videoFrameImageView;
- (IBAction)play:(id)sender;

- (IBAction)pause:(id)sender;
- (IBAction)stop:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *capture1;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (weak, nonatomic) IBOutlet UIImageView *capture2;
- (IBAction)changeFrame:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *slideView;
@end
