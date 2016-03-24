//
//  CollectionViewModel.h
//  Clan
//
//  Created by chivas on 15/3/16.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ViewModelClass.h"
//typedef NS_ENUM(NSInteger, CollcetionApiType) {
//    MyPostApi = 0,
//    myPlateApi
//};
@interface CollectionViewModel : ViewModelClass

@property (strong, nonatomic) NSMutableDictionary *favoThreadsDic;
@property (strong, nonatomic) NSMutableDictionary *favoFormsDic;
@property (strong, nonatomic) NSMutableDictionary *favoArticlesDic;

@property (assign) BOOL favoFormsRequestCompleted;
@property (assign) BOOL favoThreadsRequestCompleted;
@property (assign) BOOL favoFormsRequestLoading;
@property (assign) BOOL favoThreadsRequestLoading;
@property (assign) BOOL favoArticlesRequestCompleted;
@property (assign) BOOL favoArticlesRequestLoading;


- (void)request_MyCollection:(CollcetionType)type antPage:(NSNumber *)page andBlock:(void(^)(id data, BOOL need_more))block;
- (void)request_DeleteCollection:(NSString *)collectionId andType:(NSString *)type andBlock:(void(^)(BOOL state))block;
@property (copy, nonatomic) void(^tempBlock)(id data, BOOL need_more);

- (void)requestAllFavoForm;

- (void)requestAllFavoThread;

//请求所有的文章收藏
- (void)requestAllArticleFavo;

//收藏一个帖子
- (void)doFavoAPostByID:(NSString *)fid andBlock:(void(^)(BOOL success))block;

//收藏文章
- (void)doAnArticleByID:(NSString *)aid andBlock:(void(^)(BOOL success))block;
@end
