//
//  CheckPostModel.m
//  Clan
//
//  Created by chivas on 15/3/27.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "CheckPostModel.h"
#import "AllowpermModel.h"
@implementation CheckPostModel
+ (NSDictionary *)objectClassInArray
{
    return @{
             @"allowperm" : [AllowpermModel class],
             };
}
@end
