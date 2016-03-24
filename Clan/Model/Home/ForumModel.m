//
//  ForumModel.m
//  Clan
//
//  Created by chivas on 15/6/30.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ForumModel.h"

@implementation ForumModel
+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{@"forum_id" : @"id",
             };
}

@end
