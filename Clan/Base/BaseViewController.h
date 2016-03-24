//
//  BaseViewController.h
//  Clan
//
//  Created by chivas on 15/2/27.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

//分享
- (void)doShareWithTitle:(NSString *)title
             withcontent:(NSString *)content
                 withURL:(NSString *)url
            withShareImg:(UIImage *)img
         withShareImgURL:(NSString *)imgURL
         withDescription:(NSString *)des;

- (void)goToLoginPage;
- (void)showProgressHUDWithStatus:(NSString *)string;
- (void)hideProgressHUD;
- (void)hideProgressHUDSuccess:(BOOL)success andTipMess:(NSString *)tip;
- (void)dissmissProgress;
- (BOOL)checkLoginState;
- (void)showProgressHUDWithStatus:(NSString *)string withLock:(BOOL)lock;
- (void)addBackBtn;

@property (copy, nonatomic) void(^shareFailBlock)(NSString *type);
@end
