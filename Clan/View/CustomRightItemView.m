//
//  CustomRightItemView.m
//  Clan
//
//  Created by chivas on 15/11/17.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "CustomRightItemView.h"
#import "CustomHomeMode.h"
#import "UIView+Additions.h"
#import "LoginViewController.h"
#import "MeViewController.h"
#import "CustomTransferViewController.h"
#import "DialogListViewController.h"
//#import "MessageController.h"
@implementation CustomRightItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setCustomHomeModel:(CustomHomeMode *)customHomeModel{
    _customHomeModel = customHomeModel;
    [self initView];
}
- (void)initView{
    //添加view
    CGFloat width = self.right - 30;
    CGFloat x = 0;
    if (_customHomeModel.title_cfg.count > 0) {
        for (NSInteger index = 0; index<_customHomeModel.title_cfg.count ; index++) {
            CustomRightItemModel *model = _customHomeModel.title_cfg[index];
            UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(width-x, 7, 30, 30)];
            button.tag = 1000+index;
            [button setImage:kIMG(model.icon_type) forState:UIControlStateNormal];
            [button addTarget:self action:@selector(rightItemAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            width -= 30;
        }
    }
}

- (void)rightItemAction:(UIButton *)button{
    NSInteger index = button.tag - 1000;
    CustomRightItemModel *model = _customHomeModel.title_cfg[index];
    NSString *customViewType = @"1";
    NSString *boardViewType = @"2";
    NSString *postType = @"3";
    NSString *letterType = @"4";
    NSString *meType = @"5";
    NSString *searchType = @"6";
    if (model) {
        Class typeClass;
        if ([model.title_button_type isEqualToString:customViewType]) {
            //自定义页面
            typeClass = NSClassFromString(@"CustomTransferViewController");
        }else if ([model.title_button_type isEqualToString:boardViewType]){
            NSString *boardClassName = @"BoardViewController";
            NSString *boardstyle = [NSString returnPlistWithKeyValue:kBOARDSTYLE];
            if (boardstyle && boardstyle.intValue == 1) {
                boardClassName = @"BoardTabController";
            }
            else if (boardstyle && boardstyle.intValue == 2) {
                boardClassName = @"BroadSideController";
            }
            typeClass = NSClassFromString(boardClassName);
        }else if ([model.title_button_type isEqualToString:postType]){
            //发帖
            if ([self checkLoginState]) {
                if ([self.delegate respondsToSelector:@selector(customRightPostSend)]) {
                    [self.delegate customRightPostSend];
                }
            }
            return;
        }
        else if ([model.title_button_type isEqualToString:letterType]){
            if ([self checkLoginState]) {
                typeClass = NSClassFromString(@"MessageController");
            }
        }
        else if ([model.title_button_type isEqualToString:meType]){
            typeClass = NSClassFromString(@"MeViewController");
            
        }
        else if ([model.title_button_type isEqualToString:searchType]){
            typeClass = NSClassFromString(@"SearchViewController");
        }
        UIViewController *vc = [[typeClass alloc] init];
        if (typeClass == NSClassFromString(@"MeViewController")) {
            MeViewController *meVc = (MeViewController *)vc;
            meVc.isRightItem = YES;
            meVc.isSelf = YES;
        }else if (typeClass == NSClassFromString(@"CustomTransferViewController")){
            CustomTransferViewController *transferVc = (CustomTransferViewController *)vc;
            transferVc.rightItemModel = model;
        }else if (typeClass == NSClassFromString(@"MessageController")){
//            MessageController *messageVc = (MessageController *)vc;
//            messageVc.isRightItemBar = YES;
            DialogListViewController *messageVc = (DialogListViewController *)vc;
        }
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.additionsViewController presentViewController:nav animated:YES completion:nil];
    }
    
}

- (BOOL)checkLoginState
{
    UserModel *_cuser = [UserModel currentUserInfo];
    if (!_cuser || !_cuser.logined) {
        //没有登录 跳出登录页面
        LoginViewController *login = [[LoginViewController alloc]init];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:login];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.additionsViewController presentViewController:nav animated:YES completion:nil];
        if (self.additionsViewController.sideMenuViewController) {
            [self.additionsViewController.sideMenuViewController hideMenuViewController];
        }
        return NO;
    } else {
        return YES;
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
