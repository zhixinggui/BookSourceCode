//
//  TransferFundsViewController.m
//  Mobile-Banking
//
//  Created by Nathan Jones on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TransferFundsViewController.h"
#import "Model.h"

@interface TransferFundsViewController()

@property(nonatomic,strong) UIBarButtonItem *transferButton;

@property(nonatomic,strong) UITextField     *toAccountField;
@property(nonatomic,strong) UITextField     *fromAccountField;
@property(nonatomic,strong) UITextField     *amountField;
@property(nonatomic,strong) UITextField     *transferDateField;
@property(nonatomic,strong) UIDatePicker    *transferDatePicker;

- (IBAction)transferFunds:(id)sender;
- (IBAction)cancel:(id)sender;
- (void)transferDateChanged:(id)sender;

- (void)transferStartHandler:(NSNotification*)notification;
- (void)transferSuccessHandler:(NSNotification*)notification;
- (void)transferErrorHandler:(NSNotification*)notification;

@end

@implementation TransferFundsViewController

@synthesize transferButton, toAccountField, fromAccountField, amountField, transferDateField, transferDatePicker;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Transfer Funds";
    
    transferButton = [[UIBarButtonItem alloc] initWithTitle:@"Transfer" 
                                                      style:UIBarButtonItemStyleDone
                                                     target:self 
                                                     action:@selector(transferFunds:)];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(cancel:)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = transferButton;
    
    // register for model notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(transferStartHandler:) 
                                                 name:kFundsTransferStartNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(transferSuccessHandler:) 
                                                 name:kFundsTransferSuccessNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(transferErrorHandler:) 
                                                 name:kFundsTransferFailedNotification 
                                               object:nil];
}

#pragma mark - UI Response

- (IBAction)transferFunds:(id)sender {
    UIActionSheet *transfer = [[UIActionSheet alloc] initWithTitle:@"Funds will be immediately unavailable, are you sure you want to transfer?" 
                                                          delegate:self 
                                                 cancelButtonTitle:@"Cancel" 
                                            destructiveButtonTitle:@"Transfer Funds" 
                                                 otherButtonTitles:nil];
    transfer.tag = 1;
    [transfer showInView:self.view];
}

- (IBAction)cancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)transferDateChanged:(id)sender {
    transferDateField.text = [NSString stringWithFormat:@"%@", transferDatePicker.date];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        // accounts for transfer
        case 0:
            return 2;
            break;
        
        // amount and date of transfer
        case 1:
            return 2;
            break;
        
        // unimplemented - placeholder for notes    
        case 2:
            return 1;
            break;
            
        default:
            return 0;
            break;
    };
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // account entry. typically these would be pickers of some sort
    if (indexPath.section == 0) {
        // to account
        if (indexPath.row == 0) {
            if (toAccountField == nil) {
                toAccountField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
                toAccountField.autocorrectionType = UITextAutocorrectionTypeNo;
                toAccountField.keyboardType = UIKeyboardTypeNumberPad;
                toAccountField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            }
            
            cell.textLabel.text = @"To Account:";
            cell.accessoryView = toAccountField;
            
        // from account
        } else if (indexPath.row == 1) {
            if (fromAccountField == nil) {
                fromAccountField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
                fromAccountField.autocorrectionType = UITextAutocorrectionTypeNo;
                fromAccountField.keyboardType = UIKeyboardTypeNumberPad;
                fromAccountField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            }
            
            cell.textLabel.text = @"From Account:";
            cell.accessoryView = fromAccountField;
            
        }
    } else if (indexPath.section == 1) {
        // to account
        if (indexPath.row == 0) {
            if (amountField == nil) {
                amountField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
                amountField.autocorrectionType = UITextAutocorrectionTypeNo;
                amountField.keyboardType = UIKeyboardTypeDecimalPad;
                amountField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            }
            
            cell.textLabel.text = @"Amount:";
            cell.accessoryView = amountField;
            
            // from account
        } else if (indexPath.row == 1) {
            if (transferDateField == nil) {
                transferDateField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
                transferDateField.autocorrectionType = UITextAutocorrectionTypeNo;
                transferDateField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            }
            
            if (transferDatePicker == nil) {
                transferDatePicker = [[UIDatePicker alloc] init];
                transferDatePicker.minimumDate = [NSDate date];
                transferDatePicker.datePickerMode = UIDatePickerModeDate;
                
                [transferDatePicker addTarget:self 
                                       action:@selector(transferDateChanged:) 
                             forControlEvents:UIControlEventValueChanged];
            }
            
            // add date picker to field
            transferDateField.inputView = transferDatePicker;
            
            cell.textLabel.text = @"Transfer Date:";
            cell.accessoryView = transferDateField;
            
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (actionSheet.tag) {
        case 1:
            // transfer action sheet
            switch (buttonIndex) {
                case 0:
                    // opted to transfer funds
                    [[Model sharedModel] transferFundsFromAccount:fromAccountField.text
                                                        toAccount:toAccountField.text
                                                    effectiveDate:transferDatePicker.date
                                                       withAmount:[amountField.text doubleValue]    // you would want to add validation around this
                                                         andNotes:@""];                             // left empty on purpose for now
                    
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}

#pragma mark - Notification Handlers

- (void)transferStartHandler:(NSNotification*)notification {
    UIActivityIndicatorView *av = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [av startAnimating];
    transferButton.customView = av;
}

- (void)transferSuccessHandler:(NSNotification*)notification {
    transferButton.customView = nil;
    
    [[[UIAlertView alloc] initWithTitle:@"Transfer Completed"
                                message:@"Your funds have been successfully transfered. This is displayed for demo purposes, no funds have moved." 
                               delegate:nil 
                      cancelButtonTitle:@"OK" 
                      otherButtonTitles:nil] show];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)transferErrorHandler:(NSNotification*)notification {
    transferButton.customView = nil;
    
    [[[UIAlertView alloc] initWithTitle:@"Transfer Failed"
                                message:@"Unable to complete transfer at this time. Please try again." 
                               delegate:nil 
                      cancelButtonTitle:@"OK" 
                      otherButtonTitles:nil] show];
}
@end