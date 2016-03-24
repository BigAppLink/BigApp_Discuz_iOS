//
//  LoadingVC.m
//  Clan
//
//  Created by 昔米 on 15/11/4.
//  Copyright © 2015年 Youzu. All rights reserved.
//

#import "LoadingVC.h"
#import "AppConfigViewModel.h"
#import "AppDelegate.h"

@interface LoadingVC ()
@property (strong, nonatomic) AppConfigViewModel *configViewModel;
@property (assign) BOOL appPlugcfgLoadingComplete;
@property (assign) BOOL homeIndexcfgLoadingComplete;
@property (assign) BOOL forumsDatasLoadingComplete;
@end

@implementation LoadingVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadmodel];
    [self buildUI];
    [self requestAppBaseDatas];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    DLog(@"Loading VC 销毁");
    _configViewModel = nil;
}

#pragma mark - 初始化
- (void)loadmodel
{
    self.configViewModel = [AppConfigViewModel new];
}

- (void)buildUI
{
    UIImageView *bgView = [UIImageView new];
    bgView.frame = CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT);
    NSString *imgName = [Util splashImageName];
    UIImage *splashImage = kIMG(imgName);
    bgView.image = splashImage;
    [self.view addSubview:bgView];
}

#pragma mark - 请求数据
- (void)requestAppBaseDatas
{
    WEAKSELF
    [_configViewModel getAppBaseConfigWithBlock:^(BOOL result) {
       /*
        * 1、请求插件后面的配置信息
        * 2、请求首页的indexcfg配置信息
        * 3、请求所有的版块儿信息
        */
        [weakSelf requestAppPlugcfg];
        [weakSelf requestHomeIndexcfg];
        [weakSelf requestForumsDatas];
    }];
}

//插件后台的配置信息
- (void)requestAppPlugcfg
{
    WEAKSELF
    [_configViewModel getAppPlugcfgWithBlock:^(BOOL result) {
        weakSelf.appPlugcfgLoadingComplete = YES;
        [weakSelf checkAndCloseLoadingPage];
    }];
}

//请求首页的indexcfg配置信息
- (void)requestHomeIndexcfg
{
    WEAKSELF
    [_configViewModel getAppHomeIndexcfgWithBlock:^(BOOL result) {
        weakSelf.homeIndexcfgLoadingComplete = YES;
        [weakSelf checkAndCloseLoadingPage];
    }];
}

//版块儿所有的信息
- (void)requestForumsDatas
{
    WEAKSELF
    [_configViewModel requestBoardListWithBlock:^(BOOL result) {
        weakSelf.forumsDatasLoadingComplete = YES;
        [weakSelf checkAndCloseLoadingPage];
    }];
}

//检查并关掉loading页面
- (void)checkAndCloseLoadingPage
{
    if (_appPlugcfgLoadingComplete && _homeIndexcfgLoadingComplete && _forumsDatasLoadingComplete) {
        //发通知关闭loadingpage
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KDZ_ColsingLoadingPage" object:nil];
    } else {
        return;
    }
}
@end
