//
//  ViewController.m
//  JHNetworkSpeed
//
//  Created by HaoCold on 2019/7/25.
//  Copyright © 2019 HaoCold. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "JHNetworkSpeedFloatView.h"

@interface ViewController ()<WKNavigationDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[JHNetworkSpeedFloatView shareView] show];
    });
    
    WKWebView *webView = [[WKWebView alloc] init];
    webView.frame = self.view.bounds;
    webView.navigationDelegate = self;
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
    [self.view addSubview:webView];
}

#pragma mark --- WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    decisionHandler(WKNavigationResponsePolicyAllow);
}

@end
