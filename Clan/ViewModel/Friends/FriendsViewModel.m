//
//  FriendsViewModel.m
//  Clan
//
//  Created by chivas on 15/7/17.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "FriendsViewModel.h"
#import "UserInfoModel.h"

@implementation FriendsViewModel

//获取好友列表
- (void)getFriednsListWithUid:(NSString *)uid withReturnBlock:(void(^)(BOOL success, id data))block
{
    WEAKSELF
    [[Clan_NetAPIManager sharedManager] requests_FriednsListWithUid:uid withReturnBlock:^(id data, NSError *error) {
        STRONGSELF
        if (error) {
            [strongSelf showHudTipStr:NetError];
            block(NO, nil);
        } else {
            NSMutableArray *fArr = [NSMutableArray new];
            id resultsData = [data valueForKey:@"Variables"];
            if (resultsData && [resultsData isKindOfClass:[NSDictionary class]]) {
                NSArray *flist = [resultsData objectForKey:@"list"];
                if (flist && flist.count > 0) {
                    for (NSDictionary *dic in flist) {
                        UserInfoModel *aFriends = [UserInfoModel objectWithKeyValues:dic];
                        [fArr addObject:aFriends];
                    }
                }
            }
            block(YES, fArr);
        }
    }];
}

//获取新的好友申请列表
- (void)getNewFriendsOnlyCount:(BOOL)onlyCount WithReturnBlock:(void(^)(NSString *count))block
{
    [[Clan_NetAPIManager sharedManager] requests_NewFriendWithOnlyCount:onlyCount withReturnBlock:^(id data, NSError *error) {
        if (error) {
            block(nil);
        } else {
            NSString *countNum = @"0";
            id resultsData = [data valueForKey:@"Variables"];
            if (resultsData && [resultsData isKindOfClass:[NSDictionary class]]) {
                NSString *count = [resultsData objectForKey:@"count"];
                if (count) {
                    countNum = count;
                }
            }
            block(countNum);
        }
    }];
}


//轮询
- (void)getNewFriendsCountWithReturnBlock:(void(^)(NSString *count))block
{
    [[Clan_NetAPIManager sharedManager] requests_NewFriendWithOnlyCount:YES withReturnBlock:^(id data, NSError *error) {
        if (error) {
            block(nil);
        } else {
            NSString *countNum = @"0";
            id resultsData = [data valueForKey:@"Variables"];
            if (resultsData && [resultsData isKindOfClass:[NSDictionary class]]) {
                NSString *count = [resultsData objectForKey:@"count"];
                if (count) {
                    countNum = count;
                }
            }
            block(countNum);
        }
    }];
}

//新的好友列表
- (void)getNewFriendsListWithReturnBlock:(void(^)(BOOL success, id data))block
{
    [[Clan_NetAPIManager sharedManager] requests_NewFriendWithOnlyCount:NO withReturnBlock:^(id data, NSError *error) {
        if (error) {
            block(NO, data);
        } else {
            NSMutableArray *fArr = [NSMutableArray new];
            id resultsData = [data valueForKey:@"Variables"];
            if (resultsData && [resultsData isKindOfClass:[NSDictionary class]]) {
                NSArray *flist = [resultsData objectForKey:@"list"];
                if (flist && flist.count > 0) {
                    for (NSDictionary *dic in flist) {
                        UserInfoModel *aFriends = [UserInfoModel objectWithKeyValues:dic];
                        [fArr addObject:aFriends];
                    }
                }
            }
            block(YES, fArr);
        }
    }];
}

//添加好友前置检查 审核好友申请
- (void)checkFriend:(NSString *)uid isAgreePage:(BOOL)inAgreePage withchecktype:(NSString *)checktype WithReturnBlock:(void(^)(BOOL success, id data))block
{
    WEAKSELF
    [[Clan_NetAPIManager sharedManager]request_checkUserIsFriend:uid withtype:checktype WithReturnBlock:^(id data, NSError *error) {
        STRONGSELF
        if (error) {
            [strongSelf showHudTipStr:NetError];
            block(NO, nil);
        } else {
            id datas = [data valueForKey:@"Variables"];
            NSString *canAdd = [datas objectForKey:@"status"];
            if (!isNull(canAdd))
            {
                if (canAdd.intValue == 0 || canAdd.intValue == 2) {
                    block(YES, canAdd);
                } else {
                    NSString *errMes = [datas objectForKey:@"show_message"];
                    [strongSelf showHudTipStr:errMes];
                    block(NO, nil);
                }
            }
            else {
                NSString *errMes = [datas objectForKey:@"show_message"];
                [strongSelf showHudTipStr:errMes];
                block(NO, nil);
            }
        }
    }];
}


//审核好友申请
- (void)request_dealFriendApply:(NSString *)uid agree:(BOOL)agree withBlock:(void(^)(BOOL success))block
{
    WEAKSELF
    [[Clan_NetAPIManager sharedManager] request_dealFriendApply:uid agree:agree withBlock:^(id data, NSError *error) {
        STRONGSELF
        if (error) {
            [strongSelf showHudTipStr:NetError];
            block(NO);
        } else {
            id datas = [data valueForKey:@"Variables"];
            NSString *canAdd = [datas objectForKey:@"status"];
            if (!isNull(canAdd) && canAdd.intValue == 0) {
                block(YES);
            } else {
                NSString *errMes = [datas objectForKey:@"show_message"];
                [strongSelf showHudTipStr:errMes];
                block(NO);
            }
        }
    }];
}


//推荐好友 可能认识的人
- (void)requests_FindFriednWithReturnBlock:(void(^)(BOOL success, id data))block
{
    WEAKSELF
    [[Clan_NetAPIManager sharedManager]requests_FindFriednWithReturnBlock:^(id data, NSError *error) {
        STRONGSELF
        if (error) {
            [strongSelf showHudTipStr:NetError];
            block(NO, nil);
        } else {
            NSMutableArray *fArr = [NSMutableArray new];
            id resultsData = [data valueForKey:@"Variables"];
            if (resultsData && [resultsData isKindOfClass:[NSDictionary class]]) {
                NSArray *flist = [resultsData objectForKey:@"list"];
                if (flist && flist.count > 0) {
                    for (NSDictionary *dic in flist) {
                        UserInfoModel *aFriends = [UserInfoModel objectWithKeyValues:dic];
                        [fArr addObject:aFriends];
                    }
                }
            }
            block(YES, fArr);
        }
    }];
}

- (void)requestAddFriendWithUid:(NSString *)uid andMessage:(NSString *)message andBlock:(void(^)(BOOL isSend))block{
    WEAKSELF
    [self showProgressHUDWithStatus:@"正在申请" withLock:NO];
    [[Clan_NetAPIManager sharedManager] requestAddFriendWithUid:uid andMessage:message andBlock:^(id data, NSError *error) {
        STRONGSELF
        [strongSelf hideProgressHUD];
        if (error) {
            [strongSelf hideProgressHUDSuccess:NO andTipMess:NetError];
            return;
        }else{
            id resultData = [data valueForKeyPath:@"Variables"];
            if ([resultData[@"status"] isEqualToString:@"0"]) {
                //申请好友成功
                [strongSelf hideProgressHUDSuccess:YES andTipMess:@"已发送"];
                block(YES);
            }else{
                id messageData = [data valueForKeyPath:@"Message"];
                [strongSelf hideProgressHUDSuccess:NO andTipMess:messageData[@"messagestr"]];
                return;
            }
        }
    }];
}

- (void)requestDelegateFriendWithUid:(NSString *)uid andBlock:(void(^)(BOOL isDelegate))block{
    WEAKSELF
    [self showProgressHUDWithStatus:@"正在删除" withLock:NO];
    [[Clan_NetAPIManager sharedManager]requestDelegateFriendWithUid:uid andBlock:^(id data, NSError *error) {
        STRONGSELF
        [strongSelf hideProgressHUD];
        if (error) {
            [strongSelf hideProgressHUDSuccess:NO andTipMess:NetError];
            return;
        }else{
            id resultData = [data valueForKeyPath:@"Variables"];
            if ([resultData[@"status"] isEqualToString:@"0"]) {
                //申请好友成功
                [strongSelf hideProgressHUDSuccess:YES andTipMess:@"删除成功"];
                block(YES);
            }else{
                id messageData = [data valueForKeyPath:@"Message"];
                [strongSelf hideProgressHUDSuccess:NO andTipMess:messageData[@"messagestr"]];
                return;
            }
        }
    }];
}
@end
