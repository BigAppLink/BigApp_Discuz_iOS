//
//  HotPostViewController.m
//  Clan
//
//  Created by chivas on 15/3/17.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "HotPostViewController.h"
#import "HomeViewModel.h"
#import "HotPostCell.h"
#import "PostModel.h"
#import "BaseTableView.h"
#import "MJRefresh.h"
#import "PostDetailViewController.h"
#import "PostDetailVC.h"

@interface HotPostViewController ()
@property (strong, nonatomic)BaseTableView *tableView;
@property (strong, nonatomic)NSMutableArray *dataArray;
@property (strong, nonatomic)UITableViewCell *tempCell;
@property (strong, nonatomic)HomeViewModel *homeViewModel;
@property (assign, nonatomic)int dataPage;
@end
@implementation HotPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!_homeViewModel) {
        _homeViewModel = [HomeViewModel new];
    }
//    [self initModel];
    [self initWithTable];
    self.automaticallyAdjustsScrollViewInsets = NO;

    _dataPage = 0;
}
- (void)initModel{
    _dataArray = [NSMutableArray array];
}

- (void)initWithTable
{
    WEAKSELF
    _tableView = [[BaseTableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenBoundsHeight-44)];
    [_tableView addLegendHeaderWithRefreshingBlock:^{
        [weakSelf requestDataWithPage:weakSelf.dataPage];
    }];
    [_tableView beginRefreshing];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.sectionFooterHeight = 0;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    if (kIOS8) {
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 85;
    }
    [self.view addSubview:_tableView];
    [Util setExtraCellLineHidden:_tableView];
    //计算高度用
    UINib *cellNib = [UINib nibWithNibName:@"HotPostCell" bundle:nil];
    [_tableView registerNib:cellNib forCellReuseIdentifier:@"hotpost"];
    _tempCell  = [_tableView dequeueReusableCellWithIdentifier:@"hotpost"];
    
}
#pragma mark - 请求刷新数据
- (void)requestDataWithPage:(int)page{
    WEAKSELF
    [_homeViewModel request_hotPostBlock:^(id data) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.view endLoading];
        [strongSelf.dataArray removeAllObjects];
        [strongSelf.tableView endHeaderRefreshing];
        if (data) {
            strongSelf.dataArray = data;
        }
        [strongSelf.tableView reloadData];
        [_tableView configBlankPage:DataIsNothingWithDefault hasData:(strongSelf.dataArray.count > 0) hasError:(!data) reloadButtonBlock:^(id sender) {
            [self.view beginLoading];
            [strongSelf requestDataWithPage:strongSelf.dataPage];
        }];
    }];
}


#pragma mark - Table M


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HotPostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hotpost" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (_dataArray.count > 0) {
        PostModel *postmodel = _dataArray[indexPath.row];
        postmodel.ishot = YES;
        cell.postModel = postmodel;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (kDEVICE_IS_IPHONE6Plus) {
        return 90.f;
    }
    return 83;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 83;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //跳转到详情页面
//    PostDetailViewController *detail = [[PostDetailViewController alloc]init];
//    detail.postModel =  _dataArray[indexPath.row];
//    [self.navigationController pushViewController:detail animated:YES];
    
    PostDetailVC *detail = [[PostDetailVC alloc]init];
    detail.postModel =  _dataArray[indexPath.row];
    [self.navigationController pushViewController:detail animated:YES];
    [Util readPost:detail.postModel.tid];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)dealloc{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}
@end
