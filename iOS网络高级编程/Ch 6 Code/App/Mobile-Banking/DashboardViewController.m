//
//  DashboardViewController.m
//  Mobile-Banking
//
//  Created by Nathan Jones on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DashboardViewController.h"
#import "AccountsViewController.h"
#import "TransferFundsViewController.h"
#import "NSString+Hashing.h"
#import "Model.h"
#import "NormalLoginViewController.h"
#import "RegisteredLoginViewController.h"

@interface DashboardViewController () {
@private
    NSArray *dashboardActions;
}
@end

@implementation DashboardViewController

#pragma mark - UI lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Acme Bank";
    
    // login required, no token exists
    if ([Model sharedModel].token == nil) {
        
        // certificate authentication
        if ([[Model sharedModel] isDeviceRegistered] == YES) {
            
            RegisteredLoginViewController *vc = [[RegisteredLoginViewController alloc] initWithStyle:UITableViewStyleGrouped];
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
            [self presentModalViewController:nc animated:YES];
            
            // standard username / password authentication
        } else {
            NormalLoginViewController *vc = [[NormalLoginViewController alloc] initWithStyle:UITableViewStyleGrouped];
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
            [self presentModalViewController:nc animated:YES];
            
        }
        
    }

}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Accounts";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
            
        case 1:
            cell.textLabel.text = @"Transfer Funds";
            break;
            
        case 2:
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.text = @"Logout";
            break;
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // accounts
    if (indexPath.row == 0) {
        AccountsViewController *avc = [[AccountsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:avc animated:YES];
    
    // transfer funds
    } else if (indexPath.row == 1) {
        TransferFundsViewController *tfvc = [[TransferFundsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:tfvc];
        [self.navigationController presentModalViewController:nc animated:YES];
    
    // logout
    } else if (indexPath.row == 2) {
        UIActionSheet *logout = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to sign out?" 
                                                            delegate:self 
                                                   cancelButtonTitle:@"Cancel" 
                                              destructiveButtonTitle:@"Sign Out" 
                                                   otherButtonTitles:nil];
        logout.tag = 1;
        [logout showInView:self.view];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (actionSheet.tag) {
        case 1:
            // logout action sheet
            switch (buttonIndex) {
                case 0:
                    // opted to signout
                    [[Model sharedModel] signOut];
                    
                    // certificate authentication
                    if ([[Model sharedModel] isDeviceRegistered] == YES) {
                        
                        RegisteredLoginViewController *vc = [[RegisteredLoginViewController alloc] initWithStyle:UITableViewStyleGrouped];
                        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
                        [self presentModalViewController:nc animated:YES];
                        
                        // standard username / password authentication
                    } else {
                        NormalLoginViewController *vc = [[NormalLoginViewController alloc] initWithStyle:UITableViewStyleGrouped];
                        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
                        [self presentModalViewController:nc animated:YES];
                        
                    }
                    
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}

@end