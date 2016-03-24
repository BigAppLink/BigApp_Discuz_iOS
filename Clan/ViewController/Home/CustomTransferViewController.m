//
//  CustomTransferViewController.m
//  Clan
//
//  Created by chivas on 15/11/16.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "CustomTransferViewController.h"
#import "CustomModuleViewController.h"
#import "AboutViewController.h"
#import "CustomHomeMode.h"
#import "HomeItemViewModel.h"
#import "CustomRightItemView.h"
#import "PostSendViewController.h"
#import "HomeViewModel.h"
#import "BoardModel.h"
#import "UIView+Additions.h"
#import "ArticleViewController.h"
#import "WebNaviViewController.h"
@interface CustomTransferViewController ()<CustomRightItemDelegate,WebNavViewDelegate>
@property (strong, nonatomic) HomeItemViewModel *homeItemViewModel;
@property (strong, nonatomic) CustomRightItemView *rightItemView;
@property (strong, nonatomic) HomeViewModel *homeViewModel;
@property (assign, nonatomic) BOOL isShowNavTitle;
@end

@implementation CustomTransferViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeItemBar:) name:KCustomItemNotifi object:nil];
    if (!_homeItemViewModel) {
        _homeItemViewModel = [HomeItemViewModel new];
    }
    [self buildUI];
    [self.view beginLoading];
    [self parseModel];
//    AboutViewController *login = [[AboutViewController alloc]init];
//    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:login];
//    nav.modalPresentationStyle = UIModalPresentationFullScreen;
//    [self presentViewController:nav animated:NO completion:nil];
}

- (void)buildUI{
    UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.backgroundColor = [UIColor clearColor];
    leftButton.frame = CGRectMake(0, 0, 26, 26);
    [leftButton setBackgroundImage :[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
}

//解析数据并调用接口
- (void)parseModel{
    WEAKSELF
    [_homeItemViewModel request_CustomType:_rightItemModel Block:^(id data) {
        STRONGSELF
        [strongSelf.view endLoading];
        if (data) {
            if ([data isKindOfClass:[CustomHomeMode class]]) {
                CustomHomeMode *model = data;
                if (![strongSelf.rightItemModel.tab_type isEqualToString:@"3"] || [model.use_wap_name isEqualToString:@"0"]) {
                    strongSelf.navigationItem.title = model.navTitle;
                    strongSelf.isShowNavTitle = NO;
                }
                if ([strongSelf.rightItemModel.tab_type isEqualToString:@"3"] && [model.use_wap_name isEqualToString:@"1"]) {
                    strongSelf.isShowNavTitle = YES;
                }
                if (model.wap_page) {
                    WebNaviViewController *navWebVc = [[WebNaviViewController alloc]init];
                    navWebVc.delegate = self;
                    navWebVc.customHomeModel = model;
                    navWebVc.navigationButtonsHidden = YES;
                    navWebVc.showPageTitles = NO;
                    navWebVc.url = [NSURL URLWithString:model.wap_page];
                    navWebVc.showUrlWhileLoading = NO;
                    [strongSelf addChildViewController:navWebVc];
                    [strongSelf.view addSubview:navWebVc.view];
                }else{
                    CustomModuleViewController *customVc = [[CustomModuleViewController alloc]init];
                    customVc.customHomeModel = model;
                    [strongSelf addChildViewController:customVc];
                    [strongSelf.view addSubview:customVc.view];
                }
                
            }else if ([data isKindOfClass:[NSMutableArray class]]){
                NSMutableArray *navGetArray = data;
                ArticleViewController *articleVc = [[ArticleViewController alloc]init];
                articleVc.customNavArray = navGetArray;
                [strongSelf addChildViewController:articleVc];
                [strongSelf.view addSubview:articleVc.view];
            }
        }
    }];
}

- (void)changeItemBar:(NSNotification *)info{
    if (info.object) {
        _rightItemView = [[CustomRightItemView alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        _rightItemView.delegate = self;
        _rightItemView.customHomeModel = info.object;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:_rightItemView];
    }
}

- (void)backView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)customRightPostSend{
    [self sendPost];
}
- (void)sendPost
{
    if ([self checkLoginState])
    {
        [self showProgressHUDWithStatus:@"" withLock:YES];
        WEAKSELF
        if (!_homeViewModel) {
            _homeViewModel = [HomeViewModel new];
        }
        [_homeViewModel request_boardBlock:^(id data) {
            STRONGSELF
            [SVProgressHUD dismiss];
            id forumsdata = [UserDefaultsHelper valueForDefaultsKey:kUserDefaultsKey_ForumsStore];
            if (forumsdata && [forumsdata isKindOfClass:[NSArray class]]) {
                NSArray *forumsDataArr = (NSArray *)forumsdata;
                NSMutableArray *forumsArr = [NSMutableArray new];
                for (NSDictionary *dic in forumsDataArr) {
                    BoardModel *boardModel = [BoardModel objectWithKeyValues:dic];
                    [forumsArr addObject:boardModel];
                }
                //存储forums
                if (forumsArr && forumsArr.count > 0) {
                    //存在版块儿 跳转到
                    PostSendViewController *send = [[PostSendViewController alloc]init];
                    send.fromShouYe = YES;
                    send.dataSourceArray = [[NSArray alloc]initWithArray:forumsArr];
                    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:send];
                    [strongSelf presentViewController:navi animated:YES completion:NULL];
                } else {
                    [strongSelf showHudTipStr:@"抱歉，暂无板块儿可以发帖！"];
                }
            }
        }];
    }
}

- (void)webViewTitle:(NSString *)title{
    if (_isShowNavTitle) {
        self.navigationItem.title = title;
    }
}

- (void)dealloc{
    _rightItemView.delegate = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:KCustomItemNotifi object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
