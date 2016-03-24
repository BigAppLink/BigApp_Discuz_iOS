//
//  PostDetailViewModel.m
//  Clan
//
//  Created by chivas on 15/3/24.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "PostDetailViewModel.h"
#import "Clan_NetAPIManager.h"
#import "PostDetailModel.h"
#import "CheckPostModel.h"
#import "PostSendModel.h"

@implementation PostDetailViewModel
- (void)request_postDetailWithTid:(NSString *)tid withAuthorID:(NSString *)authorID atPage:(int)page andBlock:(void(^)(id data))block
{
    WEAKSELF
    [[Clan_NetAPIManager sharedManager]request_postDetailWithTid:tid withAuthorID:authorID atPage:page andBlock:^(id data, NSError *error) {
        STRONGSELF
        if (!error) {
            if ([data valueForKey:@"Message"]) {
                NSDictionary *messdic = [data valueForKey:@"Message"];
                NSString *mess = messdic[@"messagestr"];
                block(mess);
                return ;
            }
            id resultData = [data valueForKeyPath:@"Variables"];
            PostDetailModel *detailModel = [PostDetailModel objectWithKeyValues:resultData];
            block(detailModel);
        }else{
            block(nil);
            [strongSelf showHudTipStr:NetError];
            return ;
        }
    }];
}

- (void)request_postReplyPostWithSendModel:(PostSendModel *)sendModel andBlock:(void(^)(BOOL isSuccess,NSInteger imageCount, id data))block
{
    if (sendModel.message.length == 0)
    {
        [self showHudTipStr:@"请输入回复内容"];
        return;
    }
    [self showProgressHUDWithStatus:@"发送中..." withLock:YES];
    WEAKSELF
    if (sendModel.imageArray.count > 0) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        //有图片的帖子
        [[Clan_NetAPIManager sharedManager] uploadSendImage:sendModel andBlock:^(BOOL isUpdate,AFHTTPRequestOperation *operation,NSInteger imageCount,NSString *errorMessage) {
            [self hideProgressHUD];
            if (isUpdate) {
                //取出附件ID
                [[Clan_NetAPIManager sharedManager]uploadSendPost:sendModel andBlock:^(id data, NSError *error) {
                    id message = data[@"Message"];
                    if ([message[@"messageval"] isEqualToString:Post_reply_succeed]) {
                        //发送成功
                        [strongSelf hideProgressHUDSuccess:YES andTipMess:@"回复发送成功"];
                        block(YES,imageCount,data);
                    }else{
                        [strongSelf hideProgressHUDSuccess:NO andTipMess:message[@"messagestr"]];
                        block(NO,imageCount,data);
                    }
                }];
            }else{
                if (errorMessage) {
                    [strongSelf hideProgressHUDSuccess:NO andTipMess:errorMessage withLock:NO];
                    return ;
                }
                //呼出错误
                [strongSelf showStatusBarError:operation.responseString];
                block(NO,imageCount, nil);
            }
            
        } progerssBlock:^(CGFloat progressValue) {
            
        }];
    }
    else
    {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [[Clan_NetAPIManager sharedManager]uploadSendPost:sendModel andBlock:^(id data, NSError *error) {
            id message = data[@"Message"];
            if ([message[@"messageval"] isEqualToString:Post_reply_succeed]) {
                //发送成功
                [strongSelf hideProgressHUDSuccess:YES andTipMess:@"回复发送成功"];
                block(YES,0, data);
            }else{
                [strongSelf hideProgressHUDSuccess:NO andTipMess:message[@"messagestr"]];
                block(NO,0,data);
            }
            
        }];
    }

}

//发帖前置检查
- (void)check_post_withfid:(NSString *)fid andBlock:(void(^)(bool success, id data))block
{
    [self showProgressHUDWithStatus:@"" withLock:YES];
    WEAKSELF
    [[Clan_NetAPIManager sharedManager] check_post_withfid:fid andBlock:^(id data, NSError *error) {
        STRONGSELF
        [strongSelf hideProgressHUD];
        if (error) {
            [strongSelf showHudTipStr:NetError];
            block (NO, nil);
        }
        else {
            id resultData = [data valueForKeyPath:@"Variables"];
            if ((resultData && resultData[@"auth"] == [NSNull null]) || [resultData[@"auth"] isEqualToString:@""]) {
                UserModel *cUser = [UserModel currentUserInfo];
                if (cUser.logined) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kCookie_expired object:nil];
                }
                block (NO, kCookie_expired);
                return;
            }
            BOOL isImageType = YES;
            NSDictionary *dic = resultData[@"allowperm"];
            if (dic && dic[@"allowreply"] && [dic[@"allowreply"] intValue] == 1) {
                CheckPostModel *checkModel = [CheckPostModel objectWithKeyValues:resultData];
                if ([checkModel.allowperm.allowupload[@"jpg"] isEqualToString:@"0"] && [checkModel.allowperm.allowupload[@"jpeg"] isEqualToString:@"0"]) {
                    //如果不支持这2种格式的话 默认为不支持上传图片
                    isImageType = NO;
                }else{
                    [[NSUserDefaults standardUserDefaults]setObject:checkModel.allowperm.allowupload[@"jpg"] forKey:KimageJpg];
                    [[NSUserDefaults standardUserDefaults]setObject:checkModel.allowperm.allowupload[@"jpeg"] forKey:Kimagejpeg];
                }
                [[NSUserDefaults standardUserDefaults]setBool:isImageType forKey:KimageType];
                [[NSUserDefaults standardUserDefaults]synchronize];
                if (checkModel.allowperm && checkModel.allowperm.uploadhash && checkModel.allowperm.uploadhash.length > 0) {
                    block(YES, checkModel.allowperm.uploadhash);
                } else {
                    [strongSelf showHudTipStr:@"请重试"];
                    block (NO, nil);
                }
            } else {
                [self showHudTipStr:@"抱歉，您没有权限回复该帖"];
                block(NO, nil);
            }
        }
    }];
}

/**
 * 赞主题
 */
- (void)request_support_AThread:(NSString *)tid andBlock:(void(^)(bool success, id data))block
{
//    当且仅当Message/ messageval存在且为recommend_succeed时才算顶成功，客户端应直接显示messagestr提示用户更新成功，与此同时，根据viewthread中的recommend_value更新recommends数值（加recommend_value），更新recommend_add数值（加1）
//    其他情况，请直接展示messagestr提示失败，如果messagestr不存在，请直接使用“顶主题失败”话术；
    [[Clan_NetAPIManager sharedManager] request_support_AThread:tid withResultBlock:^(id data, NSError *error) {
        id message = data[@"Message"];
        if (message && [message[@"messageval"] isEqualToString:@"recommend_succeed"]) {
            //赞成功
            block(YES,@"");
        } else {
            if (message && message[@"messagestr"]) {
                NSString *tipmess = message[@"messagestr"];
                [self showHudTipStr:tipmess];
//                if ([tipmess containsString:@"已评价过"])
                if ([tipmess rangeOfString:@"已评价过"].location != NSNotFound)
                {
                    block(YES,@"haveSupported");
                } else {
                    block(NO,@"");
                }
            } else {
                [self showHudTipStr:@"顶主题失败"];
                block(NO,@"");
            }
        }
    }];
}

/**
 * 赞回帖
 */
- (void)request_support_APost:(NSString *)tid withPid:(NSString *)pid andBlock:(void(^)(bool success, id data))block
{
//    当且仅当Message/ messageval存在且为thread_poll_succeed时才算顶成功，客户端应直接显示messagestr提示用户更新成功，与此同时，将viewthread返回的supoort字段加1
//    其他情况，请直接展示messagestr提示失败，如果messagestr不存在，请直接使用“投票失败”话术
    [[Clan_NetAPIManager sharedManager] request_support_APost:tid withPid:pid withResultBlock:^(id data, NSError *error) {
        id message = data[@"Message"];
        if (message && [message[@"messageval"] isEqualToString:@"thread_poll_succeed"]) {
            //赞成功
            block(YES,@"");
        } else {
            if (message && message[@"messagestr"]) {
                NSString *tipmess = message[@"messagestr"];
                [self showHudTipStr:tipmess];
//                if ([tipmess containsString:@"已经对此回帖投过票"])
                if ([tipmess rangeOfString:@"已经对此回帖投过票"].location != NSNotFound)
                {
                    block(YES,@"haveSupported");
                } else {
                    block(NO,@"");
                }
            } else {
                [self showHudTipStr:@"投票失败"];
                block(NO,@"");
            }
        }
    }];
}

/**
 *  举报
 */
- (void)request_reporeWithTid:(NSString *)tid andFid:(NSString *)fid andReport_select:(NSString *)report_select andMessage:(NSString *)message andHandlekey:(NSString *)handlekey andBlock:(void(^)(BOOL success,id DataBase))block{
    [self showProgressHUDWithStatus:@"" withLock:YES];
    WEAKSELF
    [[Clan_NetAPIManager sharedManager]request_reporeWithTid:tid andFid:fid andReport_select:report_select andMessage:message andHandlekey:handlekey andUid:[UserModel currentUserInfo].uid andBlock:^(id data, NSError *error) {
        STRONGSELF
        [strongSelf hideProgressHUD];
        if (error) {
            [strongSelf showHudTipStr:NetError];
        }else{
            NSDictionary *dic = data[@"Message"];
            if (dic[@"messageval"]) {
                //请求成功
                [strongSelf showHudTipStr:dic[@"messagestr"]];
                block(YES,data);
            }else{
                [strongSelf showHudTipStr:dic[@"messagestr"]];
                block(NO,data);
            }
        }
    }];
}
@end
