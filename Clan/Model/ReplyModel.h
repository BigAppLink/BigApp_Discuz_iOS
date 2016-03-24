//
//  ReplyModel.h
//  Clan
//
//  Created by 昔米 on 15/4/9.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReplyModel : NSObject


@property (nonatomic ,copy) NSString *avatar;

@property (nonatomic ,copy) NSString *author;

@property (nonatomic ,copy) NSString *forum_name;

@property (nonatomic ,copy) NSString *message;

@property (nonatomic ,copy) NSString *pid;

@property (nonatomic ,copy) NSString *subject;

@property (nonatomic ,copy) NSString *tid;

@property (nonatomic ,copy) NSString *dateline;

/**
 *  查看次数
 */
@property (copy, nonatomic)NSString *views;
/**
 *  回帖次数
 */
@property (copy, nonatomic)NSString *replies;

@end
