//
//  TopAListCell.h
//  Clan
//
//  Created by chivas on 15/4/9.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PostModel;
@interface TopAListCell : UITableViewCell
@property (strong, nonatomic)PostModel *postModel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (assign, nonatomic) BOOL isHideLine;
@property (weak, nonatomic) IBOutlet UIImageView *line;

@end
