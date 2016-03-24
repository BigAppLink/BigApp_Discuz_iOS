//
//  HomeViewController.m
//  Clan
//
//  Created by chivas on 15/3/3.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "HomeViewController.h"
//#import "UIViewController+MMDrawerController.h"
#import "PPiFlatSegmentedControl.h"
#import "SegmentView.h"
#import "HotPostViewController.h"
#import "BoardViewController.h"
#import "YZCardView.h"
#import <UIButton+WebCache.h>
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
@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _oldSelectedIndex = 0;
    //初始化页面
    [self initViewController];
    //设置导航
    [self initNav];
    //设置segment
    [self initSegment];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCome:) name:@"KNEWS_MESSAGE_COME" object:nil];
    //注册监听模式
    UserModel *cUser = [UserModel currentUserInfo];
    [cUser addObserver:self forKeyPath:@"logined" options:NSKeyValueObservingOptionNew context:NULL];
    [cUser addObserver:self forKeyPath:@"avatar" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)dealloc
{
    [[UserModel currentUserInfo] removeObserver:self forKeyPath:@"logined"];
    [[UserModel currentUserInfo] removeObserver:self forKeyPath:@"avatar"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([UserModel currentUserInfo].logined) {
        [self doCheckIfHasNewMessage];
        [self startTimer];
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
}

- (void)initViewController
{
    //热点
    HotPostViewController *postViewController = [[HotPostViewController alloc]init];
    //版块
    BoardViewController *boardViewController = [[BoardViewController alloc]init];
    _childViewControllers = @[postViewController, boardViewController];
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
    if (cUsr
        && cUsr.logined
        && cUsr.avatar
        && cUsr.avatar.length > 0) {
        [leftButton sd_setBackgroundImageWithURL:[NSURL URLWithString:cUsr.avatar] forState:UIControlStateNormal placeholderImage:kIMG(@"navTitle")];
    } else {
        [leftButton setImage:kIMG(navTitle) forState:UIControlStateNormal];
    }
    [_baseView addSubview:leftButton];
    if (valNum && valNum.intValue != 0) {
        //加红点
        UIImageView *redPod = nil;
        redPod = [[UIImageView alloc]initWithImage:[Util imageWithColor:[UIColor redColor]]];
        redPod.backgroundColor = [UIColor redColor];
        redPod.layer.cornerRadius = 4;
        redPod.clipsToBounds = YES;
        [_baseView addSubview:redPod];
        [redPod mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_baseView.mas_right).offset(-8);
            make.top.equalTo(_baseView.mas_top).offset(6);
            make.width.equalTo(@8);
            make.height.equalTo(@8);
        }];
    }
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:_baseView];
    self.navigationItem.leftBarButtonItem = leftItem ;
}


- (void)initSegment
{
    _cardView = [[YZCardView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
    _cardView.backgroundColor = [UIColor whiteColor];
    _cardView.target = self;
    [_cardView addCardWithTitle:@"热点" withSel:@selector(hot)];
    [_cardView addCardWithTitle:@"版块" withSel:@selector(post)];
    [self.view addSubview:_cardView];
    if ([[[NSUserDefaults standardUserDefaults]stringForKey:@"KShowPostList"] isEqualToString:@"1"]) {
        //热点数为0
        [_cardView changeSelectBtn:1];
        _oldSelectedIndex = 1;
        [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"KShowPostList"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    [self segmentedControlValueChanged];
}


- (void)hot{
    int index = 0;
    if (_oldSelectedIndex == index) {
        return;
    }
    _oldSelectedIndex = index;
    [self segmentedControlValueChanged];
}

- (void)post{
    int index = 1;
    if (_oldSelectedIndex == index) {
        return;
    }
    _oldSelectedIndex = index;
    [self segmentedControlValueChanged];
}

- (void)segmentedControlValueChanged{
    UIViewController *viewController = [self.childViewControllers objectAtIndex:_oldSelectedIndex];
    if (!self.currentViewController) {
        // first time a segment is selected
        [self addChildViewController:viewController];
        [viewController.view setFrame:CGRectMake(0, 44, ScreenWidth, ScreenHeight - _cardView.height)];
        
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
            [viewController.view setFrame:CGRectMake(0, 44, ScreenWidth, ScreenHeight - _cardView.height)];
            [self.currentViewController removeFromParentViewController];
            //			[self fixInsets:viewController];
            [viewController didMoveToParentViewController:self];
            self.currentViewController = viewController;
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


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
    DLog(@"---- 轮询中...");
    //    WEAKSELF
    [[Clan_NetAPIManager sharedManager] checkNewMessageComeWithResultBlock:^(id data, NSError *error) {
        //        STRONGSELF
        if (!error) {
            NSNumber *results = [data valueForKey:@"newpm"];
            if (results && results.intValue >= 1) {
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
@end
