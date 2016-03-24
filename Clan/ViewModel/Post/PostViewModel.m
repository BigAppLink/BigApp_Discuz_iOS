//
//  PostViewModel.m
//  Clan
//
//  Created by chivas on 15/3/20.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "PostViewModel.h"
#import "Clan_NetAPIManager.h"
#import "PostModel.h"
#import "PostViewController.h"
#import "PostSendModel.h"
#import "Util.h"
#import "ForumsModel.h"
@interface PostViewModel()
@property (strong, nonatomic) NSMutableArray *listArray;
@property (assign, nonatomic) NSInteger tempPage;
@property (assign, nonatomic) BOOL isCreatListArrayMomory;

@end
@implementation PostViewModel
- (void)request_postListWithFid:(NSString *)fid andListType:(ListType )type andViewController:(UIViewController *)vc andPage:(NSString *)page andBlock:(void(^)(NSArray *topArray,NSArray *listArray,id forumInfo,BOOL isMore, BOOL isError))block
{
    WEAKSELF
    //添加字段
    NSString *filter;
    NSString *orderby;
    NSString *digest;
    NSString *listType;
    if (type == heats) {
        filter = @"heat";
        orderby = @"heats";
        listType = @"heat";
    }else if (type == newList){
        filter = @"lastpost";
        orderby = @"lastpost";
        listType = @"lastpost";
    }else if (type == digestlist){
        filter = @"digest";
        digest = @"1";
        listType = @"digest";
    }else if (type == ordbydata){
        filter = @"author";
        orderby = @"dateline";
        listType = @"dateline";
    }else if (type == allList){
        filter = @"";
        orderby = @"";
        listType = @"allList";
    }
    
    _tempPage = 1;
    _isCreatListArrayMomory = NO;
    [[Clan_NetAPIManager sharedManager]request_PostListWithFilter:filter andOrderby:orderby andDigest:digest andPage:page andFid:fid andBlock:^(id dataArray, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (error) {
            [strongSelf showHudTipStr:NetError];
            block(nil,nil,nil,NO,YES);
            return ;
        }
        if (dataArray) {
            id message = dataArray[1][@"Message"];
            if ([message[@"messageval"] isEqualToString:Forum_nonexistence]) {
                [strongSelf showHudTipStr:PostErrorMessage];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSArray *viewControllers = vc.navigationController.viewControllers;
                    if (viewControllers.count == 1) {
                        [vc dismissViewControllerAnimated:YES completion:nil];
                    }
                    [vc.navigationController popViewControllerAnimated:YES];
                });
                return;
            }else{
                if (!strongSelf.isCreatListArrayMomory ) {
                    strongSelf.listArray = [NSMutableArray array];
                }
                NSMutableArray *topArray = [NSMutableArray array];
                id topData = [dataArray[0] valueForKeyPath:@"Variables"];
                id listData = [dataArray[1] valueForKeyPath:@"Variables"];
                NSString *preifx;
                if (topData[@"threadtypes"]) {
                    preifx = topData[@"threadtypes"][@"prefix"];
                }
                for (NSDictionary *dic in [listData objectForKey:@"forum_threadlist"]) {
                    PostModel *postModel = [PostModel objectWithKeyValues:dic];
                    postModel.prefix = preifx;
                    [postModel frameWithModel];
                    [strongSelf.listArray addObject:postModel];
                }
                for (NSDictionary *dic in [topData objectForKey:@"forum_threadlist"]) {
                    PostModel *postModel = [PostModel objectWithKeyValues:dic];
                    postModel.prefix = preifx;
                    [postModel frameWithModel];
                    [topArray addObject:postModel];
                }

                if ([(NSArray *)listData[@"forum_threadlist"] count]< 5 && [listData[@"need_more"] isEqualToString:@"1"]) {
                    //说明置顶过多 page显示不全 如果小于5 而且有下一页 则请求一下页数据
                    strongSelf.tempPage ++;
                    strongSelf.isCreatListArrayMomory = YES;
                    [[Clan_NetAPIManager sharedManager]request_postListWithTopListData:dataArray[0] andFilter:filter andOrderby:orderby andDigest:digest andPage:@(strongSelf.tempPage).stringValue andFid:fid];
                    return;
                }else{
                    if (page && page.intValue == 1 && !isNull(fid)) {
                        //设置帖子缓存 by- XIMI
                        [[CacheManager sharedCacheManager] saveCache:topData withForumID:[NSString stringWithFormat:@"topData%@",fid]];
                        [[CacheManager sharedCacheManager] saveCache:listData withForumID:[NSString stringWithFormat:@"postData_%@_%@_",fid,listType]];
                    }

                }
                
                //多图模式
                NSString *image_mode = listData[@"open_image_mode"] ;
                if (image_mode && !isNull(image_mode)) {
                    [NSString updatePlistWithName:kOpenImageMode andString:image_mode];
                }
                NSString *moreStr = [listData objectForKey:@"need_more"];
                BOOL isMore = (moreStr && moreStr.intValue == 1) ? YES : NO;
                ForumsModel *fmodel = nil;
                if (listData[@"forum"]) {
                    fmodel = [ForumsModel objectWithKeyValues:listData[@"forum"]];
                }
                if (listData[@"threadtypes"]) {
                    fmodel.threadtypes = [threadtypesModel objectWithKeyValues:listData[@"threadtypes"]];
                }
                fmodel.postActivityModel = [PostActivityModel objectWithKeyValues:listData[@"activity_config"]];
                block(topArray,strongSelf.listArray,fmodel,isMore,NO);
            }
        }else{
            [strongSelf showHudTipStr:NetError];
            block(nil,nil,nil,NO,NO);
            return;
        }
    }];
}

//帖子列表缓存
- (void)request_cache_postListWithFid:(NSString *)fid andListType:(ListType )type andViewController:(UIViewController *)vc andPage:(NSString *)page andBlock:(void(^)(NSArray *topArray,NSArray *listArray,id forumInfo,BOOL isMore))block
{
    //添加字段
    NSString *listType;
    if (type == heats) {
        listType = @"heat";
    } else if (type == newList){
        listType = @"lastpost";
    } else if (type == hotList){
        listType = @"hot";
    } else if (type == ordbydata){
        listType = @"author";
    }else if(type == allList){
        listType = @"allList";
    }
    NSMutableArray *dataArray = [NSMutableArray new];
    id topdatas = [[CacheManager sharedCacheManager] cacheForForum:[NSString stringWithFormat:@"topData%@",fid]];
    id postdatas = [[CacheManager sharedCacheManager] cacheForForum:[NSString stringWithFormat:@"postData_%@_%@_",fid,listType]];
    if (topdatas) {
        [dataArray addObject:topdatas];
    }
    if (postdatas) {
        [dataArray addObject:postdatas];
    }
    if (dataArray.count == 2) {
        id message = dataArray[1][@"Message"];
        if ([message[@"messageval"] isEqualToString:Forum_nonexistence]) {
            [self showHudTipStr:PostErrorMessage];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [vc.navigationController popViewControllerAnimated:YES];
            });
            return;
        }else{
            NSMutableArray *topArray = [NSMutableArray array];
            NSMutableArray *listArray = [NSMutableArray array];
            
            id topData = dataArray[0];
            NSString *preifx;
            if (topData[@"threadtypes"]) {
                preifx = topData[@"threadtypes"][@"prefix"];
            }
            for (NSDictionary *dic in [topData objectForKey:@"forum_threadlist"]) {
                PostModel *postModel = [PostModel objectWithKeyValues:dic];

                postModel.prefix = preifx;
                [postModel frameWithModel];
                [topArray addObject:postModel];
            }
            id listData = dataArray[1];
            //多图模式
            NSString *image_mode = listData[@"open_image_mode"] ;
            if (image_mode && !isNull(image_mode)) {
                [NSString updatePlistWithName:kOpenImageMode andString:image_mode];
            }
            NSString *moreStr = [listData objectForKey:@"need_more"];
            //                [[listData objectForKey:@"need_more"]isEqualToString:@"1"]
            BOOL isMore = (moreStr && moreStr.intValue == 1) ? YES : NO;
            for (NSDictionary *dic in [listData objectForKey:@"forum_threadlist"]) {
                PostModel *postModel = [PostModel objectWithKeyValues:dic];
                postModel.prefix = preifx;
                [postModel frameWithModel];
                [listArray addObject:postModel];
            }
            ForumsModel *fmodel = nil;
            if (listData[@"forum"]) {
                fmodel = [ForumsModel objectWithKeyValues:listData[@"forum"]];
            }
            if (listData[@"threadtypes"]) {
                fmodel.threadtypes = [threadtypesModel objectWithKeyValues:listData[@"threadtypes"]];
            }
            block(topArray,listArray,fmodel,isMore);
        }
    } else{
        block(nil,nil,nil,nil);
        return;
    }
}


- (void)request_postSendWithSendModel:(PostSendModel *)sendModel andBlock:(void(^)(BOOL isSuccess,NSInteger imageCount,NSString *postTid))block{
    if (sendModel.subject.length == 0) {
        [self showHudTipStr:@"请输入帖子标题"];
        return;
    }
    if (sendModel.message.length == 0){
        [self showHudTipStr:@"请输入帖子内容"];
        return;
    }
    [self showProgressHUDWithStatus:@"正在发送帖子..." withLock:YES];
    WEAKSELF
    if (sendModel.imageArray.count > 0) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        //有图片的帖子
        [[Clan_NetAPIManager sharedManager] uploadSendImage:sendModel andBlock:^(BOOL isUpdate,AFHTTPRequestOperation *operation,NSInteger imageCount,NSString *errorMessage) {
            if (isUpdate) {
                //取出附件ID
                [[Clan_NetAPIManager sharedManager]uploadSendPost:sendModel andBlock:^(id data, NSError *error) {
                    [strongSelf hideProgressHUD];
                    id message = data[@"Message"];
                    if ([message[@"messageval"] isEqualToString:Post_newthread_succeed]) {
                        [strongSelf hideProgressHUD];
                        [strongSelf showHudTipStr:@"发帖已成功"];
                        //把tid传回去做本地页面刷新
                        id variables = data[@"Variables"];
                        block(YES,imageCount,variables[@"tid"]);
                    }else{
                        [strongSelf hideProgressHUDSuccess:NO andTipMess:message[@"messagestr"] withLock:NO];
                        block(NO,imageCount,nil);
                    }
                    
                }];
            }else{
                if (errorMessage) {
                    [strongSelf hideProgressHUDSuccess:NO andTipMess:errorMessage withLock:NO];
                    [strongSelf hideProgressHUD];
                    return ;
                }else{
                    [strongSelf hideProgressHUDSuccess:NO andTipMess:@"请求超时" withLock:NO];
                    [strongSelf hideProgressHUD];
                    
                    return;
                }
            }
            
        } progerssBlock:^(CGFloat progressValue) {
            
        }];
    }else{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [[Clan_NetAPIManager sharedManager]uploadSendPost:sendModel andBlock:^(id data, NSError *error) {
            id message = data[@"Message"];
            if ([message[@"messageval"] isEqualToString:Post_newthread_succeed]) {
                //发送成功
                [strongSelf hideProgressHUD];
                [strongSelf showHudTipStr:@"发帖已成功"];
                //把tid传回去做本地页面刷新
                id variables = data[@"Variables"];
                block(YES,0,variables[@"tid"]);
            }else{
                [strongSelf hideProgressHUDSuccess:NO andTipMess:message[@"messagestr"] withLock:NO];
                block(NO,0,nil);
            }
        }];
    }
}

- (void)request_DeleteCollection:(NSString *)collectionId andType:(NSString *)type andBlock:(void(^)(BOOL state))block
{
    [self showHudWithTitleDefault:NetLogin];
    CollcetionType colType = myPlate;
    if ([@"aid" isEqualToString:type]) {
        colType = myArticle;
    }
    else if ([@"tid" isEqualToString:type]) {
        colType = myPost;
    }
    else {
        colType = myPlate;
    }
    WEAKSELF
    [[Clan_NetAPIManager sharedManager]request_DeleteMyCollectionWithFavId:[Util getFavoIDFromID:collectionId forType:colType] andType:type andBlock:^(id data, NSError *error) {
        [weakSelf hudHide];
        if (error) {
            //错误
            [weakSelf showHudTipStr:NetError];
            return ;
        }else{
            id message = data[@"Message"];
            if ([message[@"messageval"] isEqualToString:@"favorite_delete_succeed"] ) {
                //删除收藏成功
                [weakSelf showHudTipStr:CollectSuccessMessage];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PLATEFAVO_UPDATE" object:nil];
                [Util deleteFavoed_withID:collectionId forType:colType];
                block(YES);
            }else{
                [weakSelf showHudTipStr:message[@"messagestr"]];
                return;
            }
        }
        
    }];
}

- (void)request_favBoardWithFid:(NSString *)fid andBlock:(void(^)(BOOL isSuccess))block{
    [self showHudWithTitleDefault:@"正在收藏"];
    WEAKSELF
    [[Clan_NetAPIManager sharedManager]request_favBoardWithFid:fid WithResultBlock:^(id data, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf hudHide];
        if (!error) {
            id message = data[@"Message"];
            if (message && [message[@"messageval"] isEqualToString:@"favorite_do_success"] ) {
                //收藏成功
                [strongSelf showHudTipStr:@"收藏成功"];
                id variables = data[@"Variables"];
                //刷新本地收藏 TODO 传入favoID!!!
                if (!variables[@"favid"]) {
                    block(NO);
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"PLATEFAVO_UPDATE" object:nil];
                    [Util addFavoed_withID:fid withFavoID:variables[@"favid"] forType:myPlate];
                    block(YES);
                }
            } else {
                NSString *show = (message && message[@"messagestr"]) ? message[@"messagestr"] : @"收藏失败，请重试";
                if (show.length == 0) {
                    show = @"收藏失败，请重试";
                }
                [strongSelf showHudTipStr:show];
            }
        }else{
            [strongSelf showHudTipStr:NetError];
        }
    }];
}


//请求分类帖子
- (void)request_classifiedPostsWithFid:(NSString *)fid andTypeId:(NSString *)type_id andPage:(int)page andBlock:(void(^)(NSArray *listArray,BOOL isMore))block
{
    WEAKSELF
    [[Clan_NetAPIManager sharedManager] request_classifiedPostsWithFid:fid andTypeId:type_id andPage:page andBlock:^(id data, NSError *error) {
        STRONGSELF
        if (error) {
            [strongSelf showHudTipStr:NetError];
        } else {
            id message = data[@"Message"];
            if ([message[@"messageval"] isEqualToString:Forum_nonexistence]) {
                [strongSelf showHudTipStr:PostErrorMessage];
                block(nil, NO);
                return;
            }
            NSMutableArray *resultArr = [NSMutableArray new];
            id resultData = [data valueForKeyPath:@"Variables"];
            NSString *preifx;
            if (resultData[@"threadtypes"]) {
                preifx = resultData[@"threadtypes"][@"prefix"];
            }
            for (NSDictionary *dic in [resultData objectForKey:@"forum_threadlist"]) {
                PostModel *postModel = [PostModel objectWithKeyValues:dic];
//                postModel.prefix = preifx;
                [postModel frameWithModel];
                postModel.hide_type = YES;
                [resultArr addObject:postModel];
            }
            NSString *moreStr = [resultData objectForKey:@"need_more"];
            BOOL isMore = (moreStr && moreStr.intValue == 1) ? YES : NO;
            block(resultArr, isMore);
        }
    }];
}

//活动帖子截图
- (void)request_uploadAcitvityFileImage:(SendImage *)sendImage withFid:(NSString *)fid withHash:(NSString *)hash andBlock:(void(^)(id data, bool success))block{
    WEAKSELF
    [[Clan_NetAPIManager sharedManager]request_uploadAcitvityFileImage:sendImage withFid:fid withHash:hash andBlock:^(id data, bool success) {
        if (!success) {
            if ([data isKindOfClass:[NSString class]]) {
                [weakSelf showHudTipStr:data];
            }
        }else{
            if (data) {
                block(data,YES);
            }
        }
    }];
}
//发起活动
- (void)request_PostActivity:(SendActivity *)model andBlock:(void(^)(id data, bool success))block{
    [self showProgressHUDWithStatus:@"正在发送帖子..." withLock:YES];
    WEAKSELF
    if (model.sendModel.imageArray.count > 0) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        //有图片的帖子
        [[Clan_NetAPIManager sharedManager] uploadSendImage:model.sendModel andBlock:^(BOOL isUpdate,AFHTTPRequestOperation *operation,NSInteger imageCount,NSString *errorMessage) {
            if (isUpdate) {
                //取出附件ID
                [[Clan_NetAPIManager sharedManager]upload_ActivityPost:model andBlock:^(id data, NSError *error) {
                    [strongSelf hideProgressHUD];
                    id message = data[@"Message"];
                    if ([message[@"messageval"] isEqualToString:Post_newthread_succeed]) {
                        [strongSelf hideProgressHUD];
                        [strongSelf showHudTipStr:@"发帖已成功"];
                        //把tid传回去做本地页面刷新
//                        id variables = data[@"Variables"];
                        block(data,YES);
                    }else{
                        [strongSelf hideProgressHUDSuccess:NO andTipMess:message[@"messagestr"] withLock:NO];
                        block(nil,NO);
                    }
                    
                }];
            }else{
                if (errorMessage) {
                    [strongSelf hideProgressHUDSuccess:NO andTipMess:errorMessage withLock:NO];
                    [strongSelf hideProgressHUD];
                    return ;
                }else{
                    [strongSelf hideProgressHUDSuccess:NO andTipMess:@"请求超时" withLock:NO];
                    [strongSelf hideProgressHUD];
                    
                    return;
                }
            }
            
        } progerssBlock:^(CGFloat progressValue) {
            
        }];
    }else{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [[Clan_NetAPIManager sharedManager]upload_ActivityPost:model andBlock:^(id data, NSError *error) {
            id message = data[@"Message"];
            if ([message[@"messageval"] isEqualToString:Post_newthread_succeed]) {
                //发送成功
                [strongSelf hideProgressHUD];
                [strongSelf showHudTipStr:@"发帖已成功"];
                //把tid传回去做本地页面刷新
                block(data,YES);
            }else{
                [strongSelf hideProgressHUDSuccess:NO andTipMess:message[@"messagestr"] withLock:NO];
                block(nil,NO);
            }
        }];
    }
}
@end
