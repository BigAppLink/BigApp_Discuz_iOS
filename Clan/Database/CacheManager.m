//
//  CacheManager.m
//  Clan
//
//  Created by 昔米 on 15/7/7.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "CacheManager.h"

@implementation CacheManager
+ (id)sharedCacheManager
{
    static dispatch_once_t pred;
    static CacheDBDao *_cacheM;
    dispatch_once(&pred, ^{
        _cacheM = [[CacheDBDao alloc]init];
    });
    return _cacheM;
}
@end
