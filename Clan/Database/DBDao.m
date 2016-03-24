//
//  DBDao.m
//  WSNewsReader
//
//  Created by wallstreetcn on 13-12-18.
//  Copyright (c) 2013年 wallstreetcn. All rights reserved.
//

#import "DBDao.h"

@implementation DBDao
@synthesize db;
#pragma mark - init methods
- (id)init
{
    if(self = [super init]) {
        self.db = [DataBase sharedDatabase];
    }
    return self;
}
@end
