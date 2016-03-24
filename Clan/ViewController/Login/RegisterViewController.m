//
//  RegisterViewController.m
//  Clan
//
//  Created by chivas on 15/5/12.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "RegisterViewController.h"
#import "InputTextCell.h"
#import "LoginViewModel.h"
#import "AutoScrollView.h"
#import "RulesViewController.h"
@interface RegisterViewController ()
//@property (strong,nonatomic) TPKeyboardAvoidingTableView *tableView;
@property (strong,nonatomic) UITableView *tableView;

@property (strong, nonatomic) UITextField *tf_name;
@property (strong, nonatomic) UITextField *tf_email;
@property (strong, nonatomic) UITextField *tf_pwd;
@property (strong, nonatomic) UITextField *tf_repwd;
@property (strong, nonatomic) UIButton *rulesBtn;
@property (strong, nonatomic) UILabel *rulesLabel;
//@property (copy,nonatomic) NSString *username;
//@property (copy,nonatomic) NSString *email;
//@property (copy,nonatomic) NSString *passWord;
//@property (copy,nonatomic) NSString *passWord2;
@property (copy,nonatomic) NSString *captcha;
@property (copy,nonatomic) NSString *sessionid;
@property (strong, nonatomic) UIButton *loginBtn;
@property (strong, nonatomic) LoginViewModel *loginViewModel;

@end

@implementation RegisterViewController

- (void)dealloc
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _loginViewModel = nil;
    DLog(@"RegisterViewController dealloc");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = _bindAction ? @"注册并绑定" : @"注册";
    self.view.backgroundColor = kCOLOR_BG_GRAY;
    _loginViewModel = [LoginViewModel new];
    [self initRegisterView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
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
    }
    else if(indexPath.row == 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        [cell.contentView addSubview:_tf_email];
        [_tf_email mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(cell.textLabel.mas_leading);
            make.top.equalTo(cell.contentView.mas_top);
            make.bottom.equalTo(cell.contentView.mas_bottom);
            make.width.equalTo(@(kSCREEN_WIDTH-55));
        }];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"    ";
        cell.imageView.image = kIMG(@"icon_mail");
        return cell;
    }
    else if(indexPath.row == 2) {
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
    }
    else {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        [cell.contentView addSubview:_tf_repwd];
        [_tf_repwd mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(cell.textLabel.mas_leading).offset(32);
            make.top.equalTo(cell.contentView.mas_top);
            make.bottom.equalTo(cell.contentView.mas_bottom);
            make.width.equalTo(@(kSCREEN_WIDTH-55));
        }];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"    ";
        cell.imageView.image = kIMG(@"");
        return cell;
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
    return CGFLOAT_MIN;
}

#pragma mark - 注册
- (void)regAction
{
    [self.view endEditing:YES];
    if (!_bindAction) {
        WEAKSELF
        [_loginViewModel request_Register_WithUserName:_tf_name.text andPassWord:_tf_pwd.text andPassword2:_tf_repwd.text andEmail:_tf_email.text andFid:_fid];
        [_loginViewModel setBlockWithReturnBlock:^(id returnValue) {
            [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
        } WithErrorBlock:nil];
    } else {
        WEAKSELF
        [_loginViewModel request_ThirdPartRegister_WithOpenId:self.openid token:self.oauth_token withLoginType:_bindtype username:_tf_name.text pwd:_tf_pwd.text pwd1:_tf_repwd.text email:_tf_email.text andBlock:^(id data, NSError *error) {
            STRONGSELF
            NSNumber *error_code = [data valueForKeyPath:@"error_code"];
            if (error_code && error_code.intValue == 0) {
                //提示
                [strongSelf showHudTipStr:@"账号绑定成功"];
                //登录成功
                [weakSelf dismissViewControllerAnimated:YES completion:^{
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"KNotiLogin" object:nil];
                }];
            }
        }];
    }
}

#pragma mark - UI
- (void)initRegisterView{
    AutoScrollView *autoSv = [[AutoScrollView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-64)];
    [self.view addSubview:autoSv];
    autoSv.contentSize = CGSizeMake(kSCREEN_WIDTH, kSCREEN_HEIGHT);
    
    
    _tf_name = [[UITextField alloc]init];
    _tf_name.clearButtonMode = UITextFieldViewModeWhileEditing;
    _tf_name.placeholder = @"账户名";
    _tf_name.textColor = K_COLOR_DARK_Cell;
    _tf_name.font = [UIFont fontWithSize:15.f];
    
    _tf_email = [[UITextField alloc]init];
    _tf_email.clearButtonMode = UITextFieldViewModeWhileEditing;
    _tf_email.placeholder = @"注册邮箱";
    _tf_email.textColor = K_COLOR_DARK_Cell;
    _tf_email.font = [UIFont fontWithSize:15.f];
    
    _tf_pwd = [[UITextField alloc]init];
    _tf_pwd.clearButtonMode = UITextFieldViewModeWhileEditing;
    _tf_pwd.placeholder = @"密码";
    _tf_pwd.textColor = K_COLOR_DARK_Cell;
    _tf_pwd.secureTextEntry = YES;
    _tf_pwd.font = [UIFont fontWithSize:15.f];
    
    _tf_repwd = [[UITextField alloc]init];
    _tf_repwd.clearButtonMode = UITextFieldViewModeWhileEditing;
    _tf_repwd.placeholder = @"确认密码";
    _tf_repwd.textColor = K_COLOR_DARK_Cell;
    _tf_repwd.secureTextEntry = YES;
    _tf_repwd.font = [UIFont fontWithSize:15.f];
    
    //table
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 31, ScreenWidth, 45.f*4) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorColor = K_COLOR_MOST_LIGHT_GRAY;
    _tableView.scrollEnabled = NO;
    [autoSv addSubview:_tableView];
    
    //条款按钮
    UIView *rulesView = [[UIView alloc]initWithFrame:CGRectMake(0, _tableView.bottom, ScreenWidth, 31)];
    rulesView.backgroundColor = [UIColor clearColor];
    _rulesBtn = [[UIButton alloc]initWithFrame:CGRectMake(12, rulesView.height/2 - 10 , 20, 20)];
    [_rulesBtn setImage:kIMG(@"gouxuan_acton") forState:UIControlStateNormal];
    [_rulesBtn setImage:kIMG(@"gouxuan_unAction") forState:UIControlStateSelected];
    [_rulesBtn addTarget:self action:@selector(rulesAction:) forControlEvents:UIControlEventTouchUpInside];
    [rulesView addSubview:_rulesBtn];
    
    _rulesLabel = [[UILabel alloc]initWithFrame:CGRectMake(_rulesBtn.right + 3, 0, 200, rulesView.height)];
    _rulesLabel.userInteractionEnabled = YES;
    _rulesLabel.font = [UIFont systemFontOfSize:12.0f];
    _rulesLabel.textColor = UIColorFromRGB(0xff4c4c);
    _rulesLabel.text = @"我同意使用条款隐私政策";
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:_rulesLabel.text];
    [attributedString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x424242) range:NSMakeRange(0, 3)];
    _rulesLabel.attributedText = attributedString;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelAction)];
    [_rulesLabel addGestureRecognizer:tap];
    [rulesView addSubview:_rulesLabel];
    [autoSv addSubview:rulesView];
    //注册按钮
    _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _loginBtn.frame = CGRectMake(40, kVIEW_BY(rulesView)+16, kSCREEN_WIDTH-80, 45);
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 5, 0, 5);
    UIImage *image = kIMG(@"anniu");
    image = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    [_loginBtn setBackgroundImage:image forState:UIControlStateNormal];
    [_loginBtn setTitleColor:K_COLOR_DARK forState:UIControlStateNormal];
    [_loginBtn setTitle:_bindAction ? @"注册并绑定新账户" : @"注册" forState:UIControlStateNormal];
    [_loginBtn addTarget:self action:@selector(regAction) forControlEvents:UIControlEventTouchUpInside];
    [autoSv addSubview:_loginBtn];
}

#pragma mark - 选中隐私按钮
- (void)rulesAction:(UIButton *)btn{
    _rulesBtn.selected =! _rulesBtn.selected;
    _loginBtn.enabled = !_rulesBtn.selected;

}

- (void)labelAction{
    RulesViewController *rulesVC = [[RulesViewController alloc]init];
    [self.navigationController pushViewController:rulesVC animated:YES];
}
@end
