//
//  SessionModel.h
//  Clan
//
//  Created by 昔米 on 15/4/13.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SessionModel : NSObject

@property (copy, nonatomic) NSString *plid;
@property (copy, nonatomic) NSString *authorid;
@property (copy, nonatomic) NSString *pmtype;
@property (copy, nonatomic) NSString *subject;
@property (copy, nonatomic) NSString *members;
//消息发出的时间
@property (copy, nonatomic) NSString *dateline;
@property (copy, nonatomic) NSString *pmid;
//消息内容
@property (copy, nonatomic) NSString *message;
@property (copy, nonatomic) NSString *touid;
@property (copy, nonatomic) NSString *author;
@property (copy, nonatomic) NSString *msgfromid;
//发消息的人的名字
@property (copy, nonatomic) NSString *msgfrom;
@property (copy, nonatomic) NSString *msgtoid;
@property (copy, nonatomic) NSString *msgtoid_avatar;
//发消息的人的头像
@property (copy, nonatomic) NSString *msgfromid_avatar;
//当前的登录用户ID
@property (copy, nonatomic) NSString *current_member_ID;

@end
