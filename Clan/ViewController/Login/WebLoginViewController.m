//
//  WebLoginViewController.m
//  Clan
//
//  Created by 昔米 on 15/6/23.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "WebLoginViewController.h"
#import "UserInfoViewModel.h"

@interface WebLoginViewController ()
@property (strong, nonatomic) UserInfoViewModel *vm;
@end

@implementation WebLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!self.vm) {
        _vm = [UserInfoViewModel new];
    }
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"LOGINSUCCESS"];
    NSString *regSwitch = [NSString returnPlistWithKeyValue:@"RegSwitch"];
    if ([self.title isEqualToString:@"登录"] && ![@"0" isEqualToString:regSwitch]) {
        //注册按钮
        UIButton *regBtn = [UIButton buttonWithTitle:@"注册" andImage:nil andFrame:CGRectMake(0, 0, 40, 40) target:self action:@selector(regAction)];
        regBtn.titleLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_SUBTITLE];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:regBtn];
        self.navigationItem.rightBarButtonItem = rightItem;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.backgroundColor = [UIColor clearColor];
    leftButton.frame = CGRectMake(0, 0, 26, 26);
    [leftButton setBackgroundImage :[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.webView.delegate = self;
}

- (void)dealloc
{
    DLog(@"--WebLoginViewController %@ dealloc ", self.title);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 退出登录
- (void)backView
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)regAction
{
    NSString *webregurl = [NSString returnPlistWithKeyValue:@"URLWebReg"];
    if (webregurl && webregurl.length > 0) {
        //开启web登录模式
        WebLoginViewController *toweb = [[WebLoginViewController alloc]initWithURLString:webregurl];
        toweb.showPageTitles = NO;
        toweb.title = @"注册";
        [self.navigationController pushViewController:toweb animated:YES];
        return;
    }
}

#pragma mark WebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    DLog(@"-----💗😄😄--- %@",[request URL]);
    NSString *url = [[request URL] absoluteString];
    if ([url rangeOfString:@"mod=logging&action=login"].location != NSNotFound)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LOGINSUCCESS"];
    }
    return [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [super webViewDidStartLoad:webView];
    DLog(@"WebLoginViewController webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [super webViewDidFinishLoad:webView];
    DLog(@"WebLoginViewController webViewDidFinishLoad");
    [self saveCookieData];
    [self checkLogin];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [super webView:webView didFailLoadWithError:error];
}

#pragma mark - Custom Methods
- (void)saveCookieData
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in cookies) {
        // Here I see the correct rails session cookie
        DebugLog(@"\nSave cookie: \n====================\n%@", cookie);
    }
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: cookiesData forKey: Code_CookieData];
    [defaults synchronize];
}

- (void)checkLogin
{
    WEAKSELF
    [_vm requestApi:nil andReturnBlock:^(bool success, id data, bool isSelf) {
        STRONGSELF
        if (success) {
            //登录成功
            DLog(@"登录成功");
            UserModel *user = [UserModel currentUserInfo];
            [user setValueWithObject:data];
            //设置登录成功
            user.logined = YES;
            [UserModel saveToLocal];
            [strongSelf dismissViewControllerAnimated:YES completion:^{
                [strongSelf showHudTipStr:@"登录成功"];
            }];
        } else {
            //登录失败
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"LOGINSUCCESS"];
            DLog(@"登录失败");
        }
    }];
}


@end
