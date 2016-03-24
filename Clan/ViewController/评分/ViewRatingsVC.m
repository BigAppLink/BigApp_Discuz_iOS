//
//  ViewRatingsVC.m
//  Clan
//
//  Created by 昔米 on 15/11/23.
//  Copyright © 2015年 Youzu. All rights reserved.
//

#import "ViewRatingsVC.h"
#import "ViewRatingItem.h"
#import "NSObject+MJKeyValue.h"

@interface ViewRatingsVC () <UITableViewDataSource, UITableViewDelegate>

@property (assign) NSInteger currentPage;
@property (strong, nonatomic) BaseTableView *table;
@property (strong, nonatomic) NSArray *sourceData;

@end

@implementation ViewRatingsVC

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

- (void)dealloc
{
    DLog(@"ViewRatingsVC 销毁");
}

#pragma mark - 初始化
- (void)loadModel
{
    _currentPage = 1;
}

- (void)buildUI
{
    self.title = @"查看全部评分";
    BaseTableView *table = [[BaseTableView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-64) style:UITableViewStylePlain];
    table.delegate = self;
    table.dataSource = self;
    table.separatorColor = kfsc_table_border;
    self.table = table;
    [self.view addSubview:table];
    [Util setExtraCellLineHidden:table];
    WEAKSELF
    [table createHeaderViewBlock:^{
        [weakSelf requestData];
    }];
    [table beginRefreshing];
}

#pragma mark - 请求数据
- (void)requestData
{
    WEAKSELF
    [[Clan_NetAPIManager sharedManager] request_viewRatingsForPost:_tid
                                                           withPid:_pid
                                                          andBlock:^(id data, NSError *error) {
                                                              [weakSelf.table endHeaderRefreshing];
                                                              if (data && [data valueForKey:@"Variables"]) {
                                                                  NSDictionary *dataDic = [data valueForKey:@"Variables"];
                                                                  if (dataDic[@"list"]) {
                                                                      NSArray *listArr = dataDic[@"list"];
                                                                      NSMutableArray *tempArr = [[NSMutableArray alloc]initWithCapacity:listArr.count];
                                                                      for (NSDictionary *itemdic in listArr) {
                                                                          ViewRatingItem *item = [ViewRatingItem objectWithKeyValues:itemdic];
                                                                          [tempArr addObject:item];
                                                                      }
                                                                      weakSelf.sourceData = tempArr;
                                                                      [weakSelf calculateCellHeight];
                                                                      [weakSelf.table reloadData];
                                                                  }
                                                              }
                                                          }];
}

#pragma mark - tableview delegate & datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _sourceData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifer = @"ViewRatingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor whiteColor];
        UILabel *lbl_name = [UILabel new];
        lbl_name.tag = 1100;
        lbl_name.numberOfLines = 2;
        lbl_name.lineBreakMode = NSLineBreakByWordWrapping;
        lbl_name.textColor = kColorWithRGB(0,0,0,0.7);
        lbl_name.font = [UIFont systemFontOfSize:14.f];
        lbl_name.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:lbl_name];
        UILabel *lbl_value = [UILabel new];
        lbl_value.tag = 1111;
        lbl_value.textColor = kColorWithRGB(231,86,16,1.0);
        lbl_value.font = [UIFont boldSystemFontOfSize:58/2];
        lbl_value.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:lbl_value];
        UILabel *lbl_title = [UILabel new];
        lbl_title.tag = 1122;
        lbl_title.textColor = kColorWithRGB(85,80,80,1.0);
        lbl_title.font = [UIFont systemFontOfSize:17.f];
        lbl_title.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:lbl_title];
        UILabel *lbl_reason = [UILabel new];
        lbl_reason.tag = 1133;
        lbl_reason.numberOfLines = 0;
        lbl_reason.lineBreakMode = NSLineBreakByWordWrapping;
        lbl_reason.textColor = kColorWithRGB(102,102,102,1.0);
        lbl_reason.font = [UIFont systemFontOfSize:14.f];
        [cell.contentView addSubview:lbl_reason];
        UIImageView *iv_reasonbg = [UIImageView new];
        iv_reasonbg.tag = 1144;
        iv_reasonbg.image = [Util imageWithColor:kUIColorFromRGB(0xf3f3f3)];
        iv_reasonbg.layer.cornerRadius = 8;
        iv_reasonbg.clipsToBounds = YES;
        [cell.contentView insertSubview:iv_reasonbg belowSubview:lbl_reason];
    }
    UILabel *lbl_name = [cell.contentView viewWithTag:1100];
    UILabel *lbl_value = [cell.contentView viewWithTag:1111];
    UILabel *lbl_title = [cell.contentView viewWithTag:1122];
    UILabel *lbl_reason = [cell.contentView viewWithTag:1133];
    UIImageView *iv_reasonbg = [cell.contentView viewWithTag:1144];
    CGFloat validwidth = (kSCREEN_WIDTH-32)/3.0;
    ViewRatingItem *item = _sourceData[indexPath.row];
    lbl_name.text = item.username;
    lbl_name.frame = CGRectMake(16, 0, validwidth, item.cellHeight);
    lbl_value.text = item.score;
    CGSize scroeSize = [Util sizeWithString:item.score font:lbl_value.font constraintSize:CGSizeMake(validwidth, item.cellHeight/2)];
    lbl_value.frame = CGRectMake(kVIEW_BX(lbl_name), item.cellHeight/2-scroeSize.height, validwidth, scroeSize.height);
    lbl_title.text = item.credit;
    CGSize creditSize = [Util sizeWithString:item.credit font:lbl_title.font constraintSize:CGSizeMake(validwidth, item.cellHeight/2)];
    lbl_title.frame = CGRectMake(kVIEW_TX(lbl_value), item.cellHeight/2, validwidth, creditSize.height);
    lbl_reason.text = (item.reason && item.reason.length>0) ? item.reason : @"没有理由哦~";
    CGSize reasonsize = [Util sizeWithString:lbl_reason.text font:lbl_reason.font constraintSize:CGSizeMake((kSCREEN_WIDTH-32)/3.0-18, CGFLOAT_MAX)];
    lbl_reason.frame = CGRectMake(kVIEW_BX(lbl_title)+9, 15, reasonsize.width, reasonsize.height);
    iv_reasonbg.frame = CGRectMake(kVIEW_BX(lbl_title), 10, validwidth, item.cellHeight-20);
    lbl_reason.center = iv_reasonbg.center;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ViewRatingItem *item = _sourceData[indexPath.row];
    return item.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 34.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 34)];
    view.backgroundColor = self.view.backgroundColor;
    UILabel *lbl_name = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, (kSCREEN_WIDTH-32)/3.0, 34)];
    lbl_name.text = @"用户名";
    lbl_name.textColor = kColorWithRGB(102,102,102,0.6);
    lbl_name.font = [UIFont systemFontOfSize:14.f];
    lbl_name.textAlignment = NSTextAlignmentCenter;
    [view addSubview:lbl_name];
    UILabel *lbl_scroce = [[UILabel alloc]initWithFrame:CGRectMake(kVIEW_BX(lbl_name), 0, (kSCREEN_WIDTH-32)/3.0, 34)];
    lbl_scroce.text = @"分值";
    lbl_scroce.textColor = kColorWithRGB(102,102,102,0.6);
    lbl_scroce.font = [UIFont systemFontOfSize:14.f];
    lbl_scroce.textAlignment = NSTextAlignmentCenter;
    [view addSubview:lbl_scroce];
    UILabel *lbl_reason = [[UILabel alloc]initWithFrame:CGRectMake(kVIEW_BX(lbl_scroce), 0, (kSCREEN_WIDTH-32)/3.0, 34)];
    lbl_reason.text = @"评分理由";
    lbl_reason.textColor = kColorWithRGB(102,102,102,0.6);
    lbl_reason.font = [UIFont systemFontOfSize:14.f];
    lbl_reason.textAlignment = NSTextAlignmentCenter;
    [view addSubview:lbl_reason];
    return view;
}

#pragma mark - 自定义方法
- (void)calculateCellHeight
{
    CGFloat validWidth = (kSCREEN_WIDTH-32)/3.0-18;
    for (ViewRatingItem *item in _sourceData) {
        NSString *reasonStr = (item.reason && item.reason.length>0) ? item.reason : @"没有理由哦~";
        CGSize size = [Util sizeWithString:reasonStr font:[UIFont systemFontOfSize:14.f] constraintSize:CGSizeMake(validWidth, CGFLOAT_MAX)];
        item.cellHeight = (size.height+10+20>=90.f) ? size.height+10+20 : 90.f;
    }
}
@end
