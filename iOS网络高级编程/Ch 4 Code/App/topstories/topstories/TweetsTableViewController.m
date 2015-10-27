//
//  TweetsTableViewController.m
//  topstories
//
//  Created by Nathan Jones on 5/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TweetsTableViewController.h"
#import "BrowserViewController.h"
#import "Model.h"

@interface TweetsTableViewController ()

- (void)doneButtonTapped:(id)sender;
- (void)handleTweetsStart:(id)notification;
- (void)handleTweetsSuccess:(id)notification;
- (void)handleTweetsError:(id)notification;
- (void)handleTweetProfileImageSuccess:(id)notification;

@end

@implementation TweetsTableViewController

@synthesize post = _post;

#pragma mark - View Lifecycle
- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Related Tweets";
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(doneButtonTapped:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    // register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(handleTweetsStart:) 
                                                 name:kTweetsStartNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(handleTweetsSuccess:) 
                                                 name:kTweetsSuccessNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(handleTweetsError:) 
                                                 name:kTweetsErrorNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(handleTweetProfileImageSuccess:) 
                                                 name:kTweetProfileImageSuccessNotification 
                                               object:nil];
    
    // fire the tweet operation
    [[Model sharedModel] fetchTweetsForPost:_post];
}

#pragma mark - UI Response
- (void)doneButtonTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_post.tweetsLoading == YES) {
        return 1;
    }
    
    if ([_post.tweets count]) {
        return [_post.tweets count];
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (_post.tweetsLoading == YES) {
        UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                   0,
                                                                   cell.contentView.frame.size.width,
                                                                   cell.contentView.frame.size.height)];
        
        UILabel *loadingText = [[UILabel alloc] initWithFrame:CGRectMake(125, 10, 100, 22)];
        loadingText.font = [UIFont systemFontOfSize:20];
        loadingText.text = @"loading...";
        [overlay addSubview:loadingText];
        
        UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGRect aivFrame = CGRectMake(100, 12, aiv.frame.size.width, aiv.frame.size.height);
        aiv.frame = aivFrame;
        
        [aiv startAnimating];
        [overlay addSubview:aiv];
        
        [cell.contentView addSubview:overlay];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    // the loading process is complete
    } else  {
        
        // no tweets found
        if ([_post.tweets count] == 0) {
            
            UILabel *noTweets = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, 320, 20)];
            noTweets.font = [UIFont systemFontOfSize:18];
            noTweets.text = @"No Tweets Found for Article";
            noTweets.textAlignment = UITextAlignmentCenter;
            
            [cell.contentView addSubview:noTweets];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // tweets found
        } else {
            Tweet *tweet = [_post.tweets objectAtIndex:indexPath.row];
            cell.textLabel.text = tweet.text;
            cell.detailTextLabel.text = tweet.fromUserDisplay;
            cell.imageView.image = tweet.profileImage;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Tweet *tweet = [_post.tweets objectAtIndex:indexPath.row];
    BrowserViewController *bv = [[BrowserViewController alloc] init];
    bv.url = [NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/%@/status/%@", tweet.fromUser, tweet.identifier]];
    
    [self.navigationController pushViewController:bv animated:YES];
}

#pragma mark - Notification Handlers
- (void)handleTweetsStart:(id)notification {
    // you could optionally do something here
}

- (void)handleTweetsSuccess:(id)notification {
    [self.tableView reloadData];
}

- (void)handleTweetsError:(id)notification {
    [self.tableView reloadData];
}

- (void)handleTweetProfileImageSuccess:(id)notification {
    [self.tableView reloadData];
}

@end
