//
//  LoginViewController.m
//  Clan
//
//  Created by chivas on 15/3/12.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginViewModel.h"
#import "InputTextCell.h"
#import "UIViewController+LewPopupViewController.h"
#import "LewPopupViewAnimationSpring.h"
#import "NickPopView.h"
#import "RegisterViewController.h"
#import "AutoScrollView.h"
#import <ShareSDK/ShareSDK.h>
#import "ClanNetAPI.h"
#import <CommonCrypto/CommonDigest.h>
#import "WebLoginViewController.h"
#import "YZPickView.h"
#import "QQLoginViewController.h"
#import "BindAccountController.h"
#import "UserInfoViewModel.h"
#import "WXApi.h"
#import "UIAlertView+BlocksKit.h"

@interface LoginViewController ()<YZPickViewDelegate>
//@property (strong,nonatomic) TPKeyboardAvoidingTableView *tableView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong,nonatomic) UIImageView *bgView;
@property (strong, nonatomic) YZPickView *pickview;

//@property (copy,nonatomic) NSString *email;
//@property (copy,nonatomic) NSString *passWord;
@property (strong, nonatomic) UIImageView *iconUserView;
@property (strong, nonatomic) UITextField *tf_name;
@property (strong, nonatomic) UITextField *tf_pwd;
@property (strong, nonatomic) UITextField *tf_answer;
@property (strong, nonatomic) UILabel *tf_ask;
@property (strong, nonatomic) LoginViewModel *loginViewModel;
@property (strong, nonatomic) NSArray *askArray;
@property (strong, nonatomic) NSArray *askIdArray;
@property (strong, nonatomic) UIButton *loginbtn;
@property (strong, nonatomic) UserInfoViewModel *vm;

@property (copy, nonatomic) NSString *questionId;
@property (strong, nonatomic) UIView *thirdView;

@property (copy, nonatomic) NSString *url_qqlogin; //QQ登录
@property (copy, nonatomic) NSString *url_qqlogin_end; //监测QQ登录结束的url
@end

@implementation LoginViewController


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.view endEditing:YES];
    [_pickview remove];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self buildUI];
//    [self checkThirdLoginStatus];
}

#pragma mark - 初始化

- (void)buildUI
{
    self.view.backgroundColor = kCOLOR_BG_GRAY;
    self.vm = [UserInfoViewModel new];
    if (!_loginViewModel) {
        _loginViewModel = [LoginViewModel new];
        _askIdArray = [NSArray array];
        _askArray = [NSArray array];
    }
    _askArray = @[@"无安全问题",@"母亲的名字",@"爷爷的名字",@"父亲出生的城市",@"您其中一位老师的名字",@"您个人计算机的型号",@"您最喜欢的餐馆名称",@"驾驶执照最后四位数字"];
    _askIdArray = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7"];
    NSString *webloginurl = [NSString returnPlistWithKeyValue:@"URLWebLogin"];
    if (webloginurl && webloginurl.length > 0) {
        //开启web登录模式 跳转到web
        [self webloginWithUrl:webloginurl];
        return;
    }

    self.title = @"登录";
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(youzulogins) name:@"KNotiLogin" object:nil];
    
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
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 31, ScreenWidth, 45*3) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorColor = K_COLOR_MOST_LIGHT_GRAY;
    _tableView.scrollEnabled = NO;
    [autoSv addSubview:_tableView];
    
    //默认开启注册入口
    NSString *regSwitch = [NSString returnPlistWithKeyValue:@"RegSwitch"];
    if (![@"0" isEqualToString:regSwitch]) {
        UIButton *regBtn = [UIButton buttonWithTitle:@"注册" andImage:nil andFrame:CGRectMake(0, 0, 40, 40) target:self action:@selector(regAction)];
        regBtn.titleLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_SUBTITLE];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:regBtn];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
    
    UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.backgroundColor = [UIColor clearColor];
    leftButton.frame = CGRectMake(0, 0, 26, 26);
    [leftButton setBackgroundImage :[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    
    //登录按钮
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.frame = CGRectMake(40, kVIEW_BY(_tableView)+20, kSCREEN_WIDTH-80, 45);
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 5, 0, 5);
    UIImage *image = kIMG(@"anniu");
    image = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    [loginBtn setBackgroundImage:image forState:UIControlStateNormal];
    [loginBtn setTitleColor:K_COLOR_DARK forState:UIControlStateNormal];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    self.loginbtn = loginBtn;
    [autoSv addSubview:loginBtn];
    
    _thirdView = [[UIView alloc]initWithFrame:CGRectMake(0, kVIEW_BY(loginBtn)+20, ScreenWidth, 0)];
    [autoSv addSubview:_thirdView];
    [self setupLoginButtons];

    NSString *name_key = @"kLASTUSERNAME";
    _tf_name.text = [[NSUserDefaults standardUserDefaults] objectForKey:name_key];
}

- (void)setupLoginButtons
{
    for (UIView *sview in _thirdView.subviews) {
        [sview removeFromSuperview];
    }
    //非游族登录页面
    float btnwith = 40;
    UIView *contentV = [[UIView alloc]initWithFrame:CGRectZero];
    contentV.center = CGPointMake(kSCREEN_WIDTH/2, 50+btnwith/2);
    contentV.bounds = CGRectMake(0, 0, 0, btnwith+10);
    [_thirdView addSubview:contentV];
    float spaceH = btnwith+40;
    //QQ登录
    self.url_qqlogin = [NSString returnPlistWithKeyValue:kurl_qqlogin];
    self.url_qqlogin_end = [NSString returnPlistWithKeyValue:kurl_qqlogin_end];
    if (_url_qqlogin && _url_qqlogin.length > 0 && _url_qqlogin_end && _url_qqlogin_end.length > 0) {
        CGRect rect1 = contentV.frame;
        rect1.size.width += spaceH;
        contentV.frame = rect1;
        UIButton *qqBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        qqBtn.frame = CGRectMake(kVIEW_W(contentV)-spaceH, 5, btnwith, btnwith);
        [qqBtn setBackgroundImage:kIMG(@"login_QQ") forState:UIControlStateNormal];
        qqBtn.showsTouchWhenHighlighted = YES;
        [qqBtn addTarget:self action:@selector(qqlogin:) forControlEvents:UIControlEventTouchUpInside];
        [contentV addSubview:qqBtn];
    }
    
    //微博登录
    NSString *weiboEnable = [NSString returnPlistWithKeyValue:kweiboSwitch];
    if (weiboEnable && weiboEnable.intValue == 1) {
        CGRect rect = contentV.frame;
        rect.size.width += spaceH;
        contentV.frame = rect;
        UIButton *weiboBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        weiboBtn.frame = CGRectMake(kVIEW_W(contentV)-spaceH, 5, btnwith, btnwith);
        [weiboBtn setBackgroundImage:kIMG(@"login_weibo") forState:UIControlStateNormal];
        [weiboBtn addTarget:self action:@selector(weibologin:) forControlEvents:UIControlEventTouchUpInside];
        weiboBtn.showsTouchWhenHighlighted = YES;
        [contentV addSubview:weiboBtn];
    }
    
    //微信登录
    NSString *wechatEnable = [NSString returnPlistWithKeyValue:kwechatSwitch];
    if (wechatEnable && wechatEnable.intValue == 1) {
        CGRect rect = contentV.frame;
        rect.size.width += spaceH;
        contentV.frame = rect;
        UIButton *wechatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        wechatBtn.frame = CGRectMake(kVIEW_W(contentV)-spaceH, 5, btnwith, btnwith);
        [wechatBtn setBackgroundImage:kIMG(@"login_weixin") forState:UIControlStateNormal];
        wechatBtn.showsTouchWhenHighlighted = YES;
        [wechatBtn addTarget:self action:@selector(weChatlogin:) forControlEvents:UIControlEventTouchUpInside];
        [contentV addSubview:wechatBtn];
    }
    
    //分割线
    CGRect rect = contentV.frame;
    if (rect.size.width > 0) {
        rect.size.width -= 40;
        contentV.frame = rect;
        UILabel *line = [UILabel new];
        line.frame = CGRectMake(46, 25, kSCREEN_WIDTH-92, 0.5);
        line.backgroundColor = UIColorFromRGB(0xcecccc);
        [_thirdView addSubview:line];
        
        UILabel *centerLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        centerLabel.backgroundColor = self.view.backgroundColor;
        centerLabel.textColor = UIColorFromRGB(0xa6a6a6);
        centerLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_ELEMENT];
        centerLabel.text = @"其他方式登录";
        centerLabel.textAlignment = NSTextAlignmentCenter;
        centerLabel.center = line.center;
        centerLabel.bounds = CGRectMake(0, 0, 100, 25);
        [_thirdView addSubview:centerLabel];
    }
    contentV.center = CGPointMake(kSCREEN_WIDTH/2, 50+btnwith/2);
    _thirdView.height = contentV.bottom+10;
}


#pragma mark 注册
- (void)regAction
{
    NSString *webregurl = [NSString returnPlistWithKeyValue:@"URLWebReg"];
    if (webregurl && webregurl.length > 0) {
        //开启web登录模式
        WebLoginViewController *toweb = [[WebLoginViewController alloc]initWithURLString:webregurl];
        toweb.showPageTitles = NO;
        toweb.title = @"注册";
        [self.navigationController pushViewController:toweb animated:YES];
        return;
    }
    RegisterViewController *regView = [[RegisterViewController alloc]init];
    regView.fid = _fid;
    [self.navigationController pushViewController:regView animated:YES];
}

- (IBAction)qqlogin:(id)sender
{
    QQLoginViewController *wen = [[QQLoginViewController alloc]initWithURLString:self.url_qqlogin];
    wen.showPageTitles = NO;
    wen.showDoneButton = NO;
    wen.url_qqlogin_end = self.url_qqlogin_end;
    [self.navigationController pushViewController:wen animated:YES];
}

- (IBAction)weChatlogin:(id)sender
{
    if (![WXApi isWXAppInstalled]) {
        [UIAlertView bk_showAlertViewWithTitle:@"" message:@"尚未安装微信" cancelButtonTitle:@"取消" otherButtonTitles:@[@"前往安装"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kWeiXinDownloadURL]];
            }
        }];
        return;
    }
    WEAKSELF
    [ShareSDK getUserInfo:SSDKPlatformTypeWechat
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
               STRONGSELF
               switch (state) {
                   case SSDKResponseStateBegin:
                       
                       break;
                       
                   case SSDKResponseStateFail:
                   {
                       NSString *errMess = [error localizedDescription];
                       DLog(@"----%@",errMess);
                       [strongSelf showHudTipStr:@"授权失败，请重试"];
                       break;
                   }
                   case SSDKResponseStateSuccess:
                   {
                       //授权登录成功
                       NSString *openid = [[user credential] uid];
                       NSString *tokend = [[user credential] token];
                       [strongSelf checkLogin:openid andToken:tokend andLoginType:LoginTypeWechat];
                       break;
                   }
                   case SSDKResponseStateCancel:
                       [strongSelf showHudTipStr:@"授权已取消"];
                       break;
                   default:
                       break;
               }
           }];
}


- (IBAction)weibologin:(id)sender
{
    WEAKSELF
    [ShareSDK getUserInfo:SSDKPlatformTypeSinaWeibo
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
               STRONGSELF
               switch (state) {
                   case SSDKResponseStateBegin:
                       
                       break;
                       
                   case SSDKResponseStateFail:
                   {
                       NSString *errMess = [error localizedDescription];
                       DLog(@"----%@",errMess);
                       [strongSelf showHudTipStr:@"授权失败，请重试"];
                       break;
                   }
                   case SSDKResponseStateSuccess:
                   {
                       //授权登录成功
                       NSString *openid = [[user credential] uid];
                       NSString *tokend = [[user credential] token];
                       [strongSelf checkLogin:openid andToken:tokend andLoginType:LoginTypeWeibo];
                       break;
                   }
                   case SSDKResponseStateCancel:
                       [strongSelf showHudTipStr:@"授权已取消"];
                       break;
                   default:
                       break;
               }
           }];
}


- (IBAction)tengxunlogin:(id)sender
{
    WEAKSELF
    [ShareSDK getUserInfo:SSDKPlatformTypeQQ
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
               STRONGSELF
               switch (state) {
                   case SSDKResponseStateBegin:
                       
                       break;
                       
                   case SSDKResponseStateFail:
                   {
                       NSString *errMess = [error localizedDescription];
                       DLog(@"----%@",errMess);
                       [strongSelf showHudTipStr:@"授权失败，请重试"];
                       break;
                   }
                   case SSDKResponseStateSuccess:
                   {
                       //授权登录成功
                       NSString *openid = [[user credential] uid];
                       NSString *tokend = [[user credential] token];
                       [strongSelf checkLogin:openid andToken:tokend andLoginType:LoginTypeWeibo];
                       break;
                   }
                   case SSDKResponseStateCancel:
                       [strongSelf showHudTipStr:@"授权已取消"];
                       break;
                   default:
                       break;
               }
           }];
}

- (void)checkLogin:(NSString *)openid andToken:(NSString *)token andLoginType:(LoginType)type
{
    [self showProgressHUDWithStatus:@""];
    WEAKSELF
    [[Clan_NetAPIManager sharedManager] checkBindStatusWithOpenID:openid andToken:token andLogintype:type andBlock:^(id data, NSError *error) {
        STRONGSELF
        [strongSelf hideProgressHUD];
        if (!error) {
            NSDictionary *dataDic = [data valueForKey:@"Variables"];
            if (dataDic && [dataDic objectForKey:@"hasbind"]) {
                NSString *number = [dataDic objectForKey:@"hasbind"];
                if (number.intValue == 0) {
                    //未绑定，则进行绑定
                    [strongSelf gotoBindPageWithOpenID:openid andOauthToken:token];
                }
                else if (number.intValue == 1) {
                    [strongSelf dismissLogin];
                }
            } else {
                NSString *errMess = [data valueForKeyPath:@"error"];
                if (errMess) {
                    [strongSelf showHudTipStr:errMess];
                }
            }
        }
    }];
}

- (void)dismissLogin
{
    //拉取个人信息 进行登录
    [Util saveCookieData];
    [self checkLogin];
}


- (void)checkLogin
{
    WEAKSELF
    [_vm requestApi:nil andReturnBlock:^(bool success, id data, bool isSelf) {
        STRONGSELF
        if (success) {
            //登录成功
            DLog(@"登录成功");
            UserModel *user = [UserModel currentUserInfo];
            [user setValueWithObject:data];
            //设置登录成功
            user.logined = YES;
            [UserModel saveToLocal];
            [strongSelf dismissViewControllerAnimated:YES completion:^{
                [strongSelf showHudTipStr:@"登录成功"];
            }];
        } else {
            //登录失败
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"LOGINSUCCESS"];
            DLog(@"登录失败");
        }
    }];
}

- (void)gotoBindPageWithOpenID:(NSString *)openid andOauthToken:(NSString *)oauth_token
{
    BindAccountController *bind = [[BindAccountController alloc]init];
    bind.openid = openid;
    bind.bindtype = LoginTypeWechat;
    bind.oauth_token = oauth_token;
    [self.navigationController pushViewController:bind animated:YES];
}



- (void)webloginWithUrl:(NSString *)url
{
    WebLoginViewController *toweb = [[WebLoginViewController alloc]initWithURLString:url];
    toweb.showPageTitles = NO;
    toweb.title = @"登录";
    [self.navigationController setViewControllers:@[toweb] animated:NO];
}



- (NSString *)md5:(NSString *)inPutText
{
    const char *cStr = [inPutText UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), result);
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_askArray.count > 0) {
        if (_questionId == 0) {
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
    return CGFLOAT_MIN;
}

#pragma mark - Table view Header Footer
- (UIView *)customHeaderView
{
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight/3)];
    UIImage *bgImage = [UIImage imageNamed:@"login_logo"];
    _iconUserView = [[UIImageView alloc] initWithImage:bgImage];
    _iconUserView.center = headerV.center;
    _iconUserView.top = headerV.top + 30;
    [headerV addSubview:_iconUserView];
    
    return headerV;
}

- (UIView *)customFooterView
{
    CGFloat iconUserViewWidth;
    if (kDevice_Is_iPhone6Plus) {
        iconUserViewWidth = 87;
    }else{
        iconUserViewWidth = 58;
    }
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 100)];
    footerV.backgroundColor = [UIColor redColor];
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setImage:[UIImage imageNamed:@"login_btn"] forState:UIControlStateNormal];
    loginButton.frame = CGRectMake(0, 0, iconUserViewWidth, iconUserViewWidth);
    loginButton.center = footerV.center;
    [footerV addSubview:loginButton];
    return footerV;
}

#pragma mark - 登录
- (void)loginAction
{
    [self.view endEditing:YES];

    WEAKSELF
    [_loginViewModel request_Login_WithUserName:_tf_name.text andPassWord:_tf_pwd.text andFid:_fid andQuestionid:_questionId andAnswer:_tf_answer.text withViewController:self];
    [_loginViewModel setBlockWithReturnBlock:^(id returnValue) {
        [weakSelf backView];
    } WithErrorBlock:nil];
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
- (void)toobarDonBtnHaveClick:(YZPickView *)pickView resultString:(NSString *)resultString{
    [pickView remove];
    _pickview = nil;
    _tf_ask.text = resultString;
    [_askArray enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL *stop) {
        if ([resultString isEqualToString:obj]) {
            _questionId = _askIdArray[idx];
            *stop = YES;
        }
    }];
    if (_questionId==0) {
        _tableView.height = 45*3;
    } else {
        _tableView.height = 45*4;
    }
    _loginbtn.frame = CGRectMake(40, kVIEW_BY(_tableView)+20, kSCREEN_WIDTH-80, 45);
    _thirdView.top = kVIEW_BY(_loginbtn)+20;
    [_tableView reloadData];
}
- (void)toobarCancelClick
{
    _pickview = nil;
}

#pragma mark - 退出登录
- (void)backView
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"KUpdateFavType" object:nil];
    }];
    
}

- (void)youzulogins
{
    [self backView];
}

- (UITextField *)creatFieldWithPlaceholder:(NSString *)placeholder{
    UITextField *textField = [[UITextField alloc]init];
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.placeholder = placeholder;
    [textField setValue:K_COLOR_DARK_Cell forKeyPath:@"_placeholderLabel.textColor"];
    textField.textColor = K_COLOR_DARK_Cell;
    textField.font = [UIFont fontWithSize:15.f];
    return textField;
}
- (void)dealloc
{
    DLog(@"LoginViewController dealloc");
    [self.view endEditing:YES];
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tf_pwd.delegate = nil;
    _tf_answer.delegate = nil;
    _tf_name.delegate = nil;
    
}

@end
