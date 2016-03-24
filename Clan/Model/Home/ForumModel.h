//
//  ForumModel.h
//  Clan
//
//  Created by chivas on 15/6/30.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ForumModel : NSObject
/**
 *  轮播图id
 */
@property (copy, nonatomic) NSString *forum_id;
/**
 *  标题
 */
@property (copy, nonatomic) NSString *title;
/**
 *  图片
 */
@property (copy, nonatomic) NSString *pic;
/**
 *  图片Url
 */
@property (copy, nonatomic) NSString *url;
/**
 *  类型 type=1 站外链接 ， type=2 帖子链接（站内）， type=3 板块链接（站内）
 */
@property (copy, nonatomic) NSString *type;
/**
 *  帖子id或者板块id（对应type=2、3时有效)
 */
@property (copy, nonatomic) NSString *pid;
/**
 *  描述
 */
@property (copy, nonatomic) NSString *desc;
@end
