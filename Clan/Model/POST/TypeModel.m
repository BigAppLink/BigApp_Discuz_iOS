//
//  TypeModel.m
//  Clan
//
//  Created by chivas on 15/5/29.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "TypeModel.h"

@implementation TypeModel
+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{@"typeId" : @"typeid",
             @"typeName":@"typename",
             };
}

@end
