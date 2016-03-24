//
//  threadtypesModel.m
//  Clan
//
//  Created by chivas on 15/5/29.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "threadtypesModel.h"
#import "TypeModel.h"
#import "IconModel.h"
@implementation threadtypesModel
+ (NSDictionary *)objectClassInArray
{
    return @{
             @"types" : [TypeModel class],
            @"icons" : [IconModel class],
             };
}

@end
