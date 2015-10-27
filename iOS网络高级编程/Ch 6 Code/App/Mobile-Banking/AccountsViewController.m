//
//  AccountsViewController.m
//  Mobile-Banking
//
//  Created by Nathan Jones on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AccountsViewController.h"
#import "Account.h"
#import "Model.h"
#import "Constants.h"

@interface AccountsViewController() {
@private
    NSMutableArray *accounts;
}

- (void)handleAccountsResponse:(NSNotification*)notification;
@end

@implementation AccountsViewController

#pragma mark - UI Lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Accounts";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAccountsResponse:) 
                                                 name:kAccountOperationSuccessful 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAccountsResponse:) 
                                                 name:kAccountOperationError 
                                               object:nil];
    
    // get previously loaded accounts
    accounts = [[NSMutableArray alloc] initWithArray:[Model sharedModel].accounts];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [accounts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Account *account = [accounts objectAtIndex:indexPath.row];
    cell.textLabel.text = account.accountName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Balance : $%.2f", account.accountBalance];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Account *account = [accounts objectAtIndex:indexPath.row];
    NSString *message = [NSString stringWithFormat:@"This would display an account detail view for %@. This has been disabled for this example.", account.accountName];
    
    [[[UIAlertView alloc] initWithTitle:@"Alert" 
                                message:message 
                               delegate:nil 
                      cancelButtonTitle:@"OK" 
                      otherButtonTitles:nil] show];
}

#pragma mark - Private Methods

- (void)handleAccountsResponse:(NSNotification*)notification {
    // the operation could be in process as they tapped to view accounts, handle response and update UI
    if ([[notification name] isEqualToString:kAccountOperationSuccessful]) {
        accounts = nil;
        accounts = [[NSMutableArray alloc] initWithArray:[Model sharedModel].accounts];
        [self.tableView reloadData];
        
    } else if ([[notification name] isEqualToString:kAccountOperationError]) {
        // in this case, UIAlert's are triggered from the operation and there
        // are not UI requirements to display
    }
}

@end