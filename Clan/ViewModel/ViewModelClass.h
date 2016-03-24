//
//  ViewModelClass.h
//  Clan
//
//  Created by chivas on 15/3/11.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
#import "ClanError.h"
#import "MJExtension.h"

//定义返回请求数据的block类型
typedef void (^ReturnValueBlock) (id returnValue);
typedef void (^ErrorCodeBlock) (id errorCode);
typedef void (^NetWorkBlock)(BOOL netConnetState);

@interface ViewModelClass : NSObject
@property (strong, nonatomic) ReturnValueBlock returnBlock;
@property (strong, nonatomic) ErrorCodeBlock errorBlock;
@property (strong, nonatomic) MBProgressHUD *hud;

//获取网络的链接状态
//-(void) netWorkStateWithNetConnectBlock: (NetWorkBlock) netConnectBlock WithURlStr: (NSString *) strURl;

// 传入交互的Block块
-(void) setBlockWithReturnBlock: (ReturnValueBlock) returnBlock
                 WithErrorBlock: (ErrorCodeBlock) errorBlock;
- (void)showHudWithTitleDefault:(NSString *)title;
- (void)hudHide;


- (void)showProgressHUDWithStatus:(NSString *)string withLock:(BOOL)lock;


- (void)hideProgressHUD;

- (void)dissmissProgress;

- (void)hideProgressHUDSuccess:(BOOL)success andTipMess:(NSString *)tip;

- (void)hideProgressHUDSuccess:(BOOL)success andTipMess:(NSString *)tip withLock:(BOOL)lock;

@end
