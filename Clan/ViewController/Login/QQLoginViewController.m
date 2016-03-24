//
//  QQLoginViewController.m
//  Clan
//
//  Created by 昔米 on 15/8/4.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "QQLoginViewController.h"
#import "BindAccountController.h"
#import "UserInfoViewModel.h"

@interface QQLoginViewController () <UIWebViewDelegate>

@property (strong, nonatomic) UserInfoViewModel *vm;

@end

@implementation QQLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.vm = [UserInfoViewModel new];
    [self setUpNavi];
    self.webView.delegate = self;
    self.showLoadingBar = YES;
    self.showUrlWhileLoading = NO;
    self.navigationButtonsHidden = YES;
    self.showActionButton = NO;
    self.showDoneButton = NO;
    self.showPageTitles = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.webView.delegate = nil;
    _vm = nil;
    DLog(@"QQLoginViewController dealloc");
}

- (void)setUpNavi
{
    UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.backgroundColor = [UIColor clearColor];
    leftButton.frame = CGRectMake(0, 0, 26, 26);
    [leftButton setBackgroundImage :[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
}

- (void)backView
{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = [[request URL] absoluteString];
    if ([url rangeOfString:self.url_qqlogin_end].location != NSNotFound && [url rangeOfString:@"openid="].location != NSNotFound && [url rangeOfString:@"oauth_token="].location != NSNotFound) {
        NSArray *arr = [url componentsSeparatedByString:@"?"];
        if (arr.count > 1) {
            NSString *urlParas = arr[1];
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            for (NSString *param in [urlParas componentsSeparatedByString:@"&"]) {
                NSArray *elts = [param componentsSeparatedByString:@"="];
                if([elts count] < 2) continue;
                [params setObject:[elts objectAtIndex:1] forKey:[elts objectAtIndex:0]];
            }
            NSString *oauth_token = params[@"oauth_token"];
            NSString *openid = params[@"openid"];
            DLog(@"------oauth_token是 %@", oauth_token);
            DLog(@"------openid是 %@", openid);
            //得到OpenID 和 oauth_token  跳转到下一个页面
            [self checkBindStatusWithOpenId:openid andOauth_token:oauth_token];
            return NO;
        }
        return YES;
    }
    return YES;
}

- (void)checkBindStatusWithOpenId:(NSString *)openid andOauth_token:(NSString *)oauth_token
{
    [self showProgressHUDWithStatus:@"" withLock:YES];
    WEAKSELF
    [[Clan_NetAPIManager sharedManager] checkBindStatusWithOpenID:openid andToken:oauth_token andLogintype:LoginTypeQQ andBlock:^(id data, NSError *error) {
        STRONGSELF
        [strongSelf hideProgressHUD];
        DLog(@"---- %@",data);
        NSDictionary *dataDic = [data valueForKey:@"Variables"];
        if (dataDic && [dataDic objectForKey:@"hasbind"]) {
            NSString *number = [dataDic objectForKey:@"hasbind"];
            if (number.intValue == 0) {
                //未绑定，则进行绑定
                [strongSelf gotoBindPageWithOpenID:openid andOauthToken:oauth_token];
            }
            else if (number.intValue == 1) {
                [strongSelf dismissLogin];
            }
        }
    }];
}

- (void)dismissLogin
{
    //拉取个人信息 进行登录
    [Util saveCookieData];
    [self checkLogin];
}

- (void)gotoBindPageWithOpenID:(NSString *)openid andOauthToken:(NSString *)oauth_token
{
    BindAccountController *bind = [[BindAccountController alloc]init];
    bind.bindtype = LoginTypeQQ;
    bind.openid = openid;
    bind.oauth_token = oauth_token;
    [self.navigationController pushViewController:bind animated:YES];
}

#pragma mark - Custom Methods
//- (void)saveCookieData
//{
//    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
//    for (NSHTTPCookie *cookie in cookies) {
//        // Here I see the correct rails session cookie
//        DebugLog(@"\nSave cookie: \n====================\n%@", cookie);
//    }
//    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setObject: cookiesData forKey: Code_CookieData];
//    [defaults synchronize];
//}

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
