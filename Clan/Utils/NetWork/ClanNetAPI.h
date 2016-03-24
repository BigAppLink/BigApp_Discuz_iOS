//
//  ClanNetAPI.h
//  Clan
//
//  Created by chivas on 15/3/5.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
//#import ""

typedef enum {
    Get = 0,
    Post,
    Put,
    Delete
} NetworkMethod;

@interface ClanNetAPI : AFHTTPRequestOperationManager

+ (id)sharedJsonClient;
- (void)requestDownloadWithPath:(NSString *)apath
                       andBlock:(void (^)(NSURL *filePath,NSString *fileName, NSError *error))block;

- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary*)params
                 withMethodType:(int)NetworkMethod
                       andBlock:(void (^)(id data, NSError *error))block;

//异步
- (void)requestJsonDataWithFullURL:(NSString *)urlStr
                        withParams:(NSDictionary *)params
                          andBlock:(void (^)(id data, NSError *error))block;

//同步
- (void)requestJsonDataWithFullURL1:(NSString *)urlStr
                         withParams:(NSDictionary *)params
                           andBlock:(void (^)(id data, NSError *error))block;

- (void)uploadImage:(UIImage *)image path:(NSString *)path
               name:(NSString *)name
         withParams:(NSDictionary*)params
       successBlock:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
       failureBlock:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
      progerssBlock:(void (^)(CGFloat progressValue))progress;
//取自定义首页配置
- (void)requestCustomStyleWithPath:(NSString *)path
                        withParams:(NSDictionary*)params
                    withMethodType:(int)NetworkMethod
                          andBlock:(void (^)(id data, NSError *error))block;

+ (void)saveCookieData;
+ (void)removeCookieData;
- (void)isLogin:(BOOL)loginType;
@property (nonatomic,assign)BOOL isLogin;

@end
