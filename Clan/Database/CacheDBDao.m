//
//  CacheDBDao.m
//  缓存DB
//
//  Created by 昔米 on 15/7/7.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "CacheDBDao.h"
#import "FMDatabaseAdditions.h"
static NSString *tableNameTag = @"Cache";

@implementation CacheDBDao

#pragma mark - 初始化
- (id)init
{
    if (self = [super init])
    {
        _tablename = [NSString stringWithFormat:@"%@_cachetable", tableNameTag];
        [self createTable];
    }
    return self;
}

- (void)dealloc
{
    DLog(@"CacheDBDao dealloc");
}

#pragma mark - 创建数据表
- (void)createTable
{
    //数据库是否存在
    if (!self.db) {
        self.db = [DataBase sharedDatabase];
    }
    if (![db open]) {
        [db open];
    }
    //设置缓存
    [self.db setShouldCacheStatements:YES];
    //判断是否存在此数据表
    if (![self.db tableExists:_tablename]) {
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE \"%@\" (\"CacheModule\" TEXT check(typeof(\"CacheModule\") = 'text'),\"sourcedatas\" BLOB, \"ForumID\" TEXT)",_tablename];
        DLog(@"创建cache表: %@", sql);
        _isTableExist = [self.db executeUpdate:sql];
        DLog(@"创建cache表 %@", _isTableExist ? @"成功" : @"失败");
    }
    else {
        _isTableExist = YES;
        DLog(@"cache表已经存在");
    }
}

#pragma mark - 设置缓存
/*
 ** 设置一级缓存
 */
- (BOOL)saveCache:(id)datas forCacheModule:(kCacheModule)module
{
    return [self saveCache:datas forCacheModule:module withForumID:@""];
}

- (BOOL)saveCache:(id)datas forCachetType:(NSString *)type
{
    return [self saveCache:datas forCacheType:type withForumID:@""];
}

/*
 ** 设置每个版块儿的帖子的缓存
 */
- (BOOL)saveCache:(id)datas withForumID:(NSString *)ForumID
{
    return [self saveCache:datas forCacheModule:kCacheModule_ForumPosts withForumID:ForumID];
}

/*
 ** 设置缓存
 */
- (BOOL)saveCache:(id)datas forCacheModule:(kCacheModule)module withForumID:(NSString *)ForumID
{
    if (!datas) {
        return NO;
    }
    NSString *valueForumID = [self valueForForumID:ForumID];
    if ([self isCached:module withForumID:valueForumID]) {
        return [self updatCache:datas forCacheModule:module withForumID:valueForumID];
    }
    if (![db open]) {
        [db open];
    }
    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:datas];
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO \"%@\" (\"CacheModule\", \"sourcedatas\", \"ForumID\") VALUES(?,?,?)",_tablename];
    BOOL result = [self.db executeUpdate:insertSql,[self moduleEnumToString:module],myData,valueForumID];
    DLog(@"添加缓存%@ : %@   %@", [self moduleEnumToString:module], insertSql, (result ? @"成功":@"失败"));
    [self.db close];
    return result;
}

- (BOOL)saveCache:(id)datas forCacheType:(NSString *)type withForumID:(NSString *)ForumID
{
    if (!datas) {
        return NO;
    }
    NSString *valueForumID = [self valueForForumID:ForumID];
    if ([self isCachedWithType:type withForumID:valueForumID]) {
        return [self updatCache:datas forCacheType:type withForumID:valueForumID];
    }
    if (![db open]) {
        [db open];
    }
    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:datas];
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO \"%@\" (\"CacheModule\", \"sourcedatas\", \"ForumID\") VALUES(?,?,?)",_tablename];
    BOOL result = [self.db executeUpdate:insertSql,type,myData,valueForumID];
    DLog(@"添加缓存%@ : %@   %@", type, insertSql, (result ? @"成功":@"失败"));
    [self.db close];
    return result;
}

/*
 ** 更新缓存
 */
- (BOOL)updatCache:(id)datas forCacheModule:(kCacheModule)module withForumID:(NSString *)ForumID
{
    NSString *updateSql = [NSString stringWithFormat:@"UPDATE \"%@\" SET sourcedatas = ? where CacheModule = ? and ForumID = ?",_tablename];
    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:datas];
    BOOL result = [self.db executeUpdate:updateSql,myData,[self moduleEnumToString:module],ForumID];
    DLog(@"更新缓存%@ : %@   %@", [self moduleEnumToString:module], updateSql, (result ? @"成功":@"失败"));
    [self.db close];
    return result;
}

- (BOOL)updatCache:(id)datas forCacheType:(NSString *)type withForumID:(NSString *)ForumID
{
    NSString *updateSql = [NSString stringWithFormat:@"UPDATE \"%@\" SET sourcedatas = ? where CacheModule = ? and ForumID = ?",_tablename];
    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:datas];
    BOOL result = [self.db executeUpdate:updateSql,myData,type,ForumID];
    DLog(@"更新缓存%@ : %@   %@", type, updateSql, (result ? @"成功":@"失败"));
    [self.db close];
    return result;
}

#pragma mark - 加载缓存

//获取cache
- (id)cacheForModule:(kCacheModule)module 
{
    return [self cacheForModule:module withForum:@""];
}

- (id)cacheForType:(NSString *)type{
    return [self cacheForType:type withForum:@""];
}

- (id)cacheForForum:(NSString *)ForumID
{
    return [self cacheForModule:kCacheModule_ForumPosts withForum:ForumID];
}

- (id)cacheForType:(NSString *)type withForum:(NSString *)ForumID{
    NSString *valueForumID = [self valueForForumID:ForumID];
    if (![self isCachedWithType:type withForumID:valueForumID]) {
        return nil;
    }
    if (![db open]) {
        [db open];
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM \"%@\" WHERE CacheModule = ? and ForumID = ?",_tablename];
    FMResultSet *rs = [self.db executeQuery:sql,type,valueForumID];
    //判断结果集中是否有数据，如果有则取出数据
    while ([rs next])
    {
        id mydata = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:[rs dataForColumn:@"sourcedatas"]];
        return mydata;
    }
    [self.db close];
    return nil;
}

- (id)cacheForModule:(kCacheModule)module withForum:(NSString *)ForumID
{
    NSString *valueForumID = [self valueForForumID:ForumID];
    if (![self isCached:module withForumID:valueForumID]) {
        return nil;
    }
    if (![db open]) {
        [db open];
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM \"%@\" WHERE CacheModule = ? and ForumID = ?",_tablename];
    FMResultSet *rs = [self.db executeQuery:sql,[self moduleEnumToString:module],valueForumID];
    //判断结果集中是否有数据，如果有则取出数据
    while ([rs next])
    {
        id mydata = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:[rs dataForColumn:@"sourcedatas"]];
        return mydata;
    }
    [self.db close];
    return nil;
}

#pragma mark - 判断缓存是否存在
//是否缓存了cache
- (BOOL)isCached:(kCacheModule)module withForumID:(NSString *)ForumID
{
    if (![db open]) {
        [db open];
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM \"%@\" WHERE CacheModule = ? and ForumID = ?",_tablename];
    FMResultSet *rs = [self.db executeQuery:sql,[self moduleEnumToString:module],ForumID];
    //判断结果集中是否有数据，如果有则取出数据
    while ([rs next])
    {
        return YES;
    }
    [self.db close];
    return NO;
}

- (BOOL)isCachedWithType:(NSString *)type withForumID:(NSString *)ForumID
{
    if (![db open]) {
        [db open];
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM \"%@\" WHERE CacheModule = ? and ForumID = ?",_tablename];
    FMResultSet *rs = [self.db executeQuery:sql,type,ForumID];
    //判断结果集中是否有数据，如果有则取出数据
    while ([rs next])
    {
        return YES;
    }
    [self.db close];
    return NO;
}

#pragma mark - 清除缓存
//清除缓存
- (BOOL)cleanUpCache:(kCacheModule)module
{
    if (![db open]) {
        [db open];
    }
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM \"%@\" where CacheModule = ?",_tablename];
    BOOL result = [self.db executeUpdate:sql,[self moduleEnumToString:module]];
    [self.db close];
    return result;
}

//清除缓存
- (BOOL)cleanUpCache
{
    if (![db open]) {
        [db open];
    }
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM \"%@\" ",_tablename];
    BOOL result = [self.db executeUpdate:sql];
    [self.db close];
    return result;
}


#pragma mark - enum & String exchange
- (NSString*) moduleEnumToString:(kCacheModule)module
{
    NSArray *TypeArray = [[NSArray alloc] initWithObjects:kCacheModuleArray];
    return [TypeArray objectAtIndex:module];
}

- (kCacheModule) moduleStringToEnum:(NSString*)strVal
{
    NSArray *TypeArray = [[NSArray alloc] initWithObjects:kCacheModuleArray];
    NSUInteger n = [TypeArray indexOfObject:strVal];
    if(n < 1) n = kCacheModule_Home_Functions;
    return (kCacheModule) n;
}

- (NSString *)valueForForumID:(NSString *)forumID
{
    return [NSString stringWithFormat:@"ForumID_%@",avoidNullStr(forumID)];
}
@end
