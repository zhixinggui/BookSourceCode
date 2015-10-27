//
//  TopStoriesTableViewController.m
//  topstories
//
//  Created by Nathan Jones on 5/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TopStoriesTableViewController.h"
#import "PostViewControllerViewController.h"
#import "Model.h"
#import "Utils.h"

@interface TopStoriesTableViewController ()

- (void)handleTopStoriesStart:(id)notification;
- (void)handleTopStoriesSuccess:(id)notification;
- (void)handleTopStoriesError:(id)notification;

@end

@implementation TopStoriesTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"CNN Top Stories";
    
    // add operation observers
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(handleTopStoriesStart:) 
                                                 name:kTopStoriesStartNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(handleTopStoriesSuccess:) 
                                                 name:kTopStoriesSuccessNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(handleTopStoriesError:) 
                                                 name:kTopStoriesErrorNotification 
                                               object:nil];
    
    // fetch top stories
    [[Model sharedModel] fetchTopStories];

}

- (void)viewDidUnload {
    [super viewDidUnload];

}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
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
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Post *post = [[Model sharedModel].posts objectAtIndex:indexPath.row];
    PostViewControllerViewController *pvc = [[PostViewControllerViewController alloc] init];
    pvc.post = post;
    [self.navigationController pushViewController:pvc animated:YES];
}

#pragma mark - Notification Handlers
- (void)handleTopStoriesStart:(id)notification {
    // you could optionally do something here
}

- (void)handleTopStoriesSuccess:(id)notification {
    [self.tableView reloadData];
}

- (void)handleTopStoriesError:(id)notification {
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:@"Unable to download the top stories feed from CNN."
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

@end
