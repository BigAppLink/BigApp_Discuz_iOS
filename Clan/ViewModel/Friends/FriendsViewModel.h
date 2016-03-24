//
//  FriendsViewModel.h
//  Clan
//
//  Created by chivas on 15/7/17.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ViewModelClass.h"

@interface FriendsViewModel : ViewModelClass
- (void)requestAddFriendWithUid:(NSString *)uid andMessage:(NSString *)message andBlock:(void(^)(BOOL isSend))block;
//获取好友列表
- (void)getFriednsListWithUid:(NSString *)uid withReturnBlock:(void(^)(BOOL success, id data))block;

//轮询
- (void)getNewFriendsCountWithReturnBlock:(void(^)(NSString *count))block;

//新的好友列表
- (void)getNewFriendsListWithReturnBlock:(void(^)(BOOL success, id data))block;

//审核好友申请
- (void)request_dealFriendApply:(NSString *)uid agree:(BOOL)agree withBlock:(void(^)(BOOL success))block;

//添加好友前置检查 审核好友申请
- (void)checkFriend:(NSString *)uid isAgreePage:(BOOL)inAgreePage withchecktype:(NSString *)checktype WithReturnBlock:(void(^)(BOOL success, id data))block;

//推荐好友 可能认识的人
- (void)requests_FindFriednWithReturnBlock:(void(^)(BOOL success, id data))block;

- (void)requestDelegateFriendWithUid:(NSString *)uid andBlock:(void(^)(BOOL isDelegate))block;
@end
