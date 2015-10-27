//
//  ShareTopStoriesTableViewController.m
//  topstories
//
//  Created by Nathan Jones on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ShareTopStoriesTableViewController.h"
#import "Model.h"
#import "Utils.h"

@interface ShareTopStoriesTableViewController ()
- (void)actionButtonTapped:(id)sender;
@end

@implementation ShareTopStoriesTableViewController

#pragma mark - View Lifecycle
- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Generate Payload";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *action = [[UIBarButtonItem alloc] 
                               initWithBarButtonSystemItem:UIBarButtonSystemItemAction 
                               target:self 
                               action:@selector(actionButtonTapped:)];
    
    self.navigationItem.rightBarButtonItem = action;
}

#pragma mark - UI Response
- (void)actionButtonTapped:(id)sender {
    UIActionSheet *share = [[UIActionSheet alloc] 
                            initWithTitle:@"How do you want to share posts?"
                                 delegate:self
                        cancelButtonTitle:@"Cancel" 
                   destructiveButtonTitle:nil 
                            otherButtonTitles:@"JSON", @"XML", nil];
    share.tag = 0;
    [share showFromTabBar:self.tabBarController.tabBar];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[Model sharedModel] posts] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Post *post = [[Model sharedModel].posts objectAtIndex:indexPath.row];
    cell.textLabel.text = post.title;
    cell.detailTextLabel.text = [Utils prettyStringFromDate:post.pubDate];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 0) {
        
        // JSON
        if (buttonIndex == 0) {
            [[Model sharedModel] sharePostsWithType:PayloadShareTypeJSON];
            
        // XML
        } else if (buttonIndex == 1) {
            [[Model sharedModel] sharePostsWithType:PayloadShareTypeXML];
            
        }
    }
}
@end
