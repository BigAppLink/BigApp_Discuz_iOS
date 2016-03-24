//
//  CommonWebViewController.m
//  Clan
//
//  Created by 昔米 on 15/4/29.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "CommonWebViewController.h"

@interface CommonWebViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end

@implementation CommonWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.urlStr && self.urlStr.length > 0) {
        [_webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]]];
        [self.view beginLoading];
    } else {
        [self showHudTipStr:@"请求失败，请重试"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    DLog(@"CommonWebViewController dealloc");
}

#pragma mark - webview delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.view endLoading];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.view endLoading];
    [self showHudTipStr:@"加载失败"];
}

@end
