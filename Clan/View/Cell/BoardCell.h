//
//  BoardCell.h
//  Clan
//
//  Created by chivas on 15/3/18.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ForumsModel;
@interface BoardCell : UITableViewCell
@property (strong, nonatomic)ForumsModel *forumsModel;
@property (weak, nonatomic) IBOutlet UIImageView *iv_line;

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet YZLabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *countImageView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@end
