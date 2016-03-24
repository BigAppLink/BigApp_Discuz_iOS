//
//  AFURLConnectionOperation+AuthenticationChallengeUploadFix.h
//  Clan
//
//  Created by chivas on 15/12/8.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "AFURLConnectionOperation.h"

@interface AFURLConnectionOperation (AuthenticationChallengeUploadFix)
- (NSInputStream *)connection:(NSURLConnection __unused *)connection needNewBodyStream:(NSURLRequest *)request;
@end
