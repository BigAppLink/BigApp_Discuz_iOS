//
//  ArticleDetailViewController.h
//  Clan
//
//  Created by chivas on 15/9/7.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "BaseViewController.h"
@class ArticleListModel;
@interface ArticleDetailViewController : BaseViewController
@property (strong, nonatomic) ArticleListModel *articleModel;
@property(copy, nonatomic) NSString *shareImageURL;

@end
