//
//  PostSendViewModel.m
//  Clan
//
//  Created by 昔米 on 15/8/13.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "PostSendViewModel.h"
#import "CheckPostModel.h"
#import "threadtypesModel.h"

@implementation PostSendViewModel

//版块儿发帖前置检查
- (void)request_PermissionForSendPost:(NSString *)fid withBlock:(void(^)(id data))block
{
    [[Clan_NetAPIManager sharedManager] request_checkSendPostWithFid:fid withBlock:^(id data, NSError *error) {
        if (data) {
            id resultData = [data valueForKeyPath:@"Variables"];
            CheckPostModel *checkModel = [CheckPostModel objectWithKeyValues:resultData];
            block(checkModel);
        }
        [SVProgressHUD dismiss];
    }];
}

//拉取分类信息
- (void)request_classifyForForumsId:(NSString *)fid withBlock:(void(^)(id data, BOOL success))block
{
    [[Clan_NetAPIManager sharedManager] request_classifysWithFid:fid withBlock:^(id data, NSError *error) {
        if (error) {
            block(nil, NO);
        } else {
            // 1、当前仅当返回值是json且error_code为0时，表明操作成功；
            NSString *error_code = [data valueForKeyPath:@"error_code"];
            if (error_code && error_code.intValue == 0) {
                NSDictionary *dic = [data valueForKeyPath:@"threadtypes"];
                threadtypesModel *threadTypeModel = [threadtypesModel objectWithKeyValues:dic];
                block(threadTypeModel, YES);
            } else {
                block(nil, NO);
            }
        }
    }];
}

@end
