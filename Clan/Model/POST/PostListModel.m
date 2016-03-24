//
//  PostListModel.m
//  Clan
//
//  Created by chivas on 15/4/2.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "PostListModel.h"
#import "AttachmentModel.h"
#import <objc/runtime.h>

@implementation PostListModel
+ (NSDictionary *)objectClassInArray
{
    return @{
             @"attachments" : [AttachmentModel class],
             };
}

+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{@"postmessage" : @"message",
             
             };
}

+ (NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([obj class], &count);
    
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        if ([obj valueForKey:key] ) {
            [dict setObject:[obj valueForKey:key] forKey:key];
        }
    }
    
    free(properties);
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (void)setPostmessage:(NSString *)postmessage
{
    _postmessage = [postmessage stringByReplacingOccurrencesOfString:@"✌" withString:@"✌️"];
}
@end
