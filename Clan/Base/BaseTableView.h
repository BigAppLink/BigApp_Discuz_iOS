//
//  BaseTableView.h
//  Clan
//
//  Created by chivas on 15/4/8.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"
@interface BaseTableView : UITableView

@property (copy, nonatomic) void(^moreDataBlock)();
- (void)createHeaderViewBlock:(void (^)())block;
- (void)createFooterViewBlock:(void (^)())block;
- (void)beginRefreshing;

// - By XiMi
- (void)endHeaderRefreshing;

- (BOOL)isHeaderRefreshing;

- (BOOL)isFooterrRefreshing;

- (void)resetFooterState:(MJRefreshFooterState)state;

- (void)hideTableFooter;

- (void)showTableFooter;

@end
