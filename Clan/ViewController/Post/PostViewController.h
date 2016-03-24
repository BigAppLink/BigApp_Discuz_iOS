//
//  PostViewController.h
//  Clan
//
//  Created by chivas on 15/3/20.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ForumsModel;


@interface PostViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic)ForumsModel *forumsModel;
@end
