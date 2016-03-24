//
//  DialogListViewController.h
//  Clan
//
//  Created by 昔米 on 15/4/13.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "BaseViewController.h"
#import "BaseTableView.h"

@interface DialogListViewController : BaseViewController
@property (weak, nonatomic) IBOutlet BaseTableView *tableview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomToSuperView;
@property (assign, nonatomic) BOOL isRightItemBar;
- (void)setupNavigationButtonsForVC:(UIViewController *)vc;
@end

