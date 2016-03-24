//
//  PostDetailViewModel.h
//  Clan
//
//  Created by chivas on 15/3/24.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ViewModelClass.h"
@class PostSendModel;
@interface PostDetailViewModel : ViewModelClass
//请求帖子详情页
- (void)request_postDetailWithTid:(NSString *)tid withAuthorID:(NSString *)authorID atPage:(int)page andBlock:(void(^)(id data))block;
//发表回复
- (void)request_postReplyPostWithSendModel:(PostSendModel *)sendModel andBlock:(void(^)(BOOL isSuccess,NSInteger imageCount, id data))block;

//发帖前置检查
- (void)check_post_withfid:(NSString *)fid andBlock:(void(^)(bool success, id data))block;


/**
 * 赞主题
 */
- (void)request_support_AThread:(NSString *)tid andBlock:(void(^)(bool success, id data))block;

/**
 * 赞回帖
 */
- (void)request_support_APost:(NSString *)tid withPid:(NSString *)pid andBlock:(void(^)(bool success, id data))block;

/**
 *  举报
 */
- (void)request_reporeWithTid:(NSString *)tid andFid:(NSString *)fid andReport_select:(NSString *)report_select andMessage:(NSString *)message andHandlekey:(NSString *)handlekey andBlock:(void(^)(BOOL success,id DataBase))block;
@end
