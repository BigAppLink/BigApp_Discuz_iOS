//
//  BroadSideController.m
//  Clan
//
//  Created by 昔米 on 15/7/21.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "BroadSideController.h"
#import "HomeViewModel.h"
#import "BoardCell.h"
#import "BoardModel.h"
#import "PostViewController.h"

@interface BroadSideController () <UITableViewDataSource, UITableViewDelegate>
{
    NSIndexPath *_toBeReloadPath;
    BOOL _first;
    UITableViewCell *_selectedCell;
    NSString *_selectfid;
}
@property (nonatomic, strong) UITableView *menuTable;
@property (strong, nonatomic) BaseTableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) HomeViewModel *homeViewModel;
@property (assign) int selectedMenuIndex;

@end

@implementation BroadSideController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadModel];
    [self buildUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //页面开始
    if (_toBeReloadPath) {
        [self.tableView deselectRowAtIndexPath:_toBeReloadPath animated:YES];
        _toBeReloadPath = nil;
    }
}

- (void)dealloc
{
    _menuTable.delegate = nil;
    _menuTable.dataSource = nil;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _homeViewModel = nil;
    DLog(@"Broad 侧边栏dealloc");
}

#pragma mark - 视图
//数据源
- (void)loadModel
{
    self.navigationItem.title = @"论坛";
    if (!_homeViewModel) {
        _homeViewModel = [HomeViewModel new];
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)buildUI
{
    if (!_isTabBarItem) {
        UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.backgroundColor = [UIColor clearColor];
        leftButton.frame = CGRectMake(0, 0, 26, 26);
        [leftButton setBackgroundImage :[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(backView) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    }

    float tbheight = kSCREEN_HEIGHT-64;
    if (self.tabBarController) {
        tbheight = kSCREEN_HEIGHT-64-kTABBAR_HEIGHT;
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(doAutoUpdate) name:@"AUTO_REFRESH_BANKUAI" object:nil];
    UITableView *menu = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 88, tbheight) style:UITableViewStylePlain];
    menu.dataSource = self;
    menu.delegate = self;
    [self.view addSubview:menu];
    self.menuTable = menu;
    self.menuTable.backgroundColor = kCLEARCOLOR;
    self.menuTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [Util setExtraCellLineHidden:menu];
    
    UIImageView *seperLine = [[UIImageView alloc]initWithFrame:CGRectMake(kVIEW_BX(menu)-0.5, 0, 0.5, tbheight)];
    seperLine.image = [Util imageWithColor:kUIColorFromRGB(0xdddddd)];
    [self.view insertSubview:seperLine belowSubview:menu];
    
    _tableView = [[BaseTableView alloc]initWithFrame:CGRectMake(kVIEW_BX(menu), 0, ScreenWidth-kVIEW_BX(menu), tbheight) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = kCLEARCOLOR;
    WEAKSELF
    [_tableView addLegendHeaderWithRefreshingBlock:^{
        [weakSelf requestBoardData];
    }];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_tableView];
    [Util setExtraCellLineHidden:_tableView];
    [self loadCache];
    [_tableView beginRefreshing];
}

- (void)backView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)change
{
    [self.tableView reloadData];
}
//加载缓存
- (void)loadCache
{
    WEAKSELF
    [_homeViewModel request_boardCache:^(id data) {
        STRONGSELF
        if (data) {
            strongSelf.dataArray = data;
            [strongSelf.menuTable reloadData];
            [strongSelf.tableView reloadData];
        }
    }];
}

- (void)doAutoUpdate
{
    if (!self.tableView.header.isRefreshing) {
        //是否正在下拉刷新
        [self.tableView beginRefreshing];
    }
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
            [strongSelf checkSelectedID];
            [strongSelf.menuTable reloadData];
            [strongSelf.tableView reloadData];
        }
        [strongSelf.view configBlankPage:DataIsNothingWithDefault hasData:(strongSelf.dataArray.count > 0) hasError:(!data) reloadButtonBlock:^(id sender) {
            [strongSelf.view beginLoading];
            [strongSelf requestBoardData];
        }];
    }];
}

- (void)checkSelectedID
{
    for (int i = 0; i < _dataArray.count; i++) {
        BoardModel *board = _dataArray[i];
        if (_selectfid && _selectfid.length>0 && [board.fid isEqualToString:_selectfid]) {
            _selectedMenuIndex = i;
            _selectedCell = nil;
            return;
        }
    }
    _selectedMenuIndex = 0;
    if (_dataArray.count > 0) {
        BoardModel *board1 = _dataArray[0];
        _selectfid =  board1.fid;
    } else {
        _selectfid = nil;
    }
}

#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView != _menuTable) {
        if (_dataArray && _dataArray.count > 0) {
            BoardModel *boardInfo = _dataArray[_selectedMenuIndex];
            return boardInfo.forums.count;
        } else {
            return 0;
        }
    }
    return [_dataArray count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _menuTable && indexPath.row == _selectedMenuIndex) {
        _selectedCell = cell;
        [cell setSelected:YES animated:NO];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _menuTable) {
        static NSString *cellindentifer = @"MenuCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellindentifer];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellindentifer];
            UIView *bgview = [UIView new];
            cell.backgroundView = bgview;
            UIImageView *lineView = [UIImageView new];
            lineView.frame = CGRectMake(kVIEW_W(_menuTable)-0.5, 0, 0.5, 45.f);
            lineView.image = [Util imageWithColor:kUIColorFromRGB(0xdddddd)];
            [bgview addSubview:lineView];
            UIView *sView = [UIView new];
            sView.backgroundColor = [UIColor whiteColor];
            UIImageView *toplineView = [UIImageView new];
            toplineView.frame = CGRectMake(0, 0, kVIEW_W(_menuTable), 0.5);
            toplineView.image = [Util imageWithColor:kUIColorFromRGB(0xdddddd)];
            [sView addSubview:toplineView];
            cell.selectedBackgroundView = sView;
            cell.backgroundColor = kCLEARCOLOR;
            cell.contentView.backgroundColor = kCLEARCOLOR;
            cell.textLabel.font = [UIFont fontWithSize:13.f];
            cell.textLabel.numberOfLines = 2;
            UIImageView *bottomlineView = [UIImageView new];
            bottomlineView.frame = CGRectMake(0, 45, kVIEW_W(_menuTable), 0.5);
            bottomlineView.image = [Util imageWithColor:kUIColorFromRGB(0xdddddd)];
            [cell.contentView addSubview:bottomlineView];
            cell.textLabel.textColor = K_COLOR_DARK_Cell;
            UIImageView *indicatoreView = [UIImageView new];
            indicatoreView.frame = CGRectMake(0, 0, 3, 45.f);
//            indicatoreView.image = [Util imageWithColor:kUIColorFromRGB(0xff9900)];
            indicatoreView.image = [Util imageWithColor:[Util mainThemeColor]];

            indicatoreView.tag = 77888;
            [cell.contentView addSubview:indicatoreView];
            
        }
        UIImageView *indicatorview = (UIImageView *)[cell.contentView viewWithTag:77888];
        
        cell.textLabel.text = [_dataArray[indexPath.row]name];
        if (indexPath.row == _selectedMenuIndex) {
            _selectfid = [_dataArray[indexPath.row]fid];
            indicatorview.hidden = NO;
        } else {
            indicatorview.hidden = YES;
        }
        return cell;
    }
    else {
        static   NSString *CellIdentifier10 = @"subjectDetail";
        BoardCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier10];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"BoardCell" owner:self options:nil] lastObject];
        }
        BoardModel *boardInfo = _dataArray[_selectedMenuIndex];
        NSArray *forums = [boardInfo forums];
        cell.forumsModel = forums[indexPath.row];
//        cell.iv_line.hidden = (indexPath.row == forums.count-1) ? YES : NO;
        return cell;
    }
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView == _menuTable ? 45.f : 74.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _menuTable) {
        if (indexPath.row == _selectedMenuIndex) {
            return;
        }
        if (_selectedCell) {
            [_selectedCell setSelected:NO animated:YES];
            _selectedCell = nil;
        }
        _selectfid = [_dataArray[indexPath.row]fid];
        _selectedMenuIndex = (int)indexPath.row;
        [_menuTable reloadData];
        [self change];
    } else {
        BoardModel *boardInfo = _dataArray[_selectedMenuIndex];
        NSArray *forums = [boardInfo forums];
        PostViewController *postVc = [[PostViewController alloc]init];
        postVc.hidesBottomBarWhenPushed = YES;
        postVc.forumsModel = forums[indexPath.row];
        _toBeReloadPath = indexPath;
        [self.navigationController pushViewController:postVc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
@end
