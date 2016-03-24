//
//  BoardViewController.h
//  Clan
//
//  Created by chivas on 15/3/17.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "BaseViewController.h"

@interface BoardViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
@property (assign, nonatomic) BOOL isTabBarItem;

@end
