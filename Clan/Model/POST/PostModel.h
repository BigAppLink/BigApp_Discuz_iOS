//
//  PostModel.h
//  Clan
//
//  Created by chivas on 15/3/18.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostModel : NSObject
/**
 *  主题id
 */
@property (copy, nonatomic)NSString *tid;
/**
 *  主题所属版块id
 */
@property (copy, nonatomic)NSString *fid;
/**
 *  作者名字
 */
@property (copy, nonatomic)NSString *author;
/**
 *  作者ID
 */
@property (copy, nonatomic)NSString *authorid;
/**
 *  主题的标题
 */
@property (copy, nonatomic)NSString *subject;
/**
 *  主题的发布时间
 */
@property (copy, nonatomic)NSString *dateline;
/**
 *  主题发布时间-时间戳
 */
@property (copy, nonatomic)NSString *dbdateline;
/**
 *  主题的最新回帖时间
 */
@property (copy, nonatomic)NSString *lastpost;
/**
 *  最新回帖的作者
 */
@property (copy, nonatomic)NSString *lastposter;
/**
 *  查看次数
 */
@property (copy, nonatomic)NSString *views;
/**
 *  回帖次数
 */
@property (copy, nonatomic)NSString *replies;
/**
 *  主题热度值
 */
@property (copy, nonatomic)NSString *heats;
/**
 *  主题收藏次数
 */
@property (copy, nonatomic)NSString *favtimes;
/**
 *  主题分享次数
 */
@property (copy, nonatomic)NSString *sharetimes;
/**
 *  主题作者的头像
 */
@property (copy, nonatomic)NSString *avatar;
/**
 *  主题图标，如新人贴、置顶等图标
 */
@property (copy, nonatomic)NSString *icon;
/**
 *  1：精华1、2：精华2、3：精华3
 */
@property (copy, nonatomic)NSString *digest;
/**
 *  图片数组
 */
@property (strong, nonatomic)NSArray *threadimage;
/*新增*/
/**
 *  图片hash
 */
@property (copy, nonatomic)NSString *uploadhash;

/**
 * 讨论区名称
 */
@property (strong, nonatomic)NSString *forum_name;
/**
 * 今日可发帖数
 */
@property (copy, nonatomic)NSString *toDayPostImage;
/**
 * 是否是热点
 */
@property (assign, nonatomic)BOOL ishot;
/**
 *  是否还有下一页
 */
@property (copy, nonatomic)NSString *need_more;
/**
 *  附件类型
 */
@property (copy, nonatomic)NSString *attachment;
/**
 *  多图模式下的图片
 */
@property (strong, nonatomic)NSArray *attachment_urls;
/**
 *  摘要
 */
@property (copy, nonatomic)NSString *message_abstract;
/**
 * 帖子分类id 跳转的时候要用
 */
@property (copy, nonatomic) NSString *type_id;
/**
 * 帖子分类
 */
@property (copy, nonatomic) NSString *type_name;

/**
 *  缓存高度
 */
@property (assign, nonatomic) CGFloat frame;
/**
 *  判断是首页还是帖子页
 */
@property (copy, nonatomic) NSString *modelType;
/**
 *  是否显示分类 0 不显示 1 显示
 */
@property (copy, nonatomic) NSString *prefix;
@property (assign) BOOL hide_type;
//ypeid：非0时有效，表示帖子分类ID号，当点击某分类时，应该跳转到当前板块指定分类的帖子，该id将会作为参数之一传入，详见7.3.12的参数说明部分
//typename: typeid非0时存在，表示帖子分类名字
- (CGFloat)frameWithModel;


@end


