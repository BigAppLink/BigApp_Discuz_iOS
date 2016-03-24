//
//  ShareItem.h
//  Clan
//
//  Created by 昔米 on 15/7/14.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShareSDK/SSDKTypeDefine.h>

@interface ShareItem : NSObject
@property (copy, nonatomic) NSString *title;
@property (assign) SSDKPlatformType shareType;
@property (strong, nonatomic) UIImage *image;
@end
