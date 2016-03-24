//
//  FriendVerifyViewController.m
//  Clan
//
//  Created by chivas on 15/7/17.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "FriendVerifyViewController.h"
#import "FriendsViewModel.h"
@interface FriendVerifyViewController ()
@property (strong, nonatomic) FriendsViewModel *friendViewModel;
@property (strong, nonatomic) UITextField *verifyTextField;
@end

@implementation FriendVerifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _friendViewModel = [FriendsViewModel new];
    [self initNav];
    [self initTitleLabel];
    [self initTextField];
}

- (void)initNav {
    UIBarButtonItem *buttonItem = [UIBarButtonItem itemWithBtnTitle:@"发送" target:self action:@selector(sendPost:)];
    [self.navigationItem setRightBarButtonItem:buttonItem animated:YES];
    self.title = @"好友申请";
    self.view.backgroundColor = UIColorFromRGB(0xf3f3f3);
}

- (void)initTitleLabel {
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(11, 20, ScreenWidth, 20)];
    label.tag = 1000;
    label.text = @"需要发送好友申请，最多10个字";
    label.font = [UIFont systemFontOfSize:14.0f];
    label.textColor = UIColorFromRGB(0xa6a6a6);
    [self.view addSubview:label];
}

- (void)initTextField
{
    UILabel *label = (UILabel *)[self.view viewWithTag:1000];
    UIView *verifyView = [[UIView alloc]initWithFrame:CGRectMake(0, label.bottom + 6, kSCREEN_WIDTH, 44)];
    verifyView.backgroundColor = [UIColor whiteColor];
    NSString *username = [UserModel currentUserInfo].username;
    _verifyTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, ScreenWidth-20, verifyView.height)];
    _verifyTextField.text = [NSString stringWithFormat:@"我是%@",(username&&username.length>0) ? username : @" "];
    _verifyTextField.clearButtonMode = UITextFieldViewModeAlways;
    [verifyView addSubview:_verifyTextField];
    [self.view addSubview:verifyView];
    [_verifyTextField becomeFirstResponder];
    
}
- (void)sendPost:(id)sender
{
    if ([_verifyTextField isFirstResponder]) {
        [_verifyTextField resignFirstResponder];
    }
    [self checkFriends];
}

- (void)checkFriends
{
    [self showProgressHUDWithStatus:@"请求中..."];
    WEAKSELF
    [_friendViewModel checkFriend:_uid isAgreePage:NO withchecktype:@"1" WithReturnBlock:^(BOOL success, id data) {
        STRONGSELF
        if (success) {
            NSString *suc = (NSString *)data;
            if (suc && suc.intValue == 2) {
                //同意好友
                [strongSelf request_dealFriendApply:_uid agree:YES];
            } else {
                [strongSelf requestAddFriends];
            }
        } else {
            [strongSelf dissmissProgress];
        }
    }];
}

//处理好友申请
- (void)request_dealFriendApply:(NSString *)uid agree:(BOOL)agree
{
    WEAKSELF
    [_friendViewModel request_dealFriendApply:uid agree:agree withBlock:^(BOOL success) {
        STRONGSELF
        [strongSelf hideProgressHUD];
        if (success) {
            if (agree) {
                //成为好友
                [strongSelf showHudTipStr:@"已添加好友成功"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_FRIENDS_SUCCESS" object:_uid];
                [strongSelf performSelector:@selector(backView) withObject:nil afterDelay:.2];
                
            }
        }
    }];
}

- (void)requestAddFriends
{
    WEAKSELF
    [_friendViewModel requestAddFriendWithUid:_uid andMessage:_verifyTextField.text andBlock:^(BOOL isSend) {
        STRONGSELF
        if (isSend) {
            [strongSelf dissmissProgress];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Apply_Success" object:_uid];
            [strongSelf performSelector:@selector(backView) withObject:nil afterDelay:.2];
        }
    }];
}

- (void)backView
{
    [self.navigationController popViewControllerAnimated:YES];
}
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
