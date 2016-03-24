//
//  BoardViewController.m
//  Clan
//
//  Created by chivas on 15/3/17.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "BoardViewController.h"
#import "HomeViewModel.h"
#import "BoardCell.h"
#import "BoardModel.h"
#import "BaseTableView.h"
#import "PostViewController.h"
#import "UIScrollView+MJRefresh.h"

@interface BoardViewController ()
{
    NSIndexPath *_toBeReloadPath;
}
@property (strong, nonatomic)BaseTableView *tableView;
@property (strong, nonatomic)NSMutableArray *dataArray;
@property (strong, nonatomic)HomeViewModel *homeViewModel;
@end

@implementation BoardViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_toBeReloadPath) {
        [self.tableView deselectRowAtIndexPath:_toBeReloadPath animated:YES];
        _toBeReloadPath = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"论坛";
    if (!_isTabBarItem) {
        UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.backgroundColor = [UIColor clearColor];
        leftButton.frame = CGRectMake(0, 0, 26, 26);
        [leftButton setBackgroundImage :[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(backView) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(doAutoUpdate) name:@"AUTO_REFRESH_BANKUAI" object:nil];
    if (!_homeViewModel) {
        _homeViewModel = [HomeViewModel new];
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initWithTable];
}

- (void)backView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)doAutoUpdate
{
    if (!self.tableView.header.isRefreshing) {
        //是否正在下拉刷新
        [self.tableView beginRefreshing];
    }
}

- (void)initWithTable
{
    WEAKSELF
    _tableView = [[BaseTableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, kSCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
    if (self.tabBarController) {
        _tableView.frame = CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-64-kTABBAR_HEIGHT);
    }
    _tableView.backgroundColor = kCLEARCOLOR;
    self.view.backgroundColor = kCOLOR_BG_GRAY;
    [_tableView addLegendHeaderWithRefreshingBlock:^{
        [weakSelf requestBoardData];
    }];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    [Util setExtraCellLineHidden:_tableView];
    [self loadCache];
//    [_tableView beginRefreshing];
}

//加载缓存
- (void)loadCache
{
    WEAKSELF
    [_homeViewModel request_boardCache:^(id data) {
        STRONGSELF
        if (data) {
            strongSelf.dataArray = data;
            [strongSelf.tableView reloadData];
        }
    }];
}

#pragma mark - 请求刷新数据
- (void)requestBoardData
{
    WEAKSELF
    [_homeViewModel request_boardBlock:^(id data) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.view endLoading];
        [strongSelf.tableView endHeaderRefreshing];
        if (data) {
            strongSelf.dataArray = data;
        }
        [strongSelf.tableView reloadData];
        [strongSelf.tableView configBlankPage:DataIsNothingWithDefault hasData:(strongSelf.dataArray.count > 0) hasError:(!data) reloadButtonBlock:^(id sender) {
            [self.view beginLoading];
            [strongSelf requestBoardData];
        }];
    }];
}

#pragma mark Table M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_dataArray[section]forums]count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 31 : 43;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, section == 0 ? 31 : 43)];
        view.backgroundColor = kCOLOR_BG_GRAY;
        UIView *whitebg = [UIView new];
        whitebg.backgroundColor = [UIColor whiteColor];
        [view addSubview:whitebg];
        [whitebg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(view.mas_leading);
            make.trailing.equalTo(view.mas_trailing);
            make.height.equalTo(@31);
            make.bottom.equalTo(view.mas_bottom);
        }];
        UILabel *label = [UILabel new];
        label.font = [UIFont fontWithSize:12.f];
        label.textColor = K_COLOR_DARK_Cell;
        label.text = [_dataArray[section]name];
        [view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(view.mas_leading).offset(15);
            make.trailing.equalTo(view.mas_trailing).offset(-10);
            make.height.equalTo(@31);
            make.bottom.equalTo(view.mas_bottom);
        }];
        UIView *line = [UIView new];
        line.backgroundColor = K_COLOR_MOST_LIGHT_GRAY;
        [view addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(view.mas_leading).offset(15);
            make.trailing.equalTo(view.mas_trailing);
            make.bottom.equalTo(view.mas_bottom).offset(0);
            make.height.equalTo(@(0.5));
        }];
        return view;
//    UIView *view = [UIView new];
//    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, kSCREEN_WIDTH-30, 30.f)];
//    nameLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_NORMAL];
//    nameLabel.textColor = K_COLOR_LIGHTGRAY;
//    nameLabel.text = [_dataArray[section]name];
//    [view addSubview:nameLabel];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static   NSString *CellIdentifier10 = @"subjectDetail";
    
    BoardCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier10];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"BoardCell" owner:self options:nil] lastObject];
//        [cell.countLabel removeConstraint:cell.rightConstraint];
    }
    NSArray *forums = [_dataArray[indexPath.section]forums];
    cell.forumsModel = forums[indexPath.row];
    cell.iv_line.hidden = (indexPath.row == forums.count-1) ? YES : NO;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *forums = [_dataArray[indexPath.section]forums];
    PostViewController *postVc = [[PostViewController alloc]init];
    postVc.hidesBottomBarWhenPushed = YES;
    postVc.forumsModel = forums[indexPath.row];
    _toBeReloadPath = indexPath;
    [self.navigationController pushViewController:postVc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 74;
}
- (void)dealloc
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
