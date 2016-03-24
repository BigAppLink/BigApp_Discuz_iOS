//
//  BoardView.h
//  Clan
//
//  Created by 昔米 on 15/7/22.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoardModel.h"

@interface BoardView : UIView <UITableViewDelegate, UITableViewDataSource>
{
    NSIndexPath *_toBeReloadPath;
}
@property (strong, nonatomic) BaseTableView *tableView;
@property (strong, nonatomic) BoardModel *board;
- (void)doViewAppear;
@end
