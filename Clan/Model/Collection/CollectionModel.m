//
//  CollectionModel.m
//  Clan
//
//  Created by chivas on 15/3/16.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "CollectionModel.h"
#import "CollectionListModel.h"
@implementation CollectionModel
+ (NSDictionary *)objectClassInArray
{
    return @{
             @"list" : [CollectionListModel class],
             };
}

@end
