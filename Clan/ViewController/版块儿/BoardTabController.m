//
//  BoardTabController.m
//  Clan
//
//  Created by 昔米 on 15/7/21.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "BoardTabController.h"
#import "HomeViewModel.h"
#import "BoardCell.h"
#import "BoardModel.h"
#import "PostViewController.h"
#import "BoardView.h"

@interface BoardTabController ()
{
    NSIndexPath *_toBeReloadPath;
    NSString *_selectfid;
}
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSMutableArray *titleArray;
@property (strong, nonatomic) HomeViewModel *homeViewModel;
@end

@implementation BoardTabController


- (void)viewDidLoad
{
    self.delegate = self;
    self.dataSource = self;
    [self loadModel];
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiCome:) name:@"Board_PullDown_Trigger" object:nil];
    [self buildUI];
    [self loadCache];
    [self requestBoardData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BoardTabControllerAppear" object:nil];
}

- (void)dealloc
{
    DLog(@"BoardTabController dealloc");
    _homeViewModel = nil;
}

#pragma mark - 初始化
- (void)loadModel
{
    self.dataArray = [NSMutableArray new];
    self.titleArray = [NSMutableArray new];
    _homeViewModel = [HomeViewModel new];
}

- (void)buildUI
{
    self.title = @"论坛";
    if (!_isTabBarItem) {
        UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.backgroundColor = [UIColor clearColor];
        leftButton.frame = CGRectMake(0, 0, 26, 26);
        [leftButton setBackgroundImage :[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(backView) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    }

}

- (void)backView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)notiCome:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"Board_PullDown_Trigger"]) {
        [self requestBoardData];
    }
}

- (void)doAutoUpdate
{
    
}

#pragma mark - ViewPagerDataSource
- (NSArray *)titleArrayForViewPager:(ViewPagerController *)viewpager
{
    NSArray *array = [[NSArray alloc]initWithArray:_titleArray];
    return array;
}

- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager
{
    return _titleArray.count;
}

- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index
{
    if (self.tabBarController) {
        BoardView *boardView = [[BoardView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-64-kTopSegmentBarHeight-49)];
        boardView.board = _dataArray[index];
        return boardView;
    }
    BoardView *boardView = [[BoardView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-64-kTopSegmentBarHeight)];
    boardView.board = _dataArray[index];
    return boardView;
    
}

#pragma mark - ViewPagerDelegate
- (void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index
{
}

#pragma mark - 请求刷新数据
- (void)requestBoardData
{
    WEAKSELF
    [_homeViewModel request_boardBlock:^(id data) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Board_PullDown_Completed" object:nil];
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.view endLoading];
        if (data) {
            strongSelf.dataArray = data;
            [strongSelf dealWithdatas];
        }
    }];
}

//加载缓存
- (void)loadCache
{
    [self showProgressHUDWithStatus:@""];
    WEAKSELF
    [_homeViewModel request_boardCache:^(id data) {
        STRONGSELF
        [strongSelf dissmissProgress];
        if (data) {
            strongSelf.dataArray = data;
            [strongSelf dealWithdatas];
        }
    }];
}

- (void)dealWithdatas
{
    NSMutableArray *arr = [NSMutableArray new];
    for (BoardModel *board in _dataArray) {
        [arr addObject:board.name];
    }
    self.titleArray = arr;
    [self checkSelectedID];
    [self performSelector:@selector(reloadDatas) withObject:nil afterDelay:0.25];
}

- (void)checkSelectedID
{
    for (int i = 0; i < _dataArray.count; i++) {
        BoardModel *board = _dataArray[i];
        if (_selectfid && _selectfid.length>0 && [board.fid isEqualToString:_selectfid]) {
            self.selectedIndex = i;
            _selectfid = board.fid;
            return;
        }
    }
    self.selectedIndex = 0;
    if (_dataArray.count > 0) {
        BoardModel *board1 = _dataArray[0];
        _selectfid =  board1.fid;
    } else {
        _selectfid = nil;
    }
}

- (void)viewPager:(ViewPagerController *)viewPager viewAppearAtIndex:(NSUInteger)index
{
    if (_dataArray.count <= index) {
        return;
    }
    BoardModel *board = _dataArray[index];
    _selectfid = board.fid;
}



@end
