//
//  MeViewController.m
//  Clan
//
//  Created by 昔米 on 15/7/3.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "MeViewController.h"
#import "UIViewController+NavibarDao.h"
#import "UserInfoCell.h"
#import "MyPostViewController.h"
#import "UserInfoViewModel.h"
#import "UserInfoModel.h"
#import "LucPhotoHelper.h"
#import "ChatViewController.h"
#import "DialogListModel.h"
#import "Clan_NetAPIManager.h"
#import "LoginViewController.h"
#import "MainHomeViewController.h"
#import "SettingViewController.h"
#import "BaseSegmentViewController.h"
#import "UIImage+ImageEffects.h"
#import "FriendsViewController.h"
#import "MeInfoCell.h"
#import "UserModel.h"
#import "FriendsViewModel.h"
#import "ReportViewController.h"
#import "FriendVerifyViewController.h"
static float kHeaderHeight = 210.f-64.f;

@interface MeViewController ()<UIAlertViewDelegate ,UITableViewDataSource, UITableViewDelegate,LucPhotoHelperDelegate,UIActionSheetDelegate>
{
    //name大标题
    UILabel *_titleLabel;
    //导航栏驻留
    UIImageView *_tempTopView;
    //初始状态的偏移量
    CGPoint _startPoint;
    //标记上一个滑动位置，用于判断滑动方向
    CGFloat _lastLocationY;
    BOOL _refresh;
    //上部分区域
    UIImageView *_iv_topView;
    //头像
    UIImageView *_iv_avatar;
    //昵称
    UILabel *_lbl_name;
    //性别
    UIImageView *_iv_gender;
    //info
    UILabel *_lbl_otherInfo;
    //user
    UserInfoViewModel *_userViewModel;
    //加好友按钮
    //是否为好友
    NSIndexPath *_tobeIndex;
    
}
@property (strong, nonatomic) MeInfoCell *meInfoCell;
@property (nonatomic, strong) NSDictionary *datadic;
@property (nonatomic, strong) UIButton *qiandaoBtn;
@property (nonatomic, strong) UIButton *my_addFriendBtn;
@property (assign) BOOL isMyFriend;

@property (strong, nonatomic) FriendsViewModel *friendViewModel;
@property (strong, nonatomic) LucPhotoHelper *photoHelper;
@property (strong, nonatomic) UIButton* checkinBtn;
@property (assign, nonatomic) BOOL isLoading;
@property (assign, nonatomic) BOOL complete;
@end

@implementation MeViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestCheckInSwitchStatus];
    if (_tobeIndex) {
        [self.tableview deselectRowAtIndexPath:_tobeIndex animated:YES];
        _tobeIndex = nil;
    }
    //    if (!_complete && [UserModel currentUserInfo].logined) {
    //        [self requestData];
    //    }
    if ([Util isNetWorkAvalible]) {
        [[SDImageCache sharedImageCache] removeImageForKey:_user.avatar fromDisk:YES];
        //        [_iv_avatar sd_setImageWithURL:[NSURL URLWithString:[UserModel currentUserInfo].avatar] placeholderImage:kIMG(@"portrait") options:SDWebImageRefreshCached];
    }
}

- (void)dealloc
{
    _tableview.dataSource = nil;
    _tableview.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_isSelf) {
        @try{
            //注册监听模式
            UserModel *cUser = [UserModel currentUserInfo];
            [cUser removeObserver:self forKeyPath:@"logined"];
        }@catch(id anException){
            
        }
    }
    DLog(@"MeViewController dealloc");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

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

#pragma mark - 初始化
- (void)loadModel
{
    //定制数据源
    [self setCellTitleType];
    _isMyFriend = NO;
    _userViewModel = [UserInfoViewModel new];
    if (!_user) {
        _user = [UserModel new];
    }
}

- (void)buildUI
{
    if (_isPresentMode || _isRightItem) {
        UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.backgroundColor = [UIColor clearColor];
        leftButton.frame = CGRectMake(0, 0, 26, 26);
        [leftButton setBackgroundImage :[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(navback1:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    }
    float height = self.tabBarController ? kSCREEN_HEIGHT-64-kTABBAR_HEIGHT : kSCREEN_HEIGHT-64;

    self.tableview = [[BaseTableView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, height) style:UITableViewStyleGrouped];
    self.tableview.backgroundColor = kCOLOR_BG_GRAY;
    self.view.backgroundColor = kCOLOR_BG_GRAY;
    if (kIOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.extendedLayoutIncludesOpaqueBars = NO;
    }
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.separatorColor = kCLEARCOLOR;
    [self.view addSubview:_tableview];
    [self.tableview registerClass:[MeInfoCell class] forCellReuseIdentifier:@"MeInfoCell"];
    
    //topview
    UIImageView *top = [[UIImageView alloc]initWithFrame:CGRectMake(0, -kHeaderHeight, kSCREEN_WIDTH, kHeaderHeight)];
    top.userInteractionEnabled = YES;
    top.backgroundColor = kCOLOR_BG_GRAY;
    //    top.image = [Util imageWithColor:[UIColor returnColorWithPlist:YZSegMentColor]];
    _iv_topView = top;
    _iv_topView.image = [Util imageWithColor:[UIColor returnColorWithPlist:YZSegMentColor]];
    //    [_iv_topView setImage:[Util imageWithColor:[UIColor returnColorWithPlist:YZSegMentColor]]];
    _iv_topView.clipsToBounds = YES;
    _iv_topView.contentMode = UIViewContentModeScaleAspectFill;
    [self.tableview addSubview:top];
    
    
    //初始化变量
    _lastLocationY = _tableview.contentOffset.y;
    _startPoint = _tableview.contentOffset;
    
    //头像
    UIImageView *iv = [UIImageView new];
    iv.layer.cornerRadius = 65/2;
    iv.layer.borderColor = [[UIColor whiteColor] CGColor];
    iv.layer.borderWidth = 3.0f;
    iv.clipsToBounds = YES;
    iv.contentMode = UIViewContentModeScaleAspectFill;
    iv.layer.allowsEdgeAntialiasing = true;
    [top addSubview:iv];
    _iv_avatar = iv;
    
    //昵称
    UILabel *name1 = [UILabel new];
    name1.textAlignment = NSTextAlignmentCenter;
    name1.textColor = [UIColor whiteColor];
    name1.text = @"";
    _lbl_name = name1;
    [top addSubview:name1];
    //gender 性别
    UIImageView *gender = [UIImageView new];
    gender.hidden = YES;
    [top addSubview:gender];
    _iv_gender = gender;
    
    //其他信息
    UILabel *other = [UILabel new];
    other.font = [UIFont fitFontWithSize:K_FONTSIZE_ELEMENT];
    other.textColor = [UIColor whiteColor];
    other.textAlignment = NSTextAlignmentCenter;
    _lbl_otherInfo = other;
    [top addSubview:other];
    
    [iv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_iv_topView.mas_bottom).offset(-75);
        make.centerX.equalTo(_iv_topView.mas_centerX).offset(0);
        make.width.equalTo(@65);
        make.height.equalTo(@65);
    }];
    
    [name1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_iv_avatar.mas_bottom).offset(15);
        make.centerX.equalTo(_iv_avatar.mas_centerX);
    }];
    [other mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(name1.mas_bottom).offset(10);
        make.centerX.equalTo(_iv_avatar.mas_centerX);
    }];
    
    [gender mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_lbl_name.mas_trailing).offset(5);
        make.centerY.equalTo(_lbl_name.mas_centerY);
        make.width.equalTo(@13);
        make.height.equalTo(@13);
    }];
        WEAKSELF
    [self.tableview createHeaderViewBlock:^{
        STRONGSELF
        [strongSelf requestData];
        if (strongSelf.isSelf) {
            [strongSelf requestCheckInSwitchStatus];
        }
    }];
    //根据用户的身份展现UI 分为me和other
    [self changeUIByUserIdentity];
}

- (void)navback1:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)changeUIByUserIdentity
{
    if (self.isSelf) {
        //添加各种通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCome:) name:@"AUTO_REFRESH_ME" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCome:) name:@"Avatar_Changed" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCome:) name:@"LOGOUT" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCome:) name:@"KNEWS_FRIEND_MESSAGE" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCome:) name:@"CheckInSwitch_Changed" object:nil];
        //注册监听模式
        UserModel *cUser = [UserModel currentUserInfo];
        [cUser addObserver:self forKeyPath:@"logined" options:NSKeyValueObservingOptionNew context:NULL];
        
       //添加签到按钮
        _checkinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkinBtn.backgroundColor = [UIColor clearColor];
        _checkinBtn.frame = CGRectMake(0, 0, 60, 30);
        [_checkinBtn setImage:[UIImage imageNamed:@"checkin"] forState:UIControlStateNormal];
        [_checkinBtn addTarget:self action:@selector(doCheckInAction) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:_checkinBtn];

        [self resetCheckInStatus];
        [_user setValueWithObject:[UserModel currentUserInfo]];
        [self resetValuesWithModel:[UserModel currentUserInfo]];
    }

    else {
        [self resetValuesWithModel:_user];
//        [self showProgressHUDWithStatus:@"努力加载中..."];
//        [self requestData];
    }

    if (_isSelf && ![UserModel currentUserInfo].logined) {
        
    } else {
        [self.tableview beginRefreshing];
    }
}

#pragma mark - Request
//个人信息
- (void)requestData
{
    _isLoading = YES;
    WEAKSELF
    [_userViewModel requestApi:_user.uid
                andReturnBlock:^(bool success, id data, bool isSelf) {
                    STRONGSELF
                    [strongSelf performSelector:@selector(dissmissProgress) withObject:nil afterDelay:0.4];
                    [strongSelf.tableview endHeaderRefreshing];
                    if (success) {
                        strongSelf.isSelf = isSelf;
                        [strongSelf friendBtnIsShow];
                        strongSelf.isLoading = NO;
                        if (isSelf) {
                            [[SDImageCache sharedImageCache] removeImageForKey:[UserModel currentUserInfo].avatar fromDisk:YES];
                            UserInfoModel *info = data;
                            [[UserModel currentUserInfo] setValueWithObject:info];
                            [UserModel saveToLocal];
                            [strongSelf resetValuesWithModel:[UserModel currentUserInfo]];
                        } else {
                            [strongSelf.user setValueWithObject:data];
                            UserInfoModel *info = data;
                            strongSelf.user.username = info.username;
                            strongSelf.user.friends = info.friends;
                            strongSelf.user.is_my_friend = info.is_my_friend;
                            [[SDImageCache sharedImageCache] removeImageForKey:info.avatar fromDisk:YES];
                            [strongSelf resetValuesWithModel:strongSelf.user];
                        }
//                        //先清除掉缓存
//                        [strongSelf changeAvatar];
                    } else {
                        [strongSelf showHudTipStr:data];
                    }
                }];
}

#pragma mark - 设置cell标题
- (void)setCellTitleType
{
    NSString *postString;
    NSString *friendString;
    postString = (_isSelf || [[UserModel currentUserInfo].uid isEqualToString:_user.uid]) ? @"我的帖子":@"他的帖子";
    friendString = (_isSelf || [[UserModel currentUserInfo].uid isEqualToString:_user.uid])?@"我的好友":@"他的好友";
    NSArray *titleArray_01 = @[postString, @"我的收藏"];
    NSArray *titleArray_02 = @[@"设置"];
    
    NSArray *titleArray_03 = @[friendString];
    
    NSArray *imageArray_01 = @[@"wodezhutie",@"tiezishoucang"];
    NSArray *imageArray_02 = @[@"shezhi"];
    NSArray *imageArray_03 = @[@"haoyou"];
    
    NSArray *actionArray_01 = @[
                                NSStringFromSelector(@selector(goPosts_mythread)),
                                //                                NSStringFromSelector(@selector(goPosts_myreply)),
                                NSStringFromSelector(@selector(goFavo_threads)),
                                //                                NSStringFromSelector(@selector(goFavo_forums)),
                                ];
    NSArray *actionArray_02 = @[
                                NSStringFromSelector(@selector(goSetting))
                                ];
    NSArray *actionArray_03 = @[
                                NSStringFromSelector(@selector(goToMyFriends)),
                                ];
    self.datadic = @{
                     @"title0" : titleArray_01,
                     @"title1" : titleArray_03,
                     @"title2" : titleArray_02,
                     
                     @"icon0" : imageArray_01,
                     @"icon1" : imageArray_03,
                     @"icon2" : imageArray_02,
                     
                     @"action0" : actionArray_01,
                     @"action1" : actionArray_03,
                     @"action2" : actionArray_02,
                     };
}

#pragma mark - 设置加好友按钮是否显示
- (void)friendBtnIsShow
{
    if (!self.isSelf) {
        
        //加好友按钮
        UIButton *addFriend = [UIButton createButtonWithTitle:nil andFrame:CGRectZero andBgImage:nil andImage:kIMG(@"tianjiahaoyou") target:self action:@selector(tapFriend)];
        addFriend.titleLabel.font = [UIFont systemFontOfSize:11.0f];
        [addFriend setTitleEdgeInsets:UIEdgeInsetsMake(1, 6, 0, 0)];
        _my_addFriendBtn = addFriend;
        //发消息按钮
        UIButton *postChat = [UIButton createButtonWithTitle:nil andFrame:CGRectZero andBgImage:nil andImage:kIMG(@"faxinxi") target:self action:@selector(tapChat)];
        postChat.titleLabel.font = [UIFont systemFontOfSize:11.0f];
        [postChat setTitleEdgeInsets:UIEdgeInsetsMake(1, 6, 0, 0)];
        
        //举报按钮
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list_jubao"] style:UIBarButtonItemStylePlain target:self action:@selector(reportAction)] animated:NO];
        
        //发消息 加好友按钮
        [_iv_topView addSubview:addFriend];
        [_iv_topView addSubview:postChat];
        [addFriend mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_iv_avatar.mas_top).offset(26);
            make.trailing.equalTo(_iv_avatar.mas_leading).offset(-18);
            make.width.equalTo(@70);
            make.height.equalTo(@23);
            
        }];
        
        [postChat mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_iv_avatar.mas_top).offset(26);
            make.leading.equalTo(_iv_avatar.mas_trailing).offset(18);
            make.width.equalTo(@70);
            make.height.equalTo(@23);
            
        }];
    }
}

//签到状态
//- (void)requestCheckInState
//{
//    requestCheckInSwitchStatus
//    [_userViewModel doCheckIn:[UserModel currentUserInfo].uid docheckInAction:NO andReturenBlock:^(bool success, id data) {
//
//    }];
//}

//重新赋值
- (void)resetValuesWithModel:(id)model
{
    //设置头像
    [self faceStyle];
    if (![UserModel currentUserInfo].logined && _isSelf) {
        //name大标题
        [_iv_avatar sd_cancelCurrentAnimationImagesLoad];
        [_iv_avatar sd_cancelCurrentImageLoad];
        [_iv_avatar setImage:kIMG(@"portrait")];
        _lbl_name.text = @"点击登录";
        _iv_gender.hidden = YES;
        _lbl_otherInfo.text = @"登录后可使用更多功能哦~";
        
    }
    else if (model) {
        _user = model;
        _lbl_name.text = [@"" isEqualToString:_user.username] ? @"" : _user.username;
        _lbl_otherInfo.text = @"";
        if (!_user.gender) {
            [_iv_gender setHidden:YES];
        } else {
            if (_user.gender.intValue == 0) {
                //TODO 性别保密
                [_iv_gender setHidden:YES];
            } else {
                [_iv_gender setHidden:NO];
                NSString *ivName = _user.gender.intValue == 1 ? @"left_menu_male" : @"left_menu_female";
                [_iv_gender setImage:kIMG(ivName)];
            }
        }
        //停掉所有的load
        [self changeAvatar];
//        [_iv_avatar sd_setImageWithURL:[NSURL URLWithString:_user.avatar] placeholderImage:kIMG(@"portrait") options:SDWebImageRefreshCached];
        [_tableview reloadData];
    }
    if (!_isSelf) {
        if (![_user.is_my_friend isEqualToString:@"0"]) {
            //是自己好友
            _isMyFriend = YES;
            [_my_addFriendBtn setImage:kIMG(@"shanhaoyou") forState:UIControlStateNormal];
        }else{
            _isMyFriend = NO;
            [_my_addFriendBtn setImage:kIMG(@"tianjiahaoyou") forState:UIControlStateNormal];
        }
    }
    [_tableview reloadData];
    
}

#pragma mark - 设置头像
- (void)faceStyle
{
    if (_isSelf) {
        NSString *changeAvaEnable = [NSString returnPlistWithKeyValue:KAllowAvatarChange];
        //打开开关
        if (!changeAvaEnable || changeAvaEnable.intValue == 1){
            [self addAvatarAction];
        }else{
            if (![UserModel currentUserInfo].logined) {
                [self addAvatarAction];
            }else{
                _iv_avatar.userInteractionEnabled = NO;
            }
        }
    }
}

- (void)addAvatarAction
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    [tapGestureRecognizer addTarget:self action:@selector(gestureRecognizerHandle:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    _iv_avatar.userInteractionEnabled = YES;
    [_iv_avatar addGestureRecognizer:tapGestureRecognizer];
}
#pragma mark - 调整UI
//签到按钮的隐藏
- (void)resetCheckInStatus
{
    if (_isSelf) {
        if (!_checkinBtn) {
            //添加签到按钮
            _checkinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _checkinBtn.backgroundColor = [UIColor clearColor];
            _checkinBtn.frame = CGRectMake(0, 0, 30, 30);
            [_checkinBtn setImage:[UIImage imageNamed:@"checkin"] forState:UIControlStateNormal];
            [_checkinBtn addTarget:self action:@selector(doCheckInAction) forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:_checkinBtn];
        }
    }
    NSString *checkin_enabled = [NSString returnPlistWithKeyValue:kcheckin_enabled];
    if (checkin_enabled && checkin_enabled.intValue == 1) {
        _checkinBtn.hidden = NO;
        if ([UserModel currentUserInfo].logined) {
            NSString *checked = [[UserModel currentUserInfo] checked];
            if (checked && checked.intValue == 1) {
                [_checkinBtn setImage:kIMG(@"uncheckin") forState:UIControlStateNormal];
                _checkinBtn.enabled = NO;
            } else {
                [_checkinBtn setImage:kIMG(@"checkin") forState:UIControlStateNormal];
                _checkinBtn.enabled = YES;
            }
        } else {
            [_checkinBtn setImage:kIMG(@"checkin") forState:UIControlStateNormal];
            _checkinBtn.enabled = YES;
        }
    } else {
        _checkinBtn.hidden = YES;
    }
}

//签到开关
- (void)requestCheckInSwitchStatus
{
    UserModel *cuser = [UserModel currentUserInfo];
    [_userViewModel doCheckIn:cuser.uid docheckInAction:NO andReturenBlock:^(bool success, id data) {
        
    }];
}


#pragma mark - tableview datasource
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return _iv_topView;
    }else{
        return nil;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (_isSelf && ![UserModel currentUserInfo].logined) {
            //未登陆 则不显示
            return 0;
        }else{
            return 45;
        }
    }
    return 48.f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _isSelf ?4:3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *titleArray = _datadic[[NSString stringWithFormat:@"title%ld",(long)section-1]];
    if (section == 0) {
        return 1;
    }else if(section == 1){
        if (_isSelf) {
            return titleArray.count;
        }else{
            return titleArray.count - 1;
        }
    }else{
        return titleArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        MeInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MeInfoCell" forIndexPath:indexPath];
        if (_isSelf && ![UserModel currentUserInfo].logined) {
            cell.userModel = nil;
        }else{
            cell.userModel = _user;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else{
        static NSString *identifer = @"MeCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
            //            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.accessoryView = [[UIImageView alloc]initWithImage:kIMG(@"jiantou_me")];
            UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(59, 47.5, kSCREEN_WIDTH-59, 0.5)];
            line.image = [Util imageWithColor:kUIColorFromRGB(0xeaeae9)];
            line.tag = 1122;
            [cell.contentView addSubview:line];
            cell.textLabel.font = [UIFont fitFontWithSize:17.f];
        }
        NSArray *titleArray = _datadic[[NSString stringWithFormat:@"title%ld",(long)indexPath.section-1]];
        NSArray *iconArray = _datadic[[NSString stringWithFormat:@"icon%ld",(long)indexPath.section-1]];
        cell.imageView.image = kIMG(iconArray[indexPath.row]);
        cell.textLabel.text = titleArray[indexPath.row];
        cell.textLabel.textColor = K_COLOR_LIGHT_DARK;
        UIView *v = [cell.contentView viewWithTag:1122];
        if (indexPath.row == (titleArray.count-1)) {
            v.hidden = YES;
        } else {
            v.hidden = NO;
        }
        if ([titleArray[indexPath.row] isEqualToString:@"我的好友"]) {
            NSString *count = [[NSUserDefaults standardUserDefaults] objectForKey:@"KNEWS_FRIEND_MESSAGE"];
            if (!isNull(count) && count.intValue > 0 && _isSelf) {
                //加上小红点
                NSString *redPotImage = [NSString stringWithFormat:@"%@_pot",iconArray[indexPath.row]];
                cell.imageView.image = kIMG(redPotImage);
            } else {
                //取消小红点
                cell.imageView.image = kIMG(iconArray[indexPath.row]);
            }
        } else {
            cell.imageView.image = kIMG(iconArray[indexPath.row]);
        }
        return cell;
    }
}

#pragma mark - tableview delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return kHeaderHeight;
    }
    return 12.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *actionArr = _datadic[[NSString stringWithFormat:@"action%ld",(long)indexPath.section-1]];
    SEL sel = NSSelectorFromString(actionArr[indexPath.row]);
    if ([self canPerformAction:sel withSender:nil]) {
        _tobeIndex = indexPath;
        [self performSelector:sel withObject:nil];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - 编辑头像
- (void)gestureRecognizerHandle: (UITapGestureRecognizer *)recognizer
{
    if (!self.isSelf) {
        //非自己主页的话 就不能上传图片
        return;
    }else{
        if ([self checkLoginState]) {
            //已登录
            if (!_photoHelper) {
                //编辑头像
                _photoHelper = [[LucPhotoHelper alloc]init];
                _photoHelper.target = self;
                _photoHelper.delegate = self;
            }
            [_photoHelper editPortraitInView:self.view];
            
        }
    }
    
}

#pragma mark - 举报按钮
- (void)reportAction{
    UIActionSheet *alertView = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"举报" otherButtonTitles:nil, nil];
    [alertView showInView:self.view];
}


#pragma mark - actions
//签到
- (void)doCheckInAction
{
    if ([self checkLoginState]) {
        //已登录
        WEAKSELF
        [_userViewModel doCheckIn:[UserModel currentUserInfo].uid docheckInAction:YES andReturenBlock:^(bool success, id data) {
            STRONGSELF
            if (success) {
                //签到成功 改变状态
                [strongSelf resetCheckInStatus];
            }
        }];
    }
}

//显示登录页
- (void)avatarTapAction
{
    [self goHomePage];
}

//显示登录页
- (BOOL)checkLoginState
{
    UserModel *_cuser = [UserModel currentUserInfo];
    if (!_cuser || !_cuser.logined) {
        //没有登录 跳出登录页面
        LoginViewController *login = [[LoginViewController alloc]init];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:login];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
        if (self.sideMenuViewController) {
            [self.sideMenuViewController hideMenuViewController];
        }
        return NO;
    } else {
        return YES;
    }
}

//跳转到“我的收藏”
- (void)goFavo_threads
{
    if ([self checkLoginState]) {
        
        BaseSegmentViewController *segMent = [[BaseSegmentViewController alloc]init];
        segMent.segmentType = segmentCollection;
        segMent.selectedIndex = 0;
        segMent.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:segMent animated:YES];
        
    }
}

//跳转到“版块收藏”
- (void)goFavo_forums
{
    if ([self checkLoginState]) {
        
        BaseSegmentViewController *segMent = [[BaseSegmentViewController alloc]init];
        segMent.segmentType = segmentCollection;
        segMent.selectedIndex = 1;
        segMent.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:segMent animated:YES];
        
    }
}

//跳转到“我的回帖”
- (void)goPosts_myreply
{
    if ([self checkLoginState]) {
        MyPostViewController *post = [[MyPostViewController alloc]init];
        post.userId = [UserModel currentUserInfo].uid;
        post.selectedIndex = 1;
        post.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:post animated:YES];
    }
}

//跳转到“我的帖子”
- (void)goPosts_mythread
{
    if ([self checkLoginState]) {
        MyPostViewController *post = [[MyPostViewController alloc]init];
        post.userId = _user.uid;
        post.selectedIndex = 0;
        post.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:post animated:YES];
    }
}

//跳转到“我的主页”
- (void)goHomePage
{
    if ([self checkLoginState]) {
        MainHomeViewController *main = [[MainHomeViewController alloc]initWithNibName:NSStringFromClass([MainHomeViewController class]) bundle:nil];
        UserModel *usermodel = [UserModel new];
        UserModel *cuser = [UserModel currentUserInfo];
        [usermodel setValueWithObject:cuser];
        main.user = usermodel;
        main.isSelf = YES;
        main.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:main animated:YES];
    }
}

//跳转到“设置”
- (void)goSetting
{
    SettingViewController *setting = [[SettingViewController alloc]init];
    //    WEAKSELF
    //    setting.logoutBlock = ^(){
    //        //退出了登录
    //        [weakSelf.tableview reloadData];
    //    };
    setting.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:setting animated:YES];
}

//跳我的好哟
- (void)goToMyFriends
{
    if ([self checkLoginState]) {
        FriendsViewController *fr = [[FriendsViewController alloc]init];
        if (_isSelf) {
            fr.uid = nil;
        } else {
            fr.uid = _user.uid;
        }
        fr.title = @"我的好友";
        fr.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:fr animated:YES];
    }
}


- (void)notificationCome:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"Avatar_Changed"]) {
        [self changeAvatar];
    }
    else if ([noti.name isEqualToString:@"AUTO_REFRESH_ME"]) {
        [self.tableview beginRefreshing];
    }
    else if ([noti.name isEqualToString:@"KNEWS_FRIEND_MESSAGE"]) {
        [self.tableview reloadData];
    }
    else if ([noti.name isEqualToString:@"CheckInSwitch_Changed"]) {
        [self resetCheckInStatus];
    }
}

#pragma mark -  LucPhotoHelperDelegate （头像截取成功）

- (void)LucPhotoHelperGetPhotoSuccess:(UIImage *)image
{
    WEAKSELF
    [_userViewModel upLoadAvatar:image andReturenBlock:^(bool success, id data) {
        STRONGSELF
        if (success) {
            [_iv_avatar sd_cancelCurrentImageLoad];
            [_iv_avatar sd_cancelCurrentAnimationImagesLoad];
            [[SDImageCache sharedImageCache] removeImageForKey:_user.avatar fromDisk:YES];
            [_iv_avatar sd_setImageWithURL:[NSURL URLWithString:data] placeholderImage:kIMG(@"portrait")];
        } else {
            [strongSelf changeAvatar];
        }
    }];
}

//修改头像
- (void)changeAvatar
{
    [_iv_avatar sd_cancelCurrentImageLoad];
    [_iv_avatar sd_cancelCurrentAnimationImagesLoad];
    [[SDImageCache sharedImageCache] removeImageForKey:_user.avatar fromDisk:YES];
    [_iv_avatar sd_setImageWithURL:[NSURL URLWithString:_user.avatar] placeholderImage:kIMG(@"portrait")];
}

#pragma mark - 发消息
- (void)tapChat
{
    if ([self checkLoginState]) {
        
        ChatViewController *chat = [[ChatViewController alloc]initWithNibName:NSStringFromClass([ChatViewController class]) bundle:nil];
        DialogListModel *model = [DialogListModel new];
        model.msgtoid = _user.uid;
        model.tousername = _user.username;
        chat.dialogModel = model;
        [self.navigationController pushViewController:chat animated:YES];
        
    }
}

- (void)tapFriend
{
    if (!_friendViewModel) {
        _friendViewModel = [FriendsViewModel new];
    }
    if ([self checkLoginState]) {
        if (!_isMyFriend) {
            [self checkFriends];
        }else{
            WEAKSELF
            [_friendViewModel requestDelegateFriendWithUid:_user.uid andBlock:^(BOOL isDelegate) {
                STRONGSELF
                if (isDelegate) {
                    strongSelf.isMyFriend = NO;
                    [strongSelf.my_addFriendBtn setImage:kIMG(@"tianjiahaoyou") forState:UIControlStateNormal];
                }
            }];
            
        }
    }
}

//检查好友
- (void)checkFriends
{
    [self showProgressHUDWithStatus:@""];
    
    WEAKSELF
    [_friendViewModel checkFriend:_user.uid isAgreePage:NO withchecktype:@"1" WithReturnBlock:^(BOOL success, id data) {
        STRONGSELF
        [strongSelf dissmissProgress];
        if (success) {
            NSString *suc = (NSString *)data;
            if (suc && suc.intValue == 2) {
                //同意好友
                [strongSelf request_dealFriendApply:strongSelf.user.uid agree:YES];
            } else {
                [strongSelf goToVerifyPage];
            }
        } else {
            [strongSelf dissmissProgress];
        }
    }];
}

//处理好友申请
- (void)request_dealFriendApply:(NSString *)uid agree:(BOOL)agree
{
    [self showProgressHUDWithStatus:@""];
    WEAKSELF
    [_friendViewModel request_dealFriendApply:uid agree:agree withBlock:^(BOOL success) {
        STRONGSELF
        [strongSelf dissmissProgress];
        if (success) {
            if (agree) {
                //申请成功
                strongSelf.isMyFriend = YES;
                [strongSelf showHudTipStr:@"添加好友成功"];
                [strongSelf.my_addFriendBtn setImage:kIMG(@"shanhaoyou") forState:UIControlStateNormal];
            } else {
            }
        }
    }];
}

//切换到验证界面
- (void)goToVerifyPage
{
    FriendVerifyViewController *friendVerifyVc = [[FriendVerifyViewController alloc]init];
    friendVerifyVc.uid = _user.uid;
    [self.navigationController pushViewController:friendVerifyVc animated:YES];
}

#pragma mark UIActionView
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        ReportViewController *reportView = [[ReportViewController alloc]init];
        reportView.state = ClanReportUser;
        [self.navigationController pushViewController:reportView animated:YES];
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"logined"]) {
        if ([UserModel currentUserInfo].logined) {
            if (_isSelf) {
                [self resetValuesWithModel:[UserModel currentUserInfo]];
                [self requestCheckInSwitchStatus];
            }
            [self.tableview beginRefreshing];
        } else {
            if (_isSelf) {
                [self.tableview endHeaderRefreshing];
                [self resetValuesWithModel:[UserModel new]];
                [self resetCheckInStatus];
            }
        }
    }
}

@end
