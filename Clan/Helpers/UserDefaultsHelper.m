//
//  UserDefaultsHelper.m
//  Clan
//
//  Created by 昔米 on 15/9/15.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "UserDefaultsHelper.h"

@implementation UserDefaultsHelper

//保存defaults key
+ (void)saveDefaultsValue:(id)obj forKey:(NSString *)key
{
    NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:obj];
    [[NSUserDefaults standardUserDefaults] setObject:dataSave forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
//取defaults key
+ (id)valueForDefaultsKey:(NSString *)key
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}
//存储bool值
+ (void)saveBoolValue:(BOOL)boolValue forKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setBool:boolValue forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
//取出bool值
+ (BOOL)boolValueForDefaultsKey:(NSString *)key
{
   return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

+ (void)cleanDefaultsForKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
