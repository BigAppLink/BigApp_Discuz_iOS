//
//  BoardModel.m
//  Clan
//
//  Created by chivas on 15/3/18.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "BoardModel.h"
#import "ForumsModel.h"

@implementation BoardModel
+ (NSDictionary *)objectClassInArray
{
    return @{
             @"forums" : [ForumsModel class],
             };
}

@end
