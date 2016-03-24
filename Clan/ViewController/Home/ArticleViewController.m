//
//  ArticleViewController.m
//  Clan
//
//  Created by chivas on 15/9/6.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ArticleViewController.h"
#import "CustomModuleViewController.h"
#import "ArticleModel.h"
#import "SearchViewController.h"
#import "CustomHomeMode.h"
#import "NavWebViewController.h"
#import "CustomRightItemView.h"
#import "HomeViewModel.h"
#import "PostSendViewController.h"
#import "BoardModel.h"
static NSString * const wapType = @"3";
static NSString * const customType = @"1";

@interface ArticleViewController ()<CustomRightItemDelegate>
{
    BOOL _isReload;
}
@property (strong, nonatomic) CustomRightItemView *rightItemView;
@property (strong, nonatomic) HomeViewModel *homeViewModel;

@end

@implementation ArticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_customNavArray.count > 0) {
        CustomNavModel *navmodel = _customNavArray[0];
        [[NSNotificationCenter defaultCenter]postNotificationName:KCustomItemNotifi object:navmodel.customHomeModel];
        //设置头部右侧按钮
        _rightItemView = [[CustomRightItemView alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        _rightItemView.delegate = self;
        _rightItemView.customHomeModel = navmodel.customHomeModel;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:_rightItemView];
    }
    if ([[UserDefaultsHelper valueForDefaultsKey:kUserDefaultsKey_ClanArticleList] isKindOfClass:[NSArray class]]) {
        NSArray *dataArray = [UserDefaultsHelper valueForDefaultsKey:kUserDefaultsKey_ClanArticleList];
        if (dataArray.count > 0) {
            [self searchActionEnable];
        }
    }
    [self.buttonBarView.selectedBar setBackgroundColor:[UIColor returnColorWithPlist:YZSegMentColor]];
    self.buttonBarView.selectedBarHeight = 3;
    self.navigationItem.title = _nav_title.length > 0 ? _nav_title : [NSString returnStringWithPlist:YZBBSName];
    
}

#pragma mark - XLPagerTabStripViewControllerDataSource

-(NSArray *)childViewControllersForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    NSMutableArray *vcArray = [NSMutableArray arrayWithCapacity:_customNavArray.count];
    for (NSInteger index = 0; index < _customNavArray.count ; index++) {
        CustomNavModel *navModel = _customNavArray[index];
        if ([navModel.tab_type isEqualToString:wapType]) {
            //wap
            NavWebViewController *webView = [[NavWebViewController alloc]init];
            webView.navigationButtonsHidden = YES;
            webView.navi_name = navModel.navi_name;
            webView.url = [NSURL URLWithString:navModel.wap_page];
            [vcArray addObject:webView];
        }else if ([navModel.tab_type isEqualToString:customType]){
            //nav
            CustomModuleViewController *customVc = [[CustomModuleViewController alloc]init];
            customVc.isTabBar = YES;
            customVc.navSideTitle = navModel.navi_name;
            customVc.customHomeModel = navModel.customHomeModel;
            [vcArray addObject:customVc];
        }
    }
    return vcArray;
}

#pragma mark - 是否显示搜索按钮
- (void)searchActionEnable
{
    NSDictionary *searchDic = [UserDefaultsHelper valueForDefaultsKey:kUserDefaultsKey_ClanSearchSetting];
    //清空之前的状态
    [UserDefaultsHelper cleanDefaultsForKey:kUserDefaultsKey_ClanSearchSetWithForum];
    [UserDefaultsHelper cleanDefaultsForKey:kUserDefaultsKey_ClanSearchSetWithGroup];
    
    if (searchDic) {
        if ([searchDic[@"enable"] isEqualToString:@"1"]) {
            for (NSDictionary *dic in searchDic[@"setting"]) {
                if ([dic[@"key"] isEqualToString:@"forum"]) {
                    //论坛搜索
                    [UserDefaultsHelper saveDefaultsValue:dic forKey:kUserDefaultsKey_ClanSearchSetWithForum];
                }else if ([dic[@"key"] isEqualToString:@"group"]){
                    //用户搜索
                    [UserDefaultsHelper saveDefaultsValue:dic forKey:kUserDefaultsKey_ClanSearchSetWithGroup];
                }
                
            }
        }
    }
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


#pragma mark - 搜索
//- (void)searchAction
//{
//    SearchViewController *searchVC = [[SearchViewController alloc]init];
//    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:searchVC];
//    [self presentViewController:nav animated:NO completion:nil];
//    
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
