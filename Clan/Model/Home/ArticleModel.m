//
//  ArticleModel.m
//  Clan
//
//  Created by chivas on 15/9/6.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ArticleModel.h"

@implementation ArticleModel
- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.module = [coder decodeObjectForKey:@"module"];
        self.title = [coder decodeObjectForKey:@"title"];
        self.type = [coder decodeObjectForKey:@"type"];
        self.articleId = [coder decodeObjectForKey:@"articleId"];
    }
    return self;
}
- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject:self.module forKey:@"module"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.type forKey:@"type"];
    [coder encodeObject:self.articleId forKey:@"articleId"];

}

+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{
             @"articleId" : @"id",
             };
}

@end
