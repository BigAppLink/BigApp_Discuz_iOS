//
//  AllowpermModel.m
//  Clan
//
//  Created by chivas on 15/3/27.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "AllowpermModel.h"

@implementation AllowpermModel
+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{
             @"imagecount" : @"attachremain.count",
             @"imageSize" : @"attachremain.size"
    };
}

@end
