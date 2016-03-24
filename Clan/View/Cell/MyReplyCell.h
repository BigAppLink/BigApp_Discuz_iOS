//
//  MyReplyCell.h
//  Clan
//
//  Created by 昔米 on 15/4/8.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReplyModel.h"

@interface MyReplyCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iv_avatar;
@property (weak, nonatomic) IBOutlet UILabel *lbl_name;
@property (weak, nonatomic) IBOutlet UILabel *lbl_dateline;
@property (weak, nonatomic) IBOutlet YZLabel *lbl_comments;
@property (weak, nonatomic) IBOutlet YZLabel *lbl_subject;
@property (weak, nonatomic) IBOutlet UILabel *lbl_domain;
@property (weak, nonatomic) IBOutlet UIImageView *v_postbg;
@property (weak, nonatomic) IBOutlet UILabel *lbl_reply;
@property (weak, nonatomic) IBOutlet UILabel *lbl_views;

@property (strong, nonatomic) ReplyModel *model;

@end
