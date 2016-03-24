//
//  ArticleCustomViewController.h
//  Clan
//
//  Created by chivas on 15/9/6.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "BaseViewController.h"
#import "XLPagerTabStripViewController.h"
@class ArticleModel;
@interface ArticleCustomViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,XLPagerTabStripChildItem>
@property (strong, nonatomic) ArticleModel *articleModel;
@end
