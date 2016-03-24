//
//  PostViewModel.h
//  Clan
//
//  Created by chivas on 15/3/20.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ViewModelClass.h"
#import "ClanApiUrl.h"
@class PostSendModel;
@class PostActivityModel;
@interface PostViewModel : ViewModelClass

//请求列表
- (void)request_postListWithFid:(NSString *)fid andListType:(ListType )type andViewController:(UIViewController *)vc andPage:(NSString *)page andBlock:(void(^)(NSArray *topArray,NSArray *listArray,id forumInfo,BOOL isMore, BOOL isError))block;
//发送帖子
- (void)request_postSendWithSendModel:(PostSendModel *)sendModel andBlock:(void(^)(BOOL isSuccess,NSInteger imageCount,NSString *postTid))block;
//收藏
- (void)request_favBoardWithFid:(NSString *)fid andBlock:(void(^)(BOOL isSuccess))block;
//删除收藏
- (void)request_DeleteCollection:(NSString *)collectionId andType:(NSString *)type andBlock:(void(^)(BOOL state))block;

//帖子主题分类
- (void)request_classifiedPostsWithFid:(NSString *)fid andTypeId:(NSString *)type_id andPage:(int)page andBlock:(void(^)(NSArray *listArray,BOOL isMore))block;

//帖子列表的缓存
- (void)request_cache_postListWithFid:(NSString *)fid andListType:(ListType )type andViewController:(UIViewController *)vc andPage:(NSString *)page andBlock:(void(^)(NSArray *topArray,NSArray *listArray,id forumInfo,BOOL isMore))block;
//活动帖子截图
- (void)request_uploadAcitvityFileImage:(SendImage *)sendImage withFid:(NSString *)fid withHash:(NSString *)hash andBlock:(void(^)(id data, bool success))block;
//发起活动
- (void)request_PostActivity:(SendActivity *)model andBlock:(void(^)(id data, bool success))block;

@end
