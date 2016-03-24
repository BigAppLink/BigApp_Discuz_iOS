//
//  BindAccountController.m
//  Clan
//
//  Created by 昔米 on 15/8/4.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "BindAccountController.h"
#import "LoginViewModel.h"
#import "YZPickView.h"
#import "AutoScrollView.h"
#import "QQLoginViewController.h"
#import "RegisterViewController.h"

@interface BindAccountController () <UITableViewDataSource, UITableViewDelegate, YZPickViewDelegate>

@property (strong, nonatomic,readonly) LoginViewModel *loginViewModel;
@property (strong, nonatomic) UITableView *tableView;
@property (strong,nonatomic) UIImageView *bgView;
@property (strong, nonatomic) YZPickView *pickview;
@property (strong, nonatomic) UIImageView *iconUserView;
@property (strong, nonatomic) UITextField *tf_name;
@property (strong, nonatomic) UITextField *tf_pwd;
@property (strong, nonatomic) UITextField *tf_answer;
@property (strong, nonatomic) UILabel *tf_ask;
@property (strong, nonatomic) NSArray *askArray;
@property (strong, nonatomic) NSArray *askIdArray;
@property (copy, nonatomic) NSString *questionId;
@property (strong, nonatomic) UIButton *bindbtn;
@property (strong, nonatomic) UIButton *bindRegbtn;
@end

@implementation BindAccountController

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.view endEditing:YES];
    [_pickview remove];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSMutableArray *arr =  [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    if (arr.count >= 2) {
        UIViewController *vc = arr[arr.count-2];
        if ([vc isKindOfClass:[QQLoginViewController class]]) {
            [arr removeObject:vc];
            [self.navigationController setViewControllers:arr];
        }
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"绑定账号";
    [self buildUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    DLog(@"BindAccountController dealloc");
}

#pragma mark - 初始化

- (void)buildUI
{
    self.view.backgroundColor = kCOLOR_BG_GRAY;
    if (!_loginViewModel) {
        _loginViewModel = [LoginViewModel new];
        _askIdArray = [NSArray array];
        _askArray = [NSArray array];
    }
    _askArray = @[@"无安全问题",@"母亲的名字",@"爷爷的名字",@"父亲出生的城市",@"您其中一位老师的名字",@"您个人计算机的型号",@"您最喜欢的餐馆名称",@"驾驶执照最后四位数字"];
    _askIdArray = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7"];
    
    
    AutoScrollView *autoSv = [[AutoScrollView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-64)];
    [self.view addSubview:autoSv];
    autoSv.contentSize = CGSizeMake(kSCREEN_WIDTH, kSCREEN_HEIGHT);
    
    _tf_name = [self creatFieldWithPlaceholder:@"账户名"];
    _tf_pwd = [self creatFieldWithPlaceholder:@"密码"];
    _tf_pwd.secureTextEntry = YES;
    _tf_answer = [self creatFieldWithPlaceholder:@"回答"];
    _tf_ask = [[UILabel alloc]init];
    _tf_ask.text = @"安全提问 (如无设置请忽略)";
    _tf_ask.textColor = K_COLOR_DARK_Cell;
    _tf_ask.font = [UIFont fontWithSize:15.f];
    
    //table
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 45*3+40) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorColor = K_COLOR_MOST_LIGHT_GRAY;
    _tableView.scrollEnabled = NO;
    [autoSv addSubview:_tableView];
    
    //绑定按钮
    UIButton *bindBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bindBtn.frame = CGRectMake(40, kVIEW_BY(_tableView)+20, kSCREEN_WIDTH-80, 45);
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 5, 0, 5);
    UIImage *image = kIMG(@"anniu");
    image = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    [bindBtn setBackgroundImage:image forState:UIControlStateNormal];
    [bindBtn setTitleColor:K_COLOR_DARK forState:UIControlStateNormal];
    [bindBtn setTitle:@"绑定并登录" forState:UIControlStateNormal];
    [bindBtn addTarget:self action:@selector(bindAction) forControlEvents:UIControlEventTouchUpInside];
    self.bindbtn = bindBtn;
    [autoSv addSubview:bindBtn];
    
    //绑定注册按钮
    UIButton *bindRegbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bindRegbtn.frame = CGRectMake(kSCREEN_WIDTH-180, kVIEW_BY(bindBtn)+5, 140, 30);
    [bindRegbtn setTitleColor:kUIColorFromRGB(0xff494d) forState:UIControlStateNormal];
    [bindRegbtn setTitle:@"没有账号？注册并绑定" forState:UIControlStateNormal];
    [bindRegbtn.titleLabel setFont:[UIFont fontWithSize:12.f]];
    [bindRegbtn.titleLabel  setTextAlignment:NSTextAlignmentRight];
    [bindRegbtn addTarget:self action:@selector(bindRegAction) forControlEvents:UIControlEventTouchUpInside];
    self.bindRegbtn = bindRegbtn;
    [autoSv addSubview:bindRegbtn];
    
    [_tf_name becomeFirstResponder];
    
}

- (UITextField *)creatFieldWithPlaceholder:(NSString *)placeholder
{
    UITextField *textField = [[UITextField alloc]init];
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.placeholder = placeholder;
    [textField setValue:K_COLOR_DARK_Cell forKeyPath:@"_placeholderLabel.textColor"];
    textField.textColor = K_COLOR_DARK_Cell;
    textField.font = [UIFont fontWithSize:15.f];
    return textField;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_askArray.count > 0) {
        if (_questionId.intValue == 0) {
            return 3;
        } else {
            return 4;
        }
    }
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        [cell.contentView addSubview:_tf_name];
        [_tf_name mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(cell.textLabel.mas_leading);
            make.top.equalTo(cell.contentView.mas_top);
            make.bottom.equalTo(cell.contentView.mas_bottom);
            make.width.equalTo(@(kSCREEN_WIDTH-55));
        }];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"    ";
        cell.imageView.image = kIMG(@"icon_account");
        return cell;
    }else if(indexPath.row == 1){
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        [cell.contentView addSubview:_tf_pwd];
        [_tf_pwd mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(cell.textLabel.mas_leading);
            make.top.equalTo(cell.contentView.mas_top);
            make.bottom.equalTo(cell.contentView.mas_bottom);
            make.width.equalTo(@(kSCREEN_WIDTH-55));
        }];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"    ";
        cell.imageView.image = kIMG(@"icon_mima");
        return cell;
    }else if(indexPath.row == 2){
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        [cell.contentView addSubview:_tf_ask];
        [_tf_ask mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(cell.textLabel.mas_leading);
            make.top.equalTo(cell.contentView.mas_top);
            make.bottom.equalTo(cell.contentView.mas_bottom);
            make.width.equalTo(@(kSCREEN_WIDTH-55));
        }];
        cell.accessoryView = [[UIImageView alloc]initWithImage:kIMG(@"jiantou_xia")];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"    ";
        cell.imageView.image = kIMG(@"anquan");
        return cell;
    }else{
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        [cell.contentView addSubview:_tf_answer];
        [_tf_answer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(cell.textLabel.mas_leading);
            make.top.equalTo(cell.contentView.mas_top);
            make.bottom.equalTo(cell.contentView.mas_bottom);
            make.width.equalTo(@(kSCREEN_WIDTH-55));
        }];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.imageView.image = kIMG(@"ask");
        cell.textLabel.text = @"    ";
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 2) {
        [self pickviewAction];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.f;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 40.f)];
    view.backgroundColor = kCLEARCOLOR;
    UILabel *label = [UILabel new];
    label.font = [UIFont fontWithSize:14.f];
    label.textColor = K_COLOR_DARK_Cell;
    label.text = @"请登录本站账号进行绑定";
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(view.mas_leading).offset(15);
        make.trailing.equalTo(view.mas_trailing).offset(-10);
        make.centerX.equalTo(view.mas_centerX);
        make.centerY.equalTo(view.mas_centerY).offset(5);
    }];
    return view;
}

#pragma mark - 显示分类选择器
- (void)pickviewAction
{
    [self.view endEditing:YES];
    if (!_pickview) {
        _pickview=[[YZPickView alloc] initPickviewWithArray:_askArray isHaveNavControler:NO];
        _pickview.delegate=self;
        [_pickview show];
    }
}

#pragma -mark picker delegate 选择分类
- (void)toobarDonBtnHaveClick:(YZPickView *)pickView resultString:(NSString *)resultString
{
    [pickView remove];
    _pickview = nil;
    _tf_ask.text = resultString;
    [_askArray enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL *stop) {
        if ([resultString isEqualToString:obj]) {
            _questionId = _askIdArray[idx];
            *stop = YES;
        }
    }];
    if (_questionId.intValue == 0) {
        _tableView.height = 45*3;
    } else {
        _tableView.height = 45*4;
    }
    _bindbtn.top = kVIEW_BY(_tableView)+20;
    _bindRegbtn.top = kVIEW_BY(_bindbtn)+5;
    [_tableView reloadData];
}
- (void)toobarCancelClick
{
    _pickview = nil;
}



#pragma mark - action 
- (void)bindAction
{
    WEAKSELF
    [_loginViewModel request_ThirdPartLogin_WithOpenId:self.openid token:self.oauth_token withLoginType:_bindtype username:_tf_name.text pwd:_tf_pwd.text questionid:_questionId answer:_tf_answer.text andBlock:^(id data, NSError *error) {
        STRONGSELF
        if (data) {
            NSNumber *error_code = [data valueForKeyPath:@"error_code"];
            if (error_code && error_code.intValue == 0) {
                //提示
                [strongSelf showHudTipStr:@"账号绑定成功"];
                //登录成功
                [weakSelf dismissViewControllerAnimated:YES completion:^{
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"KNotiLogin" object:nil];
                }];
            }
        }
    }];
}

- (void)bindRegAction
{
    RegisterViewController *Reg = [[RegisterViewController alloc]init];
    Reg.bindAction = YES;
    Reg.bindtype = self.bindtype;
    Reg.oauth_token = self.oauth_token;
    Reg.openid = self.openid;
    [self.navigationController pushViewController:Reg animated:YES];
}

- (void)navback:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
