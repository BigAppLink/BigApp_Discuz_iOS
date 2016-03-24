//
//  BaseTableView.m
//  Clan
//
//  Created by chivas on 15/4/8.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "BaseTableView.h"

@implementation BaseTableView

- (void)createHeaderViewBlock:(void (^)())block{
    [self addLegendHeaderWithRefreshingBlock:^{
        block();
    }];
}

- (void)createFooterViewBlock:(void (^)())block{
    _moreDataBlock = block;
    [self addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(loadDataArray)];

}

- (void)beginRefreshing
{
    [self.legendHeader beginRefreshing];
}

- (void)loadDataArray
{
    if (_moreDataBlock)
    {
        _moreDataBlock();
    }
}

// - By XiMi
- (void)beginFooterRefreshing
{
    [self.legendFooter beginRefreshing];
}

- (void)endHeaderRefreshing
{
    [self.legendHeader endRefreshing];
}

- (BOOL)isHeaderRefreshing
{
    return self.legendHeader.isRefreshing;
}

- (BOOL)isFooterrRefreshing
{
    return self.legendFooter.isRefreshing;
}

- (void)resetFooterState:(MJRefreshFooterState)state
{
    [self showTableFooter];
    switch (state) {
        case MJRefreshFooterStateIdle:
            
            [self.legendFooter endRefreshing];
            break;
            
        case MJRefreshFooterStateRefreshing:
            
            [self.legendFooter beginRefreshing];
            break;
            
        case MJRefreshFooterStateNoMoreData:
            
            [self.legendFooter noticeNoMoreData];
            break;

        default:
            break;
    }
}

- (void)hideTableFooter
{
    [self.legendFooter setHidden:YES];
}

- (void)showTableFooter
{
    [self.legendFooter setHidden:NO];
}


@end
