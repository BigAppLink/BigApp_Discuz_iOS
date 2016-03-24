//
//  DBDao.h
//  WSNewsReader
//
//  Created by wallstreetcn on 13-12-18.
//  Copyright (c) 2013年 wallstreetcn. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "DataBase.h"

static NSString *DB_NAME_CACHE = @"DB_NAME_CACHE"; //缓存数据表

@interface DBDao : NSObject
{
    FMDatabase *db;
}
@property (strong, nonatomic) FMDatabase *db;
@end
