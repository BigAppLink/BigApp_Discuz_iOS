
//
//  AppDelegate.m
//  Clan
//
//  Created by chivas on 15/2/27.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "LeftMenuViewController.h"
#import "LoginViewController.h"
#import "PostViewController.h"
#import "RESideMenu.h"
#import "MLBlackTransition.h"
#import <ShareSDK/ShareSDK.h>
#import "WeiboSDK.h"
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "HomeViewModel.h"
#import "HomeViewController.h"
#import "MainViewController.h"
#import "CollectionViewModel.h"
#import "HomeViewModel.h"
#import "FaceImageViewModel.h"
#import "AppConfigViewModel.h"
#import <ShareSDKConnector/ShareSDKConnector.h>
#import "LoadingVC.h"
#import "IQKeyboardManager.h"
//#import <Fabric/Fabric.h>
//#import <Crashlytics/Crashlytics.h>


/**
 * 　　　　　　　　┏┓　　　┏┓
 * 　　　　　　　┏┛┻━━━┛┻┓
 * 　　　　　　　┃　　　　　　　┃
 * 　　　　　　　┃　　　━　　 　┃
 * 　　　　　　　┃　 ┳┛　┗┳  　┃
 * 　　　　　　　┃　　　　　　　┃
 * 　　　　　　　┃   ╰┬┬┬╯  　┃
 * 　　　　　　　┃　　　　　　　┃
 * 　　　　　　　┗━┓　　　┏━┛
 * 　　　　　　　　　┃　　　┃　Code is far away from bug with the
                  ┃     ┃     animal protecting
 * 　　　　　　　　　┃　　　┃    神兽保佑,代码无bug.
 * 　　　　　　　　　┃　　　┃
 * 　　　　　　　　　┃　　　┃
 * 　　　　　　　　　┃　　　┃
 * 　　　　　　　　　┃　　　┃
 * 　　　　　　　　　┃　　　┗━━━┓
 * 　　　　　　　　　┃　　　　　 ┣┓
 * 　　　　　　　　　┃　　　　　┏┛
 * 　　　　　　　　　┗┓┓┏━┳┓ ┏┛
 * 　　　　　　　　　　┃┫┫　┃┫┫
 * 　　　　　　　　　　┗┻┛　┗┻┛
 */
#import "NSString+Emojize.h"

@interface AppDelegate () <RESideMenuDelegate>
@property (strong, nonatomic) CollectionViewModel *collViewModel;
@property (strong, nonatomic) FaceImageViewModel *faceViewModel;
@property (strong, nonatomic) AppConfigViewModel *configViewModel;

@end

@implementation AppDelegate

#pragma mark - leftcycle methods
- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //拉取app配置信息
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"k_dz_returnTopBtn_Status"]) {
        //设置默认的返回按钮是靠右模式
        [[NSUserDefaults standardUserDefaults] setObject:@(2) forKey:@"k_dz_returnTopBtn_Status"];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    IQKeyboardManager *magngerKeyboard = [IQKeyboardManager sharedManager];
    [magngerKeyboard disableInViewControllerClass:NSClassFromString(@"PostDetailVC")];
    [magngerKeyboard disableInViewControllerClass:NSClassFromString(@"PostDetailViewController")];
    [magngerKeyboard disableInViewControllerClass:NSClassFromString(@"ChatViewController")];
    [magngerKeyboard disableInViewControllerClass:NSClassFromString(@"PostSendViewController")];
    [magngerKeyboard disableInViewControllerClass:NSClassFromString(@"PostActivityViewController")];
    [magngerKeyboard disableInViewControllerClass:NSClassFromString(@"PostActivityInfoVC")];

    [magngerKeyboard disableToolbarInViewControllerClass:NSClassFromString(@"PostDetailVC")];
    [magngerKeyboard disableToolbarInViewControllerClass:NSClassFromString(@"PostDetailViewController")];
    [magngerKeyboard disableToolbarInViewControllerClass:NSClassFromString(@"ChatViewController")];
    [magngerKeyboard disableToolbarInViewControllerClass:NSClassFromString(@"PostSendViewController")];
    [magngerKeyboard disableToolbarInViewControllerClass:NSClassFromString(@"PostActivityViewController")];
    [magngerKeyboard disableToolbarInViewControllerClass:NSClassFromString(@"PostActivityInfoVC")];


    //注册登录 退出登录
    //for test - by ximi 先把请求收藏的接口去掉
    UserModel *cUser = [UserModel currentUserInfo];
    [cUser addObserver:self forKeyPath:@"logined" options:NSKeyValueObservingOptionNew context:NULL];
//    [self getUserAllFavos];
    
    //开启网络监测
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    //初始化
    [self configShareSDK];
    //设置状态栏
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [MLBlackTransition validatePanPackWithMLBlackTransitionGestureRecognizerType:MLBlackTransitionGestureRecognizerTypePan];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    /*设置Nav*/
    [self initNav];
    [self.window makeKeyAndVisible];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCome:) name:@"KDZ_ColsingLoadingPage" object:nil];
    [self showLoadingPage];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [UserModel saveToLocal];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [UserModel saveToLocal];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [UserModel saveToLocal];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)dealloc
{
    [[UserModel currentUserInfo] removeObserver:self forKeyPath:@"logined"];
}

#pragma mark - 静态方法
+ (AppDelegate*)appDelegate
{
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

+ (void)initialize
{
    //复制plist文件进沙盒
    [Util copyFile2Documents:[NSString stringWithFormat:@"%@.plist",ThemeStyle]];
}

#pragma mark - 自定义方法
- (void)initWithRootStyle
{
    NSString *style = [NSString returnPlistWithKeyValue:@"APPSTYLE"];
    [Util dayinplist];
    if (!isNull(style) && style.intValue == 1) {
        //开启tab风格
        MainViewController *main = [[MainViewController alloc]init];
        self.window.rootViewController = main;
    }
    else if (!isNull(style) && style.intValue == 2) {
        //侧边栏风格
        [self showRootDDmenuController];
    }
    else {
        //默认开启tab风格
        MainViewController *main = [[MainViewController alloc]init];
        self.window.rootViewController = main;
    }
}
//主页
- (void)showRootDDmenuController
{
    /*左视图*/
    LeftMenuViewController *leftMenu = [[LeftMenuViewController alloc]initWithNibName:@"LeftMenuViewController" bundle:nil];
    /*首页视图*/
    HomeViewController *homeVC = [[HomeViewController alloc]init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:homeVC];
    RESideMenu *sideMenuViewController = [[RESideMenu alloc]initWithContentViewController:navigationController leftMenuViewController:leftMenu rightMenuViewController:nil];
    sideMenuViewController.menuPreferredStatusBarStyle = 1; // UIStatusBarStyleLightContent
    sideMenuViewController.delegate = leftMenu;
    sideMenuViewController.contentViewShadowColor = [UIColor blackColor];
    sideMenuViewController.contentViewShadowOffset = CGSizeMake(0, 0);
    sideMenuViewController.contentViewShadowOpacity = 0.6;
    sideMenuViewController.contentViewShadowRadius = 12;
    sideMenuViewController.contentViewShadowEnabled = YES;
    self.window.rootViewController = sideMenuViewController;
}

//请求闪屏页
- (void)showLoadingPage
{
    LoadingVC *loading = [[LoadingVC alloc]init];
    self.window.rootViewController = loading;
}

//配置统计SDK
- (void)configShareSDK
{
    /**
     *  设置ShareSDK的appKey，如果尚未在ShareSDK官网注册过App，请移步到http://mob.com/login 登录后台进行应用注册，
     *  在将生成的AppKey传入到此方法中。
     *  方法中的第二个参数用于指定要使用哪些社交平台，以数组形式传入。第三个参数为需要连接社交平台SDK时触发，
     *  在此事件中写入连接代码。第四个参数则为配置本地社交平台时触发，根据返回的平台类型来配置平台信息。
     *  如果您使用的时服务端托管平台信息时，第二、四项参数可以传入nil，第三项参数则根据服务端托管平台来决定要连接的社交SDK。
     */
    [ShareSDK registerApp:K_APPKEY_ShareSDK
          activePlatforms:@[@(SSDKPlatformTypeSinaWeibo), @(SSDKPlatformSubTypeQZone), @(SSDKPlatformTypeCopy), @(SSDKPlatformTypeQQ), @(SSDKPlatformTypeWechat)]
                 onImport:^(SSDKPlatformType platformType) {
                     switch (platformType)
                     {
                         case SSDKPlatformTypeWechat:
                             [ShareSDKConnector connectWeChat:[WXApi class]];
                             break;
                         case SSDKPlatformTypeQQ | SSDKPlatformSubTypeQZone:
                             [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                             break;
                         default:
                             break;
                     }
                     
                 }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
              
              switch (platformType)
              {
                  case SSDKPlatformTypeSinaWeibo:
                      //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                      [appInfo SSDKSetupSinaWeiboByAppKey:[Util returnStringWithPlist:kShareAppkeySina]
                                                appSecret:[Util returnStringWithPlist:kShareAppSecretSina]
                                              redirectUri:[Util returnStringWithPlist:kShareAppRedirectUriSina]
                                                 authType:SSDKAuthTypeBoth];
                      break;
                  case SSDKPlatformTypeQQ:
                      //设置QQ应用信息,其中authType设置为使用SSO＋Web形式授权
                      [appInfo SSDKSetupQQByAppId:[Util returnStringWithPlist:kShareAppkeyTecent]
                                           appKey:[Util returnStringWithPlist:kShareAppSecretTecent]
                                         authType:SSDKAuthTypeBoth];
                      
                      break;
                      
                  case SSDKPlatformTypeWechat:
                      //设置微信应用信息，其中authType设置为只用SSO形式授权
                      [appInfo SSDKSetupWeChatByAppId:[Util returnStringWithPlist:kShareAppkeyWechat]
                                            appSecret:[Util returnStringWithPlist:kShareAppSecretWechat]];
                      break;
                  default:
                      break;
              }
              
          }];
}


//配置导航样式
- (void)initNav
{
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    [navigationBarAppearance setTintColor:[UIColor whiteColor]];
    NSDictionary *textAttributes = nil;
    textAttributes = @{
                       NSFontAttributeName: [UIFont fitFontWithSize:20.f],
                       NSForegroundColorAttributeName: [UIColor whiteColor],
                       };
    [navigationBarAppearance setBackgroundImage: [Util imageWithColor:[UIColor returnColorWithPlist:YZSegMentColor]] forBarMetrics:UIBarMetricsDefault];
    [navigationBarAppearance setTitleTextAttributes:textAttributes];
    [navigationBarAppearance setShadowImage:[UIImage new]];
    self.window.tintColor = [UIColor returnColorWithPlist:YZSegMentColor];
    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc] init]];
    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
}

#pragma mark - 如果使用SSO（可以简单理解成客户端授权），以下方法是必要的
#pragma mark - 如果使用SSO（可以简单理解成客户端授权），以下方法是必要的
- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url
{
    return YES;
}
//
////iOS 4.2+
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return YES;
}


#pragma mark - WXApiDelegate(optional)
-(void) onReq:(BaseReq*)req
{}

-(void) onResp:(BaseResp*)resp
{}

#pragma mark - 拉取用户收藏
- (void)getUserAllFavos
{
    if (!_collViewModel) {
        _collViewModel = [CollectionViewModel new];
    }
    if ([UserModel currentUserInfo].logined) {
        DLog(@"ooooooooooooooooooooooooo\n要去拉取收藏信息了\n可是帖子收藏%@了,%@加载中\n可是版块收藏%@了,%@加载中", _collViewModel.favoFormsRequestCompleted?@"完成":@"没完成",_collViewModel.favoFormsRequestLoading?@"正在":@"没有",_collViewModel.favoThreadsRequestCompleted?@"完成":@"没完成",_collViewModel.favoThreadsRequestLoading?@"正在":@"没有");
        if (!_collViewModel.favoFormsRequestCompleted && !_collViewModel.favoFormsRequestLoading) {
            [_collViewModel requestAllFavoForm];
        }
        if (!_collViewModel.favoThreadsRequestCompleted && !_collViewModel.favoThreadsRequestLoading) {
            [_collViewModel requestAllFavoThread];
        }
        if (!_collViewModel.favoArticlesRequestCompleted && !_collViewModel.favoArticlesRequestLoading) {
            [_collViewModel requestAllArticleFavo];
        }
    }
}


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"logined"]) {
        if ([UserModel currentUserInfo].logined) {
            [self getUserAllFavos];
        } else {
            //清除收藏的数组
            if (_collViewModel) {
                _collViewModel.favoThreadsRequestCompleted = NO;
                _collViewModel.favoFormsRequestCompleted = NO;
            }
            [Util cleanUpLocalFavoArray];
        }
    }
}


#pragma mark - Jpush

- (void)notificationCome:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"KDZ_ColsingLoadingPage"]) {
        //获取用户的收藏信息
        [self getUserAllFavos];
        //关闭loading页面 加载主页面 并打开闪屏广告页
        [self initWithRootStyle];
    }
}

@end
