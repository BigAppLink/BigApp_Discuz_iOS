//
//  AFURLConnectionOperation+AuthenticationChallengeUploadFix.m
//  Clan
//
//  Created by chivas on 15/12/8.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "AFURLConnectionOperation+AuthenticationChallengeUploadFix.h"

@implementation AFURLConnectionOperation (AuthenticationChallengeUploadFix)
- (NSInputStream *)connection:(NSURLConnection __unused *)connection needNewBodyStream:(NSURLRequest *)request {
    //苹果默认网络请求缓冲区复用，当缓冲区溢出后需要重新开辟缓冲区。否则溢出的数据无法上传服务器。
    if ([request.HTTPBodyStream conformsToProtocol:@protocol(NSCopying)]) {
        return  [request.HTTPBodyStream copy];
    }
    return nil;
}
@end
