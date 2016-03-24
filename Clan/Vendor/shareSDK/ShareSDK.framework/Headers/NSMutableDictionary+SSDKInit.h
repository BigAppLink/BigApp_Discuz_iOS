//
//  NSMutableDictionary+ShareSDK.h
//  ShareSDK
//
//  Created by 冯 鸿杰 on 15/2/6.
//  Copyright (c) 2015年 掌淘科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSDKTypeDefine.h"

/**
 *  初始化分享平台相关
 */
@interface NSMutableDictionary (SSDKInit)

/**
 *  设置新浪微博应用信息
 *
 *  @param appKey       应用标识
 *  @param appSecret    应用密钥
 *  @param redirectUri  回调地址
 *  @param authType     授权方式
 */
- (void)SSDKSetupSinaWeiboByAppKey:(NSString *)appKey
                         appSecret:(NSString *)appSecret
                       redirectUri:(NSString *)redirectUri
                          authType:(NSString *)authType;

/**
 *  设置微信(微信好友，微信朋友圈、微信收藏)应用信息
 *
 *  @param appId      应用标识
 *  @param appSecret  应用密钥
 */
- (void)SSDKSetupWeChatByAppId:(NSString *)appId
                     appSecret:(NSString *)appSecret;

/**
 *  设置Twitter应用信息
 *
 *  @param consumerKey    应用标识
 *  @param consumerSecret 应用密钥
 *  @param redirectUri    回调地址
 */
- (void)SSDKSetupTwitterByConsumerKey:(NSString *)consumerKey
                       consumerSecret:(NSString *)consumerSecret
                          redirectUri:(NSString *)redirectUri;

/**
 *  设置QQ分享平台（QQ空间，QQ好友分享）应用信息
 *
 *  @param appId                应用标识
 *  @param appKey               应用Key
 *  @param authType             授权方式
 */
- (void)SSDKSetupQQByAppId:(NSString *)appId
                    appKey:(NSString *)appKey
                  authType:(NSString *)authType;

/**
 *  设置Facebook应用信息
 *
 *  @param appKey       应用标识
 *  @param appSecret    应用密钥
 *  @param authType     授权方式
 */
- (void)SSDKSetupFacebookByAppKey:(NSString *)appKey
                        appSecret:(NSString *)appSecret
                         authType:(NSString *)authType;


/**
 *  设置腾讯微博应用信息
 *
 *  @param appKey        应用标识
 *  @param appSecret     应用密钥
 *  @param redirectUri   回调地址
 *  @param authType      授权方式
 */
- (void)SSDKSetupTencentWeiboByAppKey:(NSString *)appKey
                            appSecret:(NSString *)appSecret
                          redirectUri:(NSString *)redirectUri;

/**
 *  设置豆瓣应用信息
 *
 *  @param apiKey      应用标识
 *  @param secret      应用密钥
 *  @param redirectUri 回调地址
 */
- (void)SSDKSetupDouBanByApiKey:(NSString *)apiKey
                         secret:(NSString *)secret
                    redirectUri:(NSString *)redirectUri;

/**
 *  设置人人网应用信息
 *
 *  @param appId     应用标识
 *  @param appKey    应用Key
 *  @param secretKey 应用密钥
 *  @param authType  授权方式
 */
- (void)SSDKSetupRenRenByAppId:(NSString *)appId
                        appKey:(NSString *)appKey
                     secretKey:(NSString *)secretKey
                      authType:(NSString *)authType;

/**
 *  设置开心网应用信息
 *
 *  @param apiKey      应用标识
 *  @param secretKey   应用密钥
 *  @param redirectUri 回调地址
 */
- (void)SSDKSetupKaiXinByApiKey:(NSString *)apiKey
                      secretKey:(NSString *)secretKey
                    redirectUri:(NSString *)redirectUri;

/**
 *  设置Pocket应用信息
 *
 *  @param consumerKey 应用标识
 *  @param redirectUri 回调地址
 *  @param authType    授权方式
 */
- (void)SSDKSetupPocketByConsumerKey:(NSString *)consumerKey
                         redirectUri:(NSString *)redirectUri
                            authType:(NSString *)authType;

/**
 *  设置Google＋应用信息
 *
 *  @param clientId     应用标识
 *  @param clientSecret 应用密钥
 *  @param redirectUri  回调地址
 *  @param authType     授权方式
 */
- (void)SSDKSetupGooglePlusByClientID:(NSString *)clientId
                         clientSecret:(NSString *)clientSecret
                          redirectUri:(NSString *)redirectUri
                             authType:(NSString *)authType;

/**
 *  设置Instagram应用信息
 *
 *  @param clientId     应用标识
 *  @param clientSecret 应用密钥
 *  @param redirectUri  回调地址
 */
- (void)SSDKSetupInstagramByClientID:(NSString *)clientId
                        clientSecret:(NSString *)clientSecret
                         redirectUri:(NSString *)redirectUri;

/**
 *  设置LinkedIn应用信息
 *
 *  @param apiKey      应用标识
 *  @param secretKey   应用密钥
 *  @param redirectUrl 回调地址
 */
- (void)SSDKSetupLinkedInByApiKey:(NSString *)apiKey
                        secretKey:(NSString *)secretKey
                      redirectUrl:(NSString *)redirectUrl;

/**
 *  设置Tumblr应用信息
 *
 *  @param consumerKey    应用标识
 *  @param consumerSecret 应用密钥
 *  @param callbackUrl    回调地址
 */
- (void)SSDKSetupTumblrByConsumerKey:(NSString *)consumerKey
                      consumerSecret:(NSString *)consumerSecret
                         callbackUrl:(NSString *)callbackUrl;

/**
 *  设置Flickr应用信息
 *
 *  @param apiKey    应用标识
 *  @param apiSecret 应用密钥
 */
- (void)SSDKSetupFlickrByApiKey:(NSString *)apiKey
                      apiSecret:(NSString *)apiSecret;

/**
 *  设置有道云笔记应用信息
 *
 *  @param consumerKey    应用标识
 *  @param consumerSecret 应用密钥
 *  @param redirectUri    回调地址
 */
- (void)SSDKSetupYouDaoNoteByConsumerKey:(NSString *)consumerKey
                          consumerSecret:(NSString *)consumerSecret
                             redirectUri:(NSString *)redirectUri;


@end
