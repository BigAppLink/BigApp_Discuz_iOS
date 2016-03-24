//
//  LinkModel.m
//  Clan
//
//  Created by chivas on 15/6/30.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "LinkModel.h"

@implementation LinkModel
+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{@"link_id" : @"id",
             };
}

@end
