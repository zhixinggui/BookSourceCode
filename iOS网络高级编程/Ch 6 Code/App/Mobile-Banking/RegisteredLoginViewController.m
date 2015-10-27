//
//  RegisteredLoginViewController.m
//  Mobile-Banking
//
//  Created by Nathan Jones on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RegisteredLoginViewController.h"
#import "Model.h"

@interface RegisteredLoginViewController ()

@property(nonatomic,strong) UITextField *pinField;

- (void)loginStartHandler:(NSNotification*)notification;
- (void)loginSuccessHandler:(NSNotification*)notification;
- (void)loginErrorHandler:(NSNotification*)notification;

@end

@implementation RegisteredLoginViewController

@synthesize pin = _pin;
@synthesize pinField;

- (id)initWithStyle:(UITableViewStyle)style
{
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
                                                 name:kRegisteredLoginStartNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginSuccessHandler:) 
                                                 name:kRegisteredLoginSuccessNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginErrorHandler:) 
                                                 name:kRegisteredLoginFailedNotification 
                                               object:nil];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *inputCell = @"inputCell";
    static NSString *buttonCell = @"buttonCell";
    UITableViewCell *cell = nil;
    
    // PIN entry field
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:inputCell];
        if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:inputCell];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor whiteColor];
		}
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"PIN: ";
            if (pinField == nil) {
                pinField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 170, 40)];
                pinField.autocorrectionType = UITextAutocorrectionTypeNo;
                pinField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                pinField.keyboardType = UIKeyboardTypeNumberPad;
                [pinField becomeFirstResponder];
                
            }
            
            cell.accessoryView = pinField;
        }
    
    // login button
    } else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:buttonCell];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:buttonCell];
            cell.backgroundColor = [UIColor whiteColor];
        }
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Login";
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // call the model
    [[Model sharedModel] authenticateWithCertificateAndPin:pinField.text];
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
                                message:@"Unable to authenticate. Please try again." 
                               delegate:nil 
                      cancelButtonTitle:@"OK" 
                      otherButtonTitles:nil] show];
}

@end