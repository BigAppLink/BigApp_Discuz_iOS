//
//  SearchViewModel.m
//  Clan
//
//  Created by chivas on 15/7/8.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "SearchViewModel.h"
#import "ForumsModel.h"
#import "PostModel.h"
#import "BoardModel.h"
#import "UserInfoModel.h"
@implementation SearchViewModel
- (void)requestSearchWithType:(NSString *)type andkeyWord:(NSString *)keyword andPage:(NSString *)page andBlock:(void(^)(NSArray *searchArray,BOOL isMore))block{
    [[Clan_NetAPIManager sharedManager]requestSearchWithType:type andKeyWord:keyword andPage:page andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil,NO);
        }else{
            //映射
            if ([type isEqualToString:KSearchPost]) {
                id resultData = [data valueForKeyPath:@"Variables"];
                NSMutableArray *dataArray = [NSMutableArray array];
                for (NSDictionary *dic in [resultData objectForKey:@"thread_list"]) {
                    PostModel *forumModel = [PostModel objectWithKeyValues:dic];
                    [dataArray addObject:forumModel];
                }
                BOOL isMore = NO;
                if ([resultData[@"need_more"] isEqualToString:@"1"]) {
                    isMore = YES;
                }
                block(dataArray,isMore);
            }else if ([type isEqualToString:KSearchForum]){
                id resultData = [data valueForKeyPath:@"Variables"];
                NSMutableArray *dataArray = [NSMutableArray array];
                for (NSDictionary *dic in [resultData objectForKey:@"forum_list"]) {
                    ForumsModel *forumModel = [ForumsModel objectWithKeyValues:dic];
                    [dataArray addObject:forumModel];
                }
                block(dataArray,NO);
            }else if ([type isEqualToString:KSearchUser]){
                id resultData = [data valueForKeyPath:@"Variables"];
                NSMutableArray *dataArray = [NSMutableArray array];
                if ([[resultData objectForKey:@"user_list"] isKindOfClass:[NSDictionary class]]) {
                    for (NSDictionary *dic in [[resultData objectForKey:@"user_list"] allValues]) {
                        UserInfoModel *forumModel = [UserInfoModel objectWithKeyValues:dic];
                        [dataArray addObject:forumModel];
                    }
                }
                else if ([[resultData objectForKey:@"user_list"] isKindOfClass:[NSArray class]]){
                    for (NSDictionary *dic in [resultData objectForKey:@"user_list"]) {
                        UserInfoModel *forumModel = [UserInfoModel objectWithKeyValues:dic];
                        [dataArray addObject:forumModel];
                    }
                }
                block(dataArray,NO);
            }
        }
    }];
}
@end
