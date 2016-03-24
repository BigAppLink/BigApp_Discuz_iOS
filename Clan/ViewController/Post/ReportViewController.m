//
//  ReportViewController.m
//  Clan
//
//  Created by chivas on 15/8/4.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ReportViewController.h"
#import "PostDetailModel.h"
#import "PostDetailViewModel.h"
@interface ReportViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *dataArray;
@property (assign, nonatomic) NSInteger selectIndex;
@property (strong, nonatomic) UIButton *submitBtn;
@property (strong, nonatomic) PostDetailViewModel *postDetailViewModel;
@property (copy, nonatomic) NSString *messageString;
@property (strong, nonatomic) UITextField *textField;

@end

@implementation ReportViewController

- (void)setReportModel:(Report *)reportModel
{
    _reportModel = reportModel;
    _dataArray = reportModel.content;
    if (!_dataArray || _dataArray.count == 0) {
        _dataArray = [NSArray arrayWithObjects:@"广告垃圾", @"违规内容",@"恶意灌水",@"重复发帖",@"其他", nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _messageString = nil;
    _selectIndex = -1;
    if (!_postDetailViewModel) {
        _postDetailViewModel = [PostDetailViewModel new];
    }
    if (!_dataArray || _dataArray.count == 0) {
        _dataArray = [NSArray arrayWithObjects:@"广告垃圾", @"违规内容",@"恶意灌水",@"重复发帖",@"其他", nil];
    }
    //如果是用户举报状态
    if (_state == ClanReportUser) {
        _dataArray = @[@"色情低俗",@"广告骚扰",@"政治敏感",@"谣言",@"欺诈骗钱",@"违法(暴力恐怖、违禁品等)"];
    }else if (_state == ClanActivityPost) {
        _dataArray = _activityArray;
    }
    _tableView = ({
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)style:UITableViewStyleGrouped];
        tableView.backgroundColor = UIColorFromRGB(0xf3f3f3);
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView;
    });
    
    [self.view addSubview:_tableView];
    //设置footerview
    [self submitWithFooterView];
    if (!_messageString) {
        _submitBtn.enabled = NO;
    }
    self.view.backgroundColor = UIColorFromRGB(0xf3f3f3);
    if (_state == ClanActivityPost) {
        self.navigationItem.title = @"活动类型";
    }else{
        self.navigationItem.title = @"举报";
    }
}

#pragma mark - footview 提交按钮
- (void)submitWithFooterView
{
    UIView *footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 90)];
    _submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _submitBtn.frame = CGRectMake(21, 22, ScreenWidth-42, 46);
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 5, 0, 5);
    UIImage *image = kIMG(@"anniu");
    image = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    [_submitBtn setBackgroundImage:image forState:UIControlStateNormal];
    [_submitBtn setTitleColor:[UIColor returnColorWithPlist:YZSegMentColor] forState:UIControlStateNormal];
    [_submitBtn setTitle:@"提交" forState:UIControlStateNormal];
    [_submitBtn addTarget:self action:@selector(reportAction) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:_submitBtn];
    _tableView.tableFooterView = footView;
}

#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_state == ClanActivityPost) {
        return 2;
    }
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _dataArray.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = _dataArray[indexPath.row];
            cell.textLabel.textColor = UIColorFromRGB(0x424242);
            cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
        }
        cell.accessoryType = _selectIndex == indexPath.row? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        return cell;
    }else{
        static NSString *CellIdentifier1 = @"Cell1";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
            _textField = [[UITextField alloc]initWithFrame:CGRectMake(15, 0, ScreenWidth-15, 44)];
            _textField.delegate = self;
            [_textField addTarget:self action:@selector(textFieldAction:) forControlEvents:UIControlEventEditingChanged];
            _textField.textColor = UIColorFromRGB(0x424242);
            _textField.font = [UIFont systemFontOfSize:15.0f];
            _textField.placeholder = @"自定义类型";
            [cell.contentView addSubview:_textField];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 41)];
        UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 20, ScreenWidth-15, 17)];
        if (_state == ClanActivityPost) {
            textLabel.text = @"请选择活动类型";
        }else{
            textLabel.text = @"请选择举报理由";
        }
        textLabel.textColor = UIColorFromRGB(0xa6a6a6);
        textLabel.font = [UIFont systemFontOfSize:14.0f];
        [headerView addSubview:textLabel];
        return headerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 41.f : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if ([_textField isFirstResponder]) {
            [_textField resignFirstResponder];
        }
        _selectIndex = indexPath.row;
        _messageString = _dataArray[indexPath.row];
        if (_messageString && _messageString.length > 0) {
            _submitBtn.enabled = YES;
        }
        [self.tableView reloadData];
    }
}

#pragma mark - 自定义类型
- (void)textFieldAction:(UITextField *)textField{
    
    _messageString = textField.text;
    _submitBtn.enabled = _messageString.length > 0;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    _selectIndex = -1;
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
    [_tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];

    return YES;
}
#pragma mark - 请求接口
- (void)reportAction
{
    if (_state == ClanActivityPost) {
        if ([self.delegate respondsToSelector:@selector(postActivityType:)]) {
            [self.delegate postActivityType:_messageString];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        if (_state == ClanReportTPost || _state == ClanReportUser) {
            [self showHudTipStr:@"举报成功"];
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        if ([Util isNetWorkAvalible]) {
            if (!_reportModel.tid || _reportModel.tid.length == 0 || !_reportModel.fid || _reportModel.fid.length == 0) {
                [self showHudTipStr:@"举报成功"];
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
        } else {
            [self showHudTipStr:@"请检查网络设置"];
            return;
        }
        WEAKSELF
        [_postDetailViewModel request_reporeWithTid:_reportModel.tid andFid:_reportModel.fid andReport_select:_messageString andMessage:_messageString andHandlekey:_reportModel.handlekey andBlock:^(BOOL success, id DataBase) {
            if (success) {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
    
}

- (void)dealloc{
    DebugLog(@"dismiss report");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
