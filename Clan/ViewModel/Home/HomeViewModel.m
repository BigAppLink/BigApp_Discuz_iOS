//
//  HomeViewModel.m
//  Clan
//
//  Created by chivas on 15/3/17.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "HomeViewModel.h"
#import "Clan_NetAPIManager.h"
#import "PostModel.h"
#import "BoardModel.h"
#import "CustomHomeMode.h"
#import "DBDao.h"
#import "ArticleListModel.h"
#import "CustomHomeListModel.h"
#import "ArticleDetailModel.h"
#import "BannerModel.h"
#import "LinkModel.h"
#import "ForumModel.h"
//内容型
static NSString *const customContentType = @"1";
//推荐型
static NSString *const customRecommendType = @"2";
@implementation HomeViewModel
- (void)request_hotPostBlock:(void(^)(id data))block{
    WEAKSELF
    [[Clan_NetAPIManager sharedManager]request_HotPostBlock:^(id data, NSError *error) {
        if (error) {
            //错误
            [weakSelf showHudTipStr:NetError];
            block(nil) ;
        }else{
            id resultData = [data valueForKeyPath:@"Variables"];
            NSMutableArray *dataArray = [NSMutableArray array];
            if (!isNull([resultData objectForKey:@"data"])) {
                for (NSDictionary *dic in [resultData objectForKey:@"data"]) {
                    PostModel *postModel = [PostModel objectWithKeyValues:dic];
                    postModel.modelType = @"1";
                    [postModel frameWithModel];
                    [dataArray addObject:postModel];
                }
            }
            block(dataArray);
        }
    }];
}

- (void)request_boardBlock:(void(^)(id data))block
{
    WEAKSELF
    [[Clan_NetAPIManager sharedManager]request_BoardBlock:^(id data, NSError *error) {
        if (error) {
            //错误
            [weakSelf showHudTipStr:NetError];
            block(nil);
        }else{
            //设置版块儿缓存
            [[CacheManager sharedCacheManager] saveCache:data forCacheModule:kCacheModule_Forum];
            id resultData = [data valueForKeyPath:@"Variables"];
            NSMutableArray *dataArray = [NSMutableArray array];
            for (NSDictionary *dic in [resultData objectForKey:@"forums"]) {
                BoardModel *boardModel = [BoardModel objectWithKeyValues:dic];
                [dataArray addObject:boardModel];
            }
            //存储forums
            [UserDefaultsHelper saveDefaultsValue:[resultData objectForKey:@"forums"] forKey:kUserDefaultsKey_ForumsStore];
//            [[NSUserDefaults standardUserDefaults] setObject:[resultData objectForKey:@"forums"] forKey:@"forumsStore"];
            block(dataArray);
        }
    }];
}

//首页组件化自定义接口
- (void)request_customModuleHomeWithListType:(NSString *)type andBlock:(void(^)(NSArray *hotArray,BOOL isError))block{
    static NSMutableArray *dataArray = nil;
    if (type) {
        [[Clan_NetAPIManager sharedManager]request_customHomeWithListType:type andBlock:^(id data, NSError *error) {
            //热点数据解析
            if (error) {
                //错误
                block(nil,YES);
                return ;
            }else{
                if (!dataArray) {
                    dataArray = [NSMutableArray array];
                }
                [dataArray removeAllObjects];
                CacheDBDao *cache = [CacheManager sharedCacheManager];
                if (type) {
                    [cache saveCache:data forCachetType:type];
                    id resultData = [data valueForKeyPath:@"Variables"];
                    NSString *open_image_mode = resultData[@"open_image_mode"];
                    if (open_image_mode && !isNull(open_image_mode)) {
                        [NSString updatePlistWithName:kOpenImageMode andString:open_image_mode];
                    }
                    if (!isNull([resultData objectForKey:@"data"])) {
                        for (NSDictionary *dic in [resultData objectForKey:@"data"]) {
                            PostModel *postModel = [PostModel objectWithKeyValues:dic];
                            postModel.modelType = @"1";
                            [postModel frameWithModel];
                            [dataArray addObject:postModel];
                        }
                    }
                }
                block(dataArray,NO);
            }
        }];
    }
    

}
//自定义首页接口

- (void)request_customHomeWithListType:(CustomHomeListModel *)type andBlock:(void(^)(CustomHomeMode *customHomeModel,NSArray *hotArray,BOOL isError))block
{
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    static BOOL isError = NO;
    static CustomHomeMode *customHomeModel = nil;
    [[Clan_NetAPIManager sharedManager]request_customHomeWithBlock:^(id data, NSError *error) {
        dispatch_group_leave(group);
        if (error) {
            isError = YES;
        } else {
            //首页头部视图数据解析
            [[CacheManager sharedCacheManager] saveCache:data forCacheModule:kCacheModule_Home_Functions];
            id resultData = [data valueForKeyPath:@"Variables"];
            customHomeModel = [CustomHomeMode objectWithKeyValues:[resultData objectForKey:@"myhome"]];
            
        }
    }];
    static NSMutableArray *dataArray = nil;
    if (type) {
        dispatch_group_enter(group);
        if ([type.type isEqualToString:@"4"]) {
            //文章
            [[Clan_NetAPIManager sharedManager]request_articleType:type.articleId page:@"" andBlcok:^(id data, NSError *error) {
                dispatch_group_leave(group);
                if (error) {
                    isError = YES;
                }else{
                    CacheDBDao *cache = [CacheManager sharedCacheManager];
                    if (type) {
                        [cache saveCache:data forCachetType:[NSString stringWithFormat:@"%@_%@",type.module,type.articleId]];
                    }
                    id resultData = [data valueForKeyPath:@"Variables"];
                    if (!dataArray) {
                        dataArray = [NSMutableArray array];
                    }
                    [dataArray removeAllObjects];
                    if (![resultData[@"data"] isEqual:[NSNull null]]) {
                        for (NSDictionary *dic in resultData[@"data"]) {
                            ArticleListModel *articleModel = [ArticleListModel objectWithKeyValues:dic];
                            [dataArray addObject:articleModel];
                        }
                    }
                }
            }];
        }else{
            //论坛帖子
            [[Clan_NetAPIManager sharedManager]request_customHomeWithListType:type.module andBlock:^(id data, NSError *error) {
                dispatch_group_leave(group);
                //热点数据解析
                if (error) {
                    //错误
                    isError = YES;
                }else{
                    if (!dataArray) {
                        dataArray = [NSMutableArray array];
                    }
                    [dataArray removeAllObjects];
                    CacheDBDao *cache = [CacheManager sharedCacheManager];
                    
                    if (type) {
                        [cache saveCache:data forCachetType:[NSString stringWithFormat:@"%@_%@",type.module,type.type]];
                        id resultData = [data valueForKeyPath:@"Variables"];
                        NSString *open_image_mode = resultData[@"open_image_mode"];
                        if (open_image_mode && !isNull(open_image_mode)) {
                            [NSString updatePlistWithName:kOpenImageMode andString:open_image_mode];
                        }
                        if (!isNull([resultData objectForKey:@"data"])) {
                            for (NSDictionary *dic in [resultData objectForKey:@"data"]) {
                                PostModel *postModel = [PostModel objectWithKeyValues:dic];
                                postModel.modelType = @"1";
                                [postModel frameWithModel];
                                [dataArray addObject:postModel];
                            }
                        }
                    }
                    
                }
            }];
        }
        
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //全部完成后回调
        block(customHomeModel,dataArray,isError);
    });
}

- (void)request_cacheWithCustomType:(CustomHomeListModel *)type andBlock:(void(^)(NSArray *hotArray,BOOL isError))block{
    if (type) {
        NSMutableArray *dataArray = [NSMutableArray new];
        CacheDBDao *cache = [CacheManager sharedCacheManager];
        if (type) {
            id cacheData_posts = [cache cacheForType:type.data_link];
            id resultData = [cacheData_posts valueForKeyPath:@"Variables"];
            if (!isNull([resultData objectForKey:@"data"])) {
                for (NSDictionary *dic in [resultData objectForKey:@"data"]) {
                    if ([type.type isEqualToString:customContentType]) {
                        if (dic[@"tid"]) {
                            //有tid是帖子 否则是文章
                            PostModel *postModel = [PostModel objectWithKeyValues:dic];
                            postModel.modelType = @"1";
                            [postModel frameWithModel];
                            [dataArray addObject:postModel];
                        }else{
                            ArticleListModel *articleModel = [ArticleListModel objectWithKeyValues:dic];
                            [dataArray addObject:articleModel];
                        }
                    }else if ([type.type isEqualToString:customRecommendType]){
                        PostModel *postModel = [PostModel objectWithKeyValues:dic];
                        postModel.modelType = @"1";
                        [postModel frameWithModel];
                        [dataArray addObject:postModel];
                    }
                }
            }
        }
        block(dataArray,NO);
    }
}

- (void)request_customHomeWithType:(CustomHomeListModel *)type page:(NSString *)page andBlock:(void(^)(BOOL isMore,NSArray *hotArray,BOOL isError))block{
    WEAKSELF
    [[Clan_NetAPIManager sharedManager]request_customHomeWithNewList:type ?type.data_link:@"" page:page andBlock:^(id data, NSError *error) {
        STRONGSELF
        if (error) {
            [strongSelf showHudTipStr:NetError];
            block(NO,nil,YES);
            return ;
        }else{
            if (data) {
                NSMutableArray *dataArray = [NSMutableArray array];
                if ([page isEqualToString:@"1"]) {
                    //缓存
                    CacheDBDao *cache = [CacheManager sharedCacheManager];
                    if (type) {
                        [cache saveCache:data forCachetType:type.data_link];
                    }
                }
                id resultData = [data valueForKeyPath:@"Variables"];
                NSString *open_image_mode = resultData[@"pic_mode"];
                if (open_image_mode && !isNull(open_image_mode)) {
                    [NSString updatePlistWithName:kOpenImageMode andString:open_image_mode];
                }
                [dataArray removeAllObjects];
                if (![resultData[@"data"] isEqual:[NSNull null]]) {
                    for (NSDictionary *dic in resultData[@"data"]) {
                        if ([type.type isEqualToString:customContentType]) {
                            if (dic[@"tid"]) {
                                //有tid是帖子 否则是文章
                                PostModel *postModel = [PostModel objectWithKeyValues:dic];
                                postModel.modelType = @"1";
                                [postModel frameWithModel];
                                [dataArray addObject:postModel];
                            }else{
                                ArticleListModel *articleModel = [ArticleListModel objectWithKeyValues:dic];
                                [dataArray addObject:articleModel];
                            }
                        }else if ([type.type isEqualToString:customRecommendType]){
                            PostModel *postModel = [PostModel objectWithKeyValues:dic];
                            postModel.modelType = @"1";
                            [postModel frameWithModel];
                            [dataArray addObject:postModel];
                        }
                    }
                }
                BOOL isMore = [resultData[@"need_more"] isEqualToString:@"1"];
                block(isMore,dataArray,NO);
            }
        }
    }];
}

//读取缓存数据
- (void)request_cacheWithType:(CustomHomeListModel *)type andBlock:(void(^)(CustomHomeMode *customHomeModel,NSArray *hotArray,BOOL isError))block{
    
        CustomHomeMode *model = nil;
    NSMutableArray *arr = [NSMutableArray new];
    id cacheData = [[CacheManager sharedCacheManager] cacheForModule:kCacheModule_Home_Functions];
    if (cacheData) {
        id resultData = [cacheData valueForKeyPath:@"Variables"];
        model = [CustomHomeMode objectWithKeyValues:[resultData objectForKey:@"myhome"]];
    }
    if (type) {
        CacheDBDao *cache = [CacheManager sharedCacheManager];
        if ([type.type isEqualToString:@"4"]) {
            //文章缓存
            id cacheData_posts = [cache cacheForType:[NSString stringWithFormat:@"%@_%@",type.module,type.articleId]];
            id resultData = [cacheData_posts valueForKeyPath:@"Variables"];
            if (!isNull([resultData objectForKey:@"data"])) {
                for (NSDictionary *dic in [resultData objectForKey:@"data"]) {
                    ArticleListModel *postModel = [ArticleListModel objectWithKeyValues:dic];
                    [arr addObject:postModel];
                }
            }
        }else{
            if (type) {
                id cacheData_posts = [cache cacheForType:[NSString stringWithFormat:@"%@_%@",type.module,type.type]];
                id resultData = [cacheData_posts valueForKeyPath:@"Variables"];
                if (!isNull([resultData objectForKey:@"data"])) {
                    for (NSDictionary *dic in [resultData objectForKey:@"data"]) {
                        PostModel *postModel = [PostModel objectWithKeyValues:dic];
                        postModel.modelType = @"1";
                        [postModel frameWithModel];
                        [arr addObject:postModel];
                    }
                }
            }
        }
    }
    block(model,arr,NO);
}
//读取文章缓存
- (void)request_cacheWithArticleType:(NSString *)type andBlock:(void(^)(NSMutableArray *articleArray,BOOL isError))block{
    if (type) {
        NSMutableArray *arr = [NSMutableArray new];
        CacheDBDao *cache = [CacheManager sharedCacheManager];
        if (type) {
            id cacheData_posts = [cache cacheForType:type];
            id resultData = [cacheData_posts valueForKeyPath:@"Variables"];
            if (!isNull([resultData objectForKey:@"data"])) {
                for (NSDictionary *dic in [resultData objectForKey:@"data"]) {
                    ArticleListModel *postModel = [ArticleListModel objectWithKeyValues:dic];
                    [arr addObject:postModel];
                }
            }
        }
        block(arr,NO);
    }
}

//版块儿缓存
- (void)request_boardCache:(void(^)(id data))block
{
    id cacheData = [[CacheManager sharedCacheManager] cacheForModule:kCacheModule_Forum];
    NSMutableArray *dataArray = [NSMutableArray new];
    id resultData = [cacheData valueForKeyPath:@"Variables"];
    for (NSDictionary *dic in [resultData objectForKey:@"forums"]) {
        BoardModel *boardModel = [BoardModel objectWithKeyValues:dic];
        [dataArray addObject:boardModel];
    }
    block(dataArray);
}
//文章列表
- (void)request_articleType:(NSString *)type page:(NSString *)page andBlcok:(void(^)(id data,BOOL isMore))block{
    WEAKSELF
    [[Clan_NetAPIManager sharedManager]request_articleType:type page:page andBlcok:^(id data, NSError *error) {
        if (error) {
            [weakSelf showHudTipStr:NetError];
            block(nil,NO);
        }else{
            if ([page isEqualToString:@"1"]) {
                CacheDBDao *cache = [CacheManager sharedCacheManager];
                if (type) {
                    [cache saveCache:data forCachetType:type];
                }
            }
            id resultData = [data valueForKeyPath:@"Variables"];
            NSMutableArray *array = [NSMutableArray array];
            if (![resultData[@"data"] isEqual:[NSNull null]]) {
                for (NSDictionary *dic in resultData[@"data"]) {
                    ArticleListModel *articleModel = [ArticleListModel objectWithKeyValues:dic];
                    [array addObject:articleModel];
                }
            }

            BOOL isMore = NO;
            if ([resultData[@"needmore"] isEqualToString:@"1"]) {
                isMore = YES;
            }
            block(array,isMore);
        }
    }];
}

//文章详情
- (void)request_articleDetailWithId:(NSString *)aid andBlock:(void(^)(id data))block{
    WEAKSELF
    [[Clan_NetAPIManager sharedManager]request_articleDetailWithId:aid andBlock:^(id data, NSError *error) {
        if (error) {
            [weakSelf showHudTipStr:NetError];
            block(nil);
        }else{
            if (data) {
                id resultData = [data valueForKeyPath:@"Variables"];
                ArticleDetailModel *articleModel = [ArticleDetailModel objectWithKeyValues:resultData[@"data"]];
                block(articleModel);
            }else{
                block(nil);
            }
            
        }
    }];
}
//首页数据Model
- (CustomHomeMode *)request_homeWithDataArray:(NSArray *)array{
    CustomHomeMode *customHomeModel = [CustomHomeMode new];
    for (NSDictionary *dicType in array) {
        if ([dicType[@"type"] isEqualToString:@"banner"]) {
            NSMutableArray *bannerArray = [NSMutableArray array];
            for (NSDictionary *bannerDic in dicType[@"setting"]) {
                BannerModel *bannerModel = [BannerModel objectWithKeyValues:bannerDic];
                [bannerArray addObject:bannerModel];
            }
            customHomeModel.banner = bannerArray;
        }else if ([dicType[@"type"] isEqualToString:@"func"]){
            NSMutableArray *linkArray = [NSMutableArray array];
            for (NSDictionary *linkDic in dicType[@"setting"]) {
                LinkModel *linkModel = [LinkModel objectWithKeyValues:linkDic];
                [linkArray addObject:linkModel];
            }
            customHomeModel.link = linkArray;
        }else if ([dicType[@"type"] isEqualToString:@"hot"]){
            NSMutableArray *hotArray = [NSMutableArray array];
            for (NSDictionary *hotDic in dicType[@"setting"]) {
                ForumModel *forumModel = [ForumModel objectWithKeyValues:hotDic];
                [hotArray addObject:forumModel];
            }
            customHomeModel.forum = hotArray;
        }else if ([dicType[@"type"] isEqualToString:@"recomm"]){
            NSMutableArray *recomm = [NSMutableArray array];
            for (NSDictionary *recommDic in dicType[@"recommend"][@"thread_config"]) {
                CustomHomeListModel *listModel = [CustomHomeListModel objectWithKeyValues:recommDic];
                listModel.type = dicType[@"recommend"][@"type"];
                [recomm addObject:listModel];
            }
            customHomeModel.recommend = recomm;
            customHomeModel.recommendType = dicType[@"recommend"][@"type"];
        }
    }
    return customHomeModel;
}
@end
