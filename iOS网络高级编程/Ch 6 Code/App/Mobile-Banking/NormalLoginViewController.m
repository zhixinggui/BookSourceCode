//
//  NormalLoginViewController.m
//  Mobile-Banking
//
//  Created by Nathan Jones on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NormalLoginViewController.h"
#import "Model.h"

@interface NormalLoginViewController ()

@property(nonatomic,strong) UITextField *usernameField;
@property(nonatomic,strong) UITextField *passwordField;
@property(nonatomic,strong) UISwitch    *rememberMeSwitch;

- (void)loginStartHandler:(NSNotification*)notification;
- (void)loginSuccessHandler:(NSNotification*)notification;
- (void)loginErrorHandler:(NSNotification*)notification;

@end

@implementation NormalLoginViewController

@synthesize usernameField, passwordField, rememberMeSwitch;

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
    self.title = @"Login";
    
    // register for model notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStartHandler:) 
                                                 name:kNormalLoginStartNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginSuccessHandler:) 
                                                 name:kNormalLoginSuccessNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginErrorHandler:) 
                                                 name:kNormalLoginFailedNotification 
                                               object:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // username / password section
    if (section == 0) {
        return 2;
    }
    
    // login button and remember me section
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *inputCell = @"inputCell";
    static NSString *buttonCell = @"buttonCell";
    UITableViewCell *cell = nil;
    
    // username / password
    if (indexPath.section == 0) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:inputCell];
        if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:inputCell];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor whiteColor];
		}
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Username: ";
                if (usernameField == nil) {
                    usernameField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 180, 40)];
                    usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
                    usernameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                    [usernameField becomeFirstResponder];
                }
                
                cell.accessoryView = usernameField;
                
                break;
            
            case 1:
            default:
                cell.textLabel.text = @"Password: ";
                
                if (passwordField == nil) {
                    passwordField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 180, 40)];
                    passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
                    passwordField.secureTextEntry = YES;
                    passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                }
                
                cell.accessoryView = passwordField;
                
                break;
        }
    
    // login button
    } else if (indexPath.section == 1) {    
        cell = [tableView dequeueReusableCellWithIdentifier:buttonCell];
        if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:buttonCell];
            cell.backgroundColor = [UIColor whiteColor];
		}
        
        cell.textLabel.text = @"Login";
        cell.textLabel.textAlignment = UITextAlignmentCenter;
    
    // remember me
    } else if (indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:buttonCell];
        if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:inputCell];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor whiteColor];
		}
        
        cell.textLabel.text = @"Remember Me";
        
        if (rememberMeSwitch == nil) {
            rememberMeSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        }
        
        cell.accessoryView = rememberMeSwitch;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 && indexPath.row == 0) {
        
        if (usernameField.text.length == 0 || passwordField.text.length == 0) {
            [[[UIAlertView alloc] initWithTitle:@"Validation Error"
                                        message:@"Username or Password is empty. Enter credentials and try again."
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                                otherButtonTitles:nil] show];
            return;
        }
        
        if (rememberMeSwitch.on == YES) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Choose Numeric PIN"
                                                         message:@""
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"OK", nil];
            
            av.alertViewStyle = UIAlertViewStyleSecureTextInput;
            av.tag = 1;
            [av show];
            return;
        }
        // attempt authentication
        [[Model sharedModel] authenticateWithUsername:usernameField.text
                                          andPassword:passwordField.text
                                       registerDevice:rememberMeSwitch.on
                                         withPasscode:@""];
        
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 1) {
        // attempt authentication
        if (buttonIndex == 1) {
            UITextField *pinField = [alertView textFieldAtIndex:0];
            [[Model sharedModel] authenticateWithUsername:usernameField.text
                                              andPassword:passwordField.text
                                           registerDevice:rememberMeSwitch.on
                                             withPasscode:pinField.text];
        }
    }
}

#pragma mark - Notification Handlers

- (void)loginStartHandler:(NSNotification*)notification {
    // you could do something here like update the UI. this example relies on the activity indicator
}

- (void)loginSuccessHandler:(NSNotification*)notification {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)loginErrorHandler:(NSNotification*)notification {
    [[[UIAlertView alloc] initWithTitle:@"Login Failed"
                                message:@"Invalid username or password. Please try again." 
                               delegate:nil 
                      cancelButtonTitle:@"OK" 
                      otherButtonTitles:nil] show];
}

@end