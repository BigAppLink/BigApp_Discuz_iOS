//
//  MainHomeViewController.m
//  Clan
//
//  Created by 昔米 on 15/4/10.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "MainHomeViewController.h"
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
#import "UIImage+ImageEffects.h"
#import "MyInfoCell.h"
#import "MyInfoTwoCell.h"
#import "MyInfoThreeCell.h"
#import "FriendVerifyViewController.h"
#import "FriendsViewModel.h"
#import "FriendsViewController.h"
#import "ReportViewController.h"
static float kHeaderHeight = 210.f-64.f;
static float kStayHeight = 64.f;

@interface MainHomeViewController () <UIAlertViewDelegate ,UITableViewDataSource, UITableViewDelegate, LucPhotoHelperDelegate,UIActionSheetDelegate>
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
    //TITLE
    UILabel *_lbl_title_normal;
    //头像
    UIImageView *_iv_avatar;
    //昵称
    UILabel *_lbl_name;
    //性别
    UIImageView *_iv_gender;
    //info
    UILabel *_lbl_otherInfo;
    //user
    UserInfoCell *_userinfo_cell;
    MyInfoCell *_myinfo_cell;
    MyInfoTwoCell *_myinfo2_cell;
    MyInfoThreeCell *_myinfo3_cell;
    UserInfoViewModel *_userViewModel;
    NSString *_titlevalue;
    LucPhotoHelper *_photoHelper;
    
    UIButton *_rightButton;
    
    UIView *_infoCellView;
    BOOL _isLoading;
    
}

//加好友按钮
@property (strong, nonatomic) UIButton *my_addFriendBtn;
@property (assign) BOOL isMyFriend;
@property (strong, nonatomic) FriendsViewModel *friendViewModel;
//@property (strong, nonatomic) UIButton *my_addFriendBtn;
//@property (assign) BOOL isMyFriend;
@end

@implementation MainHomeViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    //    [self setNaviTransparent];
}

- (void)dealloc
{
    _tableview.dataSource = nil;
    _tableview.delegate = nil;
    _photoHelper.target = nil;
    _photoHelper.delegate = nil;
    _photoHelper = nil;
    DLog(@"MainHomeViewController dealloc");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_isLoading) {
        [self showProgressHUDWithStatus:@"努力加载中..."];
    }
}

- (void)navback{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    _isMyFriend = NO;
    _friendViewModel = [FriendsViewModel new];
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count == 1) {
        UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.backgroundColor = [UIColor clearColor];
        leftButton.frame = CGRectMake(0, 0, 26, 26);
        [leftButton setBackgroundImage :[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(navback) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    }
    
    self.tableview.backgroundColor = kCOLOR_BG_GRAY;
    self.tableview.scrollIndicatorInsets = UIEdgeInsetsMake(kStayHeight, 0, 0, 0);
    self.tableview.contentInset = UIEdgeInsetsMake(kHeaderHeight, 0, 0, 0);
    if (kIOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.extendedLayoutIncludesOpaqueBars = NO;
    }
    self.tableview.sectionHeaderHeight = 0.0;
    self.tableview.sectionFooterHeight = 10.f;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    //    self.tableview.separatorColor = kCOLOR_BORDER;
    
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([UserInfoCell class]) bundle:nil];
    _userinfo_cell = [nib instantiateWithOwner:self options:nil][0];
    _userinfo_cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UINib *nib1 = [UINib nibWithNibName:NSStringFromClass([MyInfoCell class]) bundle:nil];
    _myinfo_cell = [nib1 instantiateWithOwner:self options:nil][0];
    _myinfo_cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UINib *nib2 = [UINib nibWithNibName:NSStringFromClass([MyInfoTwoCell class]) bundle:nil];
    _myinfo2_cell = [nib2 instantiateWithOwner:self options:nil][0];
    _myinfo2_cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UINib *nib3 = [UINib nibWithNibName:NSStringFromClass([MyInfoThreeCell class]) bundle:nil];
    _myinfo3_cell = [nib3 instantiateWithOwner:self options:nil][0];
    _myinfo3_cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //topview
    UIImageView *top = [[UIImageView alloc]initWithFrame:CGRectMake(0, -kHeaderHeight, kSCREEN_WIDTH, kHeaderHeight)];
    top.backgroundColor = kCOLOR_BG_GRAY;
    //    top.image = [Util imageWithColor:[UIColor returnColorWithPlist:YZSegMentColor]];
    _iv_topView = top;
    _iv_topView.image = [Util imageWithColor:[UIColor returnColorWithPlist:YZSegMentColor]];
    _iv_topView.clipsToBounds = YES;
    _iv_topView.contentMode = UIViewContentModeScaleAspectFill;
    [self.tableview addSubview:top];
    
    //正常状态的tilte
    UILabel *lbl_t = [[UILabel alloc]init];
    lbl_t.bounds = CGRectMake(0, 0, kSCREEN_WIDTH-100, 44);
    lbl_t.backgroundColor = [UIColor clearColor];
    lbl_t.textColor = [UIColor whiteColor];
    lbl_t.textAlignment = NSTextAlignmentCenter;
    lbl_t.center = CGPointMake(kSCREEN_WIDTH/2, 20+22);
    lbl_t.text = _titlevalue;
    _lbl_title_normal = lbl_t;
    _lbl_title_normal.font = [UIFont fitFontWithSize:20.f];
    [top addSubview:lbl_t];
    
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
    //    iv.image = kIMG(@"portrait");
    [top addSubview:iv];
    _iv_avatar = iv;
    //    [Util addBorderForImageView:_iv_avatar];
    
    //昵称
    UILabel *name1 = [UILabel new];
    name1.textAlignment = NSTextAlignmentCenter;
    name1.textColor = [UIColor whiteColor];
    name1.text = @"";
    //    _lbl_name.font = [UIFont fitFontWithSize:K_FONTSIZE_TITLE];
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
    //    [top addSubview:other];
    
    [iv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_iv_topView.mas_bottom).offset(-75);
        make.centerX.equalTo(_iv_topView.mas_centerX).offset(0);
        make.width.equalTo(@65);
        make.height.equalTo(@65);
    }];
    
    
    
    //    [other mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.bottom.equalTo(_iv_topView.mas_bottom).offset(-64);
    //        make.centerX.equalTo(_iv_avatar.mas_centerX);
    //    }];
    //
    [name1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_iv_avatar.mas_bottom).offset(15);
        make.centerX.equalTo(_iv_avatar.mas_centerX);
    }];
    
    //
    [gender mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_lbl_name.mas_trailing).offset(5);
        make.centerY.equalTo(_lbl_name.mas_centerY);
        make.width.equalTo(@13);
        make.height.equalTo(@13);
    }];
    
    //昵称
    UILabel *titl = [UILabel new];
    titl.bounds = CGRectMake(0, 0, kSCREEN_WIDTH-100, 44);
    [self.view addSubview:titl];
    titl.alpha = 0;
    titl.backgroundColor = [UIColor clearColor];
    titl.textColor = [UIColor whiteColor];
    _titleLabel = titl;
    _titleLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_TITLE];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    titl.center = CGPointMake(kSCREEN_WIDTH/2, 20+22);
    NSString *changeAvaEnable = [NSString returnPlistWithKeyValue:KAllowAvatarChange];
    //打开开关
    if (!changeAvaEnable || changeAvaEnable.intValue == 1)
    {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
        [tapGestureRecognizer addTarget:self action:@selector(gestureRecognizerHandle:)];
        [tapGestureRecognizer setNumberOfTapsRequired:1];
        [tapGestureRecognizer setNumberOfTouchesRequired:1];
        _iv_avatar.userInteractionEnabled = YES;
        [_iv_avatar addGestureRecognizer:tapGestureRecognizer];
    }
    _iv_topView.userInteractionEnabled = YES;
    [self resetValuesWithModel:self.user];
    [self requestData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if ([self checkLoginState]) {
        if (!_isMyFriend) {
            [self checkFriends];
        }else{
            if (!_friendViewModel) {
                _friendViewModel = [FriendsViewModel new];
            }
            [_friendViewModel requestDelegateFriendWithUid:_user.uid andBlock:^(BOOL isDelegate) {
                if (isDelegate) {
                    _isMyFriend = NO;
                    [_my_addFriendBtn setImage:kIMG(@"tianjiahaoyou") forState:UIControlStateNormal];
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

#pragma mark - setter方法
- (void)setUser:(UserModel *)user
{
    _user = user;
}

- (void)gestureRecognizerHandle: (UITapGestureRecognizer *)recognizer
{
    //    UserModel *_cuser = [UserModel currentUserInfo];
    if (!self.isSelf) {
        //非自己主页的话 就不能上传图片
        return;
    }
    if (!_photoHelper) {
        //编辑头像
        _photoHelper = [[LucPhotoHelper alloc]init];
        _photoHelper.target = self;
        _photoHelper.delegate = self;
    }
    [_photoHelper editPortraitInView:self.view];
    
}

- (void)requestData
{
    if (!_userViewModel) {
        _userViewModel = [UserInfoViewModel new];
    }
    _isLoading = YES;
    WEAKSELF
    [_userViewModel requestApi:_user.uid
                andReturnBlock:^(bool success, id data, bool isSelf) {
                    STRONGSELF
                    _isLoading = NO;
                    [strongSelf performSelector:@selector(dissmissProgress) withObject:nil afterDelay:0.4];
                    if (success) {
                        strongSelf.isSelf = isSelf;
                        [strongSelf friendBtnIsShow];
                        if (isSelf) {
                            [[SDImageCache sharedImageCache] removeImageForKey:[UserModel currentUserInfo].avatar fromDisk:YES];
                        }
                        [strongSelf.user setValueWithObject:data];
                        UserInfoModel *info = data;
                        strongSelf.user.username = info.username;
                        strongSelf.user.friends = info.friends;
                        strongSelf.user.is_my_friend = info.is_my_friend;
                        [[SDImageCache sharedImageCache] removeImageForKey:info.avatar fromDisk:YES];
                        [strongSelf resetValuesWithModel:strongSelf.user];
                    } else {
                        [strongSelf showHudTipStr:data];
                    }
                }];
}

//重新赋值
- (void)resetValuesWithModel:(id)model
{
    if (self.isSelf) {
        //        _titlevalue = @"我的主页";
        _rightButton.hidden = YES;
        [_iv_avatar sd_setImageWithURL:[NSURL URLWithString:_user.avatar] placeholderImage:kIMG(@"portrait")];
    }
    else {
        //        _titlevalue = @"TA的主页";
        _rightButton.hidden = NO;
    }
    _lbl_title_normal.text = _titlevalue;
    
    
    UserModel *user = model;
    _lbl_name.text = [@"" isEqualToString:user.username] ? @"" : user.username;
    NSString *infoValue = @"";
    if (user.extcredits && user.extcredits.count > 0) {
        int num = user.extcredits.count > 3 ? 3 : (int)user.extcredits.count;
        for (int i = 0; i < num; i++) {
            NSString *name = user.extcredits[i][@"name"];
            NSNumber *value = user.extcredits[i][@"value"];
            NSString *str = [NSString stringWithFormat:@"%@  %@  ",name,value];
            if (i == 0) {
                infoValue = str;
            } else {
                NSString *str1 = [NSString stringWithFormat:@"| %@",str];
                infoValue = [infoValue stringByAppendingString: str1];
            }
        }
    }
    _lbl_otherInfo.text = infoValue;
    if (!user.gender) {
        [_iv_gender setHidden:YES];
    } else {
        if (user.gender.intValue == 0) {
            //TODO 性别保密
            [_iv_gender setHidden:YES];
        } else {
            [_iv_gender setHidden:NO];
            NSString *ivName = user.gender.intValue == 1 ? @"left_menu_male" : @"left_menu_female";
            [_iv_gender setImage:kIMG(ivName)];
        }
        //        if ([user.gender isEqualToString:@"0"]) {
        //            //TODO 性别保密
        //            [_iv_gender setHidden:YES];
        //        } else {
        //            [_iv_gender setHidden:NO];
        //            NSString *ivName = [user.gender isEqualToString:@"1"] ? @"left_menu_male" : @"left_menu_female";
        //            [_iv_gender setImage:kIMG(ivName)];
        //        }
    }
    //    if ([Util isNetWorkAvalible]) {
    //        [self changeAvatar];
    //    }
    [_iv_avatar sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:kIMG(@"portrait") completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        //        if (image) {
        //            UIImage *blurImage  = [image applyLightEffect];
        //            [_iv_topView setImage:blurImage];
        //        } else {
        //            _iv_topView.image = [Util imageWithColor:[UIColor returnColorWithPlist:YZSegMentColor]];
        //        }
    }];
    _titleLabel.text = _lbl_name.text;
    if (![user.is_my_friend isEqualToString:@"0"]) {
        //是自己好友
        _isMyFriend = YES;
        [_my_addFriendBtn setImage:kIMG(@"shanhaoyou") forState:UIControlStateNormal];
    }else{
        _isMyFriend = NO;
        [_my_addFriendBtn setImage:kIMG(@"tianjiahaoyou") forState:UIControlStateNormal];
    }
    [_tableview reloadData];
}

- (void)goChatPage
{
    if ([self checkLoginState]) {
        NSArray *arr = self.navigationController.viewControllers;
        if ([arr[arr.count-2] isKindOfClass:[ChatViewController class]]) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            ChatViewController *chat = [[ChatViewController alloc]initWithNibName:NSStringFromClass([ChatViewController class]) bundle:nil];
            DialogListModel *model = [DialogListModel new];
            model.msgtoid = _user.uid;
            model.tousername = _user.username;
            chat.dialogModel = model;
            [self.navigationController pushViewController:chat animated:YES];
        }
    }
}

#pragma mark - 设置加好友按钮是否显示
- (void)friendBtnIsShow{
    //加好友按钮
    UIButton *addFriend = [UIButton createButtonWithTitle:nil andFrame:CGRectZero andBgImage:nil andImage:kIMG(@"tianjiahaoyou") target:self action:@selector(tapFriend)];
    addFriend.titleLabel.font = [UIFont systemFontOfSize:11.0f];
    [addFriend setTitleEdgeInsets:UIEdgeInsetsMake(1, 6, 0, 0)];
    _my_addFriendBtn = addFriend;
    //发消息按钮
    UIButton *postChat = [UIButton createButtonWithTitle:nil andFrame:CGRectZero andBgImage:nil andImage:kIMG(@"faxinxi") target:self action:@selector(tapChat)];
    postChat.titleLabel.font = [UIFont systemFontOfSize:11.0f];
    [postChat setTitleEdgeInsets:UIEdgeInsetsMake(1, 6, 0, 0)];
    
    
    if (!self.isSelf) {
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
#pragma mark - 举报按钮
- (void)reportAction{
    UIActionSheet *alertView = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"举报" otherButtonTitles:nil, nil];
    [alertView showInView:self.view];
}

#pragma mark - tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    if (self.isSelf) {
        return 4;
    }
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return 2;
    }else if (section == 2){
        return 3;
    }else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (_user.extcredits.count > 1) {
            _myinfo_cell.userModel = _user;
            return _myinfo_cell;
        }else if (_user.extcredits.count == 1){
            _myinfo2_cell.userModel = _user;
            return _myinfo2_cell;
        }else{
            _myinfo3_cell.userModel = _user;
            return _myinfo3_cell;
        }
    }else if (indexPath.section == 1){
        static NSString *identifer = @"InfoCell1";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifer];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
        cell.textLabel.textColor = UIColorFromRGB(0x424242);
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0f];
        cell.detailTextLabel.textColor = UIColorFromRGB(0xa6a6a6);
        if (indexPath.row == 0) {
            cell.textLabel.text = @"所在群组";
            cell.detailTextLabel.text = (self.user.group_title) ? self.user.group_title : @"";
        }else{
            cell.textLabel.text = @"注册时间";
            cell.detailTextLabel.text = self.user.regdate;
            
        }
        if (indexPath.row != 1) {
            UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(15, 47.5, kSCREEN_WIDTH-15, 0.5)];
            line.image = [Util imageWithColor:kUIColorFromRGB(0xeaeaee)];
            [cell.contentView addSubview:line];
        }
        return cell;
        
        //        _userinfo_cell.lbl_brith.text = (self.user.group_title) ? self.user.group_title : @"";
        //        _userinfo_cell.lbl_regdate.text = self.user.regdate;
        //        return _userinfo_cell;
    }
    else {
        static NSString *identifer = @"InfoCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
        cell.textLabel.textColor = UIColorFromRGB(0x424242);
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0f];
        cell.detailTextLabel.textColor = UIColorFromRGB(0xa6a6a6);
        if (indexPath.section == 2) {
            //            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.accessoryView = [[UIImageView alloc]initWithImage:kIMG(@"jiantou_me")];
            if (indexPath.row == 0) {
                cell.textLabel.text = @"好友数";
                if (_user.friends && _user.friends.length > 0) {
                    [cell.contentView addSubview:[self cellNumberWithString:_user.friends]];
                }
            }else if (indexPath.row == 1){
                cell.textLabel.text = @"回帖数";
                if (_user.threads && _user.threads.length > 0) {
                    [cell.contentView addSubview:[self cellNumberWithString:_user.posts]];
                }
            }else{
                if (_user.posts && _user.posts.length > 0) {
                    cell.textLabel.text = @"发帖数";
                    [cell.contentView addSubview:[self cellNumberWithString:_user.threads]];
                }
            }
            if (indexPath.row != 2) {
                UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(15, 47.5, kSCREEN_WIDTH-15, 0.5)];
                line.image = [Util imageWithColor:kUIColorFromRGB(0xeaeaee)];
                [cell.contentView addSubview:line];
            }
            
        }
        else {
            UIView *v = [cell.contentView viewWithTag:5566];
            [v removeFromSuperview];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
            cell.textLabel.textColor = UIColorFromRGB(0x424242);
            cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0f];
            cell.detailTextLabel.textColor = UIColorFromRGB(0xa6a6a6);
            cell.textLabel.text = @"退出登录";
        }
        return cell;
    }
}

#pragma mark - tableview delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 45;
    }else{
        return 50;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 15.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 15)];
    view.backgroundColor = UIColorFromRGB(0xf3f3f3);
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2) {
        //TODO : 跳转到好友页面
        if (indexPath.row == 0) {
            FriendsViewController *friends = [[FriendsViewController alloc]init];
            if (_isSelf) {
                friends.uid = nil;
            } else {
                friends.uid = _user.uid;
            }
            [self.navigationController pushViewController:friends animated:YES];
        }else if (indexPath.row == 1) {
            if ([self checkLoginState]) {
                MyPostViewController *mypost = [[MyPostViewController alloc]init];
                mypost.userId = _user.uid;
                mypost.selectedIndex = 1;
                [self.navigationController pushViewController:mypost animated:YES];
            }
        }else if (indexPath.row == 2) {
            if ([self checkLoginState]) {
                MyPostViewController *mypost = [[MyPostViewController alloc]init];
                mypost.userId = _user.uid;
                mypost.selectedIndex = 0;
                [self.navigationController pushViewController:mypost animated:YES];
            }
        }
    }
    else if (indexPath.section == 3) {
        //TODO 退出登录
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"确定退出登录吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
}

#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat yOffset  = scrollView.contentOffset.y;
    if (yOffset < -kHeaderHeight) {
        CGRect f = _iv_topView.frame;
        f.origin.y = yOffset;
        f.size.height =  -yOffset;
        _iv_topView.frame = f;
        [_iv_topView setNeedsLayout];
    }
    //    float cLocationY = scrollView.contentOffset.y;
    //    if (_lastLocationY < cLocationY) {
    //        //像下滑动--固定view的位置在self.view上面
    //        if (scrollView.contentOffset.y >= -kStayHeight)
    //        {
    //            if (!_tempTopView) {
    //                _tempTopView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -kHeaderHeight+kStayHeight, kSCREEN_WIDTH, kHeaderHeight)];
    //                _tempTopView.image = [Util imageWithColor:[UIColor returnColorWithPlist:YZSegMentColor]];
    //                [self.view addSubview:_tempTopView];
    //            }
    //        }
    //    }
    //    else {
    //        //像上滑动 移开
    //        if (scrollView.contentOffset.y <= -kStayHeight) {
    //            if (_tempTopView != nil) {
    //                [_tempTopView removeFromSuperview];
    //                _tempTopView = nil;
    //            }
    //        }
    //    }
    //    _lastLocationY = cLocationY;
    //    int offset = scrollView.contentOffset.y - _startPoint.y;
    //    if (offset < 0) {
    //        _iv_avatar.alpha = 1;
    //    }
    //    else if(offset >= kStayHeight) {
    //        _iv_avatar.alpha = 0;
    //    }
    //    else {
    //        _iv_avatar.alpha = 1 - (scrollView.contentOffset.y - _startPoint.y)/kStayHeight;
    //    }
    //
    //    if (offset < 0) {
    //        _lbl_title_normal.alpha = 1;
    //    }
    //    else if(offset >= 33) {
    //        _lbl_title_normal.alpha = 0;
    //    }
    //    else {
    //        _lbl_title_normal.alpha = 1 - offset/33.0;
    //
    //    }
    //
    //    if (offset < 0) {
    //        _lbl_name.alpha = 1;
    //        _iv_gender.alpha = 1;
    //    }
    //    else if(offset >= kStayHeight+95) {
    //        _lbl_name.alpha = 0;
    //        _iv_gender.alpha = 0;
    //    }
    //    else {
    //        _lbl_name.alpha = 1 - offset/(kStayHeight+95);
    //        _iv_gender.alpha = 1 - offset/(kStayHeight+95);
    //    }
    //
    //    if (offset < 0) {
    //        _lbl_otherInfo.alpha = 1;
    //    }
    //    else if(offset >= kStayHeight+115) {
    //        _lbl_otherInfo.alpha = 0;
    //    }
    //    else {
    //        _lbl_otherInfo.alpha = 1 - offset/(kStayHeight+115);
    //    }
    //
    //    if (scrollView.contentOffset.y>-kStayHeight+30) {
    //        _titleLabel.alpha = 1.0;
    //        [self.view bringSubviewToFront:_titleLabel];
    //    }
    //    else if (scrollView.contentOffset.y<-kStayHeight) {
    //        _titleLabel.alpha = 0;
    //    }
    //    else {
    //        float ff = fabs(scrollView.contentOffset.y+kStayHeight);
    //        _titleLabel.alpha = ff/30.0;
    //        [self.view bringSubviewToFront:_titleLabel];
    //    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //    DLog(@"*** %@",NSStringFromCGRect(_iv_topView.frame));
    float offset = scrollView.contentOffset.y - _startPoint.y;
    if ( offset < -75) {
        _refresh = YES;
    }
}

#pragma mark -  LucPhotoHelperDelegate （头像截取成功）

- (void)LucPhotoHelperGetPhotoSuccess:(UIImage *)image
{
    WEAKSELF
    [_userViewModel upLoadAvatar:image andReturenBlock:^(bool success, id data) {
        STRONGSELF
        [strongSelf changeAvatar];
    }];
}

//修改头像
- (void)changeAvatar
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Avatar_Changed" object:nil];
    [[SDImageCache sharedImageCache] removeImageForKey:_user.avatar fromDisk:YES];
    [_iv_topView setImage:[Util imageWithColor:[UIColor returnColorWithPlist:YZSegMentColor]]];
    [_iv_avatar sd_setImageWithURL:[NSURL URLWithString:_user.avatar] placeholderImage:kIMG(@"portrait")];
    //    [_iv_avatar sd_setImageWithURL:[NSURL URLWithString:_user.avatar] placeholderImage:kIMG(@"portrait") completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    //        if (image) {
    //            UIImage *blurImage  = [image applyLightEffect];
    //            [_iv_topView setImage:blurImage];
    //        }
    //    }];
}

#pragma mark - 字数
- (UIButton *)cellNumberWithString:(NSString *)string{
    UIFont *butfont = [UIFont systemFontOfSize:15.f];
    UIButton *v = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *bgImg = [Util imageWithColor:kUIColorFromRGB(0xf34a5a)];
    [v setBackgroundImage:bgImg forState:UIControlStateNormal];
    v.clipsToBounds = YES;
    [v setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [v.titleLabel setFont:butfont];
    CGSize size = [Util sizeWithString:string font:butfont constraintSize:CGSizeMake(200, 20)];
    size.width = size.width > 30 ? size.width : 30;
    v.frame = CGRectMake(kSCREEN_WIDTH-45-size.width, 15, size.width, 20);
    v.layer.cornerRadius = kVIEW_H(v)/2;
    [v setTitle:string forState:UIControlStateNormal];
    v.tag = 5566;
    v.titleLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_SUBTITLE];
    return v;
}
#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        UserModel *_cuser = [UserModel currentUserInfo];
        [_cuser logout];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kKEY_CURRENT_USER];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [ClanNetAPI removeCookieData];
        //清除收藏的数组
        [Util cleanUpLocalFavoArray];
        //清除信息
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"KNEWS_MESSAGE"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KNEWS_MESSAGE_COME" object:nil];
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"KNEWS_FRIEND_MESSAGE"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KNEWS_FRIEND_MESSAGE" object:nil];
        [self.tableview reloadData];
        [self showHudTipStr:@"已成功退出登录"];
        //name大标题
        _titleLabel.text = @"点击头像登录";
        [_iv_avatar sd_cancelCurrentAnimationImagesLoad];
        [_iv_avatar sd_cancelCurrentImageLoad];
        [_iv_avatar setImage:kIMG(@"portrait")];
        [_iv_topView setImage:[Util imageWithColor:[UIColor returnColorWithPlist:YZSegMentColor]]];
        _lbl_name.text = @"点击头像登录";
        _iv_gender.hidden = YES;
        _lbl_otherInfo.text = @"登录后可使用更多功能哦~";
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark UIActionView
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        ReportViewController *reportView = [[ReportViewController alloc]init];
        reportView.state = ClanReportUser;
        [self.navigationController pushViewController:reportView animated:YES];
    }
}

@end
