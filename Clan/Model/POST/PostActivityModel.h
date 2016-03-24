//
//  PostActivityModel.h
//  Clan
//
//  Created by chivas on 15/10/30.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PostSendModel;
@interface PostActivityModel : NSObject
/**
 *   allowpostactivity: 0--不支持活动，后续字段无效，1--支持活动
 */
@property (copy, nonatomic) NSString *allowpostactivity;
/**
 *  如果存在且非空，则允许主题作者设置参与活动需要消耗的积分，具体是消耗哪种积分，则使用本字段返回的值
 */
@property (copy, nonatomic) NSString *credit_title;
/**
 *  类型
 */
@property (strong, nonatomic) NSArray *activitytype;
/**
 *  必填项
 */
@property (strong, nonatomic) NSArray *activityfield;
/**
 *  最多允许扩展项数目
 */
@property (copy, nonatomic) NSString *activityextnum;
/**
 *  主题展示页中每页展示多少个活动申请者
 */
@property (copy, nonatomic) NSString *activitypp;

@end

@interface SendActivity : NSObject
/**
 *  主题
 */
@property (copy, nonatomic) NSString *subject;
/**
 *  版块id
 */
@property (copy, nonatomic) NSString *fid;
@property (strong, nonatomic) PostSendModel *sendModel;
/**
 *  时间
 */
@property (copy, nonatomic) NSString *starttimefrom;
/**
 *  活动地点
 */
@property (copy, nonatomic) NSString *activityplace;
/**
 *  活动类型
 */
@property (copy, nonatomic) NSString *activityclass;
/**
 *  作者选择的必填项信息，数组
 */
@property (strong, nonatomic) NSArray *userfield;
/**
 *  最多允许的扩展项数目
 */
@property (copy, nonatomic) NSString *activityextnum;
/**
 *  封面id
 */
@property (copy, nonatomic) NSString *activityaid;
/**
 *  封面图片地址
 */
@property (copy, nonatomic) NSString *activityaid_url;
/**
 *  封面图片
 */
@property (strong, nonatomic) SendImage *activityImage;
/**
 *  扩展
 */
@property (copy, nonatomic) NSString *extfield;
@end

