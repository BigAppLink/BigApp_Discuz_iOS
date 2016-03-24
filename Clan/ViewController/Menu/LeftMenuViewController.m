
//
//  LeftMenuViewController.m
//  Clan
//
//  Created by chivas on 15/3/3.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "UserInfoViewModel.h"
#import "LoginViewController.h"
#import "MyPostViewController.h"
#import "SettingViewController.h"
#import "MainHomeViewController.h"
#import "BaseSegmentViewController.h"
//#import "DialogListViewController.h"
#import "UserInfoModel.h"
#import "CollectionViewModel.h"
#import "TOWebViewController.h"
#import "FriendsViewController.h"
#import "FriendsViewModel.h"
#import "MessageController.h"
#import "PostDetailViewController.h"
#import "PostDetailVC.h"
#import "LucPhotoHelper.h"


@interface LeftMenuViewController () <UITableViewDataSource, UITableViewDelegate,LucPhotoHelperDelegate>
{
    NSArray *_titleArr;
    NSArray *_iconArr;
    NSArray *_actionArr;
    UILabel *_nickLabel;
    UIImageView *_portraitIV;
    UIImageView *_genderIV;
    BOOL _updateComplete;
    UserInfoViewModel *_userViewModel;
    CollectionViewModel *_favoViewModel;
    UITableView *_tableView;
    NSDate *_lastDate;
    //用于站内信轮询
    NSTimer *_timer;
}
@property (nonatomic, strong) UIScrollView *sv_content;
@property (nonatomic, strong) UILabel *lbl_info;
@property (nonatomic, strong) UIButton *qiandaoBtn;
@property (nonatomic, strong) FriendsViewModel *friendsviewmodel;
@property (strong, nonatomic) LucPhotoHelper *photoHelper;


@end

@implementation LeftMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initModel];
    [self buildUI];
    if ([UserModel currentUserInfo].logined && [Util isNetWorkAvalible]) {
        //重新启动 要换头像
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Avatar_Changed" object:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[UserModel currentUserInfo] removeObserver:self forKeyPath:@"logined"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - timer
#pragma mark - timer
//停止计时器
- (void)stopTimer
{
    //开始拖动scrollview的时候 停止计时器控制的跳转
    [_timer invalidate];
    _timer = nil;
}
//开始计时器
- (void)startTimer
{
    [self stopTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:5.f target:self selector:@selector(doAutoCheck) userInfo:nil repeats:YES];
}

- (void)doAutoCheck
{
    [self doCheckIfHasNewFriends];
}


- (void)initModel
{
    _friendsviewmodel = [FriendsViewModel new];
    _lastDate = [NSDate date];
    _titleArr = @[@"消息", @"我的帖子", @"我的收藏", @"我的好友", @"设置"];
    _iconArr = @[@"left_menu_xiaoxi", @"left_menu_tiezi", @"left_menu_shoucang",@"left_menu_haoyou", @"left_menu_shezhi"];//
    _actionArr = @[
                   NSStringFromSelector(@selector(goMess)),
                   NSStringFromSelector(@selector(goPosts)),
                   NSStringFromSelector(@selector(goFavo)),
                   NSStringFromSelector(@selector(goFriends)),
                   NSStringFromSelector(@selector(goSetting))
                   ];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCome:) name:@"KNEWS_MESSAGE_COME" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCome:) name:@"Avatar_Changed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCome:) name:kCookie_expired object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCome:) name:@"CheckInSwitch_Changed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCome:) name:@"KNEWS_FRIEND_MESSAGE" object:nil];
}

- (void)buildUI
{
    self.view.backgroundColor = kCOLOR_BG_GRAY;
    _sv_content = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT)];
    _sv_content.showsVerticalScrollIndicator = NO;
//    _sv_content
    [self.view addSubview:_sv_content];
    
    //头像
    UIImageView *pIV = [[UIImageView alloc]initWithImage:kIMG(@"portrait")];
    pIV.frame = CGRectMake((kVISIBLE_WIDTH-100)/2, 64, 75, 75);
    pIV.layer.cornerRadius = kVIEW_W(pIV)/2;
    pIV.layer.borderWidth = 4;
    pIV.layer.borderColor = UIColorFromRGB(0xe7e7e7).CGColor;
    pIV.clipsToBounds = YES;
    pIV.layer.allowsEdgeAntialiasing = true;

    _portraitIV = pIV;
    [_sv_content addSubview:pIV];
    
//    UIButton *loginBTN = [UIButton buttonWithType:UIButtonTypeCustom];
//    loginBTN.backgroundColor = kCLEARCOLOR;
//    loginBTN.frame = pIV.frame;
//    [loginBTN addTarget:self action:@selector(avatarTapAction) forControlEvents:UIControlEventTouchUpInside];
//    [_sv_content addSubview:loginBTN];
    
    //昵称
    UILabel *label = [[UILabel alloc]init];
    //    label.text = @"昔米爱大白";
    label.text = @"";
    label.font = [UIFont fitFontWithSize:16.f];
    label.textColor = K_COLOR_DARK;
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    label.center = CGPointMake(kVIEW_CENTERX(pIV), kVIEW_BY(pIV)+10+6);
    label.backgroundColor = kCLEARCOLOR;
    _nickLabel = label;
    [_sv_content addSubview:label];
    
    //性别
    UIImageView *genderImg = [[UIImageView alloc]initWithImage:kIMG(@"left_menu_female")];
    _genderIV.center = CGPointMake(kVIEW_BX(_nickLabel)+5+10, _nickLabel.center.y);
    _genderIV = genderImg;
    _genderIV.hidden = YES;
    [_sv_content addSubview:genderImg];
    
    //userinfo
    _lbl_info = [[UILabel alloc]initWithFrame:CGRectMake(kVIEW_TX(_nickLabel), kVIEW_BY(_nickLabel), kVIEW_W(_nickLabel), 20)];
    _lbl_info.font = [UIFont fitFontWithSize:11.f];
    _lbl_info.textColor = K_COLOR_DARK_Cell;
    _lbl_info.textAlignment = NSTextAlignmentCenter;
    _lbl_info.backgroundColor = kCLEARCOLOR;
    [_sv_content addSubview:_lbl_info];
    
    //签到按钮
    UIButton *qiandaobtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [qiandaobtn setImage:kIMG(@"qiandao") forState:UIControlStateNormal];
    qiandaobtn.exclusiveTouch = YES;
    qiandaobtn.showsTouchWhenHighlighted = YES;
    self.qiandaoBtn = qiandaobtn;
    [qiandaobtn addTarget:self action:@selector(doCheckInAction) forControlEvents:UIControlEventTouchUpInside];
    qiandaobtn.frame = CGRectMake(0, 0, 104, 42);
    qiandaobtn.center = CGPointMake(_nickLabel.center.x, kVIEW_BY(_lbl_info)+22+8);
    [_sv_content addSubview:qiandaobtn];

    
    //分割线
//    UIView *linev = [UIView new];
//    linev.frame = CGRectMake(30, kVIEW_BY(qiandaobtn)+10, kSCREEN_WIDTH-30, 0.5);
//    linev.backgroundColor = [UIColor clearColor];
//    [_sv_content addSubview:linev];
    
    float tableHeight = 6*50 > (kSCREEN_HEIGHT-kVIEW_BY(qiandaobtn)-10) ? 6*50: (kSCREEN_HEIGHT-kVIEW_BY(qiandaobtn)-10);
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kVIEW_BY(qiandaobtn)+10, kSCREEN_WIDTH, tableHeight) style:UITableViewStylePlain];
    //    tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView = tableView;
    _tableView.scrollEnabled = NO;
    [_sv_content addSubview:tableView];
    [Util setExtraCellLineHidden:_tableView];
    [self resetContentSize];
    
    //注册监听模式
    UserModel *cUser = [UserModel currentUserInfo];
    [cUser addObserver:self forKeyPath:@"logined" options:NSKeyValueObservingOptionNew context:NULL];
    [self setLoginStatus];
    [self resetCheckInStatus];
}

- (void)resetContentSize
{
    float heightM = kVIEW_BY(_tableView) > kSCREEN_HEIGHT ? kVIEW_BY(_tableView)+40 : kSCREEN_HEIGHT+40;
    [_sv_content setContentSize:CGSizeMake(kSCREEN_WIDTH, heightM)];
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SEL sel = NSSelectorFromString(_actionArr[indexPath.row]);
    [self performSelector:sel withObject:nil];
}

#pragma mark - tableview datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return _titleArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont fitFontWithSize:15.f];
        cell.textLabel.textColor = K_COLOR_DARK;
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor whiteColor];
        UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(17, 50-0.5, kSCREEN_WIDTH, 0.5)];
        line.image = [Util imageWithColor:UIColorFromRGB(0xeeeeee)];
        line.tag = 1199;
        [cell.contentView addSubview:line];
        UIImageView *jiantou = [[UIImageView alloc]initWithImage:kIMG(@"jiantou_me")];
        jiantou.center = CGPointMake(kSCREEN_WIDTH-130, 50/2);
        [cell.contentView addSubview:jiantou];
    }
    cell.textLabel.text = _titleArr[indexPath.row];
    UIImageView *line = (UIImageView *)[cell.contentView viewWithTag:1199];
    line.image = [Util imageWithColor:UIColorFromRGB(0xeeeeee)];
    if ([cell.textLabel.text isEqualToString:@"站内消息"]) {
        UIView *newmess = [cell.contentView viewWithTag:9876];
        [newmess removeFromSuperview];
        newmess = nil;
        NSNumber *valNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"KNEWS_MESSAGE"];
        if (valNum && valNum.intValue != 0) {
            //改变
            UIButton *newMess_btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [cell.contentView addSubview:newMess_btn];
            newMess_btn.enabled = NO;
            newMess_btn.layer.cornerRadius = 10;
            newMess_btn.clipsToBounds = YES;
            newMess_btn.tag = 9876;
            if (valNum.intValue > 99) {
                [newMess_btn setTitle:@"99+" forState:UIControlStateNormal];
            } else {
                [newMess_btn setTitle:[NSString stringWithFormat:@"%@",valNum] forState:UIControlStateNormal];
            }
            [newMess_btn.titleLabel setFont:[UIFont fitFontWithSize:K_FONTSIZE_SUBTITLE]];
            [newMess_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [newMess_btn setBackgroundImage:[Util imageWithColor:[UIColor redColor]] forState:UIControlStateNormal];
            [newMess_btn setBackgroundColor:[UIColor redColor]];
            [newMess_btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(cell.imageView.mas_centerX).offset(7);
                make.centerY.equalTo(cell.imageView.mas_centerY).offset(-10);
                make.width.equalTo(@20);
                make.height.equalTo(@20);
            }];
        }
    }
    else {
        UIView *line = [cell.contentView viewWithTag:1111];
        [line removeFromSuperview];
        line = nil;
        UIView *newmess = [cell.contentView viewWithTag:2222];
        [newmess removeFromSuperview];
        newmess = nil;
    }
    
    if ([cell.textLabel.text isEqualToString:@"我的好友"]) {
        if ([self newFriendTip]) {
            cell.imageView.image = kIMG(@"left_menu_xinhaoyou");

        } else {
            cell.imageView.image = kIMG(@"left_menu_haoyou");
        }
    } else {
        cell.imageView.image = [UIImage imageNamed:_iconArr[indexPath.row]];
    }
    return cell;
}

#pragma mark - actions
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
        [self.sideMenuViewController hideMenuViewController];
        return NO;
    } else {
        return YES;
    }
}

//跳转到“我的收藏”
- (void)goFavo
{
    if ([self checkLoginState]) {
        
        BaseSegmentViewController *segMent = [[BaseSegmentViewController alloc]init];
        segMent.segmentType = segmentCollection;
        [self.sideMenuViewController pushVC:segMent];
        
    }
}

//跳转到“站内信”
- (void)goMess
{
    if ([self checkLoginState]) {
        MessageController *messagevc = [[MessageController alloc]init];
        [self.sideMenuViewController pushVC:messagevc];
//        DialogListViewController *dialog = [[DialogListViewController alloc]initWithNibName:NSStringFromClass([DialogListViewController class]) bundle:nil];
//        [self.sideMenuViewController pushVC:dialog];
        
    }
}

//我的好友
- (void)goFriends
{
    if ([self checkLoginState]) {
        FriendsViewController *friends = [[FriendsViewController alloc]init];
        [self.sideMenuViewController pushVC:friends];
    }
}

//跳转到“我的帖子”
- (void)goPosts
{
    if ([self checkLoginState]) {
        
        MyPostViewController *post = [[MyPostViewController alloc]init];
        post.userId = [UserModel currentUserInfo].uid;
        [self.sideMenuViewController pushVC:post];
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
        [self.sideMenuViewController pushVC:main];
    }
}

//跳转到“设置”
- (void)goSetting
{
    SettingViewController *setting = [[SettingViewController alloc]init];
    [self.sideMenuViewController pushVC:setting];
}

#pragma mark - 设置头像
- (void)faceStyle{
    NSString *changeAvaEnable = [NSString returnPlistWithKeyValue:KAllowAvatarChange];
    //打开开关
    if (!changeAvaEnable || changeAvaEnable.intValue == 1){
        [self addAvatarAction];
    }else{
        if (![UserModel currentUserInfo].logined) {
            [self addAvatarAction];
        }else{
            _portraitIV.userInteractionEnabled = NO;
        }
    }
}

- (void)addAvatarAction{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    [tapGestureRecognizer addTarget:self action:@selector(gestureRecognizerHandle:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    _portraitIV.userInteractionEnabled = YES;
    [_portraitIV addGestureRecognizer:tapGestureRecognizer];
}

#pragma mark - 编辑头像
- (void)gestureRecognizerHandle: (UITapGestureRecognizer *)recognizer
{
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
    UserModel *cUser = [UserModel currentUserInfo];

    [[SDImageCache sharedImageCache] removeImageForKey:cUser.avatar fromDisk:YES];
    [_portraitIV sd_setImageWithURL:[NSURL URLWithString:cUser.avatar] placeholderImage:kIMG(@"portrait")];

}

#pragma mark - 登录 登出 状态发生变化监听
- (void)setLoginStatus
{
    UserModel *_cuser = [UserModel currentUserInfo];
    [self faceStyle];
    if (_cuser.logined) {
        [self requestCheckInSwitchStatus];
        [self doLogin];
        //若登录则去请求个人信息
        if (!_userViewModel) {
            _userViewModel = [UserInfoViewModel new];
        }
        WEAKSELF
        [_userViewModel requestApi:nil andReturnBlock:^(bool success, id data, bool isSelf) {
            STRONGSELF
            if (success) {
                UserModel *user = [UserModel currentUserInfo];
                [user setValueWithObject:data];
                [UserModel saveToLocal];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"getUserInfo" object:nil];
                [strongSelf doLogin];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"updateFaceImage" object:nil];

            } else {
//                [strongSelf doLogout];
            }
        }];
    } else {
        [self.sideMenuViewController popToRoot];
        [self doLogout];
        
    }
}


- (void)doLogin
{
    //昵称
    UserModel *_cuser = [UserModel currentUserInfo];
    _nickLabel.text = _cuser.username ? _cuser.username : @"";
    [_nickLabel sizeToFit];
    _nickLabel.center = CGPointMake(kVIEW_CENTERX(_portraitIV), kVIEW_BY(_portraitIV)+10+6);
    [_portraitIV sd_setImageWithURL:[NSURL URLWithString:_cuser.avatar] placeholderImage:kIMG(@"portrait")];
    _lbl_info.text = [UserInfoViewModel infoForUser:_cuser];
    [_lbl_info sizeToFit];
    _lbl_info.center = CGPointMake(kVIEW_CENTERX(_portraitIV), kVIEW_BY(_nickLabel)+10+7);    //头像
    if ([Util isBlankString:_cuser.gender]) {
        [_genderIV setHidden:YES];
    }
    else {
        [_genderIV setHidden:NO];
        if (_cuser.gender.intValue == 0) {
            [_genderIV setImage:nil];
        } else {
            NSString *genderName = _cuser.gender.intValue == 1 ? @"left_menu_male" : @"left_menu_female";
            [_genderIV setImage:kIMG(genderName)];
        }
//        if ([_cuser.gender isEqualToString:@"0"]) {
//            [_genderIV setImage:nil];
//        } else {
//            NSString *genderName = [_cuser.gender isEqualToString:@"1"] ? @"left_menu_male" : @"left_menu_female";
//            [_genderIV setImage:kIMG(genderName)];
//        }
    }
    _genderIV.center = CGPointMake(kVIEW_BX(_nickLabel)+5+10, _nickLabel.center.y);
//    _genderIV.frame = CGRectMake(kVIEW_BX(_nickLabel)+5, kVIEW_TY(_nickLabel)+3.5, 13, 13);
    _qiandaoBtn.center = CGPointMake(_nickLabel.center.x, kVIEW_BY(_lbl_info)+22+5);
}

- (void)doLogout
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userLogout" object:nil];
    //清除本地收藏
    [Util cleanUpLocalFavoArray];
    _nickLabel.text = @"点击头像登录";
    [_nickLabel sizeToFit];
    _nickLabel.center = CGPointMake(kVIEW_CENTERX(_portraitIV), kVIEW_BY(_portraitIV)+10+6);
    [_portraitIV sd_cancelCurrentImageLoad];
    [_portraitIV sd_cancelCurrentAnimationImagesLoad];
    [_portraitIV setImage:kIMG(@"portrait")];
    [_genderIV setHidden:YES];
    _genderIV.center = CGPointMake(kVIEW_BX(_nickLabel)+5+10, _nickLabel.center.y);
    _lbl_info.text = @"登录有更多惊喜哦~";
    [_lbl_info sizeToFit];
    _lbl_info.center = CGPointMake(kVIEW_CENTERX(_portraitIV), kVIEW_BY(_nickLabel)+10+7);
    
    [self resetCheckInStatus];
}

- (void)notificationCome:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"Avatar_Changed"]) {
        [[SDImageCache sharedImageCache] removeImageForKey:[UserModel currentUserInfo].avatar fromDisk:YES];
        if ([UserModel currentUserInfo].logined) {
            [_portraitIV sd_setImageWithURL:[NSURL URLWithString:[UserModel currentUserInfo].avatar] placeholderImage:kIMG(@"portrait")];
        }
    }
    else if ([noti.name isEqualToString:kCookie_expired]) {
        //TODO logout
        UserModel *_cuser = [UserModel currentUserInfo];
        [_cuser logout];
    }
    else if ([noti.name isEqualToString:@"KNEWS_MESSAGE_COME"]) {
        [_tableView reloadData];
    }
    //签到信息更新
    else if ([noti.name isEqualToString:@"CheckInSwitch_Changed"]) {
        [self resetCheckInStatus];
    }
    else if ([noti.name isEqualToString:@"KNEWS_FRIEND_MESSAGE"]) {
        [_tableView reloadData];
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"logined"]) {
        [self setLoginStatus];
    }
}

#pragma mark - RESideMenu 代理方法
- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController
{
    if ([UserModel currentUserInfo].logined) {
        [self doCheckIfHasNewFriends];
        [self startTimer];
    }
    [self requestCheckInSwitchStatus];
    NSDate *cDate = [NSDate date];
    NSTimeInterval date1 = [cDate timeIntervalSince1970]*1;
    NSTimeInterval date2 = [_lastDate timeIntervalSince1970]*1;
    NSTimeInterval cha = date2-date1;
    int min = (int)cha/60%60;
     if ([UserModel currentUserInfo].logined && [Util isNetWorkAvalible] && min > 10) {
         _lastDate = [NSDate date];
         [_portraitIV sd_setImageWithURL:[NSURL URLWithString:[UserModel currentUserInfo].avatar]];
        //刷新头像
//        [[SDImageCache sharedImageCache] removeImageForKey:[UserModel currentUserInfo].avatar fromDisk:YES];
//        [_portraitIV sd_setImageWithURL:[NSURL URLWithString:[UserModel currentUserInfo].avatar] placeholderImage:kIMG(@"portrait")];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"Avatar_Changed" object:nil];
    }
}

- (void)sideMenu:(RESideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController
{
    [self stopTimer];
}

- (void)sideMenu:(RESideMenu *)sideMenu didRecognizePanGesture:(UIPanGestureRecognizer *)recognizer
{
    CGPoint nowPosition = [recognizer translationInView: [self view]];
    CGFloat alpha = (nowPosition.x)/kSCREEN_WIDTH;
    UINavigationController *navi = (UINavigationController *)sideMenu.contentViewController;
    if ([navi isKindOfClass:[UINavigationController class]]) {
        //说明在home页面
        UIViewController *vc = navi.viewControllers[0];
        UIView *view = vc.navigationItem.leftBarButtonItem.customView;
        view.alpha = 1 - alpha;
    }
}

- (void)sideMenu:(RESideMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController
{
    UINavigationController *navi = (UINavigationController *)sideMenu.contentViewController;
    if ([navi isKindOfClass:[UINavigationController class]]) {
        //说明在home页面
        UIViewController *vc = navi.viewControllers[0];
        UIView *view = vc.navigationItem.leftBarButtonItem.customView;
        view.alpha = 0.3;
    }
}

- (void)sideMenu:(RESideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController
{
    UINavigationController *navi = (UINavigationController *)sideMenu.contentViewController;
    if ([navi isKindOfClass:[UINavigationController class]]) {
        //说明在home页面
        UIViewController *vc = navi.viewControllers[0];
        UIView *view = vc.navigationItem.leftBarButtonItem.customView;
        view.alpha = 1;
    }
}

#pragma mark - Action Methods
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
                [strongSelf setLoginStatus];
                [strongSelf resetCheckInStatus];
            }
        }];
    }
}

//签到开关
- (void)requestCheckInSwitchStatus
{
    UserModel *cuser = [UserModel currentUserInfo];
    if (!cuser.logined) {
        return;
    }
    [_userViewModel doCheckIn:cuser.uid docheckInAction:NO andReturenBlock:^(bool success, id data) {
        
    }];
}

#pragma mark - 调整UI
//签到按钮的隐藏
- (void)resetCheckInStatus
{
    NSString *checkin_enabled = [NSString returnPlistWithKeyValue:kcheckin_enabled];
    if (checkin_enabled && checkin_enabled.intValue == 1) {
        _qiandaoBtn.hidden = NO;
        if ([UserModel currentUserInfo].logined) {
            NSString *checked = [[UserModel currentUserInfo] checked];
            if (checked && checked.intValue == 1) {
                [_qiandaoBtn setImage:kIMG(@"yiqiandao") forState:UIControlStateNormal];
                _qiandaoBtn.enabled = NO;
            } else {
                [_qiandaoBtn setImage:kIMG(@"qiandao") forState:UIControlStateNormal];
                _qiandaoBtn.enabled = YES;
            }
        } else {
            [_qiandaoBtn setImage:kIMG(@"qiandao") forState:UIControlStateNormal];
            _qiandaoBtn.enabled = YES;
        }
    } else {
        _qiandaoBtn.hidden = YES;
    }
    if (_qiandaoBtn.hidden) {
        float tableHeight = 6*50 > (kSCREEN_HEIGHT-kVIEW_BY(_lbl_info)-10) ? 6*50: (kSCREEN_HEIGHT-kVIEW_BY(_lbl_info)-10);
        _tableView.frame = CGRectMake(0, kVIEW_BY(_lbl_info)+10, kSCREEN_WIDTH, tableHeight);
    } else {
        float tableHeight = 6*50 > (kSCREEN_HEIGHT-kVIEW_BY(_qiandaoBtn)-30) ? 6*50: (kSCREEN_HEIGHT-kVIEW_BY(_qiandaoBtn)-10);
        _tableView.frame = CGRectMake(0, kVIEW_BY(_qiandaoBtn)+10, kSCREEN_WIDTH, tableHeight);
    }
    [self resetContentSize];
}

- (BOOL)newFriendTip
{
    if (![UserModel currentUserInfo].logined) {
        return NO;
    }
    NSNumber *valNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"KNEWS_FRIEND_MESSAGE"];
    if (!isNull(valNum) && valNum.intValue > 0) {
        return YES;
    } else {
        return NO;
    }
}

//好友消息轮询
- (void)doCheckIfHasNewFriends
{
    [_friendsviewmodel getNewFriendsCountWithReturnBlock:^(NSString *count) {
        if (!isNull(count) && count.intValue >= 1) {
            //有新消息
            [[NSUserDefaults standardUserDefaults] setObject:count forKey:@"KNEWS_FRIEND_MESSAGE"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"KNEWS_FRIEND_MESSAGE" object:nil];
        } else {
            //无新消息
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"KNEWS_FRIEND_MESSAGE"];
        }
    }];
}

@end
