//
//  PostActivityViewController.m
//  Clan
//
//  Created by chivas on 15/10/28.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "PostActivityViewController.h"
#import "PostActivityInfoVC.h"
#import "PostActivityIntroduceVC.h"
#import "PostActivityModel.h"
#import "PostSendModel.h"
#import "PostViewModel.h"
#import "ForumsModel.h"

@interface PostActivityViewController ()
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UIButton *lastButton;
@property (strong, nonatomic) PostActivityInfoVC *postActivityInfoVc;
@property (strong, nonatomic) PostActivityIntroduceVC *postActivityIntroduceVc;
@property (strong, nonatomic) UIViewController *currentVc;
@property (strong, nonatomic) SendActivity *sendActivityModel;
@property (strong, nonatomic) PostViewModel *postViewModel;
@end

@implementation PostActivityViewController

- (void)dealloc{
    NSLog(@"💗退出发帖视图");
}

- (void)viewWillAppear:(BOOL)animated{
    self.title = @"发起活动";
    UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.backgroundColor = [UIColor clearColor];
    leftButton.frame = CGRectMake(0, 0, 26, 26);
    [leftButton setBackgroundImage :[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    [self rightItemType];
    [super viewWillAppear:animated];
}

- (void)rightItemType{
    NSString *title = [_currentVc isEqual:_postActivityInfoVc] ? @"下一步": @"提交";
    UIBarButtonItem *buttonItem = [UIBarButtonItem itemWithBtnTitle:title target:self action:@selector(activityAction)];
    [self.navigationItem setRightBarButtonItem:buttonItem animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if (!_postViewModel) {
        _postViewModel = [PostViewModel new];
    }
    //头部视图
    [self.view addSubview:self.headerView];
    //头部按钮
    [self initWithButtonViewWithHeaderView];
    //设置子视图
    [self addchildVC];
}
#pragma mark - 头部按钮
- (void)initWithButtonViewWithHeaderView{
    NSArray *titleArray = @[@"基本信息",@"活动介绍",@"发布成功"];
    CGFloat itemViewLeft = 0;
    CGFloat itemWidth = ScreenWidth/titleArray.count;
    for (NSInteger index = 0; index < titleArray.count ; index++) {
        UIView *itemView = [[UIView alloc]initWithFrame:CGRectMake(itemViewLeft, 0, itemWidth, 80)];
        itemView.backgroundColor = [UIColor clearColor];
        [_headerView addSubview:itemView];
        UIButton *itemButton = [[UIButton alloc]initWithFrame:CGRectMake(itemView.width/2- 30, itemView.height/2 - 30, 60, 60)];
        itemButton.tag = 100+index;
        itemButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        [itemButton setTitle:titleArray[index] forState:UIControlStateNormal];
        [itemButton setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
        [itemButton setTitleColor:[UIColor returnColorWithPlist:YZSegMentColor] forState:UIControlStateSelected];
        itemButton.backgroundColor = [UIColor clearColor];
        if (index == 0) {
            itemButton.layer.cornerRadius = itemButton.width/2;
            itemButton.layer.borderWidth = 2;
            itemButton.layer.borderColor = [UIColor returnColorWithPlist:YZSegMentColor].CGColor;
            itemButton.clipsToBounds = YES;
            itemButton.selected = YES;
            _lastButton = itemButton;
        }
        [itemButton addTarget:self action:@selector(changeActivity:) forControlEvents:UIControlEventTouchUpInside];
        [itemView addSubview:itemButton];
        itemViewLeft += itemWidth;
    }
}
#pragma mark - 头部视图
- (UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 80)];
        _headerView.backgroundColor = UIColorFromRGB(0xfcfcfc);
    }
    return _headerView;
}

#pragma -mark 设置子视图
- (void)addchildVC{
    _postActivityInfoVc = [[PostActivityInfoVC alloc]init];
    WEAKSELF
    _postActivityInfoVc.returnPostActivityModel = ^(SendActivity *sendActivityModel){
        weakSelf.sendActivityModel = sendActivityModel;
    };
    _postActivityInfoVc.forumModel = _forumModel;
    _postActivityInfoVc.view.frame = CGRectMake(0, _headerView.bottom, ScreenWidth, ScreenHeight - _headerView.height);
    [self addChildViewController:_postActivityInfoVc];
    _postActivityIntroduceVc = [[PostActivityIntroduceVC alloc]init];
    _postActivityIntroduceVc.returnPostActivityModel = ^(SendActivity *sendActivityModel){
        weakSelf.sendActivityModel.sendModel = sendActivityModel.sendModel;
        weakSelf.sendActivityModel.activityImage = sendActivityModel.activityImage;
    };

    _postActivityIntroduceVc.view.frame = CGRectMake(0, _headerView.bottom, ScreenWidth, ScreenHeight - _headerView.height);
    [self.view addSubview:_postActivityInfoVc.view];
    _currentVc = _postActivityInfoVc;
}
#pragma -mark 返回按钮
- (void)cancelBtnClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma -mark 切换活动视图按钮
- (void)changeActivity:(UIButton *)button{
    if ([button isEqual:_lastButton] || button.tag == 102) {
        return;
    }
    if (![self activityPostModelIsTrue]) {
        return;
    }
    _lastButton.selected =! _lastButton.selected;
    if (!_lastButton.selected) {
        _lastButton.layer.borderColor = [UIColor clearColor].CGColor;
    }
    _lastButton = button;
    UIButton *buttonItem = button;
    button.selected = YES;
    buttonItem.layer.cornerRadius = buttonItem.width/2;
    buttonItem.layer.borderWidth = 2;
    buttonItem.layer.borderColor = [UIColor returnColorWithPlist:YZSegMentColor].CGColor;
    buttonItem.clipsToBounds = YES;
    switch (buttonItem.tag) {
        case 100:
            [self replaceController:_currentVc newController:_postActivityInfoVc];
            break;
        case 101:
        [self replaceController:_currentVc newController:_postActivityIntroduceVc];
        break;
        default:
            break;
    }
}

#pragma -mark 切换视图
- (void)replaceController:(UIViewController *)oldController newController:(UIViewController *)newController{
    [self addChildViewController:newController];
    [self transitionFromViewController:oldController toViewController:newController duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        if (finished) {
            [newController didMoveToParentViewController:self];
            [oldController willMoveToParentViewController:nil];
            [oldController removeFromParentViewController];
            _currentVc = newController;
            [self rightItemType];
        }else{
            _currentVc = oldController;
        }
    }];
}

#pragma mark - 点击rightItem按钮
- (void)activityAction{
    if (![self activityPostModelIsTrue]) {
        return;
    }
    if ([_currentVc isEqual:_postActivityIntroduceVc]) {
        if (!_sendActivityModel.sendModel.message || _sendActivityModel.sendModel.message.length == 0) {
            kTipAlert(@"请输入活动详情");
            return;
        }
        self.navigationItem.rightBarButtonItem.enabled = NO;
        _sendActivityModel.fid = _forumModel.fid;
        _sendActivityModel.sendModel.fid = _forumModel.fid;
        _sendActivityModel.sendModel.uploadhash = _forumModel.uploadhash;
        //调用网络层
        if (_sendActivityModel.activityImage) {
            [self coverPost];
        }else{
            [self sendPostActivity];
        }
        return;
    }
    [self replaceController:_currentVc newController:_postActivityIntroduceVc];
    _lastButton.selected =! _lastButton.selected;
    if (!_lastButton.selected) {
        _lastButton.layer.borderColor = [UIColor clearColor].CGColor;
    }
    UIButton *button = (UIButton *)[self.view viewWithTag:101];
    button.selected = YES;
    button.layer.cornerRadius = button.width/2;
    button.layer.borderWidth = 2;
    button.layer.borderColor = [UIColor returnColorWithPlist:YZSegMentColor].CGColor;
    button.clipsToBounds = YES;
    _lastButton = button;
    
}

- (BOOL)activityPostModelIsTrue{
    if (!_sendActivityModel.subject && _sendActivityModel.subject.length == 0) {
        kTipAlert(@"请输入活动名称");
        return NO;
    }else if (!_sendActivityModel.starttimefrom || _sendActivityModel.starttimefrom.length == 0){
        kTipAlert(@"请选择活动时间");
        return NO;
    }else if (!_sendActivityModel.activityplace || _sendActivityModel.activityplace.length == 0){
        kTipAlert(@"请输入活动地点");
        return NO;
    }else if (!_sendActivityModel.activityclass || _sendActivityModel.activityclass.length == 0){
        kTipAlert(@"请选择活动类型");
        return NO;
    }
    return YES;
}

#pragma mark - 退出
- (void)backView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 网络层
- (void)sendPostActivity{
    WEAKSELF
    [_postViewModel request_PostActivity:_sendActivityModel andBlock:^(id data, bool success) {
        STRONGSELF
        strongSelf.navigationItem.rightBarButtonItem.enabled = YES;
        if (success) {
            //发表成功
            [strongSelf performSelector:@selector(backView) withObject:nil afterDelay:.5f];
        }
    }];
}

- (void)coverPost{
    WEAKSELF
    [_postViewModel request_uploadAcitvityFileImage:_sendActivityModel.activityImage withFid:_forumModel.fid withHash:_forumModel.uploadhash andBlock:^(id data, bool success) {
        STRONGSELF
        strongSelf.navigationItem.rightBarButtonItem.enabled = YES;
        strongSelf.sendActivityModel.activityaid_url = data[@"relative_url"];
        strongSelf.sendActivityModel.activityaid = data[@"aId"];
        [strongSelf sendPostActivity];
    }];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
