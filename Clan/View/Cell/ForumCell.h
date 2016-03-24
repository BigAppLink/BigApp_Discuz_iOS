//
//  ForumCell.h
//  Clan
//
//  Created by chivas on 15/7/2.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForumCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel1;
@property (weak, nonatomic) IBOutlet UILabel *desLabel1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel2;
@property (weak, nonatomic) IBOutlet UILabel *desLabel2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (strong, nonatomic) NSArray *forumArray;
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;

@end
