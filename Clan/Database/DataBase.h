//
//  DataBase.h
//  WSNewsReader
//
//  Created by wallstreetcn on 13-12-18.
//  Copyright (c) 2013年 wallstreetcn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataBase : NSObject
+ (FMDatabase *) sharedDatabase;

//清除数据库
+ (void) deleteDatabase;
@end
