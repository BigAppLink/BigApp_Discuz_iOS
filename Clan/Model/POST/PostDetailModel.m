//
//  PostListModel.m
//  Clan
//
//  Created by chivas on 15/4/1.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "PostDetailModel.h"
#import "PostListModel.h"
@implementation PostDetailModel

+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{
             @"tid" : @"thread.tid",
             @"author":@"thread.author",
             @"subject":@"thread.subject",
             @"authorid": @"thread.authorid",
             @"share_url":@"thread.share_url",
            };
}

+ (NSDictionary *)objectClassInArray
{
    return @{
             @"postlist" : [PostListModel class],
             };
}

@end

@implementation Report
@end
