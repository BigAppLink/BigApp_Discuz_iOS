//
//  UserModel.m
//  Clan
//
//  Created by chivas on 15/3/13.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "UserModel.h"
#import <objc/runtime.h>
#import <ShareSDK/ShareSDK.h>

@implementation UserModel

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeObject:self.uid forKey:@"uid"];
    [aCoder encodeObject:self.realname forKey:@"realname"];
    [aCoder encodeObject:self.group_title forKey:@"group_title"];
    [aCoder encodeObject:self.avatar forKey:@"avatar"];
    [aCoder encodeObject:self.gender forKey:@"gender"];
    [aCoder encodeObject:self.regdate forKey:@"regdate"];
    [aCoder encodeObject:self.posts forKey:@"posts"];
    [aCoder encodeObject:self.threads forKey:@"threads"];
    [aCoder encodeObject:self.credits forKey:@"credits"];
    [aCoder encodeObject:self.extcredits1 forKey:@"extcredits1"];
    [aCoder encodeObject:self.extcredits2 forKey:@"extcredits2"];
    [aCoder encodeBool:self.logined forKey:@"logined"];
    [aCoder encodeObject:self.constellation forKey:@"constellation"];
    [aCoder encodeObject:self.extcredits forKey:@"extcredits"];
    [aCoder encodeObject:self.checked forKey:@"checked"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.username = [aDecoder decodeObjectForKey:@"username"];
        self.uid = [aDecoder decodeObjectForKey:@"uid"];
        self.realname = [aDecoder decodeObjectForKey:@"realname"];
        self.group_title = [aDecoder decodeObjectForKey:@"group_title"];
        self.avatar = [aDecoder decodeObjectForKey:@"avatar"];
        self.gender = [aDecoder decodeObjectForKey:@"gender"];
        self.regdate = [aDecoder decodeObjectForKey:@"regdate"];
        self.posts = [aDecoder decodeObjectForKey:@"posts"];
        self.threads = [aDecoder decodeObjectForKey:@"threads"];
        self.credits = [aDecoder decodeObjectForKey:@"credits"];
        self.extcredits1 = [aDecoder decodeObjectForKey:@"extcredits1"];
        self.extcredits2 = [aDecoder decodeObjectForKey:@"extcredits2"];
        self.constellation = [aDecoder decodeObjectForKey:@"constellation"];
        self.logined = [aDecoder decodeBoolForKey:@"logined"];
        self.extcredits = [aDecoder decodeObjectForKey:@"extcredits"];
        self.checked = [aDecoder decodeObjectForKey:@"checked"];
    }
    return self;
}

#pragma mark - current user 单例
+ (UserModel * )currentUserInfo
{
    static dispatch_once_t pred;
    static UserModel *_cUser;
    dispatch_once(&pred, ^{
        
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kKEY_CURRENT_USER];
        
        if (data) {
            
            _cUser = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            
        } else {
            
            _cUser = [[self alloc]init];
        }
    });
    return _cUser;
}

- (void)setUid:(NSString *)uid
{
    if (_uid && [_uid isEqualToString:uid]) {
        return;
    }
    _uid = uid;
}

//给没有值的赋值
- (void)setValueWithObject:(id)obj
{
    NSArray *properties = [UserModel propertiesForClass:[obj class]];
    for (NSString *property in properties) {
        id value = [obj valueForKey:property];
        SEL sel = NSSelectorFromString(property);
        
        if ([property isEqualToString:@"uid"]) {
            NSString *valueStr = value;
            if (valueStr && valueStr.length > 0) {
                [self setValue:value forKey:property];
            }
        }
        if (![property isEqualToString:@"logined"] && ![property isEqualToString:@"uid"] && value && [self respondsToSelector:sel] && ![property isEqualToString:@"checked"]) {
            [self setValue:value forKey:property];
        }
    }
}


+ (NSArray *)propertiesForClass:(Class) aClass
{
    NSMutableArray *propertyNamesArr = [NSMutableArray array];
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(aClass, &propertyCount);
    for (unsigned int i = 0; i<propertyCount; i++) {
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
        [propertyNamesArr addObject:[NSString stringWithUTF8String:name]];
    }
    free(properties);
    return propertyNamesArr;
}

+ (void)saveToLocal
{
    NSData *date = [NSKeyedArchiver archivedDataWithRootObject:[UserModel currentUserInfo]];
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:kKEY_CURRENT_USER];
}

//退出登录
- (void)logout
{
    [ShareSDK cancelAuthorize:SSDKPlatformTypeSinaWeibo];
    [ShareSDK cancelAuthorize:SSDKPlatformTypeWechat];
    [ClanNetAPI removeCookieData];
    UserModel *user = [UserModel new];
    NSArray *properties = [UserModel propertiesForClass:[user class]];
    for (NSString *property in properties) {
        id value = [user valueForKey:property];
        SEL sel = NSSelectorFromString(property);
        if ([self respondsToSelector:sel]) {
            [self setValue:value forKey:property];
        }
    }
    [UserModel saveToLocal];
    [UserModel currentUserInfo].logined = NO;
    [UserModel saveToLocal];
    //清除信息
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"KNEWS_MESSAGE"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KNEWS_MESSAGE_COME" object:nil];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"KNEWS_FRIEND_MESSAGE"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KNEWS_FRIEND_MESSAGE" object:nil];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:ClanFormhash];
}
@end
