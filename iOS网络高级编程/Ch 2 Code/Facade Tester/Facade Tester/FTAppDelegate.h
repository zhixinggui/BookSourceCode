//
//  FTAppDelegate.h
//  Facade Tester
//
//  Copyright (c) 2012 John Szumski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FTAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow				*window;
@property (strong, nonatomic) UITabBarController	*tabBarController;

// normally you wouldn't put these here!
@property (strong, nonatomic) NSURL					*urlForWeatherVersion1;
@property (strong, nonatomic) NSURL					*urlForWeatherVersion2;
@property (strong, nonatomic) NSURL					*urlForStockVersion1;
@property (strong, nonatomic) NSURL					*urlForStockVersion2;


@end