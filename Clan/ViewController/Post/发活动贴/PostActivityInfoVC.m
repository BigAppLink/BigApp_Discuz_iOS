//
//  PostActivityInfoVC.m
//  Clan
//
//  Created by chivas on 15/10/28.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "PostActivityInfoVC.h"
#import "TPKeyboardAvoidingTableView.h"
#import "YZDataPicker.h"
#import "ReportViewController.h"
#import "postActivityModel.h"
#import "ForumsModel.h"
#import "PostActivitySelectCell.h"
#import "PostSendModel.h"
#import "PostActivityModel.h"
#import "PostActivityExpandCell.h"
@interface PostActivityInfoVC ()<UITableViewDataSource,UITableViewDelegate,YZDataPickerDelegate,PostActivityDelegate,ActivitySelectInfoDelegate,ActivityExpandDelegate>
@property (strong, nonatomic) TPKeyboardAvoidingTableView *tableView;
@property (strong, nonatomic) NSMutableArray *tableTitleArray;
@property (copy, nonatomic) NSString *forumsString;
@property (copy, nonatomic) NSString *activityName;
@property (copy, nonatomic) NSString *activityTime;
@property (copy, nonatomic) NSString *activityAddress;
@property (copy, nonatomic) NSString *activityType;
@property (strong, nonatomic) UITextField *activityTimeTextField;
@property (strong, nonatomic) UITextField *activityAddressTextField;
@property (strong, nonatomic) PostActivitySelectCell *tempCell;
@property (strong, nonatomic) PostSendModel *sendModel;
@property (strong, nonatomic) YZDataPicker *dataPicker;
@property (strong, nonatomic) NSMutableArray *userfieldArray;
@property (strong, nonatomic) SendActivity *sendActivityModel;
@end

@implementation PostActivityInfoVC
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_dataPicker remove];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //计算
    //初始化TableView Title
    [self initTableViewTitle];
    //创建TableView
    [self.view addSubview:self.tableView];
    //创建日期控件
    [self.view addSubview:self.dataPicker];
    //创建textfield
    [self addTextField];
    if (!_sendModel) {
        _sendModel = [PostSendModel new];
    }
    if (!_sendActivityModel) {
        _sendActivityModel = [SendActivity new];
    }
    
}

#pragma mark - 初始化TableView Title
- (void)initTableViewTitle{
    if (!_tableTitleArray) {
        _tableTitleArray = [NSMutableArray array];
    }
    [_tableTitleArray addObject:[@[@"名称"]mutableCopy]];
    [_tableTitleArray addObject:[@[@"时间",@"地点"]mutableCopy]];
    [_tableTitleArray addObject:[@[@"类别",@"必填资料项"]mutableCopy]];
    
}
#pragma mark - 创建tableview
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[TPKeyboardAvoidingTableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, self.view.bounds.size.height - 80 - 64) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.sectionFooterHeight = 0;
        _tableView.sectionHeaderHeight = 0;
        [_tableView registerClass:[PostActivitySelectCell class] forCellReuseIdentifier:@"PostActivitySelectCell"];
        [_tableView registerClass:[PostActivityExpandCell class] forCellReuseIdentifier:@"PostActivityExpandCell"];
        _tempCell = [_tableView dequeueReusableCellWithIdentifier:@"PostActivitySelectCell"];

    }
    return _tableView;
}

#pragma mark - 创建时间控件
- (YZDataPicker *)dataPicker{
    if (!_dataPicker) {
        _dataPicker = [[YZDataPicker alloc]init];
        _dataPicker.backgroundColor = [UIColor whiteColor];
        _dataPicker.delegate = self;
    }
    return _dataPicker;
}

#pragma mark - 创建输入框
- (void)addTextField{
    if (!_activityTimeTextField) {
        _activityTimeTextField = [[UITextField alloc]initWithFrame:CGRectMake(ScreenWidth-34-200, 0, 200, 44)];
        _activityTimeTextField.font = [UIFont systemFontOfSize:14.0f];
        _activityTimeTextField.tag = 5000;
        _activityTimeTextField.textAlignment = NSTextAlignmentRight;
        [_activityTimeTextField addTarget:self action:@selector(textFieldText:) forControlEvents:UIControlEventEditingChanged];
        _activityTimeTextField.placeholder = @"输入名称";
        [_activityTimeTextField setValue:UIColorFromRGB(0x999999) forKeyPath:@"_placeholderLabel.textColor"];
    }
    if (!_activityAddressTextField) {
        _activityAddressTextField = [[UITextField alloc]initWithFrame:CGRectMake(ScreenWidth-34-200, 0, 200, 44)];
        _activityAddressTextField.font = [UIFont systemFontOfSize:14.0f];
        [_activityAddressTextField addTarget:self action:@selector(textFieldText:) forControlEvents:UIControlEventEditingChanged];
        _activityAddressTextField.tag = 6000;
        _activityAddressTextField.textAlignment = NSTextAlignmentRight;
        _activityAddressTextField.placeholder = @"输入地点";
        [_activityAddressTextField setValue:UIColorFromRGB(0x999999) forKeyPath:@"_placeholderLabel.textColor"];
    }
    
}
#pragma mark - tableview代理
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (indexPath.section == 0) {
        static NSString *section1 = @"cell1";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:section1];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:section1];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            if (row == 0) {
//                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            }
        }
        UILabel *label = [self titleWithCellText:_tableTitleArray[section][row]];
        label.font = [UIFont systemFontOfSize:14.0f];
        label.textColor = UIColorFromRGB(0x303030);
        [cell.contentView addSubview:label];
        [cell.contentView addSubview:_activityTimeTextField];
        return cell;
    }else if (indexPath.section == 1){
        static NSString *section2 = @"cell2";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:section2];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:section2];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (row == 0) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        UILabel *label = [self titleWithCellText:_tableTitleArray[section][row]];
        label.font = [UIFont systemFontOfSize:14.0f];
        label.textColor = UIColorFromRGB(0x303030);
        [cell.contentView addSubview:label];
        if (row == 0) {
            cell.detailTextLabel.text = _activityTime ? :@"选择时间";
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0f];
            if (_activityTime) {
                cell.detailTextLabel.textColor = UIColorFromRGB(0x333333);
            }
        }else{
            [cell.contentView addSubview:_activityAddressTextField];
        }
        return cell;
    }else if (indexPath.section == 2){
        if (row == 0) {
            static NSString *section3 = @"cell3";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:section3];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:section3];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            UILabel *label = [self titleWithCellText:_tableTitleArray[section][row]];
            label.font = [UIFont systemFontOfSize:14.0f];
            label.textColor = UIColorFromRGB(0x303030);
            [cell.contentView addSubview:label];
            cell.detailTextLabel.text = _activityType ? :@"选择类别";
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0f];
            if (_activityType) {
                cell.detailTextLabel.textColor = UIColorFromRGB(0x333333);
            }
            return cell;    
        }else if(row == 1){
            PostActivitySelectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostActivitySelectCell" forIndexPath:indexPath];
            cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.selectArray = _forumModel.postActivityModel.activityfield;
            return cell;
        }else if (row == 2){
            PostActivityExpandCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostActivityExpandCell" forIndexPath:indexPath];
            cell.activityextnum = _forumModel.postActivityModel.activityextnum;
            cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        if (indexPath.row == 1) {
            if (_forumModel.postActivityModel.activityfield.count > 0) {
                return [_tempCell heightWithSelectCell:_forumModel.postActivityModel.activityfield];
            }else{
                return 0;
            }
        }else if (indexPath.row == 2){
            return _forumModel.postActivityModel.activityextnum.integerValue>0 ? 150: 0;
        }
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [_dataPicker show];
        }
    }else if (indexPath.section == 2){
        if (indexPath.row == 0) {
            ReportViewController *activityTypeVc = [[ReportViewController alloc]init];
            activityTypeVc.delegate = self;
            activityTypeVc.state = ClanActivityPost;
            activityTypeVc.activityArray = _forumModel.postActivityModel.activitytype;
            [self.navigationController pushViewController:activityTypeVc animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1 || section == 2) {
        return 10;
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else if (section == 2){
        if (_forumModel.postActivityModel.activityfield && _forumModel.postActivityModel.activityfield.count > 0) {
            if (_forumModel.postActivityModel.activityextnum && _forumModel.postActivityModel.activityextnum.integerValue > 0) {
                return 3;
            }else{
                return 2;
            }
        }else if (_forumModel.postActivityModel.activityextnum && _forumModel.postActivityModel.activityextnum.integerValue > 0){
            return 2;
        }else{
            return 1;
        }
    }
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

#pragma mark - 类型选择回调
- (void) postActivityType:(NSString *)type{
    _activityType = type;
    _sendActivityModel.activityclass = _activityType;
    WEAKSELF
    if (self.returnPostActivityModel) {
        self.returnPostActivityModel(weakSelf.sendActivityModel);
    }

    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:2];
    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - YZDatepPicker Delegate
-(void)toobarDonBtnHaveClick:(YZDataPicker *)pickView resultString:(NSString *)resultString{
    _activityTime = resultString;
    [pickView remove];
    _sendActivityModel.starttimefrom = _activityTime;
    WEAKSELF
    if (self.returnPostActivityModel) {
        self.returnPostActivityModel(weakSelf.sendActivityModel);
    }
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:1];
    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - 自定义标题
- (UILabel *)titleWithCellText:(NSString *)text{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(18, 0, 200, 44)];
    label.textColor = UIColorFromRGB(0x303030);
    label.font = [UIFont systemFontOfSize:14.0f];
    label.text = text;
    return label;
}

#pragma 选择必填项回调
- (void)activitySelectInfoWithInfoDic:(NSDictionary *)dic{
    if (!_userfieldArray) {
        _userfieldArray = [NSMutableArray array];
    }
    if ([_userfieldArray containsObject:dic[@"fieldid"]]) {
        [_userfieldArray removeObject:dic[@"fieldid"]];
    }else{
        [_userfieldArray addObject:dic[@"fieldid"]];
    }
    _sendActivityModel.userfield = _userfieldArray;
    WEAKSELF
    if (self.returnPostActivityModel) {
        self.returnPostActivityModel(weakSelf.sendActivityModel);
    }
}

#pragma textField 回调
- (void)textFieldText:(UITextField *)textField{
    if (textField.tag == 5000) {
        //名称
        _sendActivityModel.subject = textField.text;
    }else if (textField.tag == 6000){
        //地点
        _sendActivityModel.activityplace = textField.text;
    }
    WEAKSELF
    if (self.returnPostActivityModel) {
        self.returnPostActivityModel(weakSelf.sendActivityModel);
    }
}

#pragma mark - 扩展回调
- (void)activityExpandString:(NSString *)string{
    _sendActivityModel.extfield = string;
    if (self.returnPostActivityModel) {
        self.returnPostActivityModel(self.sendActivityModel);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
