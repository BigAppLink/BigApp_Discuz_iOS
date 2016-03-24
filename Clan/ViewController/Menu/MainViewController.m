//
//  MainViewController.m
//  Clan
//
//  Created by chivas on 15/6/16.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "MainViewController.h"
#import "LoginViewController.h"
//#import "DialogListViewController.h"
#import "FriendsViewModel.h"
#import "BoardViewController.h"
#import "BoardTabController.h"
#import "BroadSideController.h"
#import "PostSendViewController.h"
#import "HomeViewModel.h"
#import "BoardModel.h"
#import "PostDetailViewController.h"
#import "XLPagerTabStripViewController.h"
//#import "MessageController.h"
//#import "TOWebViewController.h"
#import "WebNaviViewController.h"
#import "BannerModel.h"
#import "LinkModel.h"
#import "ForumModel.h"
#import "CustomHomeListModel.h"
#import "CustomModuleViewController.h"
#import "MeViewController.h"
#import "ArticleViewController.h"
#import "PostDetailVC.h"
#import "ShareItem.h"
#import "ShareMenu.h"
#import "MessageVC.h"

static float interval = 60.f;

@interface MainViewController ()
{
    UIImageView *_tabBarBG;
    YZButton *_lastButton;
    //用于站内信轮询
    NSTimer *_timer;
    NSString *_boardStyle;
}
@property (strong, nonatomic) FriendsViewModel *friendsviewmodel;
@property (strong, nonatomic) HomeViewModel *homeviewmodel;
@property (strong, nonatomic) NSArray *tabbarArray;
@property (strong, nonatomic) YZButton *defaultSelectedBtn;
@property (assign) BOOL meVCExist;
@property (assign) BOOL messageVCExist;

@end

@implementation MainViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    for (UIView* obj in self.tabBar.subviews) {
        if (obj != _tabBarBG) {
            //_tabBarView 应该单独封装。
            [obj removeFromSuperview];
        }
    }
    if ([UserModel currentUserInfo].logined) {
        [self doCheckIfHasNewMessage];
        [self startTimer];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    _tabbarArray = [NSArray new];
    if ([[TMCache sharedCache]objectForKey:@"ClanTabBarStyle"]) {
        _tabbarArray = [[TMCache sharedCache]objectForKey:@"ClanTabBarStyle"];
    }

    [[UITabBar appearance] setShadowImage:[UIImage new]];
    _friendsviewmodel = [FriendsViewModel new];
    _homeviewmodel = [HomeViewModel new];
    //注册监听模式
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCome:) name:@"KNEWS_MESSAGE_COME" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCome:) name:@"KNEWS_FRIEND_MESSAGE" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCome:) name:@"GET_kBOARDSTYLE" object:nil];
    UserModel *cUser = [UserModel currentUserInfo];
    [cUser addObserver:self forKeyPath:@"logined" options:NSKeyValueObservingOptionNew context:NULL];
    [self customTabBarView];
    [self newMessTip];
    [self loadBoardStyleVC:[NSString returnPlistWithKeyValue:kBOARDSTYLE]];
}

- (void)dealloc
{
    _friendsviewmodel = nil;
    [[UserModel currentUserInfo] removeObserver:self forKeyPath:@"logined"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DLog(@" MainViewController dealloc");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopTimer];
}

#pragma mark - timer
//停止计时器
- (void)stopTimer
{
    [_timer invalidate];
    _timer = nil;
}
//开始计时器
- (void)startTimer
{
    [self stopTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(doAutoCheck) userInfo:nil repeats:YES];
}

- (void)doAutoCheck
{
    if (_messageVCExist) {
        [self doCheckIfHasNewMessage];
    }
    if (_meVCExist) {
        [self doCheckIfHasNewFriends];
    }
}

//轮询
- (void)doCheckIfHasNewMessage
{
    [[Clan_NetAPIManager sharedManager] checkNewMessageComeWithResultBlock:^(id data, NSError *error) {
        if (!error) {
            NSNumber *results = [data valueForKey:@"newpm"];
            if (!isNull(results) && results.intValue >= 1) {
                //有新消息
                [[NSUserDefaults standardUserDefaults] setObject:results forKey:@"KNEWS_MESSAGE"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"KNEWS_MESSAGE_COME" object:nil];
            } else {
                //无新消息
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"KNEWS_MESSAGE"];
            }
        } else {
            
        }
    }];
}

//好友消息轮询
- (void)doCheckIfHasNewFriends
{
    [_friendsviewmodel getNewFriendsCountWithReturnBlock:^(NSString *count) {
        if (!isNull(count) && count.intValue >= 1) {
            //有新消息
            [[NSUserDefaults standardUserDefaults] setObject:count forKey:@"KNEWS_FRIEND_MESSAGE"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"KNEWS_FRIEND_MESSAGE" object:nil];
        } else {
            //无新消息
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"KNEWS_FRIEND_MESSAGE"];
        }
    }];
}

#pragma mark - 初始化
- (void)loadBoardStyleVC:(NSString *)bs
{
    NSArray *array = self.viewControllers;
    for (UIViewController *subvc in array) {
        if ([subvc isKindOfClass:[UINavigationController class]]) {
            DZNavigationController *navi = (DZNavigationController *)subvc;
            if (navi.tabType == DZTabType_ForumPage) {
                //遍历出所有的版块儿页面
                NSString *boardClassName = @"BoardViewController";
                NSString *boardstyle = [NSString returnPlistWithKeyValue:kBOARDSTYLE];
                if (boardstyle && boardstyle.intValue == 1) {
                    boardClassName = @"BoardTabController";
                }
                else if (boardstyle && boardstyle.intValue == 2) {
                    boardClassName = @"BroadSideController";
                }
                Class typeClass = NSClassFromString(boardClassName);
                UIViewController *vc = [[typeClass alloc] init];
                if ([vc isKindOfClass:[BoardViewController class]]) {
                    BoardViewController *boardVc = (BoardViewController *)vc;
                    boardVc.isTabBarItem = YES;
                }else if ([vc isKindOfClass:[BoardTabController class]]){
                    BoardTabController *boardVc = (BoardTabController *)vc;
                    boardVc.isTabBarItem = YES;
                }else if ([vc isKindOfClass:[BroadSideController class]]){
                    BroadSideController *boardVc = (BroadSideController *)vc;
                    boardVc.isTabBarItem = YES;
                }

                [navi setViewControllers:@[vc] animated:NO];
            }
        }
    }
    for (UIView* obj in self.tabBar.subviews) {
        if (obj != _tabBarBG) {
            //_tabBarView 应该单独封装。
            [obj removeFromSuperview];
        }
    }
}

- (void)customTabBarView
{
    // 自定义tabBar背景视图
    _tabBarBG = [[UIImageView alloc] initWithFrame:self.tabBar.bounds];
    _tabBarBG.userInteractionEnabled = YES;
    _tabBarBG.image = [Util imageWithColor:[UIColor whiteColor]];
    [self.tabBar addSubview:_tabBarBG];
    
    //tabbar controller的所有子类vc
    NSMutableArray *vcArr = [[NSMutableArray alloc]initWithCapacity:_tabbarArray.count];
    BOOL changeDefaultSelected = NO;
    for (int i = 0; i< _tabbarArray.count;i++ ) {
        //首页基础数据
        CustomHomeMode *customHomeModel = nil;
        //导航页面基础数据
        NSMutableArray *navGetArray = [NSMutableArray array];

        NSString *typeClassStrValue = @"UIViewController";
        NSDictionary *dic = _tabbarArray[i];
        NSString *backImage = [NSString stringWithFormat:@"%@",dic[@"icon_type"]];
        NSString *backImage_H = [NSString stringWithFormat:@"%@_H",dic[@"icon_type"]];
        YZButton *button = [YZButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(_tabBarBG.width/_tabbarArray.count * i, 0, _tabBarBG.width/_tabbarArray.count, 49);
        NSString *buttonName = dic[@"button_name"];
        BOOL hasTitle = NO;
        if (!isNull(buttonName) && buttonName.length > 0) {
            hasTitle = YES;
            [button setTitle:buttonName forState:UIControlStateNormal];
            [button setTitleColor:[UIColor returnColorWithPlist:YZSegMentColor] forState:UIControlStateSelected];
        }
        [button setImage:[UIImage imageNamed:backImage] forState:UIControlStateNormal];
        UIImage *seleimage = [UIImage imageNamed:backImage_H];
        if (!seleimage) {
            seleimage = [[UIImage imageNamed:backImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        } else {
            seleimage = [[UIImage imageNamed:backImage_H] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        [button setImage:seleimage forState:UIControlStateSelected];
        button.titleLabel.font = [UIFont systemFontOfSize:9.0f];
        [button setTitleColor:UIColorFromRGB(0x424242) forState:UIControlStateNormal];
        button.tabIndex = i;
        /**
         *  根据Id 1 2 3 4 5 分别为
         *  判断类型 1:自定义TAB 2:版块 3:发帖 4:消息 5:我的
         *  自定义TAB 1:单页面 2:导航页面 3:WAP页面
         */
        NSString *button_type = dic[@"button_type"];
        NSString *button_name = dic[@"button_name"];
        NSString *navTitle = dic[@"tab_cfg"][@"title"];
        DZTabType tabType = DZTabType_Custom_SinglePage;
        if (button_type && button_type.intValue == 1) {
            //首页和导航头部右侧视图
            CustomRightItemModel *customRightItemModel = nil;
            NSString *c_tab_type = dic[@"tab_cfg"][@"tab_type"];
            if (c_tab_type && c_tab_type.intValue == 1) {
                //单页面
                tabType = DZTabType_Custom_SinglePage;
                //拉取首页基础数据
                if (dic[@"tab_cfg"][@"home_page"]) {
                    NSArray *array = dic[@"tab_cfg"][@"home_page"];
                    customHomeModel = [_homeviewmodel request_homeWithDataArray:array];
                    customHomeModel.navTitle = i == 0 ? @"": navTitle;
                } else {
                    customHomeModel = [CustomHomeMode new];
                }
                
                //拉取右侧视图配置
                if (dic[@"tab_cfg"][@"title_cfg"]) {
                    NSArray *itemArray = dic[@"tab_cfg"][@"title_cfg"];
                    NSMutableArray *tempCustomItemArray = [NSMutableArray array];
                    for (NSDictionary *dics  in itemArray) {
                        customRightItemModel = [CustomRightItemModel objectWithKeyValues:dics];
                        [tempCustomItemArray addObject:customRightItemModel];
                    }
                    customHomeModel.title_cfg = tempCustomItemArray;
                }
                typeClassStrValue = @"CustomModuleViewController";
            }
            else if (c_tab_type && c_tab_type.intValue == 2) {
                //导航页面
                tabType = DZTabType_Custom_NavigationPage;
                typeClassStrValue = @"ArticleViewController";
                if (dic[@"tab_cfg"][@"navi_page"]) {
                    for (NSDictionary *navDic in dic[@"tab_cfg"][@"navi_page"]) {
                        CustomNavModel *customNav = [CustomNavModel objectWithKeyValues:navDic];
                        customNav.customHomeModel = [_homeviewmodel request_homeWithDataArray:navDic[@"navi_setting"][@"home_page"]];
                        //拉取右侧视图配置
                        if (dic[@"tab_cfg"][@"title_cfg"]) {
                            NSArray *itemArray = dic[@"tab_cfg"][@"title_cfg"];
                            NSMutableArray *tempCustomItemArray = [NSMutableArray array];
                            for (NSDictionary *dics  in itemArray) {
                                customRightItemModel = [CustomRightItemModel objectWithKeyValues:dics];
                                [tempCustomItemArray addObject:customRightItemModel];
                            }
                            customNav.customHomeModel.title_cfg = tempCustomItemArray;
                        }
                        [navGetArray addObject:customNav];
                    }
                }
            }
            else if (c_tab_type && c_tab_type.intValue == 3) {
                //WAP页面
                tabType = DZTabType_Custom_WapPage;
                typeClassStrValue =  @"WebNaviViewController";
                //拉取右侧视图配置
                if (dic[@"tab_cfg"][@"title_cfg"]) {
                    NSArray *itemArray = dic[@"tab_cfg"][@"title_cfg"];
                    NSMutableArray *tempCustomItemArray = [NSMutableArray array];
                    for (NSDictionary *dics  in itemArray) {
                        customRightItemModel = [CustomRightItemModel objectWithKeyValues:dics];
                        [tempCustomItemArray addObject:customRightItemModel];
                    }
                    customHomeModel = [CustomHomeMode new];
                    customHomeModel.title_cfg = tempCustomItemArray;
                    customHomeModel.use_wap_name = dic[@"tab_cfg"][@"use_wap_name"];
                }
            }
            else {
                //默认设置为 单页面
                tabType = DZTabType_Custom_SinglePage;
                typeClassStrValue = @"CustomModuleViewController";
            }
        }
        else if (button_type && button_type.intValue == 2) {
            //版块儿页面
            tabType = DZTabType_ForumPage;
            typeClassStrValue = @"UIViewController";
        }
        else if (button_type && button_type.intValue == 3) {
            //发帖页面
            tabType = DZTabType_PostingPage;
            typeClassStrValue = nil;
        }
        else if (button_type && button_type.intValue == 4) {
            //消息页面
            tabType = DZTabType_MessagePage;
            self.messageVCExist = YES;
            //先判断是否登录
            if ([UserModel currentUserInfo].logined) {
                typeClassStrValue = @"MessageVC";
            } else {
                typeClassStrValue = @"UIViewController";
            }
        }
        else if (button_type && button_type.intValue == 5) {
            //我的页面
            self.meVCExist = YES;
            tabType = DZTabType_MePage;
            typeClassStrValue = @"MeViewController";
        }
        else {
            //默认设置为 单页面
            tabType = DZTabType_Custom_SinglePage;
            typeClassStrValue = @"CustomModuleViewController";
        }
        button.tabtype = tabType;
        button.tag = i+1000;
        [_tabBarBG addSubview:button];
        
        if (hasTitle) {
            //button有标题的话 需要调整位置
            CGPoint buttonBoundsCenter = CGPointMake(CGRectGetMidX(button.bounds), CGRectGetMidY(button.bounds));
            // 找出imageView最终的center
            CGPoint endImageViewCenter = CGPointMake(buttonBoundsCenter.x, CGRectGetMidY(button.imageView.bounds));
            // 找出titleLabel最终的center
            CGPoint endTitleLabelCenter = CGPointMake(buttonBoundsCenter.x, CGRectGetHeight(button.bounds)-CGRectGetMidY(button.titleLabel.bounds));
            // 取得imageView最初的center
            CGPoint startImageViewCenter =button.imageView.center;
            // 取得titleLabel最初的center
            CGPoint startTitleLabelCenter = button.titleLabel.center;
            CGFloat imageEdgeInsetsTop = endImageViewCenter.y - startImageViewCenter.y;
            CGFloat imageEdgeInsetsLeft = endImageViewCenter.x - startImageViewCenter.x;
            CGFloat imageEdgeInsetsBottom = -imageEdgeInsetsTop;
            CGFloat imageEdgeInsetsRight = -imageEdgeInsetsLeft;
            button.imageEdgeInsets = UIEdgeInsetsMake(0, imageEdgeInsetsLeft, imageEdgeInsetsBottom, imageEdgeInsetsRight);
            //        CGFloat titleEdgeInsetsTop = endTitleLabelCenter.y-startTitleLabelCenter.y;
            CGFloat titleEdgeInsetsLeft = endTitleLabelCenter.x - startTitleLabelCenter.x;
            //        CGFloat titleEdgeInsetsBottom = -titleEdgeInsetsTop;
            CGFloat titleEdgeInsetsRight = -titleEdgeInsetsLeft;
            button.titleEdgeInsets = UIEdgeInsetsMake(31, titleEdgeInsetsLeft, 0, titleEdgeInsetsRight);
        }
        //加事件
        [button addTarget:self action:@selector(selectedTab:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 0) {
            button.selected = YES;
            _lastButton = button;
        }
        if (typeClassStrValue) {
            //定制view
            Class typeClass = NSClassFromString(typeClassStrValue);
            UIViewController *vc = [[typeClass alloc] init];
            if (typeClass == NSClassFromString(@"WebNaviViewController")) {
                WebNaviViewController *wapVc = (WebNaviViewController *)vc;
                wapVc.customHomeModel = customHomeModel;
                wapVc.navTitle = i == 0 ? @"": navTitle;
                wapVc.navigationButtonsHidden = YES;
                wapVc.isTabBarItem = YES;
                wapVc.showPageTitles = NO;
                wapVc.showUrlWhileLoading = NO;
                wapVc.url = [NSURL URLWithString:dic[@"tab_cfg"][@"wap_page"]];
            }else if (typeClass == NSClassFromString(@"CustomModuleViewController")){
                //自定义首页
                CustomModuleViewController *customVc = (CustomModuleViewController *)vc;
                customVc.customHomeModel = customHomeModel;
            }else if (typeClass == NSClassFromString(@"MeViewController")){
                MeViewController *meVc = (MeViewController *)vc;
                meVc.isSelf = YES;
            }else if (typeClass == NSClassFromString(@"ArticleViewController")){
                //导航型
                ArticleViewController *articleVc = (ArticleViewController *)vc;
                articleVc.nav_title = navTitle;
                articleVc.customNavArray = navGetArray;
            }else if (typeClass == NSClassFromString(@"MessageVC")) {
                //消息页面
                MessageVC *messvc = (MessageVC *)vc;
                messvc.fromTabbar = YES;
            }
            DZNavigationController * navi = [[DZNavigationController alloc]initWithRootViewController:vc];
            navi.tabType = tabType;
            navi.controllerIndex = vcArr.count;
            navi.tabBarButtonIndex = i;
            [vcArr addObject:navi];
        } else {
            UIViewController *view = [[UIViewController alloc]init];
            DZNavigationController * navi = [[DZNavigationController alloc]initWithRootViewController:view];
            navi.tabType = DZTabType_NonePage;
            navi.controllerIndex = vcArr.count;
            navi.tabBarButtonIndex = i;
            [vcArr addObject:navi];
        }
        //消息页面 和 发帖 不能作为默认tab选择
        if (i == 0 && (tabType == DZTabType_MessagePage || tabType == DZTabType_PostingPage)) {
            changeDefaultSelected = YES;
        }
        
        if (i == 0 && tabType != DZTabType_MessagePage && tabType != DZTabType_PostingPage && !_defaultSelectedBtn) {
            self.defaultSelectedBtn = button;
        }
        
        if (changeDefaultSelected && i != 0 && tabType != DZTabType_MessagePage && tabType != DZTabType_PostingPage && !_defaultSelectedBtn) {
            self.defaultSelectedBtn = button;
        }
    }

    UIImageView *linev = [[UIImageView alloc]initWithImage:[Util imageWithColor:kCOLOR_BORDER]];
    linev.frame = CGRectMake(0, 0, kSCREEN_WIDTH, 0.5);
    [_tabBarBG addSubview:linev];
    
    for (UIView* obj in self.tabBar.subviews) {
        if (obj != _tabBarBG) {
            //_tabBarView 应该单独封装。
            [obj removeFromSuperview];
        }
    }
    self.viewControllers = vcArr;
    
    if (changeDefaultSelected && _defaultSelectedBtn) {
        //改变默认的tab
//        [self setSelectedIndex:_defaultSelectedBtn.tabIndex];
        [self selectedTab:_defaultSelectedBtn];
    }
}

- (void)selectedTab:(YZButton *)button
{
    //重复点击某一个tabbar
    if (_lastButton == button) {
        if (button.tabtype == DZTabType_Custom_SinglePage) {
            //单页面自动更新 第一个tab 点击第二次 通知自动刷新
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AUTO_REFRESH_SHOWYE" object:nil];
        }
        else if (button.tabtype == DZTabType_ForumPage) {
            //版块自动刷新
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"AUTO_REFRESH_BANKUAI" object:nil];
        }
        else if (button.tabtype == DZTabType_MessagePage) {
            if (![self checkLoginState]) {
                return;
            } else {
                //通知站内信刷新
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"AUTO_REFRESH_XINXI" object:nil];
            }
        }
        else if (button.tabtype == DZTabType_MePage) {
            if ([UserModel currentUserInfo].logined) {
                //我的页面更新
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"AUTO_REFRESH_ME" object:nil];
            }
        }
        return;
    } else {
        if (button.tabtype == DZTabType_MessagePage) {
            //选中站内信 要判断是否登录成功了
            if (![self checkLoginState]) {
                return;
            }
        }
        else if (button.tabtype == DZTabType_PostingPage) {
            //发帖
            if ([self checkLoginState]) {
                [self sendPost:button];
//                [self sendNormalPost];
            }
            return;
        }
        button.selected = YES;
        _lastButton.selected = NO;
        _lastButton = button;
        self.selectedIndex = button.tabIndex;
    }
}


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSInteger count = navigationController.viewControllers.count;
    if (count == 2) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//显示登录页
- (BOOL)checkLoginState
{
    UserModel *_cuser = [UserModel currentUserInfo];
    if (!_cuser || !_cuser.logined) {
        //没有登录 跳出登录页面
        LoginViewController *login = [[LoginViewController alloc]init];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:login];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
        return NO;
    } else {
        return YES;
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

#pragma mark - Action
- (void)sendPost:(id)btn
{
    YZButton *messBtn = (YZButton *)btn;
    NSInteger tag = messBtn.tag-1000;
    //微信好友
    ShareItem *shareitemWeiXinSession = [ShareItem new];
    shareitemWeiXinSession.title = @"主题帖";
    shareitemWeiXinSession.image = kIMG(@"shouye_zhutie");
    shareitemWeiXinSession.shareType = SSDKPlatformSubTypeWechatSession;
    //微信朋友圈
    ShareItem *shareitemWeiXinTimeline = [ShareItem new];
    shareitemWeiXinTimeline.title = @"活动贴";
    shareitemWeiXinTimeline.image = kIMG(@"shouye_huodongtie");
    shareitemWeiXinTimeline.shareType = SSDKPlatformSubTypeWechatTimeline;
    
    NSArray *shareListArr = @[shareitemWeiXinSession, shareitemWeiXinTimeline];
    ShareMenu *menu = [[ShareMenu alloc]initWithFrame:CGRectMake(0, 70, kSCREEN_WIDTH, 400) withShareList:shareListArr];
    if (tag != 3) {
        menu.startCenterX = messBtn.center.x;
    }
    menu.menuMode = MenuViewMode_FullScreen;
    [menu show];
    WEAKSELF
    [menu setSelectedBlock:^(id data) {
        NSNumber *type = data;
        if (type.intValue == SSDKPlatformSubTypeWechatSession) {
            [weakSelf sendNormalPost];
        } else {
            
        }
    }];
}

- (void)sendNormalPost
{
    if ([self checkLoginState])
    {
        [self showProgressHUDWithStatus:@"" withLock:YES];
        WEAKSELF
        [_homeviewmodel request_boardBlock:^(id data) {
            STRONGSELF
            [SVProgressHUD dismiss];
            id forumsdata = [UserDefaultsHelper valueForDefaultsKey:kUserDefaultsKey_ForumsStore];
            if (forumsdata && [forumsdata isKindOfClass:[NSArray class]]) {
                NSArray *forumsDataArr = (NSArray *)forumsdata;
                NSMutableArray *forumsArr = [NSMutableArray new];
                for (NSDictionary *dic in forumsDataArr) {
                    BoardModel *boardModel = [BoardModel objectWithKeyValues:dic];
                    [forumsArr addObject:boardModel];
                    //                    if (boardModel.forums && boardModel.forums.count>0) {
                    //                        [forumsArr addObjectsFromArray:boardModel.forums];
                    //                    }
                }
                //存储forums
                if (forumsArr && forumsArr.count > 0) {
                    //存在版块儿 跳转到
                    PostSendViewController *send = [[PostSendViewController alloc]init];
                    send.fromShouYe = YES;
                    send.dataSourceArray = [[NSArray alloc]initWithArray:forumsArr];
                    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:send];
                    [strongSelf presentViewController:navi animated:YES completion:NULL];
                } else {
                    [strongSelf showHudTipStr:@"抱歉，暂无板块儿可以发帖！"];
                }
            }
        }];
    }
}

- (void)showProgressHUDWithStatus:(NSString *)string withLock:(BOOL)lock
{
    [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    if (!string || [@"" isEqualToString:string]) {
        if (lock) {
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
            return;
        }
        [SVProgressHUD show];
        return;
    }
    if (lock) {
        [SVProgressHUD showWithStatus:string maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    [SVProgressHUD showWithStatus:string];
}


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"logined"]) {
        for (UIView* obj in self.tabBar.subviews) {
            if (obj != _tabBarBG) {
                //_tabBarView 应该单独封装。
                [obj removeFromSuperview];
            }
        }
        NSArray *array = self.viewControllers;
        for (UIViewController *subvc in array) {
            if ([subvc isKindOfClass:[UINavigationController class]]) {
                DZNavigationController *dznavi = (DZNavigationController *)subvc;
                if (dznavi.tabType == DZTabType_MessagePage) {
                    if ([UserModel currentUserInfo].logined) {
                        //站内信更新
                        MessageVC *mess = [[MessageVC alloc]init];
                        mess.fromTabbar = YES;
                        [dznavi setViewControllers:@[mess] animated:NO];
                        [self doAutoCheck];
                        [self startTimer];
                    } else {
                        //要取消选中站内信
                        if (_lastButton.tabtype == DZTabType_MessagePage) {
                            //选中首页
                            [self selectedTab:_defaultSelectedBtn];
                        }
                        //把dialog对话列表释放掉
                        UIViewController *newvc = [[UIViewController alloc]init];
                        [dznavi setViewControllers:@[newvc] animated:NO];
                    }
                }
                else if (dznavi.tabType == DZTabType_MePage) {
                    if (![UserModel currentUserInfo].logined) {
                        [dznavi popToRootViewControllerAnimated:YES];
                        [self showHudTipStr:@"成功退出登录"];
                    }
                }
            }
        }
        for (UIView* obj in self.tabBar.subviews) {
            if (obj != _tabBarBG) {
                //_tabBarView 应该单独封装。
                [obj removeFromSuperview];
            }
        }
    }
}

#pragma mark - notification
- (void)notificationCome:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"KNEWS_MESSAGE_COME"]) {
        if (_lastButton.tabtype == DZTabType_MessagePage) {
            //当前的视图要刷新
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DO_DIALOG_UPDATE" object:nil];
        }
        [self newMessTip];
    }
    else if ([noti.name isEqualToString:@"KNEWS_FRIEND_MESSAGE"]) {
        [self newFriendTip];
    }
    else if ([noti.name isEqualToString:@"GET_kBOARDSTYLE"]) {
        [self loadBoardStyleVC:[NSString returnPlistWithKeyValue:kBOARDSTYLE]];
    }
}

//新消息提示
- (void)newMessTip
{
    NSNumber *valNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"KNEWS_MESSAGE"];
    for (UIViewController *subvc in self.viewControllers) {
        if ([subvc isKindOfClass:[UINavigationController class]]) {
            DZNavigationController *subnavi = (DZNavigationController *)subvc;
            if (subnavi.tabType == DZTabType_MessagePage) {
                //遍历出所有信息页面 并找到信息页面对应的tabbar button所在的位置 进而找到button 添加小角标
                NSInteger btnindex = subnavi.tabBarButtonIndex;
                NSInteger btnTag = btnindex+1000;
                UIButton *zhanneixinBtn = (UIButton *)[_tabBarBG viewWithTag:btnTag];
                //新消息到达
                UIView *newmess = [zhanneixinBtn viewWithTag:9876];
                [newmess removeFromSuperview];
                newmess = nil;
                if (!isNull(valNum) && valNum.intValue != 0) {
                    //改变
                    UIButton *newMess_btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    [zhanneixinBtn addSubview:newMess_btn];
                    newMess_btn.enabled = NO;
                    newMess_btn.layer.cornerRadius = 10;
                    newMess_btn.clipsToBounds = YES;
                    newMess_btn.tag = 9876;
                    if (valNum.intValue > 99) {
                        [newMess_btn setTitle:@"99+" forState:UIControlStateNormal];
                    } else {
                        [newMess_btn setTitle:[NSString stringWithFormat:@"%@",valNum] forState:UIControlStateNormal];
                    }
                    [newMess_btn.titleLabel setFont:[UIFont fitFontWithSize:K_FONTSIZE_Icon]];
                    [newMess_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [newMess_btn setBackgroundImage:[Util imageWithColor:[UIColor redColor]] forState:UIControlStateNormal];
                    [newMess_btn setBackgroundColor:[UIColor redColor]];
                    [newMess_btn mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.centerX.equalTo(zhanneixinBtn.mas_centerX).offset(20);
                        make.centerY.equalTo(zhanneixinBtn.mas_centerY).offset(-10);
                        make.width.equalTo(@20);
                        make.height.equalTo(@20);
                    }];
                }
            }
        }
    }
}


//好友提醒
- (void)newFriendTip
{
    NSNumber *valNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"KNEWS_FRIEND_MESSAGE"];
    for (UIViewController *subvc in self.viewControllers) {
        if ([subvc isKindOfClass:[UINavigationController class]]) {
            DZNavigationController *subnavi = (DZNavigationController *)subvc;
            if (subnavi.tabType == DZTabType_MePage) {
                //遍历出所有的 “我的” 页面
                NSInteger btnindex = subnavi.tabBarButtonIndex;
                NSInteger btnTag = btnindex+1000;
                UIButton *meBtn = (UIButton *)[_tabBarBG viewWithTag:btnTag];
                //新消息到达
                UIView *newmess = [meBtn viewWithTag:9876];
                [newmess removeFromSuperview];
                newmess = nil;
                if (!isNull(valNum) && valNum.intValue > 0) {
                    //改变
                    UIButton *newMess_btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    [meBtn addSubview:newMess_btn];
                    newMess_btn.enabled = NO;
                    newMess_btn.layer.cornerRadius = 10;
                    newMess_btn.clipsToBounds = YES;
                    newMess_btn.tag = 9876;
                    if (valNum.intValue > 99) {
                        [newMess_btn setTitle:@"99+" forState:UIControlStateNormal];
                    } else {
                        [newMess_btn setTitle:[NSString stringWithFormat:@"%@",valNum] forState:UIControlStateNormal];
                    }
                    [newMess_btn.titleLabel setFont:[UIFont fitFontWithSize:K_FONTSIZE_Icon]];
                    [newMess_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [newMess_btn setBackgroundImage:[Util imageWithColor:[UIColor redColor]] forState:UIControlStateNormal];
                    [newMess_btn setBackgroundColor:[UIColor redColor]];
                    [newMess_btn mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.centerX.equalTo(meBtn.mas_centerX).offset(20);
                        make.centerY.equalTo(meBtn.mas_centerY).offset(-10);
                        make.width.equalTo(@20);
                        make.height.equalTo(@20);
                    }];
                }
            }
        }
    }

}


@end
