//
//  BrowserViewController.m
//  topstories
//
//  Created by Nathan Jones on 5/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BrowserViewController.h"

@interface BrowserViewController ()

@end

@implementation BrowserViewController

@synthesize url = _url;

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
	
    UIWebView *wv = [[UIWebView alloc] initWithFrame:CGRectMake(0,
                                                                0,
                                                                self.view.frame.size.width,
                                                                self.view.frame.size.height - 44)]; // 44-nav bar

    wv.delegate = self;
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:_url];
    [wv loadRequest:req];
    [self.view addSubview:wv];
}

- (void)viewDidDisappear:(BOOL)animated {
    // turn off network spinner if user hits
    // back before loading is complete
    if ([UIApplication sharedApplication].networkActivityIndicatorVisible == YES) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end