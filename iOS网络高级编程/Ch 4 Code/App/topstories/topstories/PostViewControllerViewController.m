//
//  PostViewControllerViewController.m
//  topstories
//
//  Created by Nathan Jones on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PostViewControllerViewController.h"
#import "TweetsTableViewController.h"
#import "BrowserViewController.h"
#import "Utils.h"

@interface PostViewControllerViewController ()

- (void)tweetButtonTapped:(id)sender;
- (void)postHeaderTapped:(id)sender;

@end

@implementation PostViewControllerViewController

@synthesize post = _post;

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // modify the UI
    self.title = _post.title;
    
    UIBarButtonItem *tweetButton = [[UIBarButtonItem alloc] initWithTitle:@"Tweets"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(tweetButtonTapped:)];
    self.navigationItem.rightBarButtonItem = tweetButton;
    
    // determine the approx size for the header
    NSString *headerContent = [NSString stringWithFormat:@"%@\n%@%@", _post.title, _post.pubDate, _post.author];
    CGSize constraint = CGSizeMake(280, MAXFLOAT);
    CGSize headerSize = [headerContent sizeWithFont:[UIFont boldSystemFontOfSize:16] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    headerSize.height+= 10; // adjust for body padding
    
    // create the header content
    NSMutableString *postHeaderContent = [[NSMutableString alloc] init];
    [postHeaderContent appendFormat:@"<html><body>"];
    [postHeaderContent appendFormat:@"<head><style>body{background-color:#f4f4f4; margin:0px; padding:5px 10px 5px 10px;} .title{font-weight:bold; font-size:18px;} .meta{font-size:12px;} .meta .subtitle{font-weight:bold;}</style></head>"];
    [postHeaderContent appendFormat:@"<div class='title'>%@</div>", _post.title];
    [postHeaderContent appendFormat:@"<div class='meta'><span class='subtitle'>Published:</span> %@</div>", [Utils prettyStringFromDate:_post.pubDate]];
    [postHeaderContent appendFormat:@"<div class='meta'><span class='subtitle'>Author:</span> %@</div>", _post.author];
    [postHeaderContent appendFormat:@"</body></html>"];
    
    // create the post header
    UIWebView *postHeader = [[UIWebView alloc] initWithFrame:CGRectMake(0,
                                                                        0,
                                                                        self.view.frame.size.width,
                                                                        headerSize.height)];
    [postHeader loadHTMLString:postHeaderContent baseURL:nil];
    postHeader.backgroundColor = [UIColor clearColor];
    postHeader.scrollView.scrollEnabled = NO;
    
    // add a recognizer so we can display the post source url
    UIGestureRecognizer *tappedRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                                    action:@selector(postHeaderTapped:)];
    tappedRecognizer.delegate = self;
    postHeader.gestureRecognizers = [NSArray arrayWithObject:tappedRecognizer];
    
    [self.view addSubview:postHeader];
    
    // set our post content
    UIWebView *postContent = [[UIWebView alloc] initWithFrame:CGRectMake(0, 
                                                                         headerSize.height, 
                                                                         self.view.frame.size.width, 
                                                                         self.view.frame.size.height-93-headerSize.height)]; // 93 = 44 nav bar + 49 tab bar
    [postContent loadHTMLString:_post.content baseURL:nil];
    postContent.scrollView.contentInset = UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0);
    postContent.backgroundColor = [UIColor whiteColor];
    postContent.scrollView.showsHorizontalScrollIndicator = NO;
    postContent.delegate = self;
    postContent.tag = 2;
    [self.view addSubview:postContent];
    
}

#pragma mark - UI Response
- (void)tweetButtonTapped:(id)sender {
    TweetsTableViewController *tvc = [[TweetsTableViewController alloc] init];
    tvc.post = _post;
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:tvc];
    [self.tabBarController presentModalViewController:nc animated:YES];
}

- (void)postHeaderTapped:(id)sender {
    BrowserViewController *bv = [[BrowserViewController alloc] init];
    bv.url = [NSURL URLWithString:_post.contentURL];
    [self.navigationController pushViewController:bv animated:YES];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        BrowserViewController *bv = [[BrowserViewController alloc] init];
        bv.url = [request URL];
        [self.navigationController pushViewController:bv animated:YES];
        return NO;
    }
    return YES;
}

@end
