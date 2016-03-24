//
//  WebNaviViewController.m
//  Clan
//
//  Created by 昔米 on 15/10/14.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "WebNaviViewController.h"
#import "CustomRightItemView.h"
#import "HomeViewModel.h"
#import "BoardModel.h"
#import "PostSendViewController.h"
@interface WebNaviViewController ()<CustomRightItemDelegate>
@property (strong, nonatomic) CustomRightItemView *rightItemView;
@property (strong, nonatomic)HomeViewModel *homeViewModel;

@end

@implementation WebNaviViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (_customHomeModel) {
        _rightItemView = [[CustomRightItemView alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        _rightItemView.delegate = self;
        _rightItemView.customHomeModel = _customHomeModel;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:_rightItemView];
        [[NSNotificationCenter defaultCenter]postNotificationName:KCustomItemNotifi object:_customHomeModel];

    }
    
    if (!_isTabBarItem) {
        UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.backgroundColor = [UIColor clearColor];
        leftButton.frame = CGRectMake(0, 0, 26, 26);
        [leftButton setBackgroundImage :[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(backView) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];

    }
    
    
    // Do any additional setup after loading the view.
}

- (void)customRightPostSend{
    [self sendPost];
}

- (void)sendPost
{
    if ([self checkLoginState])
    {
        if (!_homeViewModel) {
            _homeViewModel = [[HomeViewModel alloc]init];
        }
        [self showProgressHUDWithStatus:@"" withLock:YES];
        WEAKSELF
        [_homeViewModel request_boardBlock:^(id data) {
            STRONGSELF
            [SVProgressHUD dismiss];
            id forumsdata = [UserDefaultsHelper valueForDefaultsKey:kUserDefaultsKey_ForumsStore];
            if (forumsdata && [forumsdata isKindOfClass:[NSArray class]]) {
                NSArray *forumsDataArr = (NSArray *)forumsdata;
                NSMutableArray *forumsArr = [NSMutableArray new];
                for (NSDictionary *dic in forumsDataArr) {
                    BoardModel *boardModel = [BoardModel objectWithKeyValues:dic];
                    if (boardModel.forums && boardModel.forums.count>0) {
                        [forumsArr addObjectsFromArray:boardModel.forums];
                    }
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

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *text = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if ([_customHomeModel.use_wap_name isEqualToString:@"1"]) {
        self.navigationItem.title = text;
    }
    if ([self.delegate respondsToSelector:@selector(webViewTitle:)]) {
        [self.delegate webViewTitle:text];
    }
}
- (void)backView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setNavTitle:(NSString *)navTitle{
    if (navTitle.length == 0) {
        self.navigationItem.title = [NSString returnStringWithPlist:YZBBSName];
    }else{
        if ([_customHomeModel.use_wap_name isEqualToString:@"0"]) {
            self.navigationItem.title = navTitle;
        }
    }
}

- (void)didReceiveMemoryWarning
{
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
