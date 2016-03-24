//
//  HomeViewController.m
//  Clan
//
//  Created by chivas on 15/3/3.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "HomeViewController.h"
#import "PPiFlatSegmentedControl.h"
#import "SegmentView.h"
//#import "HotPostViewController.h"
#import "BoardViewController.h"
#import "YZCardView.h"
#import "BroadSideController.h"
#import "CustomViewController.h"
#import "SearchViewController.h"
#import "HomeViewModel.h"
#import "PostSendViewController.h"
#import "BoardModel.h"

static float interval = 60.f;

@interface HomeViewController ()
{
    //用于站内信轮询
    NSTimer *_timer;
    UIView *_baseView;
}
@property (strong, nonatomic)YZCardView *cardView;
@property (assign, nonatomic) NSInteger oldSelectedIndex;
@property (strong, nonatomic)NSArray *childViewControllers;
@property (strong, nonatomic)UIViewController *currentViewController;
@property (nonatomic,strong)UIView *segmentView;
@property (nonatomic,strong)UIButton *fatieBtn;
@property (nonatomic,strong)HomeViewModel *homeviewmodel;


@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _homeviewmodel = [HomeViewModel new];
    _oldSelectedIndex = 0;
    //初始化页面
//    [self initViewController];
    [self loadBoardStyleVC:NO];
    
    UISegmentedControl *statFilter = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"首页", @"论坛", nil]];
    statFilter.layer.cornerRadius = 13.f;
    statFilter.layer.borderColor = [UIColor whiteColor].CGColor;
    statFilter.layer.borderWidth = 1.0f;
    statFilter.layer.masksToBounds = YES;
    statFilter.bounds = CGRectMake(0, 0, 138.f, 30.f);
    [statFilter setSelectedSegmentIndex:0];
    [statFilter addTarget:self action:@selector(segmentAction:)forControlEvents:UIControlEventValueChanged];  //添加委托方法
    self.navigationItem.titleView = statFilter;
    //设置导航
    [self initNav];
    [self addFaTieButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCome:) name:@"KNEWS_MESSAGE_COME" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCome:) name:@"KNEWS_FRIEND_MESSAGE" object:nil];
    //注册监听模式
    UserModel *cUser = [UserModel currentUserInfo];
    [cUser addObserver:self forKeyPath:@"logined" options:NSKeyValueObservingOptionNew context:NULL];
    [cUser addObserver:self forKeyPath:@"avatar" options:NSKeyValueObservingOptionNew context:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCome:) name:@"Avatar_Changed" object:nil];
    [self segmentedControlValueChanged];
}

- (void)dealloc
{
    @try {
        [[UserModel currentUserInfo] removeObserver:self forKeyPath:@"logined"];
        [[UserModel currentUserInfo] removeObserver:self forKeyPath:@"avatar"];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    };
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.toolbarItems = nil;
    self.navigationController.toolbarHidden = YES;
    if ([UserModel currentUserInfo].logined) {
        [self doCheckIfHasNewMessage];
        [self startTimer];
        AppDelegate *dele = [AppDelegate appDelegate];
        [dele getUserAllFavos];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopTimer];
}

- (void)notificationCome:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"KNEWS_MESSAGE_COME"]) {
        [self initNav];
    }
    else if ([noti.name isEqualToString:@"Avatar_Changed"]) {
        [[SDImageCache sharedImageCache] removeImageForKey:[UserModel currentUserInfo].avatar fromDisk:YES];
        [self initNav];
    }
    else if ([noti.name isEqualToString:@"KNEWS_FRIEND_MESSAGE"]) {
        [self initNav];
    }
}

- (void)initViewController
{
    //热点
    CustomViewController *custom = [[CustomViewController alloc]init];
//    HotPostViewController *postViewController = [[HotPostViewController alloc]init];
    //版块
    BoardViewController *boardViewController = [[BoardViewController alloc]init];
    _childViewControllers = @[custom, boardViewController];
}


- (void)loadBoardStyleVC:(BOOL)removeOld
{
    CustomViewController *custom = [[CustomViewController alloc]init];
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
    _childViewControllers = @[custom, vc];
}


- (void)initNav
{
    self.navigationItem.title = [NSString returnStringWithPlist:YZBBSName];
    if (!_baseView) {
        _baseView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    }
    for (UIView *view in _baseView.subviews) {
        [view removeFromSuperview];
    }
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sousuoshouye"] style:UIBarButtonItemStylePlain target:self action:@selector(searchAction)] animated:NO];

    
    NSNumber *valNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"KNEWS_MESSAGE"];
    NSString *navTitle = @"nav_left";
    //    if (valNum && valNum.intValue != 0) {
    //        navTitle = @"nav_left_news";
    //    }
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 5, 30, 30);
    [leftButton addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    leftButton.layer.cornerRadius = 15;
    leftButton.clipsToBounds = YES;
    UserModel *cUsr = [UserModel currentUserInfo];
    if (cUsr && cUsr.logined) {
        [leftButton sd_setBackgroundImageWithURL:[NSURL URLWithString:cUsr.avatar] forState:UIControlStateNormal placeholderImage:kIMG(@"portrait_small")];
    } else {
        [leftButton sd_cancelBackgroundImageLoadForState:UIControlStateNormal];
        [leftButton sd_cancelImageLoadForState:UIControlStateNormal];
        [leftButton setImage:kIMG(navTitle) forState:UIControlStateNormal];
    }
    [_baseView addSubview:leftButton];
    if ((!isNull(valNum) && valNum.intValue != 0) || [self newFriendTip]) {
        //加红点
        UIImageView *redPod = nil;
        redPod = [[UIImageView alloc]initWithImage:[Util imageWithColor:[UIColor redColor]]];
        redPod.backgroundColor = [UIColor redColor];
        redPod.layer.cornerRadius = 4;
        redPod.clipsToBounds = YES;
        [_baseView addSubview:redPod];
        [redPod mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(_baseView.mas_trailing).offset(-8);
            make.top.equalTo(_baseView.mas_top).offset(6);
            make.width.equalTo(@8);
            make.height.equalTo(@8);
        }];
    }
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:_baseView];
    self.navigationItem.leftBarButtonItem = leftItem ;
}


- (BOOL)newFriendTip
{
    if (![UserModel currentUserInfo].logined) {
        return NO;
    }
    NSNumber *valNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"KNEWS_FRIEND_MESSAGE"];
    if (!isNull(valNum) && valNum.intValue > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (void)addFaTieButton
{
    if (!_fatieBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:kIMG(@"fatie_big") forState:UIControlStateNormal];
        [self.view addSubview:btn];
        self.fatieBtn = btn;
        [_fatieBtn addTarget:self action:@selector(sendPost) forControlEvents:UIControlEventTouchUpInside];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.view.mas_trailing).offset(-54/2);
            make.bottom.equalTo(self.view.mas_bottom).offset(-58/2);
            make.width.equalTo(@(126/2));
            make.height.equalTo(@(126/2));
        }];
    }
    [self.view bringSubviewToFront:_fatieBtn];
}


#pragma mark - 搜索
- (void)searchAction
{
    SearchViewController *searchVC = [[SearchViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:searchVC];
    [self presentViewController:nav animated:NO completion:nil];
}


- (void)initSegment
{
    _cardView = [[YZCardView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
    _cardView.backgroundColor = [UIColor whiteColor];
    _cardView.target = self;
    [_cardView addCardWithTitle:@"首页" withSel:@selector(hot)];
    [_cardView addCardWithTitle:@"版块" withSel:@selector(post)];
    [self.view addSubview:_cardView];
//    if ([[[NSUserDefaults standardUserDefaults]stringForKey:@"KShowPostList"] isEqualToString:@"1"]) {
//        //热点数为0
//        [_cardView changeSelectBtn:1];
//        _oldSelectedIndex = 1;
//        [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"KShowPostList"];
//        [[NSUserDefaults standardUserDefaults]synchronize];
//    }
    [self segmentedControlValueChanged];
}

- (void)segmentAction:(UISegmentedControl *)Seg
{
    NSInteger Index = Seg.selectedSegmentIndex;
    if (_oldSelectedIndex == Index) {
        return;
    }
    _oldSelectedIndex = Index;
    [self segmentedControlValueChanged];
}

- (void)hot {
    int index = 0;
    if (_oldSelectedIndex == index) {
        return;
    }
    _oldSelectedIndex = index;
    [self segmentedControlValueChanged];
}

- (void)post {
    int index = 1;
    if (_oldSelectedIndex == index) {
        return;
    }
    _oldSelectedIndex = index;
    [self segmentedControlValueChanged];
}

- (void)segmentedControlValueChanged
{
    UIViewController *viewController = [self.childViewControllers objectAtIndex:_oldSelectedIndex];
    if (!self.currentViewController) {
        // first time a segment is selected
        [self addChildViewController:viewController];
        [viewController.view setFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        
        [self.view addSubview:viewController.view];
        //		[self fixInsets:viewController];
        [viewController didMoveToParentViewController:self];
        self.currentViewController = viewController;
    }
    else {
        // swap the existing view with the newly selected one
        [self.currentViewController willMoveToParentViewController:nil];
        [self addChildViewController:viewController];
        
        [self transitionFromViewController:self.currentViewController toViewController:viewController duration:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
        } completion:^(BOOL finished) {
            [viewController.view setFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
            [self.currentViewController removeFromParentViewController];
            //			[self fixInsets:viewController];
            [viewController didMoveToParentViewController:self];
            self.currentViewController = viewController;
        }];
    }
    [self addFaTieButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - timer
//停止计时器
- (void)stopTimer
{
    //开始拖动scrollview的时候 停止计时器控制的跳转
    [_timer invalidate];
    _timer = nil;
}
//开始计时器
- (void)startTimer
{
    [self stopTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(doCheckIfHasNewMessage) userInfo:nil repeats:YES];
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"logined"] || [keyPath isEqualToString:@"avatar"]) {
        [self initNav];
    }
}

- (void)sendPost
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
                    if (boardModel.forums && boardModel.forums.count>0) {
                        [forumsArr addObjectsFromArray:boardModel.forums];
                    }
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
@end
