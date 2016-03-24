//
//  ManageActivityVC.m
//  Clan
//
//  Created by 昔米 on 15/11/19.
//  Copyright © 2015年 Youzu. All rights reserved.
//

#import "ManageActivityVC.h"
#import "ApplyActItemCell.h"
#import "UIAlertView+BlocksKit.h"
#import "ApplyActivityItem.h"
#import "NSObject+MJKeyValue.h"
#import "MeViewController.h"

@interface ManageActivityVC () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) BaseTableView *table;
@property (strong, nonatomic) NSIndexPath *expandIndex;
@property (strong, nonatomic) NSMutableArray *selectIDs;
@property (strong, nonatomic) UITextView *tempView;
@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UIButton *agreeButton;
@property (strong, nonatomic) UIButton *refuseButton;
@end

@implementation ManageActivityVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadModal];
    [self buildUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    DLog(@"ManageActivityVC dealloc");
    _table.delegate = nil;
    _table.dataSource = nil;
    _table = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //页面结束
    [self.view endEditing:YES];
}


#pragma mark - 初始化
- (void)loadModal
{
    if (!_tid || !_fid || !_pid) {
        WEAKSELF
        [UIAlertView bk_showAlertViewWithTitle:@"" message:@"抱歉,活动信息出错了" cancelButtonTitle:@"返回" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
        return;
    }
    self.selectIDs = [NSMutableArray new];

}

- (void)buildUI
{
    self.title = @"管理活动";
    BaseTableView *table = [[BaseTableView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = self.view.backgroundColor;
    table.separatorColor = kfsc_table_border;
    self.table = table;
    [self.view addSubview:table];
    WEAKSELF
    [_table createHeaderViewBlock:^{
        [weakSelf requestData];
    }];
    [self setupBottomView];
    [self showProgressHUDWithStatus:@"" withLock:YES];
    [_table beginRefreshing];
}

////    NSString *htmlString = @"<h1>Header</h1><h2>Subheader</h2><p>Some <em>text</em></p><img src='http://blogs.babble.com/famecrawler/files/2010/11/mickey_mouse-1097.jpg' width=70 height=100 />";

//底部UI
- (void)setupBottomView
{
    self.bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, kSCREEN_HEIGHT, kSCREEN_WIDTH, 50.f)];
    self.bottomView.backgroundColor = kUIColorFromRGB(0xf6fbfa);
    [self.view addSubview:_bottomView];
    
    self.agreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.agreeButton.frame = CGRectMake(0, 0, kVIEW_W(_bottomView)/2, 50.f);
    [self.agreeButton.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
    [self.agreeButton setTitleColor:kUIColorFromRGB(0x666666) forState:UIControlStateNormal];
    [self.agreeButton setImage:kIMG(@"act_agree") forState:UIControlStateNormal];
    [self.agreeButton setTitle:@" 批准" forState:UIControlStateNormal];
    [self.agreeButton addTarget:self action:@selector(agreeAction) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_agreeButton];
    
    self.refuseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.refuseButton.frame = CGRectMake(kVIEW_BX(_agreeButton), 0, kVIEW_W(_bottomView)/2, 50.f);
    [self.refuseButton.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
    [self.refuseButton setTitleColor:kUIColorFromRGB(0x666666) forState:UIControlStateNormal];
    [self.refuseButton setImage:kIMG(@"act_refuse") forState:UIControlStateNormal];
    [self.refuseButton setTitle:@" 拒绝" forState:UIControlStateNormal];
    [self.refuseButton addTarget:self action:@selector(refuseAction) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_refuseButton];
    
    //分割线
    UIView *serpr = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0.5, 38/2)];
    serpr.center = CGPointMake(kVIEW_W(_bottomView)/2, 50/2);
    serpr.backgroundColor = kUIColorFromRGB(0x999999);
    [_bottomView addSubview:serpr];
    
    //顶上的线
    UIView *topserpr = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kVIEW_W(_bottomView), 0.5)];
    topserpr.backgroundColor = kUIColorFromRGB(0xefefef);
    [_bottomView addSubview:topserpr];
}

#pragma mark - request Data
- (void)requestData
{
    WEAKSELF
    [[Clan_NetAPIManager sharedManager] request_activityApplyListWithTid:_tid
                                                                 withPid:_pid
                                                                 withfid:_fid
                                                                andBlock:^(id data, NSError *error) {
                                                                    [weakSelf dissmissProgress];
                                                                    [weakSelf.table endHeaderRefreshing];
                                                                    if (data) {
                                                                        NSDictionary *MessDic = [data valueForKey:@"Message"];
                                                                        NSString *messVal = MessDic[@"messageval"];
                                                                        NSString *messTip = MessDic[@"messagestr"];
                                                                        if (messVal && messTip) {
                                                                            [weakSelf showHudTipStr:messTip];
                                                                            return ;
                                                                        }
                                                                        NSDictionary *varDic = [data valueForKey:@"Variables"];
                                                                        NSArray *arrData = varDic[@"applylist"];
                                                                        NSMutableArray *Arr = [NSMutableArray new];
                                                                        for (id obj in arrData) {
                                                                            if (obj && [obj isKindOfClass:[NSDictionary class]]) {
                                                                                ApplyActivityItem *applyItem = [ApplyActivityItem objectWithKeyValues:obj];
                                                                                [Arr addObject:applyItem];
                                                                            }
                                                                        }
                                                                        weakSelf.sourceData = [[NSArray alloc]initWithArray:Arr];
                                                                        if (Arr.count > 0) {
                                                                            [weakSelf resetAllItemsCellHeight];
                                                                            if (weakSelf.sourceData.count > 0) {
                                                                                [weakSelf showBottomView];
                                                                            } else {
                                                                                [weakSelf dissmissBottomView];
                                                                            }
                                                                        }
                                                                        [weakSelf.selectIDs removeAllObjects];
                                                                        [weakSelf disableBottomViewButton];
                                                                        weakSelf.expandIndex = nil;
                                                                        [weakSelf.table reloadData];
                                                                        [weakSelf.view configBlankPage:DataIsNothingWithDefault hasData:arrData.count > 0 hasError:NO reloadButtonBlock:^(id sender) {
                                                                            [weakSelf requestData];
                                                                        }];
                                                                    }
    }];
}

#pragma mark - 自定义方法
- (void)showBottomView
{
    CGRect bottomRect = _bottomView.frame;
    if (bottomRect.origin.y <= kSCREEN_HEIGHT-64-50.f) {
        return;
    }
    
    bottomRect.origin.y = kSCREEN_HEIGHT-64-50.f;
    CGRect tableviewRect = _table.frame;
    tableviewRect.size.height -= 50;
    [UIView animateWithDuration:0.25 animations:^{
        _bottomView.frame = bottomRect;
        _table.frame = tableviewRect;
    } ];
}

- (void)dissmissBottomView
{
    CGRect bottomRect = _bottomView.frame;
    if (bottomRect.origin.y >= kSCREEN_HEIGHT) {
        return;
    }
    bottomRect.origin.y = kSCREEN_HEIGHT;
    CGRect tableviewRect = _table.frame;
    tableviewRect.size.height += 50;
    [UIView animateWithDuration:0.25 animations:^{
        _bottomView.frame = bottomRect;
        _table.frame = tableviewRect;
    }];
}

- (void)disableBottomViewButton
{
    [self.agreeButton setTitleColor:kUIColorFromRGB(0x666666) forState:UIControlStateNormal];
    [self.agreeButton setImage:kIMG(@"act_agree") forState:UIControlStateNormal];
    [self.refuseButton setTitleColor:kUIColorFromRGB(0x666666) forState:UIControlStateNormal];
    [self.refuseButton setImage:kIMG(@"act_refuse") forState:UIControlStateNormal];
    self.agreeButton.enabled = NO;
    self.refuseButton.enabled = NO;
}

- (void)enableBottomViewButton
{
    [self.agreeButton setTitleColor:[Util mainThemeColor] forState:UIControlStateNormal];
    [self.agreeButton setImage:[[UIImage imageNamed:@"act_agree"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.refuseButton setTitleColor:[Util mainThemeColor] forState:UIControlStateNormal];
    [self.refuseButton setImage:[[UIImage imageNamed:@"act_refuse"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.agreeButton.enabled = YES;
    self.refuseButton.enabled = YES;
}

//提前计算cell的高度
- (void)resetAllItemsCellHeight
{
    for (ApplyActivityItem *item in _sourceData) {
        //把留言信息拼进去
        NSString *message = [NSString stringWithFormat:@"<li>留言信息  :  %@</li>",item.message];
        item.ufielddata = [item.ufielddata stringByAppendingString:message];
    }
    //根据textview自适应 去计算html内容的高度
    if (!_tempView) {
        UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(55, 0, kSCREEN_WIDTH-55-16, 100)];
        textView.selectable = YES;
        textView.dataDetectorTypes = UIDataDetectorTypeLink;
        [textView setEditable:NO];
        self.tempView = textView;
        textView.hidden = YES;
        [self.view addSubview:textView];
    }
    for (ApplyActivityItem *applyitem in self.sourceData) {
        NSString *htmlStr = applyitem.ufielddata;
        htmlStr = [htmlStr stringByAppendingString:@"<style>body{font-size:14px;color:#303030;}</style>"];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithData:[htmlStr dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        _tempView.attributedText = attributedString;
        [_tempView sizeToFit];
        CGRect rect = _tempView.bounds;
        if (rect.size.height <= 100.f) {
            //隐藏展开按钮
            applyitem.normalHeight = 45+rect.size.height+5;
            applyitem.expandedHeight = 45+rect.size.height+5;
        } else {
            applyitem.expandedHeight = 45+rect.size.height+34+5;
            applyitem.normalHeight = 45+100+35+5;
        }
    }
    [_tempView removeFromSuperview];
    _tempView = nil;
}

#pragma mark - tableview 代理方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sourceData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifer = @"ManageActivityCell";
    ApplyActItemCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell) {
        cell = [[ApplyActItemCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.btn_expand addTarget:self action:@selector(expandCellAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btn_select addTarget:self action:@selector(selectCellAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btn_name addTarget:self action:@selector(selectNameAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    cell.path = indexPath;
    ApplyActivityItem *item = _sourceData[indexPath.section];
    cell.applyitem = item;
    cell.itemSleceted = [_selectIDs containsObject:item.applyid];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
     ApplyActivityItem *applyitem = _sourceData[indexPath.section];
    CGFloat height = applyitem.expanded ? applyitem.expandedHeight : applyitem.normalHeight;
    return height;
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.f;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

#pragma mark - Action methods
- (IBAction)expandCellAction:(id)sender
{
    YZButton *expandBtn = sender;
    NSIndexPath *selectPath = expandBtn.path;
    NSIndexPath *pre = _expandIndex;
    ApplyActivityItem *item = _sourceData[selectPath.section];
    item.expanded = !item.expanded;
    if (pre && selectPath.section == pre.section && selectPath.row == pre.row) {
        self.expandIndex = nil;
        [self.table reloadRowsAtIndexPaths:@[pre] withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }
    self.expandIndex = selectPath;
    if (pre) {
        ApplyActivityItem *item = _sourceData[pre.section];
        item.expanded = !item.expanded;
        [self.table reloadRowsAtIndexPaths:@[pre, selectPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    } else {
        [self.table reloadRowsAtIndexPaths:@[selectPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (IBAction)selectCellAction:(id)sender
{
    YZButton *selectBtn = sender;
    NSIndexPath *path = selectBtn.path;
    ApplyActivityItem *item = _sourceData[path.section];
    if ([_selectIDs containsObject:item.applyid]) {
        [_selectIDs removeObject:item.applyid];
        [selectBtn setImage:kIMG(@"act_select_n") forState:UIControlStateNormal];
    } else {
        [_selectIDs addObject:item.applyid];
        [selectBtn setImage:[[UIImage imageNamed:@"act_select_h"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    }
    if (_selectIDs.count > 0) {
        [self enableBottomViewButton];
    } else {
        [self disableBottomViewButton];
    }
}

- (IBAction)selectNameAction:(id)sender
{
    YZButton *selectBtn = sender;
    NSIndexPath *path = selectBtn.path;
    ApplyActivityItem *item = _sourceData[path.section];
    MeViewController *home = [[MeViewController alloc]init];
    home.hidesBottomBarWhenPushed = YES;
    UserModel *user = [UserModel new];
    user.uid = item.uid;
    user.username = item.username;
    home.user = user;
    [self.navigationController pushViewController:home animated:YES];
}

- (void)agreeAction
{
    if (_tid && _tid.length > 0) {
        NSArray *arr = [[NSArray alloc]initWithArray:_selectIDs];
        [self showProgressHUDWithStatus:@"" withLock:YES];
        WEAKSELF
        [[Clan_NetAPIManager sharedManager] request_agreeActivityApplyForapplyids:arr withTid:_tid withReason:@"同意了" andBlock:^(id data, NSError *error) {
            [weakSelf dissmissProgress];
            if (data) {
                NSDictionary *messDic = [data valueForKey:@"Message"];
                NSString *messVal = messDic[@"messageval"];
                NSString *messTip = messDic[@"messagestr"];
                [weakSelf showHudTipStr:messTip];
                if (messVal && [@"activity_auditing_completion" isEqualToString:messVal]) {
                    //活动申请成功
                    for (ApplyActivityItem *item in weakSelf.sourceData) {
                        if ([weakSelf.selectIDs containsObject:item.applyid]) {
                            //状态更新为已通过审核
                            item.verified = @"1";
                        }
                    }
                    [weakSelf.selectIDs removeAllObjects];
                    [weakSelf disableBottomViewButton];
                    [weakSelf.table reloadData];
//                    [weakSelf dissmissBottomView];
                }
            } else {
                [weakSelf showHudTipStr:@"出错了,请重试"];
            }
        }];
    } else {
        [self showHudTipStr:@"您的信息出错了，请返回"];
    }
}

- (void)refuseAction
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请选择" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"打回完善资料", @"直接拒绝", nil];
    alert.tag = 8899;
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alert textFieldAtIndex:0] setPlaceholder:@"拒绝活动申请的理由~"];
    [alert textFieldAtIndex:0].tintColor = [Util mainThemeColor];
    [[alert textFieldAtIndex:0] setClearButtonMode:UITextFieldViewModeWhileEditing];
    [alert show];
}

#pragma mark - UIAlertView 代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 8899) {
        NSString *reason = [alertView textFieldAtIndex:0].text;
        if (buttonIndex == 1) {
            //打回完善资料
            reason = (reason && reason.length > 0) ? reason : @"资料不完善，请完善";
            [self showProgressHUDWithStatus:@"" withLock:YES];
            WEAKSELF
            [[Clan_NetAPIManager sharedManager]request_replenishActivityApplyForapplyids:_selectIDs withTid:_tid withReason:reason andBlock:^(id data, NSError *error) {
                [weakSelf dissmissProgress];
                if (data) {
                    NSDictionary *messDic = [data valueForKey:@"Message"];
                    NSString *messVal = messDic[@"messageval"];
                    NSString *messTip = messDic[@"messagestr"];
                    [weakSelf showHudTipStr:messTip];
                    if (messVal && [@"activity_auditing_completion" isEqualToString:messVal]) {
                        for (ApplyActivityItem *item in weakSelf.sourceData) {
                            if ([weakSelf.selectIDs containsObject:item.applyid]) {
                                //状态更新为已打回完善资料
                                item.verified = @"2";
                            }
                        }
                        [weakSelf.selectIDs removeAllObjects];
                        [weakSelf disableBottomViewButton];
                        [weakSelf.table reloadData];
//                        [weakSelf dissmissBottomView];
                    }
                }
            }];
        }
        else if (buttonIndex == 2) {
            //拒绝活动申请
            reason = (reason && reason.length > 0) ? reason : @"拒绝参加活动";
            [self showProgressHUDWithStatus:@"" withLock:YES];
            WEAKSELF
            [[Clan_NetAPIManager sharedManager]request_refuseActivityApplyForapplyids:_selectIDs withTid:_tid withReason:reason andBlock:^(id data, NSError *error) {
                [weakSelf dissmissProgress];
                if (data) {
                    NSDictionary *messDic = [data valueForKey:@"Message"];
                    NSString *messVal = messDic[@"messageval"];
                    NSString *messTip = messDic[@"messagestr"];
                    [weakSelf showHudTipStr:messTip];
                    if (messVal && [@"activity_delete_completion" isEqualToString:messVal]) {
                        NSMutableArray *arr = [[NSMutableArray alloc]initWithArray:weakSelf.sourceData];
                        for (ApplyActivityItem *item in arr) {
                            if ([weakSelf.selectIDs containsObject:item.applyid]) {
                                //状态更新为已打回完善资料
                                [arr removeObject:item];
                            }
                        }
                        weakSelf.sourceData = [[NSArray alloc]initWithArray:arr];
                        [weakSelf.selectIDs removeAllObjects];
                        [weakSelf disableBottomViewButton];
                        [weakSelf.table reloadData];
//                        [weakSelf dissmissBottomView];
                    }
                }
            }];
        }
    }
}

@end
