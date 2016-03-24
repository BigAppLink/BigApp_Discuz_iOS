//
//  CustomHomeMode.m
//  Clan
//
//  Created by chivas on 15/6/30.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "CustomHomeMode.h"
#import "BannerModel.h"
#import "LinkModel.h"
#import "ForumModel.h"
@implementation CustomHomeMode
+ (NSDictionary *)objectClassInArray
{
    return @{
             @"banner" : [BannerModel class],
             @"link" : [LinkModel class],
             @"forum" : [ForumModel class],
             };
}
+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{
             @"link" : @"func.link",
             @"forum" : @"func.forum"
             };
}

@end

@implementation CustomNavModel
+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{
             @"wap_page" : @"navi_setting.wap_page",
             @"tab_type": @"navi_setting.tab_type"
             };
}

@end

@implementation CustomRightItemModel



@end

