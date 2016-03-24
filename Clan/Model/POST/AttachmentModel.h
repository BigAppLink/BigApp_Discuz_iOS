//
//  AttachmentModel.h
//  Clan
//
//  Created by chivas on 15/4/2.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AttachmentModel : NSObject
/**
 *  附件id
 */
@property (copy, nonatomic)NSString *aid;
/**
 *  帖子id
 */
@property (copy, nonatomic)NSString *pid;
/**
 *  图片路径
 */
@property (copy, nonatomic)NSString *absurl;
@end
