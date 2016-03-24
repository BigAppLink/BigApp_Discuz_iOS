//
//  MyPostViewModel.m
//  Clan
//
//  Created by 昔米 on 15/4/3.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "MyPostViewModel.h"
#import "PostModel.h"
#import "ReplyModel.h"

@implementation MyPostViewModel

/**
 * 我的主贴
 */
- (void)requestPostsForPage:(NSNumber *)page withUserID:(NSString *)uid andReturnBlock:(void(^)(bool success, id data))block
{
    WEAKSELF
    [[Clan_NetAPIManager sharedManager] request_PostsForPage:page withUserId:uid WithResultBlock:^(id data, NSError *error) {
        if (error) {
            //错误
            [weakSelf showHudTipStr:NetError];
            block(NO, nil);
            return ;
        }
        else {
            if ((data && data[@"auth"] == [NSNull null]) || [data[@"auth"] isEqualToString:@""]) {
                UserModel *cUser = [UserModel currentUserInfo];
                if (cUser.logined) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kCookie_expired object:nil];
                }
                block(NO, kCookie_expired);
                return;
            }
            NSMutableArray *returnarr = [NSMutableArray new];
            NSString *avatar = [data valueForKey:@"avatar"];
            NSArray *arr = [data valueForKey:@"data"];
            for (NSDictionary *dic in arr)
            {
                PostModel *postModel = [PostModel objectWithKeyValues:dic];
                postModel.avatar = avatar;
                [returnarr addObject:postModel];
            }
            block(YES,returnarr);
        }

    }];
}

/**
 * 我的回复
 */
- (void)requestReplysForPage:(NSNumber *)page withUserID:(NSString *)uid andReturnBlock:(void(^)(bool success, id data))block
{
    WEAKSELF
    [[Clan_NetAPIManager sharedManager] request_ReplysForPage:page withUserId:uid WithResultBlock:^(id data, NSError *error) {
        if (error) {
            //错误
            [weakSelf showHudTipStr:NetError];
            block(NO, nil);
            return ;
        }
        else {
            if ((data && data[@"auth"] == [NSNull null]) || [data[@"auth"] isEqualToString:@""]) {
                UserModel *cUser = [UserModel currentUserInfo];
                if (cUser.logined) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kCookie_expired object:nil];
                }
                block(NO, kCookie_expired);
                return;
            }
            NSMutableArray *resultsArr = [NSMutableArray new];
            id resultData = [data valueForKeyPath:@"data"];
            NSString *avatar = [data valueForKey:@"avatar"];
            for (NSDictionary *dic  in resultData) {
                id details = [dic valueForKey:@"details"];
                NSString *replies = [dic objectForKey:@"replies"];
                NSString *views = [dic objectForKey:@"views"];
                for (id obj in details) {
                    ReplyModel *reply = [ReplyModel objectWithKeyValues:obj];
                    reply.subject = [dic objectForKey:@"subject"];
                    reply.avatar = avatar;
                    reply.forum_name = [dic objectForKey:@"forum_name"];
                    reply.views = views;
                    reply.replies = replies;
                    [resultsArr addObject:reply];
                }
            }
            block(YES, resultsArr);
        }
    }];
}

@end
