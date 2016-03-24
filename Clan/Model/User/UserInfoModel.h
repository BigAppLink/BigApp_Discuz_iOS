//
//  UserInfoModel.h
//  Clan
//
//  Created by 昔米 on 15/4/13.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfoModel : NSObject

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *regdate;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *credits;
@property (copy, nonatomic) NSString *gender; //性别
@property (copy, nonatomic) NSString *posts; //回帖数
@property (copy, nonatomic) NSString *threads; //发帖数
@property (copy, nonatomic) NSString *extcredits1; //威望
@property (copy, nonatomic) NSString *extcredits2; //金钱
@property (copy, nonatomic) NSString *constellation; //星座
@property (copy, nonatomic) NSString *realname; //真实名称
@property (copy, nonatomic) NSString *group_title; //群组名称
@property (copy, nonatomic) NSString *groupname;
@property (copy, nonatomic) NSString *friends;
@property (strong, nonatomic) NSArray *extcredits;
@property (copy, nonatomic) NSString *note; //备注
@property (copy, nonatomic) NSString *isfriend;
@property (copy, nonatomic) NSString *is_my_friend;

@end
