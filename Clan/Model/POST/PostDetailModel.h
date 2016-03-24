//
//  PostListModel.h
//  Clan
//
//  Created by chivas on 15/4/1.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Report;
@interface PostDetailModel : NSObject
/**
  * 回主题是NO 回帖是YES
  */
@property (assign, nonatomic)BOOL isRelayPost;
/**
 *  版块id
 */
@property (copy, nonatomic)NSString *fid;
/**
 *  主题id
 */
@property (copy, nonatomic)NSString *tid;
/**
 *  回复列表
 */
@property (strong, nonatomic)NSArray *postlist;

/**
 *  作者
 */
@property (copy, nonatomic)NSString *author;

/**
 *  作者ID
 */
@property (copy, nonatomic)NSString *authorid;

/**
 *  总页数
 */
@property (copy, nonatomic)NSString *totalpage;

/**
 *  帖子标题
 */
@property (copy, nonatomic)NSString *subject;
/**
 *  今日发帖数
 */
@property (copy, nonatomic)NSString *toDayPostImage;
@property (copy, nonatomic)NSString *uploadhash;
/**
 *  pid 回复用
 */
@property (copy, nonatomic)NSString *pid;
@property (copy, nonatomic)NSString *textMessage;
@property (copy, nonatomic)NSString *dbdateline;
@property (copy, nonatomic)NSString *dateline;

@property (strong, nonatomic)Report *report;
/*
 * 分享链接
 */
@property (copy, nonatomic) NSString *share_url;

@end

@interface Report : NSObject
@property (copy, nonatomic) NSString *enable;
@property (copy, nonatomic) NSString *tid;
@property (copy, nonatomic) NSString *fid;
@property (copy, nonatomic) NSArray *content;
@property (copy, nonatomic) NSString *handlekey;

@end
