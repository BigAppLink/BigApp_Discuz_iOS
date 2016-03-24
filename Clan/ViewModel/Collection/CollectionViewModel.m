//
//  CollectionViewModel.m
//  Clan
//
//  Created by chivas on 15/3/16.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "CollectionViewModel.h"
#import "Clan_NetAPIManager.h"
#import "ForumsModel.h"
#import "CollectionModel.h"

@implementation CollectionViewModel

- (void)dealloc
{
    DLog(@"CollectionViewModel dealloc");
}

- (void)request_MyCollection:(CollcetionType)type antPage:(NSNumber *)page andBlock:(void(^)(id data, BOOL need_more))block
{
    _tempBlock = nil;
    self.tempBlock = block;
    if (type == myPost)
    {
        [self requestPostApi_atPage:page withAll:NO];
    }
    else if (type == myPlate)
    {
        [self requestPlateApi_atPage:page withAll:NO];
    }
    else {
        [self requestArticleApi_atPage:page withAll:NO];
    }
}

- (void)requestPostApi_atPage:(NSNumber *)page withAll:(BOOL)isAll
{
    WEAKSELF
    [[Clan_NetAPIManager sharedManager]request_MyPostCollection_atPage:page andBlock:^(id data, NSError *error) {
        STRONGSELF
        if (error) {
            //错误
            if (!isAll)  [weakSelf showHudTipStr:NetError];
            if (strongSelf.tempBlock) {
                strongSelf.tempBlock(data, NO);
            }
            strongSelf.favoThreadsRequestLoading = NO;
            return ;

        } else {
            id Message = [data valueForKey:@"Message"];
            if (Message) {
                NSString *mess = Message[@"messagestr"];
                if (!isAll) {
                    strongSelf.tempBlock(mess, NO);
                }
                strongSelf.favoThreadsRequestLoading = NO;
                return;
            }
            id resultData = [data valueForKeyPath:@"Variables"];

            NSString *needMore = [resultData valueForKey:@"need_more"];
            BOOL need_more = [@"1" isEqualToString:needMore] ? YES : NO;
            if (!isAll) {
                CollectionModel *collectionListModel = [CollectionModel objectWithKeyValues:resultData];
                strongSelf.tempBlock(collectionListModel, need_more);
                strongSelf.favoThreadsRequestLoading = NO;
                return;
            }
            else {
                //为了请求所有的收藏
                NSArray *arr1 = [resultData valueForKey:@"list"];
                if (page.intValue == 1) {
                    [strongSelf.favoThreadsDic removeAllObjects];
                }
                for (NSDictionary *dic in arr1) {
                    //存储收藏ID到本地
                    [strongSelf.favoThreadsDic setObject:avoidNullStr(dic[@"favid"]) forKey:dic[@"id"]];
                }
                if (need_more) {
                    //两页以上的数据，递归请求
                    int nexppage = page.intValue + 1;
                    [strongSelf requestPostApi_atPage:[NSNumber numberWithInt:nexppage] withAll:YES];
                } else {
                    //结束请求，存储数据
                    strongSelf.favoThreadsRequestLoading = NO;
                    strongSelf.favoThreadsRequestCompleted = YES;
                    [strongSelf saveToLocalWithThreadType:myPost];
                    return;
                }
            }
        }
    }];
}

- (void)requestPlateApi_atPage:(NSNumber *)page withAll:(BOOL)isAll
{
    WEAKSELF
    [[Clan_NetAPIManager sharedManager]request_MyPlateCollection_atPage:page andBlock:^(id data, NSError *error) {
        STRONGSELF
        if (error) {
            //错误
            if (!isAll)  [strongSelf showHudTipStr:NetError];
            strongSelf.favoFormsRequestLoading = NO;
            if (strongSelf.tempBlock) {
                strongSelf.tempBlock(nil,YES);
            }
            return ;
        }
        else {
            id Message = [data valueForKey:@"Message"];
            if (Message) {
                NSString *mess = Message[@"messagestr"];
                if (!isAll) {
                    strongSelf.tempBlock(mess, NO);
                }
                //尚未登录
                strongSelf.favoFormsRequestLoading = NO;
                return;
            }
            id resultData = [data valueForKeyPath:@"Variables"];
            NSString *needMore = [resultData valueForKey:@"need_more"];
            BOOL need_more = [@"1" isEqualToString:needMore] ? YES : NO;
            NSArray *array = [resultData objectForKey:@"list"];
            if(!isAll) {
                NSMutableArray *dataArray = [NSMutableArray array];
                for (NSDictionary *dic in array) {
                    ForumsModel *forumsModel = [ForumsModel objectWithKeyValues:dic];
                    forumsModel.fid = dic[@"id"];
                    [dataArray addObject:forumsModel];
                }
                _tempBlock(dataArray, need_more);
                strongSelf.favoFormsRequestLoading = NO;
                return;
            }
            else {
                //为了请求所有的版块收藏
                NSArray *arr1 = [resultData valueForKey:@"list"];
                if (page.intValue == 1) {
                    [strongSelf.favoFormsDic removeAllObjects];
                }
                for (NSDictionary *dic in arr1) {
                    //存储收藏ID到本地
                    [strongSelf.favoFormsDic setObject:avoidNullStr(dic[@"favid"]) forKey:dic[@"id"]];
                }
                if (need_more) {
                    //两页以上的数据，递归请求
                    int nexppage = page.intValue+1;
                    [strongSelf requestPlateApi_atPage:[NSNumber numberWithInt:nexppage] withAll:YES];
                } else {
                    //结束请求，存储数据
                    strongSelf.favoFormsRequestLoading = NO;
                    strongSelf.favoFormsRequestCompleted = YES;
                    [strongSelf saveToLocalWithThreadType:myPlate];
                    return;
                }
            }
        }
    }];
}

//文章收藏
- (void)requestArticleApi_atPage:(NSNumber *)page withAll:(BOOL)isAll
{
    WEAKSELF
    [[Clan_NetAPIManager sharedManager] request_articleFavoAtPage:page WithBlock:^(id data, NSError *error) {
        STRONGSELF
        if (error) {
            //错误
            if (!isAll)  [weakSelf showHudTipStr:NetError];
            if (strongSelf.tempBlock) {
                strongSelf.tempBlock(data, NO);
            }
            strongSelf.favoArticlesRequestLoading = NO;
            return ;
            
        } else {
            id Message = [data valueForKey:@"Message"];
            if (Message) {
                NSString *mess = Message[@"messagestr"];
                if (!isAll) {
                    strongSelf.tempBlock(mess, NO);
                }
                strongSelf.favoArticlesRequestLoading = NO;
                return;
            }
            id resultData = [data valueForKeyPath:@"Variables"];
            
            NSString *needMore = [resultData valueForKey:@"need_more"];
            BOOL need_more = [@"1" isEqualToString:needMore] ? YES : NO;
            if (!isAll) {
                CollectionModel *collectionListModel = [CollectionModel objectWithKeyValues:resultData];
                strongSelf.tempBlock(collectionListModel, need_more);
                strongSelf.favoArticlesRequestLoading = NO;
                return;
            }
            else {
                //为了请求所有的收藏
                NSArray *arr1 = [resultData valueForKey:@"list"];
                if (page.intValue == 1) {
                    [strongSelf.favoArticlesDic removeAllObjects];
                }
                for (NSDictionary *dic in arr1) {
                    //存储收藏ID到本地
                    [strongSelf.favoArticlesDic setObject:avoidNullStr(dic[@"favid"]) forKey:dic[@"id"]];
                }
                if (need_more) {
                    //两页以上的数据，递归请求
                    int nexppage = page.intValue + 1;
                    [strongSelf requestArticleApi_atPage:[NSNumber numberWithInt:nexppage] withAll:YES];
                } else {
                    //结束请求，存储数据
                    strongSelf.favoArticlesRequestLoading = NO;
                    strongSelf.favoArticlesRequestCompleted = YES;
                    [strongSelf saveToLocalWithThreadType:myArticle];
                    return;
                }
            }
        }
    }];
}

- (void)request_DeleteCollection:(NSString *)collectionId andType:(NSString *)type andBlock:(void(^)(BOOL state))block
{
//    [self showHudWithTitleDefault:NetLogin];
    WEAKSELF
    [[Clan_NetAPIManager sharedManager]request_DeleteMyCollectionWithFavId:collectionId andType:type andBlock:^(id data, NSError *error) {
        STRONGSELF
        [strongSelf hudHide];
        if (error) {
            //错误
            [strongSelf showHudTipStr:NetError];
            block(NO);
            return ;
        }
        else {
            id message = data[@"Message"];
            if ([message[@"messageval"] isEqualToString:@"favorite_delete_succeed"] ) {
                //删除收藏成功
                [[NSNotificationCenter defaultCenter] postNotificationName:@"POSTFAVO_UPDATE" object:nil];
                [strongSelf showHudTipStr:CollectSuccessMessage];
                block(YES);
            }else{
                [strongSelf showHudTipStr:message[@"messagestr"]];
                block(NO);
                return;
            }
        }

    }];
}

//收藏一个帖子
- (void)doFavoAPostByID:(NSString *)fid andBlock:(void(^)(BOOL success))block
{
    [self showHudWithTitleDefault:@"收藏中.."];
    WEAKSELF
    [[Clan_NetAPIManager sharedManager]favo_a_post_byid:fid andBlock:^(id data, NSError *error) {
        STRONGSELF
        [strongSelf hudHide];
        if (error) {
            //错误
            [strongSelf showHudTipStr:NetError];
            return ;
        }
        else {
            id message = data[@"Message"];
            [strongSelf showHudTipStr:message[@"messagestr"]];
            if ([message[@"messageval"] isEqualToString:@"favorite_do_success"] ) {
                //收藏成功 TODO 拿到favoID
                id variables = data[@"Variables"];
                //刷新本地收藏 TODO 传入favoID!!!
                if (!variables[@"favid"]) {
                    block(NO);
                } else {
                    //发送通知 收到帖子收藏了
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"POSTFAVO_UPDATE" object:nil];
                    [Util addFavoed_withID:fid withFavoID:variables[@"favid"] forType:myPost];
                    block(YES);
                }
            } else {
                block(NO);
                return;
            }
        }
    }];
}

//收藏文章
- (void)doAnArticleByID:(NSString *)aid andBlock:(void(^)(BOOL success))block
{
    [self showHudWithTitleDefault:@"收藏中.."];
    WEAKSELF
    [[Clan_NetAPIManager sharedManager] request_doFavoAnArticleWithId:aid WithBlock:^(id data, NSError *error) {
        STRONGSELF
        [strongSelf hudHide];
        if (error) {
            //错误
            [strongSelf showHudTipStr:NetError];
            return ;
        }
        else {
            id message = data[@"Message"];
            [strongSelf showHudTipStr:message[@"messagestr"]];
            if ([message[@"messageval"] isEqualToString:@"favorite_do_success"] ) {
                //收藏成功 TODO 拿到favoID
                id variables = data[@"Variables"];
                //刷新本地收藏 TODO 传入favoID!!!
                if (!variables[@"favid"]) {
                    block(NO);
                } else {
                    //发送通知 收到帖子收藏了
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"POSTFAVO_UPDATE" object:nil];
                    [Util addFavoed_withID:aid withFavoID:variables[@"favid"] forType:myArticle];
                    block(YES);
                }
            } else {
                if (!message || !message[@"messagestr"]) {
                    [strongSelf showHudTipStr:@"收藏失败"];
                }
                block(NO);
                return;
            }
        }
    }];
}


//请求所有的版块收藏
- (void)requestAllFavoForm
{
    _favoFormsDic = [NSMutableDictionary new];
    _favoFormsRequestLoading = YES;
    [self requestPlateApi_atPage:[NSNumber numberWithInt:1] withAll:YES];
}

//请求所有的帖子收藏
- (void)requestAllFavoThread
{
    _favoThreadsDic = [NSMutableDictionary new];
    _favoThreadsRequestLoading = YES;
    [self requestPostApi_atPage:[NSNumber numberWithInt:1] withAll:YES];
}

//请求所有的文章收藏
- (void)requestAllArticleFavo
{
    _favoArticlesDic = [NSMutableDictionary new];
    _favoArticlesRequestLoading = YES;
    [self requestArticleApi_atPage:[NSNumber numberWithInt:1] withAll:YES];
}

- (void)saveToLocalWithThreadType:(CollcetionType)colType
{
    if (colType == myPost) {
        [[NSUserDefaults standardUserDefaults]setObject:_favoThreadsDic forKey:kKEY_FAVO_THREADS];
    }
    else if (colType == myPlate) {
        [[NSUserDefaults standardUserDefaults]setObject:_favoFormsDic forKey:kKEY_FAVO_FORUMS];
    }
    else {
        [[NSUserDefaults standardUserDefaults]setObject:_favoArticlesDic forKey:kKEY_FAVO_ARTICLES];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
