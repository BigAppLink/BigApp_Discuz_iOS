//
//  ArticleViewController.h
//  Clan
//
//  Created by chivas on 15/9/6.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "XLButtonBarPagerTabStripViewController.h"

@interface ArticleViewController : XLButtonBarPagerTabStripViewController
@property (strong, nonatomic) NSArray *customNavArray;
@property (copy, nonatomic) NSString *nav_title;
@end
