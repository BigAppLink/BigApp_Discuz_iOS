//
//  ClanNetAPI.m
//  Clan
//
//  Created by chivas on 15/3/5.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ClanNetAPI.h"
#import "AFHTTPRequestOperationManager+Synchronous.h"
//Remove:
//#define kNetPath_Code_Base        @"http://192.168.180.23:8080/"
//#define kNetPath_Code_Base @"http://qawww.3body.com/"

//#define kNetPath_Code_Base        @"http://120.24.233.197:8080"
//#define  kNetPath_Code_Base [NSString returnPlistWithKeyValue:YZBaseURL]
#define  kNetPath_Code_Base [NSString returnPlistWithKeyValue:YZBaseURL]

//#define  kNetPath_Code_Base [NSString returnStringWithPlist:YZBaseURL]

@interface ClanNetAPI()

@end

@implementation ClanNetAPI
+ (ClanNetAPI *)sharedJsonClient
{
    static ClanNetAPI *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[ClanNetAPI alloc] initWithBaseURL:[NSURL URLWithString:kNetPath_Code_Base]];
    });
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    self.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    self.requestSerializer.timeoutInterval = 30;
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json",@"text/html", nil];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    self.securityPolicy.allowInvalidCertificates = YES;
    self.isLogin = NO;
    return self;
}

- (void)isLogin:(BOOL)loginType
{
    _isLogin = loginType;
}

+ (void)saveCookieData
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in cookies) {
        // Here I see the correct rails session cookie
//        DebugLog(@"\nSave cookie: \n====================\n%@", cookie);
    }
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: cookiesData forKey: Code_CookieData];
    [defaults synchronize];
}

+ (void)removeCookieData
{
    NSURL *url = [NSURL URLWithString:[NSString returnPlistWithKeyValue:YZBaseURL]];
    if (url) {
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
        for (int i = 0; i < [cookies count]; i++) {
            NSHTTPCookie *cookie = (NSHTTPCookie *)[cookies objectAtIndex:i];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
//            DebugLog(@"\nDelete cookie: \n====================\n%@", cookie);
        }
    }
    NSURL *url1 = [NSURL URLWithString:kNetPath_Code_Base];
    if (url1) {
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url1];
        for (int i = 0; i < [cookies count]; i++) {
            NSHTTPCookie *cookie = (NSHTTPCookie *)[cookies objectAtIndex:i];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
//            DebugLog(@"\nDelete cookie: \n====================\n%@", cookie);
        }
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:Code_CookieData];
    [defaults synchronize];
}

+ (void)loadCookies
{
    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey: Code_CookieData]];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookies)
    {
        [cookieStorage setCookie: cookie];
    }
}
- (void)requestCustomStyleWithPath:(NSString *)path
                        withParams:(NSDictionary*)params
                        withMethodType:(int)NetworkMethod
                        andBlock:(void (^)(id data, NSError *error))block{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 10;
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    //log请求数据
//    DebugLog(@"\n===========request===========\n%@:\n%@", path, params);
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //发起请求
    switch (NetworkMethod) {
        case Get:{
            [self GET:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
//                DebugLog(@"\n===========response===========\n%@:\n%@", operation, responseObject);
                if (responseObject) {
                    id resultData = [responseObject valueForKeyPath:@"Variables"];
                    if (resultData && ![resultData isKindOfClass:[NSNull class]] && [resultData objectForKey:@"formhash"]) {
                        [[NSUserDefaults standardUserDefaults]setObject:[resultData objectForKey:@"formhash"] forKey:ClanFormhash];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    block(responseObject,nil);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                DebugLog(@"\n===========response   %@===========\n%@:\n%@", operation,path, error);
                //                [self showError:error];
                block(nil, error);
            }];
            break;
        }
        default:
            break;
    }
}

- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary*)params
                 withMethodType:(int)NetworkMethod
                       andBlock:(void (^)(id data, NSError *error))block
{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 60;
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    
    [ClanNetAPI loadCookies];
    //log请求数据
    DebugLog(@"\n===========request===========\n%@:\n%@", aPath, params);
    aPath = [aPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //发起请求
    switch (NetworkMethod) {
        case Get:{
            WEAKSELF
            [self GET:aPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                DebugLog(@"\n===========response===========\n%@:\n%@", operation, responseObject);
                if (responseObject) {
                    STRONGSELF
                    [strongSelf checkLoginStatus:responseObject];
                    id resultData = [responseObject valueForKeyPath:@"Variables"];
                    if (resultData && ![resultData isKindOfClass:[NSNull class]] && [resultData objectForKey:@"formhash"]) {
                        [[NSUserDefaults standardUserDefaults]setObject:[resultData objectForKey:@"formhash"] forKey:ClanFormhash];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    block(responseObject,nil);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                DebugLog(@"\n===========response   %@===========\n%@:\n%@", operation,aPath, error);
                //                [self showError:error];
                block(nil, error);
            }];
            break;}
        case Post:{
            WEAKSELF
            [self POST:aPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                DebugLog(@"\n===========response===========\n%@:\n%@", operation, responseObject);
                if (responseObject) {
                    STRONGSELF
                    [strongSelf checkLoginStatus:responseObject];
                    id resultData = [responseObject valueForKeyPath:@"Variables"];
                    if ([resultData objectForKey:@"formhash"]) {
                        [[NSUserDefaults standardUserDefaults]setObject:[resultData objectForKey:@"formhash"] forKey:ClanFormhash];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    block(responseObject,nil);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                DebugLog(@"\n===========response===========\n%@:\n%@", operation, error);
                block(nil, error);
            }];
            break;
        }
        case Put:{
            [self PUT:aPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                DebugLog(@"\n===========response===========\n%@:\n%@", aPath, responseObject);
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                DebugLog(@"\n===========response===========\n%@:\n%@", aPath, error);
                block(nil, error);
            }];
            break;}
        case Delete:{
            [self DELETE:aPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                DebugLog(@"\n===========response===========\n%@:\n%@", aPath, responseObject);
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                DebugLog(@"\n===========response===========\n%@:\n%@", aPath, error);
                block(nil, error);
            }];}
        default:
            break;
    }
}

- (void)checkLoginStatus:(id)responseData
{
    if (![UserModel currentUserInfo].logined) {
        return;
    }
    id resultData = [responseData valueForKeyPath:@"Variables"];
    if ((!resultData || [resultData isKindOfClass:[NSNull class]])) {
        return;
    }
    if ((resultData[@"auth"] == [NSNull null]) || [resultData[@"auth"] isEqualToString:@""]) {
        //session 过期 LOGOUT
        [self doLogout];
        return;
    }

    NSDictionary *messDic = [responseData valueForKey:@"Message"];
    if (messDic && messDic.count > 0) {
        NSString *messageval = messDic[@"messageval"];
        if (messageval && messageval.length > 0 && ([messageval isEqualToString:@"login_before_enter_home//1"] || [messageval isEqualToString:@"to_login//1"])) {
            //DO LOGOUT
            [self doLogout];
        }
    }
}

- (void)doLogout
{
//    [self showHudTipStr:@"您的登录已过期，请重新登录"];
    DLog(@"----- token过期了");
    UserModel *_cuser = [UserModel currentUserInfo];
    [_cuser logout];
    [ClanNetAPI removeCookieData];
    //清除收藏的数组
    [Util cleanUpLocalFavoArray];
}

- (void)requestJsonDataWithFullURL:(NSString *)urlStr
                        withParams:(NSDictionary *)params
                          andBlock:(void (^)(id data, NSError *error))block
{
    [ClanNetAPI loadCookies];
    if (!urlStr || [@"" isEqualToString:urlStr]) {
        DLog(@"url地址是空的啊....大哥哥");
        return;
    }
    //log请求数据
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    NSMutableURLRequest *request = (NSMutableURLRequest *) [[AFJSONRequestSerializer serializer] requestBySerializingRequest:urlRequest withParameters:params error:nil];
    [request setTimeoutInterval:3];
    
    AFHTTPRequestOperation *oper = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                DebugLog(@"\n===========response===========\n%@:\n%@", operation, responseObject);
        //返回数据
        block(responseObject,nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(nil, error);
    }];
    //异步
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperation:oper];
    
}

//同步
- (void)requestJsonDataWithFullURL1:(NSString *)urlStr
                         withParams:(NSDictionary *)params
                           andBlock:(void (^)(id data, NSError *error))block
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSError *error = nil;
    AFHTTPRequestOperation *operation = nil;
    NSData *result = [manager syncGET:urlStr
                           parameters:params
                            operation:&operation
                                error:&error];
    DLog(@"【同步拉取配置信息**************\n%@-----%@-----%@\n****************】",operation,error,result);
    if (!error && result) {
        block(result,nil);
    } else {
        block(nil, error);
    }
}


- (void)uploadImage:(UIImage *)image path:(NSString *)path
               name:(NSString *)name
         withParams:(NSDictionary*)params
       successBlock:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
       failureBlock:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
      progerssBlock:(void (^)(CGFloat progressValue))progress
{
    [ClanNetAPI loadCookies];
    NSString *fileType = @"jpg";
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    float size = 1024*200/(float)data.length;
    if ((float)data.length/1024 > 150) {
        data = UIImageJPEGRepresentation(image, 1024*200/(float)data.length);
    }
    if (params) {
        NSString *jpgSize = [[NSUserDefaults standardUserDefaults]objectForKey:KimageJpg];
        NSString *jpegSize = [[NSUserDefaults standardUserDefaults]objectForKey:Kimagejpeg];
        //如果有params 说明是发帖子上传图片
        if (jpgSize && ![jpgSize isEqualToString:@"0"]) {
            //如果可以上传jpg图片 则判断文件大小
            if (![jpgSize isEqualToString:@"-1"]) {
                //有尺寸大小限制
                for (float x = size - 0.2 ; x > 0; x-=0.2) {
                    if ((float)data.length/1024 > jpgSize.floatValue/1024) {
                        data = UIImageJPEGRepresentation(image, x);
                    }else{
                        break;
                    }
                }
            }
        }else{
            //不能上传jepg格式图片
            if (jpegSize && ![jpegSize isEqualToString:@"0"]) {
                //如果可以上传jepg图片 则判断文件大小
                fileType = @"jepg";
                if (![jpgSize isEqualToString:@"-1"]) {
                    //有尺寸大小限制
                    for (float x = size - 0.2 ; x > 0; x-=0.2) {
                        if ((float)data.length/1024 > jpgSize.floatValue/1024) {
                            data = UIImageJPEGRepresentation(image, x);
                        }else{
                            break;
                        }
                    }
                }
            }
        }
        
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmssSSS";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.%@", [[NSUserDefaults standardUserDefaults] stringForKey:ClanUserId], str,fileType];
    AFHTTPRequestOperation *operation = [self POST:path parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:name fileName:fileName mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        if (failure) {
            failure(operation, error);
        }
    }];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        CGFloat progressValue = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
        if (progress) {
            progress(progressValue);
        }
    }];
    [operation start];
}

- (void)requestDownloadWithPath:(NSString *)apath
                       andBlock:(void (^)(NSURL *filePath,NSString *fileName, NSError *error))block{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:apath];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error) {
            block(nil,nil,error);
        }else{
            block(filePath,[response suggestedFilename],nil);
        }
    }];
    [downloadTask resume];
}
@end
