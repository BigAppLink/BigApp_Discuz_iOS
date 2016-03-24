//
//  CommentVC.m
//  Clan
//
//  Created by 昔米 on 15/11/24.
//  Copyright © 2015年 Youzu. All rights reserved.
//

#import "CommentVC.h"
#import "UIAlertView+BlocksKit.h"
#import "ComtFeildItem.h"
#import "NSObject+MJKeyValue.h"
//#import "IQTextView.h"
#import "UIPlaceHolderTextView.h"
#import "YZButton.h"
#import "UIAlertView+BlocksKit.h"
#import "PostDetailVC.h"

@interface CommentVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *sourceData;
@property (nonatomic, strong) BaseTableView *table;
@property (nonatomic, strong) UIPlaceHolderTextView *tv_viewpoint;

@end

@implementation CommentVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadmodel];
    [self buildUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    _table.delegate = nil;
    _table.dataSource = nil;
    _table = nil;
    DLog(@"CommentVC 销毁了");
}

#pragma mark - 初始化
- (void)loadmodel
{
    if (!_commentFeild || _commentFeild.count == 0) {
        WEAKSELF
        [UIAlertView bk_showAlertViewWithTitle:@"" message:@"信息有误，暂不能进行点评操作。" cancelButtonTitle:@"好" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
        return;
    }
    NSMutableArray *newFeild = [NSMutableArray new];
    for (NSDictionary *itemDic in _commentFeild) {
        ComtFeildItem *itemfeild = [ComtFeildItem objectWithKeyValues:itemDic];
        [newFeild addObject:itemfeild];
    }
    self.commentFeild = newFeild;
    _sourceData = [NSMutableArray new];
    NSMutableArray *tempArr = [NSMutableArray new];
    for (ComtFeildItem *item in _commentFeild) {
        if ([@"message" isEqualToString:item.fieldid]) {
            [_sourceData addObject:@[item]];
        } else {
            [tempArr addObject:item];
        }
    }
    if (tempArr.count > 0) {
        [_sourceData insertObject:tempArr atIndex:0];
    }
}

- (void)buildUI
{
    self.title = @"我要点评";
    
    UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.backgroundColor = [UIColor clearColor];
    leftButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
    leftButton.frame = CGRectMake(0, 0, 40, 26);
    [leftButton setTitle:@"提 交" forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(commitAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    
    BaseTableView *table = [[BaseTableView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
    table.delegate = self;
    table.dataSource = self;
    table.separatorColor = kfsc_table_border;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.table = table;
    [self.view addSubview:table];
    
    _tv_viewpoint = [[UIPlaceHolderTextView alloc]initWithFrame:CGRectMake(8, 0, kSCREEN_WIDTH-16, 286/2.0)];
    _tv_viewpoint.placeholder = @"点评观点";
    _tv_viewpoint.font = [UIFont systemFontOfSize:14.f];
}

#pragma mark - uitablview delegate & datasources

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sourceData.count == 0 ? 0 : _sourceData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == _sourceData.count) {
        return 1;
    }
    NSArray *arr = _sourceData[section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == _sourceData.count) {
        //提交按钮
       UITableViewCell *commitcell = [[UITableViewCell alloc]init];
        commitcell.textLabel.text = @"提交";
        commitcell.textLabel.textAlignment = NSTextAlignmentCenter;
        commitcell.textLabel.textColor = [Util mainThemeColor];
        commitcell.textLabel.font = [UIFont systemFontOfSize:17.f];
        return commitcell;
    }
    NSArray *arr = _sourceData[indexPath.section];
    ComtFeildItem *item = arr[indexPath.row];
    if ([item.fieldid isEqualToString:@"message"]) {
        //点评观点评论框
        UITableViewCell *cell = [[UITableViewCell alloc]init];
        [cell.contentView addSubview:_tv_viewpoint];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else {
        static NSString *identifer = @"commentfeildCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UIView *iconview = [[UIView alloc]initWithFrame:CGRectMake(8, 0, 5*40, 35)];
            iconview.tag = 1100;
            [cell.contentView addSubview:iconview];
            for (int i = 0; i < 5; i++) {
                YZButton *btn = [[YZButton alloc]initWithFrame:CGRectMake(i*40, 0, 40, 35)];
                btn.tabIndex = i+1;
                btn.tag = 2000+i;
                [btn setImage:kIMG(@"comt_icon_n") forState:UIControlStateNormal];
                [iconview addSubview:btn];
                [btn addTarget:self action:@selector(lightAction:) forControlEvents:UIControlEventTouchUpInside];
            }
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(kVIEW_BX(iconview), 0, kSCREEN_WIDTH-kVIEW_W(iconview)-8-16, 35)];
            titleLabel.textAlignment = NSTextAlignmentRight;
            titleLabel.tag = 1111;
            titleLabel.font = [UIFont systemFontOfSize:14.f];
            titleLabel.textColor = UIColorFromRGB(0x666666);
            [cell.contentView addSubview:titleLabel];
        }
        for (int i = 0; i < 5; i++) {
            YZButton *btn = [cell.contentView viewWithTag:2000+i];
            if (btn) {
                btn.path = indexPath;
                if (item.inputValue && item.inputValue.intValue > 0) {
                    NSString *imgName = (btn.tabIndex <= item.inputValue.intValue) ? @"comt_icon_h" : @"comt_icon_n";
                    [btn setImage:kIMG(imgName) forState:UIControlStateNormal];
                } else {
                    [btn setImage:kIMG(@"comt_icon_n") forState:UIControlStateNormal];
                }
            }
        }
        UIView *iconview = [cell.contentView viewWithTag:1100];
        UILabel *lbl_title = [cell.contentView viewWithTag:1111];
        lbl_title.text = item.title;
        CGFloat iconY = 0;
        if (arr.count == 1) {
            iconY = (88-35)/2;

        } else {
            if (indexPath.row > 0 && indexPath.row < arr.count-1) {
                iconY = (44-35)/2;
            }
            else if (indexPath.row == 0) {
                iconY = 22+(44-35)/2;
            }
            else {
                iconY = (44-35)/2;
            }
        }
        iconview.frame = CGRectMake(8, iconY, 5*40, 35);
        lbl_title.frame = CGRectMake(kVIEW_BX(iconview), iconY, kSCREEN_WIDTH-kVIEW_W(iconview)-8-16, 35);
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == _sourceData.count) {
        //提交按钮
        return 50.f;
    }
    NSArray *arr = _sourceData[indexPath.section];
    ComtFeildItem *item = arr[indexPath.row];
    if ([item.fieldid isEqualToString:@"message"]) {
        //点评观点评论框
        return 286/2.0;
    }
    else {
        if (arr.count == 1) {
            return 88;
        } else {
            if (indexPath.row > 0 && indexPath.row < arr.count-1) {
                return 44.f;
            }
            else {
                return 44+22;
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.f;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
////    [self commitAction];
//}

#pragma mark - action
- (IBAction)lightAction:(id)sender
{
    YZButton *btn = (YZButton *)sender;
    if (btn) {
        NSIndexPath *path = btn.path;
        NSArray *arr = _sourceData[path.section];
        ComtFeildItem *item = arr[path.row];

        if (btn.tabIndex && btn.tabIndex == 1) {
            if (item.inputValue && item.inputValue.intValue == 1) {
                item.inputValue = nil;
                [_table reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
                return;
            }
        }
        item.inputValue = (btn.tabIndex && btn.tabIndex>0) ? [NSString stringWithFormat:@"%ld",btn.tabIndex] : nil;
        [_table reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)commitAction
{
    BOOL hasData = NO;
    for (ComtFeildItem *item in _commentFeild) {
        if (![item.fieldid isEqualToString:@"message"]) {
            if (item.inputValue && item.inputValue.intValue > 0) {
                hasData = YES;
                break;
            }
        } else {
            if (_tv_viewpoint.text && _tv_viewpoint.text.length > 0) {
                item.inputValue = _tv_viewpoint.text;
                hasData = YES;
            }
        }
    }
    if (hasData) {
        NSMutableDictionary *paraDic = [NSMutableDictionary new];
        for (ComtFeildItem *item in _commentFeild) {
            [paraDic setObject:item.inputValue ? item.inputValue : @"0" forKey:item.fieldid];
        }
        //可以提交了
        [self showProgressHUDWithStatus:@"" withLock:YES];
        WEAKSELF
        [[Clan_NetAPIManager sharedManager] request_addPostCommentWithTid:_tid withPid:_pid withParas:paraDic andBlock:^(id data, NSError *error) {
            [weakSelf dissmissProgress];
            DLog(@"----- data");
            if (data && [data valueForKey:@"Message"]) {
                NSDictionary *dic = [data valueForKey:@"Message"];
                NSString *messVal = dic[@"messageval"];
                NSString *messTip = dic[@"messagestr"];
                if (messTip) {
                    [weakSelf showHudTipStr:messTip];
                }
                if (messVal && [messVal isEqualToString:@"comment_add_succeed"]) {
                    //帖子点评申请成功
                    [weakSelf showHudTipStr:messTip];
                    if (weakSelf.navigationController) {
                        //把当前页面销毁 返回上一个页面
                        if (weakSelf.targetVC && [weakSelf.targetVC isKindOfClass:[PostDetailVC class]]) {
                            PostDetailVC *vc = (PostDetailVC *)weakSelf.targetVC;
                            [vc commentPostSuccess:data];
                        }
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }
                }
            } else {
                [weakSelf showHudTipStr:@"帖子点评失败，请检查网络重试"];
            }
        }];
    } else {
        [self showHudTipStr:@"请发表观点或至少选择一项进行点评"];
    }
}

@end
