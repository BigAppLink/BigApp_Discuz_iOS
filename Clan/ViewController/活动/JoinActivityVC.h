//
//  JoinActivityVC.h
//  Clan
//
//  Created by 昔米 on 15/11/13.
//  Copyright © 2015年 Youzu. All rights reserved.
//

#import "BaseViewController.h"

@interface JoinActivityVC : BaseViewController

@property (strong, nonatomic) NSArray *joinfieldArr;
@property (strong, nonatomic) NSArray *extfield;
@property (copy, nonatomic) NSString *pid;
@property (copy, nonatomic) NSString *tid;
@property (copy, nonatomic) NSString *fid;
@property (copy, nonatomic) NSString *credit_title; //参加活动要消耗的单位（金钱 积分 还是威望等）
@property (copy, nonatomic) NSString *credit; //参加活动要消耗对应单位的量值（比如 10个积分）
@property (copy, nonatomic) NSString *uploadHash; //参加活动要消耗对应单位的量值（比如 10个积分）

@property (weak, nonatomic) id targetVC;
@end
