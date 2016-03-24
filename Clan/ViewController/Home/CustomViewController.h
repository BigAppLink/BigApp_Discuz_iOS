//
//  CustomViewController.h
//  Clan
//
//  Created by chivas on 15/6/30.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLPagerTabStripViewController.h"
@interface CustomViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,XLPagerTabStripChildItem>
@property (assign, nonatomic) BOOL isTabBar;
@end
