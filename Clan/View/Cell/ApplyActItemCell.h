//
//  ApplyActItemCell.h
//  Clan
//
//  Created by 昔米 on 15/11/19.
//  Copyright © 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApplyActivityItem.h"

@interface ApplyActItemCell : UITableViewCell

@property (strong, nonatomic) YZButton *btn_select;
@property (strong, nonatomic) YZButton *btn_name;
@property (strong, nonatomic) YZButton *btn_deal;
@property (strong, nonatomic) UITextView *tv_content;
@property (strong, nonatomic) UIView *v_bottom;
@property (strong, nonatomic) YZButton *btn_expand;
@property (strong, nonatomic) UIImageView *iv_seperator;
@property (strong, nonatomic) UILabel *lbl_date;
@property (strong, nonatomic) NSIndexPath *path;

@property (strong, nonatomic) ApplyActivityItem *applyitem;

@property (assign, nonatomic) BOOL itemSleceted;
@end
