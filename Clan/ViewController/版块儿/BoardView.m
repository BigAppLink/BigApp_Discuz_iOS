//
//  BoardView.m
//  Clan
//
//  Created by 昔米 on 15/7/22.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "BoardView.h"
#import "HomeViewModel.h"
#import "BoardCell.h"
#import "BoardModel.h"
#import "BaseTableView.h"
#import "PostViewController.h"
#import "UIScrollView+MJRefresh.h"
#import "UIView+Additions.h"

@implementation BoardView

- (id)init
{
    self = [super init];
    if (self) {
        //初始化工作
        [self buildUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //初始化工作
        [self buildUI];
    }
    return self;
}

- (void)dealloc
{
    DLog(@"BoardView dealloc");
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)doViewAppear
{
    if (_toBeReloadPath) {
        [self.tableView deselectRowAtIndexPath:_toBeReloadPath animated:YES];
        _toBeReloadPath = nil;
    }
}

//初始化
- (void)buildUI
{
    if (!_tableView) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCome:) name:@"Board_PullDown_Completed" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCome:) name:@"BoardTabControllerAppear" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationCome:) name:@"AUTO_REFRESH_BANKUAI" object:nil];

        _tableView = [[BaseTableView alloc]initWithFrame:CGRectMake(0, 0, kVIEW_W(self), kVIEW_H(self)) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = kCLEARCOLOR;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        WEAKSELF
        [_tableView addLegendHeaderWithRefreshingBlock:^{
            [weakSelf doPullDownRefresh];
        }];
        self.tableView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_tableView];
        [Util setExtraCellLineHidden:_tableView];
    }
}

- (void)doPullDownRefresh
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Board_PullDown_Trigger" object:nil];
}

- (void)notificationCome:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"Board_PullDown_Completed"]) {
        [self.tableView endHeaderRefreshing];
    }
    else if ([noti.name isEqualToString:@"BoardTabControllerAppear"]) {
        [self doViewAppear];
    }
    else if ([noti.name isEqualToString:@"AUTO_REFRESH_BANKUAI"]) {
        [self.tableView beginRefreshing];
    }
}


#pragma mark Table M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _board.forums.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, section == 0 ? 31 : 43)];
//    view.backgroundColor = kCOLOR_BG_GRAY;
//    UIView *whitebg = [UIView new];
//    whitebg.backgroundColor = [UIColor whiteColor];
//    [view addSubview:whitebg];
//    [whitebg mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(view.mas_leading);
//        make.trailing.equalTo(view.mas_trailing);
//        make.height.equalTo(@31);
//        make.bottom.equalTo(view.mas_bottom);
//    }];
//    UILabel *label = [UILabel new];
//    label.font = [UIFont fontWithSize:12.f];
//    label.textColor = K_COLOR_DARK_Cell;
//    label.text = [_dataArray[section]name];
//    [view addSubview:label];
//    [label mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(view.mas_leading).offset(15);
//        make.trailing.equalTo(view.mas_trailing).offset(-10);
//        make.height.equalTo(@31);
//        make.bottom.equalTo(view.mas_bottom);
//    }];
//    UIView *line = [UIView new];
//    line.backgroundColor = K_COLOR_MOST_LIGHT_GRAY;
//    [view addSubview:line];
//    [line mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(view.mas_leading).offset(15);
//        make.trailing.equalTo(view.mas_trailing);
//        make.bottom.equalTo(view.mas_bottom).offset(0);
//        make.height.equalTo(@(0.5));
//    }];
//    return view;
//    //    UIView *view = [UIView new];
//    //    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, kSCREEN_WIDTH-30, 30.f)];
//    //    nameLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_NORMAL];
//    //    nameLabel.textColor = K_COLOR_LIGHTGRAY;
//    //    nameLabel.text = [_dataArray[section]name];
//    //    [view addSubview:nameLabel];
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static   NSString *CellIdentifier10 = @"subjectDetail";
    
    BoardCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier10];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"BoardCell" owner:self options:nil] lastObject];
//        [cell.countLabel removeConstraint:cell.rightConstraint];
    }
    cell.forumsModel = _board.forums[indexPath.row];
//    cell.iv_line.hidden = (indexPath.row == _board.forums.count-1) ? YES : NO;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *forums = _board.forums;
    PostViewController *postVc = [[PostViewController alloc]init];
    postVc.hidesBottomBarWhenPushed = YES;
    postVc.forumsModel = forums[indexPath.row];
    _toBeReloadPath = indexPath;
//    [self.navigationController pushViewController:postVc animated:YES];
    [self.additionsViewController.navigationController pushViewController:postVc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 74;
}

- (void)setBoard:(BoardModel *)board
{
    _board = board;
    [self.tableView reloadData];
}

@end
