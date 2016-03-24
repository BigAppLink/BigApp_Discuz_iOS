//
//  MeViewController.h
//  Clan
//
//  Created by 昔米 on 15/7/3.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "BaseViewController.h"

@interface MeViewController : BaseViewController

@property (strong, nonatomic)  BaseTableView *tableview;
@property (assign) BOOL isSelf;
@property (strong, nonatomic) UserModel *user;
@property (assign) BOOL isPresentMode;
@property (assign, nonatomic) BOOL isRightItem;
@end
