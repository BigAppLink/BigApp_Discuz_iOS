//
//  MainHomeViewController.h
//  Clan
//
//  Created by 昔米 on 15/4/10.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "BaseViewController.h"

@interface MainHomeViewController : BaseViewController

@property (weak, nonatomic) IBOutlet BaseTableView *tableview;

@property (copy, nonatomic) UserModel *user;

@property (assign) BOOL isSelf;

@end
