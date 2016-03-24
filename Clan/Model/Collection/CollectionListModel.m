//
//  CollectionListModel.m
//  Clan
//
//  Created by chivas on 15/3/16.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "CollectionListModel.h"

@implementation CollectionListModel
+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{@"fid" : @"id",
             @"Cdescription" : @"description"
             };
}

@end
