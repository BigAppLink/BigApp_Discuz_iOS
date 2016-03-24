//
//  ViewModelClass.m
//  Clan
//
//  Created by chivas on 15/3/11.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ViewModelClass.h"
#import "SVProgressHUD.h"
@implementation ViewModelClass
#pragma 接收穿过来的block
-(void) setBlockWithReturnBlock: (ReturnValueBlock) returnBlock
                 WithErrorBlock: (ErrorCodeBlock) errorBlock
{
    _returnBlock = returnBlock;
    _errorBlock = errorBlock;
}
- (void)showHudWithTitleDefault:(NSString *)title
{
    _hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    _hud.labelFont = [UIFont systemFontOfSize:14];
    _hud.labelText = title;
}

- (void)hudHide
{
    [_hud hide:YES];
    _hud.removeFromSuperViewOnHide = YES;
    
}

- (void)showProgressHUDWithStatus:(NSString *)string withLock:(BOOL)lock
{
    [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    if (!string || [@"" isEqualToString:string]) {
        if (lock) {
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
            return;
        }
        [SVProgressHUD show];
        return;
    }
    if (lock) {
        [SVProgressHUD showWithStatus:string maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    [SVProgressHUD showWithStatus:string];
}


- (void)hideProgressHUD
{
    [self performSelector:@selector(dissmissProgress) withObject:nil afterDelay:0.2];
}

- (void)dissmissProgress
{
    [SVProgressHUD dismiss];
}

- (void)hideProgressHUDSuccess:(BOOL)success andTipMess:(NSString *)tip
{
    [self hideProgressHUDSuccess:success andTipMess:tip withLock:NO];
}

- (void)hideProgressHUDSuccess:(BOOL)success andTipMess:(NSString *)tip withLock:(BOOL)lock
{
    if (!tip || [@"" isEqualToString:tip]) {
        [SVProgressHUD dismiss];
        return;
    }
    if (lock) {
        
        if (success)
            [SVProgressHUD showSuccessWithStatus:tip maskType:SVProgressHUDMaskTypeClear];
        else
            [SVProgressHUD showErrorWithStatus:tip maskType:SVProgressHUDMaskTypeClear];
    } else {
        
        if (success)
            [SVProgressHUD showSuccessWithStatus:tip];
        else
            [SVProgressHUD showErrorWithStatus:tip];
    }
}

@end
