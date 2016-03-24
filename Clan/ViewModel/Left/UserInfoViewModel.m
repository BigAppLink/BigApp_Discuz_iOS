//
//  UserInfoViewModel.m
//  Clan
//
//  Created by 昔米 on 15/4/1.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "UserInfoViewModel.h"
#import "UserModel.h"
#import "UserInfoModel.h"
#import "SDImageCache.h"

@implementation UserInfoViewModel

- (void)requestApi:(NSString *)uid andReturnBlock:(void(^)(bool success, id data, bool isSelf))returnBlock
{
    WEAKSELF
    [[Clan_NetAPIManager sharedManager] request_UserInfo_ByUserId:uid WithResultBlock:^(id data, NSError *error, NSString *message)
     {
         __strong __typeof(weakSelf)strongSelf = weakSelf;
         [strongSelf hudHide];
         if (message) {
             [strongSelf hudHide];
             [strongSelf showHudTipStr:message];
             returnBlock(NO,nil,NO);
         }
         if (error) {
             returnBlock(NO,NetError,NO);
         }
         else {
             [strongSelf hudHide];
             
             NSDictionary *mess = [data valueForKey:@"Message"];
             if (mess && [mess[@"messageval"] isEqualToString:@"login_before_enter_home//1"]) {
                 [[NSNotificationCenter defaultCenter] postNotificationName:kCookie_expired object:nil];
                 returnBlock(NO, nil, NO);
                 return ;
             }
             
             NSString *errorMess = [data valueForKey:@"error"];
             if (errorMess) {
                 if ([errorMess isEqualToString:@"user_banned"]) {
                     [strongSelf showHudTipStr:@"用户被锁定"];
                 }
                 returnBlock(NO, nil, YES);
                 return;
             }
             id resultData = [data valueForKeyPath:@"Variables"];
             NSDictionary *space = [resultData valueForKey:@"space"];
             UserInfoModel *infomodel = [UserInfoModel objectWithKeyValues:space];
             infomodel.group_title = space[@"group"][@"grouptitle"];
             NSString *hasSelf = space[@"self"];
             if (hasSelf && [hasSelf isEqualToString:@"1"]) {
                 //如果是自己 拉取信息的时候 把头像缓存清除掉
                 returnBlock(YES,infomodel, YES);
             } else {
                 NSString *uid = [resultData valueForKeyPath:@"member_uid"];
                 if (uid && [uid isEqualToString:[UserModel currentUserInfo].uid]) {
                     returnBlock(YES, infomodel, NO);
                 } else {
                     returnBlock(YES, infomodel, NO);
                 }
             }
         }
     }];
}

//上传头像
- (void)upLoadAvatar:(UIImage *)image andReturenBlock:(void(^)(bool success, id data))block
{
    [self showHudWithTitleDefault:@"上传中..."];
    WEAKSELF
    [[Clan_NetAPIManager sharedManager] upload_avatar:image WithResultBlock:^(id data, NSError *error, NSString *message) {
        STRONGSELF
        [strongSelf hudHide];
        NSString *uploadavatar = [data valueForKey:@"Variables"][@"uploadavatar"];
        if ([uploadavatar isEqualToString:@"api_uploadavatar_success"]) {
            //修改头像成功
            [strongSelf showHudTipStr:@"修改头像成功"];
            NSString *member_avatar = [data valueForKey:@"Variables"][@"member_avatar"];
            block(YES, member_avatar);
        } else {
            [strongSelf showHudTipStr:@"上传失败，请重试"];
        }
        if (error) {
            
        }
    }];
}

//签到
- (void)doCheckIn:(NSString *)uid docheckInAction:(BOOL)checkInAction andReturenBlock:(void(^)(bool success, id data))block
{
    if (checkInAction) {
        [self showProgressHUDWithStatus:@"签到中..." withLock:YES];
    }
    WEAKSELF
    [[Clan_NetAPIManager sharedManager] checkInWithUid:uid docheckInAction:checkInAction withBlock:^(id data, NSError *error) {
        STRONGSELF
        [strongSelf hideProgressHUD];
        if (error && checkInAction) {
            [strongSelf hideProgressHUDSuccess:NO andTipMess:@"签到失败" withLock:YES];
            block(NO,nil);
            return ;
        } else {
            [strongSelf hideProgressHUD];
        }
        if (data) {
            NSDictionary *messageDic = [data valueForKey:@"Message"];
            NSDictionary *dic = [data valueForKeyPath:@"Variables"];
            if (checkInAction) {
                //签到
                NSString *mess = messageDic[@"messagestr"];
                NSString *credit = dic[@"credit"];
                NSString *title = dic[@"title"];
                UserModel *cuser = [UserModel currentUserInfo];
                if (mess && [mess isEqualToString:@"checked in success"]) {
                    //签到成功
                    NSString *tipMess = [NSString stringWithFormat:@"您已成功签到,今日获得%@%@",title,credit];
                    cuser.checked = @"1";
                    [strongSelf showHudTipStr:tipMess];
                    block(YES, nil);
                }
                else if (mess && [mess isEqualToString:@"has checked in"]) {
                    cuser.checked = @"1";
                    [strongSelf showHudTipStr:@"亲~ 今天已经签到过了"];
                    block(YES, nil);
                }
                else {
                    [strongSelf showHudTipStr:mess];
                    block(NO, nil);
                }
                
            } else {
                //请求当前用户签到状态
                NSString *checkin_enabled = dic[@"checkin_enabled"];
                if (checkin_enabled) {
                    [NSString updatePlistWithName:kcheckin_enabled andString:checkin_enabled];
                }
                NSString *checked = dic[@"checked"];
                UserModel *cuser = [UserModel currentUserInfo];
                if (checked && cuser.logined) {
                    cuser.checked = checked;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CheckInSwitch_Changed" object:nil];
            }
            [UserModel saveToLocal];
        } else {
            [strongSelf hideProgressHUD];
            block(NO, nil);
        }
    }];
}

//获取水滴的信息
+ (NSString *)infoForUser:(UserModel *)user
{
    NSString *infoValue = @"";
    if (user.extcredits && user.extcredits.count > 0) {
        int num = user.extcredits.count > 2 ? 3 : (int)user.extcredits.count+1;
        for (int i = 0; i < num; i++) {
            if (i == 0) {
                infoValue = [NSString stringWithFormat:@"积分 %@ ",user.credits];
            } else {
                NSString *name = user.extcredits[i-1][@"name"];
                NSNumber *value = user.extcredits[i-1][@"value"];
                NSString *str1 = [NSString stringWithFormat:@" | %@ %@ ",name,value];
                infoValue = [infoValue stringByAppendingString: str1];
            }
        }
    }
    return infoValue;
}

@end
