//
//  CheckPostModel.h
//  Clan
//
//  Created by chivas on 15/3/27.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//
#define KCheckPost @"checkPost"
#import "AllowpermModel.h"
#import <Foundation/Foundation.h>
@interface CheckPostModel : NSObject
@property (strong, nonatomic)AllowpermModel *allowperm;
/**
 *  判断是否登录 为空时未登录
 */
@property (copy, nonatomic) NSString *auth;


@end
