//
//  FTWeatherViewController.m
//  Facade Tester
//
//  Copyright (c) 2012 John Szumski. All rights reserved.
//

#import "FTWeatherViewController.h"
#import "FTAppDelegate.h"

@interface FTWeatherViewController () {
	UISegmentedControl	*versionSelector;
	
	NSString			*v1_city;
	NSString			*v1_state;
	NSString			*v1_temperature;

	NSString			*v2_city;
	NSString			*v2_state;
	NSInteger			v2_temperature;
	NSString			*v2_conditions;
}

- (void)versionChanged:(id)sender;
- (void)loadVersion1Weather;
- (void)loadVersion2Weather;

@end

@implementation FTWeatherViewController

- (id)init{
    self = [super initWithStyle:UITableViewStyleGrouped];
   
	if (self) {
		// configure the tab icon
		self.tabBarItem.title = NSLocalizedString(@"Weather", @"Weather");
		self.tabBarItem.image = [UIImage imageNamed:@"weather"];
    }
	
    return self;
}
							
- (void)viewDidLoad {
    [super viewDidLoad];

	// configure the version selector
	versionSelector = [[UISegmentedControl alloc] initWithItems:
						   [NSArray arrayWithObjects:
								NSLocalizedString(@"Version 1", @"Version 1"),
								NSLocalizedString(@"Version 2", @"Version 2"), 
							nil]];
	versionSelector.segmentedControlStyle = UISegmentedControlStyleBar;
	versionSelector.selectedSegmentIndex = 0;
	
	[versionSelector addTarget:self
						action:@selector(versionChanged:)
			  forControlEvents:UIControlEventValueChanged];
	
	self.navigationItem.titleView = versionSelector;
}


#pragma mark - UI response

- (void)versionChanged:(id)sender {
	[self.tableView reloadData];
}

- (void)loadVersion1Weather {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		FTAppDelegate *appDelegate = (FTAppDelegate*)[[UIApplication sharedApplication] delegate];

		if (appDelegate.urlForWeatherVersion1 != nil) {
			NSError *error = nil;
			NSData *data = [NSData dataWithContentsOfURL:appDelegate.urlForWeatherVersion1 
												 options:NSDataReadingUncached 
												   error:&error];
			
			if (error == nil) {
				NSDictionary *weatherDictionary = [NSJSONSerialization JSONObjectWithData:data 
																				  options:NSJSONReadingMutableLeaves 
																					error:&error];
				
				if (error == nil) {
					v1_city = [weatherDictionary objectForKey:@"city"];
					v1_state = [weatherDictionary objectForKey:@"state"];
					v1_temperature = [weatherDictionary objectForKey:@"currentTemperature"];

					// update the table on the UI thread
					dispatch_async(dispatch_get_main_queue(), ^{
						[self.tableView reloadData];
					});
					
				} else {
					NSLog(@"Unable to parse weather because of error: %@", error);
					[self showParseError];
				}

			} else {
				[self showLoadError];
			}
			
		} else {
			[self showLoadError];
		}
	});
}

- (void)loadVersion2Weather {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		FTAppDelegate *appDelegate = (FTAppDelegate*)[[UIApplication sharedApplication] delegate];
		
		if (appDelegate.urlForWeatherVersion2 != nil) {
			NSError *error = nil;
			NSData *data = [NSData dataWithContentsOfURL:appDelegate.urlForWeatherVersion2 
												 options:NSDataReadingUncached 
												   error:&error];
			
			if (error == nil) {
				NSDictionary *weatherDictionary = [NSJSONSerialization JSONObjectWithData:data 
																				  options:NSJSONReadingMutableLeaves 
																					error:&error];
				
				if (error == nil) {
					v2_city = [weatherDictionary objectForKey:@"city"];
					v2_state = [weatherDictionary objectForKey:@"state"];
					v2_temperature = [[weatherDictionary objectForKey:@"currentTemperature"] intValue];
					v2_conditions = [weatherDictionary objectForKey:@"currentConditions"];
					
					// update the table on the UI thread
					dispatch_async(dispatch_get_main_queue(), ^{
						[self.tableView reloadData];
					});
					
				} else {
					NSLog(@"Unable to parse weather because of error: %@", error);
					[self showParseError];
				}
				
			} else {
				[self showLoadError];
			}
			
		} else {
			[self showLoadError];
		}
	});
}

- (void)showLoadError {
	// inform the user on the UI thread
	dispatch_async(dispatch_get_main_queue(), ^{
		[[[UIAlertView alloc] initWithTitle:@"Error" 
									message:@"Unable to load weather data." 
								   delegate:nil 
						  cancelButtonTitle:@"OK" 
						  otherButtonTitles:nil] show];
	});
}

- (void)showParseError {
	// inform the user on the UI thread
	dispatch_async(dispatch_get_main_queue(), ^{
		[[[UIAlertView alloc] initWithTitle:@"Error" 
									message:@"Unable to parse weather data." 
								   delegate:nil 
						  cancelButtonTitle:@"OK" 
						  otherButtonTitles:nil] show];
	});
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	// weather info
	if (section == 0) {
		
		// version 1 has 3 cells of information
		if (versionSelector.selectedSegmentIndex == 0) {
			return 3;
			
		// version 2 has 4 cells of information
		} else if (versionSelector.selectedSegmentIndex == 1) {
			return 4;
		}
		
	// refresh button
	} else if (section == 1) {
		return 1;
	}

	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;

	// info group
	if (indexPath.section == 0) {
		static NSString *infoCellId = @"infoCell";
		cell = [tableView dequeueReusableCellWithIdentifier:infoCellId];
		
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:infoCellId];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		// version 1
		if (versionSelector.selectedSegmentIndex == 0) {
			
			if (indexPath.row == 0) {
				cell.textLabel.text = NSLocalizedString(@"City", @"City");
				cell.detailTextLabel.text = v1_city;
				
			} else if (indexPath.row == 1) {
				cell.textLabel.text = NSLocalizedString(@"State", @"State");
				cell.detailTextLabel.text = v1_state;
				
			} else if (indexPath.row == 2) {
				cell.textLabel.text = NSLocalizedString(@"Temperature", @"Temperature");
				cell.detailTextLabel.text = [v1_temperature stringByAppendingString:@"\u00B0F"];
			}
			
			
		// version 2
		} else if (versionSelector.selectedSegmentIndex == 1) {
			
			// city
			if (indexPath.row == 0) {
				cell.textLabel.text = NSLocalizedString(@"City", @"City");
				cell.detailTextLabel.text = v2_city;
				
			// state
			} else if (indexPath.row == 1) {
				cell.textLabel.text = NSLocalizedString(@"State", @"State");
				cell.detailTextLabel.text = v2_state;
				
			// temperature
			} else if (indexPath.row == 2) {
				cell.textLabel.text = NSLocalizedString(@"Temperature", @"Temperature");
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%i\u00B0F", v2_temperature];
			
			// conditions
			} else if (indexPath.row == 3) {
				cell.textLabel.text = NSLocalizedString(@"Conditions", @"Conditions");
				cell.detailTextLabel.text = v2_conditions;
			}
		}
		
	// button group
	} else if (indexPath.section == 1) {
		static NSString *buttonCellId = @"buttonCell";
		cell = [tableView dequeueReusableCellWithIdentifier:buttonCellId];
		
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:buttonCellId];
		}
		
		cell.textLabel.text = NSLocalizedString(@"Refresh Richmond, VA", @"Refresh Richmond, VA");
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.textColor = [UIColor blueColor];
	}

	return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == 1) {
		
		// version 1
		if (versionSelector.selectedSegmentIndex == 0) {
			[self loadVersion1Weather];
		
		// version 2
		} else if (versionSelector.selectedSegmentIndex == 1) {
			[self loadVersion2Weather];
		}
	}
}

@end