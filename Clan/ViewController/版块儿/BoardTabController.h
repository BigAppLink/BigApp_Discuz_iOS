//
//  BoardTabController.h
//  Clan
//
//  Created by 昔米 on 15/7/21.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "BaseViewController.h"
#import "ViewPagerController.h"

@interface BoardTabController : ViewPagerController <ViewPagerDataSource, ViewPagerDelegate>
@property (assign, nonatomic) BOOL isTabBarItem;
@end
