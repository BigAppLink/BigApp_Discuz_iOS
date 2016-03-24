//
//  ArticleCell.h
//  Clan
//
//  Created by chivas on 15/9/6.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ArticleListModel;
@interface ArticleCell : UITableViewCell
@property (strong, nonatomic) ArticleListModel *articleModel;
@property (weak, nonatomic) IBOutlet UIImageView *articleImage;
@property (weak, nonatomic) IBOutlet UILabel *articleTitle;
@property (weak, nonatomic) IBOutlet UILabel *articleCentent;
@property (weak, nonatomic) IBOutlet UILabel *articleTime;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *articleImageWidthLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLeftLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLeftLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLeftLayout;
@end
