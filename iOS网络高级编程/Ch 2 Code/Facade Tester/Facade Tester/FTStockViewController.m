//
//  FTStockViewController.m
//  Facade Tester
//
//  Copyright (c) 2012 John Szumski. All rights reserved.
//

#import "FTStockViewController.h"
#import "FTAppDelegate.h"

@interface FTStockViewController () {
	UISegmentedControl	*versionSelector;
	
	NSString			*v1_symbol;
	NSString			*v1_name;
	NSNumber			*v1_currentPrice;
	
	NSString			*v2_symbol;
	NSString			*v2_name;
	NSNumber			*v2_currentPrice;
	NSNumber			*v2_openingPrice;
	NSString			*v2_percentageChange;
}

- (void)versionChanged:(id)sender;
- (void)loadVersion1Stock;
- (void)loadVersion2Stock;

@end

@implementation FTStockViewController

- (id)init{
    self = [super initWithStyle:UITableViewStyleGrouped];
	
	if (self) {
		// configure the tab icon
		self.tabBarItem.title = NSLocalizedString(@"Stock Quote", @"Stock Quote");
		self.tabBarItem.image = [UIImage imageNamed:@"stock"];
		
		v1_symbol = @"";
		v1_name = @"";
		v1_currentPrice = nil;
		
		v2_symbol = @"";
		v2_name = @"";
		v2_currentPrice = nil;
		v2_openingPrice = nil;
		v2_percentageChange = @"";
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

- (void)loadVersion1Stock {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		FTAppDelegate *appDelegate = (FTAppDelegate*)[[UIApplication sharedApplication] delegate];
		
		if (appDelegate.urlForStockVersion1 != nil) {
			NSError *error = nil;
			NSData *data = [NSData dataWithContentsOfURL:appDelegate.urlForStockVersion1 
												 options:NSDataReadingUncached 
												   error:&error];
			
			if (error == nil) {
				NSDictionary *stockDictionary = [NSJSONSerialization JSONObjectWithData:data 
																				  options:NSJSONReadingMutableLeaves 
																					error:&error];
				
				if (error == nil) {
					v1_symbol = [stockDictionary objectForKey:@"symbol"];
					v1_name = [stockDictionary objectForKey:@"name"];
					v1_currentPrice = [NSNumber numberWithFloat:[[stockDictionary objectForKey:@"currentPrice"] floatValue]];
					
					// update the table on the UI thread
					dispatch_async(dispatch_get_main_queue(), ^{
						[self.tableView reloadData];
					});
					
				} else {
					NSLog(@"Unable to parse stock quote because of error: %@", error);
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

- (void)loadVersion2Stock {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		FTAppDelegate *appDelegate = (FTAppDelegate*)[[UIApplication sharedApplication] delegate];
		
		if (appDelegate.urlForStockVersion2 != nil) {
			NSError *error = nil;
			NSData *data = [NSData dataWithContentsOfURL:appDelegate.urlForStockVersion2 
												 options:NSDataReadingUncached 
												   error:&error];
			
			if (error == nil) {
				NSDictionary *stockDictionary = [NSJSONSerialization JSONObjectWithData:data 
																				options:NSJSONReadingMutableLeaves 
																				  error:&error];
				
				if (error == nil) {
					v2_symbol = [stockDictionary objectForKey:@"symbol"];
					v2_name = [stockDictionary objectForKey:@"name"];
					v2_openingPrice = [stockDictionary objectForKey:@"openingPrice"];
					v2_currentPrice = [stockDictionary objectForKey:@"currentPrice"];
					v2_percentageChange = [stockDictionary objectForKey:@"percentageChange"];
					
					// update the table on the UI thread
					dispatch_async(dispatch_get_main_queue(), ^{
						[self.tableView reloadData];
					});
					
				} else {
					NSLog(@"Unable to parse stock quote because of error: %@", error);
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
									message:@"Unable to load stock data." 
								   delegate:nil 
						  cancelButtonTitle:@"OK" 
						  otherButtonTitles:nil] show];
	});
}

- (void)showParseError {
	// inform the user on the UI thread
	dispatch_async(dispatch_get_main_queue(), ^{
		[[[UIAlertView alloc] initWithTitle:@"Error" 
									message:@"Unable to parse stock data." 
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
	
	// stock info
	if (section == 0) {
		
		// version 1 has 3 cells of information
		if (versionSelector.selectedSegmentIndex == 0) {
			return 3;
			
		// version 2 has 5 cells of information
		} else if (versionSelector.selectedSegmentIndex == 1) {
			return 5;
		}
		
	// refresh button
	} else if (section == 1) {
		return 1;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
	currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;

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
			
			// symbol
			if (indexPath.row == 0) {
				cell.textLabel.text = @"Symbol";
				cell.detailTextLabel.text = v1_symbol;
				
			// name
			} else if (indexPath.row == 1) {
				cell.textLabel.text = @"Name";
				cell.detailTextLabel.text = v1_name;
			
			// price
			} else if (indexPath.row == 2) {
				cell.textLabel.text = @"Price";
				cell.detailTextLabel.text = [currencyFormatter stringFromNumber:v1_currentPrice];
			}
			
			
		// version 2
		} else if (versionSelector.selectedSegmentIndex == 1) {
			
			// symbol
			if (indexPath.row == 0) {
				cell.textLabel.text = @"Symbol";
				cell.detailTextLabel.text = v2_symbol;
				
			// name
			} else if (indexPath.row == 1) {
				cell.textLabel.text = @"Name";
				cell.detailTextLabel.text = v2_name;
				
			// opening price
			} else if (indexPath.row == 2) {
				cell.textLabel.text = @"Opening Price";
				cell.detailTextLabel.text = [currencyFormatter stringFromNumber:v2_openingPrice];
				
			// current price
			} else if (indexPath.row == 3) {
				cell.textLabel.text = @"Current Price";
				cell.detailTextLabel.text = [currencyFormatter stringFromNumber:v2_currentPrice];
				
			// percentage change
			} else if (indexPath.row == 4) {
				cell.textLabel.text = @"Percent Change";
				cell.detailTextLabel.text = v2_percentageChange;
			}
		}
		
	// button group
	} else if (indexPath.section == 1) {
		static NSString *buttonCellId = @"buttonCell";
		cell = [tableView dequeueReusableCellWithIdentifier:buttonCellId];
		
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:buttonCellId];
		}
		
		cell.textLabel.text = @"Refresh AAPL";
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
			[self loadVersion1Stock];
			
		// version 2
		} else if (versionSelector.selectedSegmentIndex == 1) {
			[self loadVersion2Stock];
		}
	}
}

@end