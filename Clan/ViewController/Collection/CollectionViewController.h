//
//  CollectionViewController.h
//  Clan
//
//  Created by chivas on 15/3/16.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "BaseViewController.h"
//#import "BaseSegmentViewController.h"



@interface CollectionViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong,nonatomic)BaseTableView *tableView;
//@property (assign, nonatomic)BOOL isMyPost;
@property (assign,nonatomic)CollcetionType collcetionType;
@property (weak,nonatomic)id target;
//重置导航
- (void)setUpNavi;
@end
