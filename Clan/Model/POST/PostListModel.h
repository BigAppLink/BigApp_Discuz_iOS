//
//  PostListModel.h
//  Clan
//
//  Created by chivas on 15/4/2.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostListModel : NSObject
/**
 *  帖子id
 */
@property (copy, nonatomic)NSString *pid;
/**
 *  主题id
 */
@property (copy, nonatomic)NSString *tid;
/**
 *  是否是顶楼
 */
@property (copy, nonatomic)NSString *first;
/**
 *  作者
 */
@property (copy, nonatomic)NSString *author;
/**
 *  作者id
 */
@property (copy, nonatomic)NSString *authorid;
/**
 *  发布时间
 */
@property (copy, nonatomic)NSString *dateline;
/**
 *  发布时间
 */
@property (copy, nonatomic)NSString *dbdateline;
/**
 *  正文
 */
@property (copy, nonatomic)NSString *postmessage;
/**
 *  头像
 */
@property (copy, nonatomic)NSString *avatar;
/**
 *  用户组
 */
@property (copy, nonatomic)NSString *groupid;
/**
 *  头衔
 */
@property (copy, nonatomic)NSString *authortitle;
/**
 *  附件数组
 */
@property (strong, nonatomic)NSArray *attachments;
/**
 *楼号
 */
@property (copy, nonatomic) NSString *position;

/**
 * 点赞数
 */
@property (copy, nonatomic) NSString *support;

/**
 * 反对数
 */
@property (copy, nonatomic) NSString *oppose;

/**
 * 是否允许点击
 */
@property (copy, nonatomic) NSString *enable_support;

/**
 * 针对楼主 顶的人数
 */
@property (copy, nonatomic) NSString *recommend_add;

/**
 * 针对楼主 是否允许顶一个主题
 */
@property (copy, nonatomic) NSString *enable_recommend;

/**
 * 针对楼主 顶的时候 是否登录
 */
@property (copy, nonatomic) NSString *click2login;

/**
 *  是否已经点过主题
 */
@property (copy, nonatomic) NSString *recommended;

/**
 *  当前用户是否已经赞过回帖
 */
@property (copy, nonatomic) NSString *voteUped;




+ (NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj;

@end
