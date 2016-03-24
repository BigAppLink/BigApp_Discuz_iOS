//
//  CustomModuleViewController.h
//  Clan
//
//  Created by chivas on 15/10/8.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "BaseViewController.h"
#import "XLPagerTabStripViewController.h"
@class CustomHomeMode;
@interface CustomModuleViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,XLPagerTabStripChildItem>
@property (assign, nonatomic) BOOL isTabBar;
@property (strong, nonatomic)CustomHomeMode *customHomeModel;
@property (copy, nonatomic)NSString *navSideTitle;
@property (assign, nonatomic) BOOL isRightItem;

@end
