//
//  CustomHomeListModel.m
//  Clan
//
//  Created by chivas on 15/9/6.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "CustomHomeListModel.h"

@implementation CustomHomeListModel
+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{
             @"articleId" : @"id",
             };
}

@end
