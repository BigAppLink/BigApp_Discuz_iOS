//
//  DataBase.m
//  WSNewsReader
//
//  Created by wallstreetcn on 13-12-18.
//  Copyright (c) 2013年 wallstreetcn. All rights reserved.
//

#import "DataBase.h"

@implementation DataBase
static FMDatabase *db;

static NSString *const DBName = @"db";

+ (FMDatabase *) sharedDatabase
{
	if (db) {
		return db;
	}
    //存放再沙盒中的document目录下
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    //dbPath： 数据库路径，在Document中。
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:DBName];
    db = [FMDatabase databaseWithPath:dbPath];
	return db;
}

// 删除数据库
+ (void) deleteDatabase
{
    //存放再沙盒中的document目录下
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    //dbPath： 数据库路径，在Document中。
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:DBName];
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:dbPath];
    if (blHave) {
        BOOL successDelete = [[NSFileManager defaultManager] removeItemAtPath:dbPath error:NULL];
        DLog(@"删除数据库 %@ %@",dbPath, successDelete ? @"成功" : @"失败");
        return ;
    }
}



@end
