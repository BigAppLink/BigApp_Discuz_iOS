//
//  APostCell.h
//  Clan
//
//  Created by 昔米 on 15/7/8.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostModel.h"

@interface APostCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iv_topline;
@property (weak, nonatomic) IBOutlet UIImageView *iv_bottomline;
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UIView *v_abstract;
@property (weak, nonatomic) IBOutlet UILabel *lbl_abstract;
@property (weak, nonatomic) IBOutlet UIView *v_images;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_height_imagesview;
@property (weak, nonatomic) IBOutlet UIImageView *iv_avatar;
@property (weak, nonatomic) IBOutlet UILabel *lbl_name;
@property (weak, nonatomic) IBOutlet UILabel *lbl_time;
@property (weak, nonatomic) IBOutlet UILabel *lbl_replys;
@property (weak, nonatomic) IBOutlet UILabel *lbl_views;
@property (strong, nonatomic) PostModel *postModel;
@property (assign) BOOL showTopic; //是否显示
@property (assign) BOOL listable; //是否可点

@end
