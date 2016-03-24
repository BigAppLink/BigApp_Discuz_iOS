//
//  HomeViewModel.h
//  Clan
//
//  Created by chivas on 15/3/17.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ViewModelClass.h"
#import "CustomHomeMode.h"
@class CustomHomeListModel;
@interface HomeViewModel : ViewModelClass

@property (copy, nonatomic) void(^tempBlock)(id data);

//首页组件化自定义接口
- (void)request_customModuleHomeWithListType:(NSString *)type andBlock:(void(^)(NSArray *hotArray,BOOL isError))block;
- (void)request_customHomeWithListType:(CustomHomeListModel *)type andBlock:(void(^)(CustomHomeMode *customHomeModel,NSArray *hotArray,BOOL isError))block;
- (void)request_cacheWithType:(CustomHomeListModel *)type andBlock:(void(^)(CustomHomeMode *customHomeModel,NSArray *hotArray,BOOL isError))block;
//读取文章缓存
- (void)request_cacheWithArticleType:(NSString *)type andBlock:(void(^)(NSMutableArray *articleArray,BOOL isError))block;
//版块儿列表
- (void)request_hotPostBlock:(void(^)(id data))block;
- (void)request_boardBlock:(void(^)(id data))block;
//版块儿缓存
- (void)request_boardCache:(void(^)(id data))block;
//取文章列表
- (void)request_articleType:(NSString *)type page:(NSString *)page andBlcok:(void(^)(id data,BOOL isMore))block;
//取得文章详情
- (void)request_articleDetailWithId:(NSString *)aid andBlock:(void(^)(id data))block;
//首页数据model
- (CustomHomeMode *)request_homeWithDataArray:(NSArray *)array;
/**
 *  关于组件化首页新增接口
 */
- (void)request_cacheWithCustomType:(CustomHomeListModel *)type andBlock:(void(^)(NSArray *hotArray,BOOL isError))block;
- (void)request_customHomeWithType:(CustomHomeListModel *)type page:(NSString *)page andBlock:(void(^)(BOOL isMore,NSArray *hotArray,BOOL isError))block;

@end
