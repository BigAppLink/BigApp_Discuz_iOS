//
//  CacheDBDao.h
//  Clan
//
//  Created by 昔米 on 15/7/7.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "DBDao.h"
/*
** 缓存模块
*/
typedef enum
{
    kCacheModule_Home_Functions = 0, //首页功能区
    kCacheModule_Home_Posts, //首页帖子区
    kCacheModule_Forum, //版块儿
    kCacheModule_Dialog, //消息
    kCacheModule_ForumPosts, //单独版块儿
    kCacheModule_new,//最新回复
    kCacheModule_digest,//精华帖
    kCacheModule_hot, //热帖
    kCacheModule_newthread, //新帖
}kCacheModule;

#define kCacheModuleArray @"kCacheModule_Home_Functions", @"kCacheModule_Home_Posts", @"kCacheModule_Forum", @"kCacheModule_Dialog",@"kCacheModule_ForumPosts",@"kCacheModule_new",@"kCacheModule_digest",@"kCacheModule_hot",@"kCacheModule_newthread", nil


@interface CacheDBDao : DBDao
{
    BOOL _isTableExist;
    NSString *_tablename;
}
@property (assign,nonatomic)kCacheModule kcacheType;

/*
 ** 设置一级缓存
 */
- (BOOL)saveCache:(id)datas forCacheModule:(kCacheModule)module;
- (BOOL)saveCache:(id)datas forCachetType:(NSString *)type;

/*
 ** 设置对应版块儿的帖子缓存
 */
- (BOOL)saveCache:(id)datas withForumID:(NSString *)ForumID;

/*
 ** 设置缓存
 */
- (BOOL)saveCache:(id)datas forCacheModule:(kCacheModule)module withForumID:(NSString *)ForumID;

/*
 ** 清除缓存
 */
- (BOOL)cleanUpCache:(kCacheModule)module;

/*
 ** 获取一级缓存
 */
- (id)cacheForModule:(kCacheModule)module;

/*
 ** 获取版块儿帖子缓存
 */
- (id)cacheForForum:(NSString *)ForumID;

/*
 ** 缓存
 */
- (id)cacheForModule:(kCacheModule)module withForum:(NSString *)ForumID;
/**
 *  string转枚举
 */
- (kCacheModule) moduleStringToEnum:(NSString*)strVal;
/**
 *  通过type类型记录缓存
 */
- (id)cacheForType:(NSString *)type;


//清除缓存
- (BOOL)cleanUpCache;
@end
