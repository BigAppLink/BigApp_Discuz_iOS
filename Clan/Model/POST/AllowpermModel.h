//
//  AllowpermModel.h
//  Clan
//
//  Created by chivas on 15/3/27.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Allowupload;
@interface AllowpermModel : NSObject
/**
 *  是否允许发表帖子
 */
@property (copy, nonatomic) NSString *allowpost;
/**
 *  允许发的图片数
 */
@property (copy, nonatomic) NSString *imagecount;
/**
 *  是否允许回复帖子
 */
@property (copy, nonatomic) NSString *allowreply;
/**
 *  发帖时会用到
 */
@property (copy, nonatomic) NSString *uploadhash;
/**
 *  可以上传的图片总大小 kb
 */
@property (copy, nonatomic) NSString *imageSize;
/**
 *  图片上传限制
 */
@property (strong, nonatomic) NSDictionary *allowupload;
@end
