//
//  DialogListModel.h
//  Clan
//
//  Created by 昔米 on 15/4/13.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DialogListModel : NSObject

//会话ID号，代表和某个用户的一系列会话记录
@property (copy, nonatomic) NSString *plid;
//是否是新的（没读过的就是新消息）
@property (copy, nonatomic) NSString *isnew;
//总消息个数
@property (copy, nonatomic) NSString *pmnum;
//上次我发送消息过去的时间
@property (copy, nonatomic) NSString *lastupdate;
//上次消息列表的更新时间
@property (copy, nonatomic) NSString *lastdateline;
//发起本次会话的的用户ID
@property (copy, nonatomic) NSString *authorid;
//目前恒定为1，即短消息会话
@property (copy, nonatomic) NSString *pmtype;
//会话列表的标题
@property (copy, nonatomic) NSString *subject;
//会话人数
@property (copy, nonatomic) NSString *members;
//上次会话的更新时间
@property (copy, nonatomic) NSString *dateline;
//最新消息的目标用户
@property (copy, nonatomic) NSString *touid;
//恒定等于plid
@property (copy, nonatomic) NSString *pmid;
//最后消息的作者
@property (copy, nonatomic) NSString *lastauthorid;
//最后消息的作者
@property (copy, nonatomic) NSString *lastauthor;
//最后消息的摘要
@property (copy, nonatomic) NSString *lastsummary;
//最后消息是哪个用户发送的
@property (copy, nonatomic) NSString *msgfromid;
//最后消息是哪个用户发送的
@property (copy, nonatomic) NSString *msgfrom;
//最后消息的完整内容
@property (copy, nonatomic) NSString *message;
//本会话是当前用户和哪个用户的会话，在查看会话内容时，请用该字段填充touid参数
@property (copy, nonatomic) NSString *msgtoid;
//本会话是当前用户和哪个用户的会话
@property (copy, nonatomic) NSString *tousername;
//会话消息的对方头像
@property(copy, nonatomic) NSString *msgtoid_avatar;



@end
