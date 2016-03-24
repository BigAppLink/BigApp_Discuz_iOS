//
//  PostCell.h
//  demoSizeCell
//
//  Created by 昔米 on 15/4/8.
//  Copyright (c) 2015年 游族. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostModel.h"

@interface MyPostsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *v_line1;
@property (weak, nonatomic) IBOutlet UIImageView *iv_avatar;
@property (weak, nonatomic) IBOutlet UILabel *lbl_name;
@property (weak, nonatomic) IBOutlet UILabel *lbl_dateline;
@property (weak, nonatomic) IBOutlet UILabel *lbl_replys;
@property (weak, nonatomic) IBOutlet UIImageView *iv_replys;
@property (weak, nonatomic) IBOutlet UILabel *lbl_views;
@property (weak, nonatomic) IBOutlet UIImageView *iv_views;
@property (weak, nonatomic) IBOutlet YZLabel *lbl_subject;
@property (weak, nonatomic) IBOutlet UIView *v_line2;
@property (weak, nonatomic) IBOutlet UILabel *lbl_domain;
@property (weak, nonatomic) IBOutlet UIView *v_line3;
//@property (weak, nonatomic) IBOutlet UILabel *lbl_lastpost_info;

@property (strong, nonatomic) PostModel *post;
@end
