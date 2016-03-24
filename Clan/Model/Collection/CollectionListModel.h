//
//  CollectionListModel.h
//  Clan
//
//  Created by chivas on 15/3/16.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CollectionListModel : NSObject
/**
 *  收藏id
 */
@property (copy, nonatomic) NSString *favid;
/**
 *  当前用户的id
 */
@property (copy, nonatomic) NSString *uid;
/**
 *  被收藏的ID，具体是指板块id还是帖子id，由idtype决定 
 */
@property (copy, nonatomic) NSString *fid;
/**
 *  id类型，tid--帖子id，fid--板块id
 */
@property (copy, nonatomic) NSString *idtype;
/**
 *  空间用户id，忽略
 */
@property (copy, nonatomic) NSString *spaceuid;
/**
 *  板块或帖子标题
 */
@property (copy, nonatomic) NSString *title;
/**
 *  收藏描述，忽略
 */
@property (copy, nonatomic) NSString *Cdescription;
/**
 *  收藏时间的时间戳
 */
@property (copy, nonatomic) NSString *dateline;
/**
 *  板块或帖子的图标
 */
@property (copy, nonatomic) NSString *icon;
/**
 *  作者
 */
@property (copy, nonatomic) NSString *author;
@end
