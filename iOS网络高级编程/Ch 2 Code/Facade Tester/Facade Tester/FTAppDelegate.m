//
//  FTAppDelegate.m
//  Facade Tester
//
//  Copyright (c) 2012 John Szumski. All rights reserved.
//

#import "FTAppDelegate.h"
#import "FTWeatherViewController.h"
#import "FTStockViewController.h"

@implementation FTAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize urlForStockVersion1 = _urlForStockVersion1;
@synthesize urlForStockVersion2 = _urlForStockVersion2;
@synthesize urlForWeatherVersion1 = _urlForWeatherVersion1;
@synthesize urlForWeatherVersion2 = _urlForWeatherVersion2;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	UIViewController *weatherVC = [[UINavigationController alloc] initWithRootViewController:[[FTWeatherViewController alloc] init]];
	UIViewController *stockVC = [[UINavigationController alloc] initWithRootViewController:[[FTStockViewController alloc] init]];
	
	self.tabBarController = [[UITabBarController alloc] init];
	self.tabBarController.viewControllers = [NSArray arrayWithObjects:weatherVC, stockVC, nil];
	self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
	
	/*
	 * load the service locator
	 *
	 * note: You should probably show a splash screen of some kind here that waits for the SL to fully load.
	 *		Currently a user could try to start a network request before it knows which URL to use.
	 */
	[self loadServiceLocator];
	
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// load the service locator
	[self loadServiceLocator];
}

- (void)loadServiceLocator {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSError *error = nil;
		#warning Replace the following line with your own domain and path to the service locator
		NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://example.com/api/serviceLocator.json"] 
											 options:NSDataReadingUncached 
											   error:&error];
		
		if (error == nil) {
			NSDictionary *locatorDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
			
			if (error == nil) {
				self.urlForStockVersion1 = [self findURLForServiceNamed:@"stockQuote" version:1 inDictionary:locatorDictionary];
				self.urlForStockVersion2 = [self findURLForServiceNamed:@"stockQuote" version:2 inDictionary:locatorDictionary];
				self.urlForWeatherVersion1 = [self findURLForServiceNamed:@"weather" version:1 inDictionary:locatorDictionary];
				self.urlForWeatherVersion2 = [self findURLForServiceNamed:@"weather" version:2 inDictionary:locatorDictionary];
				
			} else {
				NSLog(@"Unable to parse service locator because of error: %@", error);
				
				// inform the user on the UI thread
				dispatch_async(dispatch_get_main_queue(), ^{
					[[[UIAlertView alloc] initWithTitle:@"Error" 
												message:@"Unable to parse service locator." 
											   delegate:nil 
									  cancelButtonTitle:@"OK" 
									  otherButtonTitles:nil] show];
				});
			}
			
		} else {
			NSLog(@"Unable to load service locator because of error: %@", error);
			
			// inform the user on the UI thread
			dispatch_async(dispatch_get_main_queue(), ^{
				[[[UIAlertView alloc] initWithTitle:@"Error" 
											message:@"Unable to load service locator.  Did you remember to update the URL to your own copy of it?" 
										   delegate:nil 
								  cancelButtonTitle:@"OK" 
								  otherButtonTitles:nil] show];
			});
		}
	});
}

- (NSURL*)findURLForServiceNamed:(NSString*)serviceName version:(NSInteger)versionNumber inDictionary:(NSDictionary*)locatorDictionary {
	NSArray *services = [locatorDictionary objectForKey:@"services"];

	for (NSDictionary *serviceInfo in services) {
		NSString *name = [serviceInfo objectForKey:@"name"];
		NSInteger version = [[serviceInfo objectForKey:@"version"] intValue];
		
		if ([name caseInsensitiveCompare:serviceName] == NSOrderedSame && version == versionNumber) {
			return [NSURL URLWithString:[serviceInfo objectForKey:@"url"]];
		}
	}

	return nil;
}

@end
