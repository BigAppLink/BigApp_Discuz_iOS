//
//  MessageController.m
//  Clan
//
//  Created by 昔米 on 15/9/9.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "MessageController.h"
#import "DialogListViewController.h"
#import "WarnController.h"

@interface MessageController () <UIScrollViewDelegate>
@property (nonatomic, strong) UISegmentedControl *segment;
@property (nonatomic, strong) UIScrollView *contentscroll;
@property (nonatomic, strong) DialogListViewController *dialogVC;
@property (nonatomic, strong) WarnController *warnVC;

//@property (nonatomic, strong)  UIBarButtonItem *cancelButton;
//@property (nonatomic, strong)  UIBarButtonItem *deleteButton;
//@property (nonatomic, strong)  UIBarButtonItem *backButton;
@end

@implementation MessageController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self buildUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    DLog(@"MessageController dealloc");
    _contentscroll.delegate = nil;
}

#pragma mark - 自定义方法

- (void)backView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)buildUI
{
    [self addTitleView];

    float height = self.tabBarController ? kSCREEN_HEIGHT-64-kTABBAR_HEIGHT : kSCREEN_HEIGHT-64;
    UIScrollView *sv = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, height)];
    sv.delegate = self;
    sv.scrollEnabled = NO;
    sv.showsHorizontalScrollIndicator = NO;
    sv.showsVerticalScrollIndicator = NO;
    sv.pagingEnabled = YES;
    [sv setContentSize:CGSizeMake(kSCREEN_WIDTH*2, height)];
    self.contentscroll = sv;
    [self.view addSubview:sv];
    [self showDialogView];
}

- (void)addTitleView
{
    UISegmentedControl *statFilter = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"好友消息", @"系统提醒", nil]];
    statFilter.layer.cornerRadius = 13.f;
    statFilter.layer.borderColor = [UIColor whiteColor].CGColor;
    statFilter.layer.borderWidth = 1.0f;
    statFilter.layer.masksToBounds = YES;
    statFilter.bounds = CGRectMake(0, 0, 150.f, 30.f);
    [statFilter setSelectedSegmentIndex:0];
    [statFilter addTarget:self action:@selector(segmentAction:)forControlEvents:UIControlEventValueChanged];  //添加委托方法
    self.navigationItem.titleView = statFilter;
    self.segment = statFilter;
}

- (void)setUpNaviButtons
{
    switch (_segment.selectedSegmentIndex) {
        case 0:
            [_dialogVC setupNavigationButtonsForVC:self];
            break;
        case 1:
//            self.navigationItem.leftBarButtonItem = nil;
//            self.navigationItem.rightBarButtonItem = nil;
            break;
            
        default:
            break;
    }
    [self addBackBtn];
}

//- (void)addBackBtn
//{
//    NSArray *viewControllers = self.navigationController.viewControllers;
//    if (viewControllers.count > 1 || !_isTabBarItem) {
//        UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        leftButton.backgroundColor = [UIColor clearColor];
//        leftButton.frame = CGRectMake(0, 0, 26, 26);
//        [leftButton setBackgroundImage :[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
//        [leftButton addTarget:self action:@selector(navback:) forControlEvents:UIControlEventTouchUpInside];
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
//    }
//}

- (void)navback:(id)sender
{
    if (_isRightItemBar) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

//好友消息界面
- (void)showDialogView
{
    if (!_dialogVC) {
        DialogListViewController *dialog = [[DialogListViewController alloc]initWithNibName:@"DialogListViewController" bundle:[NSBundle mainBundle]];
        dialog.isRightItemBar = _isRightItemBar;
        dialog.view.frame = CGRectMake(0, 0, kSCREEN_WIDTH, kVIEW_H(_contentscroll));
        [_contentscroll addSubview:dialog.view];
        self.dialogVC = dialog;
        [self addChildViewController:dialog];
    }
    [_contentscroll setContentOffset:CGPointMake(0, 0) animated:YES];
    [self setUpNaviButtons];
}

//消息提醒界面
- (void)showWarnView
{
    if (!_warnVC) {
        WarnController *warn = [[WarnController alloc]init];
        warn.view.frame = CGRectMake(kSCREEN_WIDTH, 0, kSCREEN_WIDTH, kVIEW_H(_contentscroll));
        [_contentscroll addSubview:warn.view];
        self.warnVC = warn;
        [self addChildViewController:warn];
    }
    [_contentscroll setContentOffset:CGPointMake(kSCREEN_WIDTH, 0) animated:YES];
    [self setUpNaviButtons];
}

#pragma mark - Action methods
- (void)segmentAction:(UISegmentedControl *)Seg
{
    switch (Seg.selectedSegmentIndex) {
        case 0:
            [self showDialogView];
            break;
        case 1:
            [self showWarnView];
            break;
        default:
            break;
    }
}

#pragma mark - Scrollview Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / kSCREEN_WIDTH;
    [_segment setSelectedSegmentIndex:index];
}


@end
