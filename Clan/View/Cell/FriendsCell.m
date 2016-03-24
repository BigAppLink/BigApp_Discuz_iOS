//
//  FriendsCell.m
//  Clan
//
//  Created by 昔米 on 15/7/17.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "FriendsCell.h"

@implementation FriendsCell

- (void)awakeFromNib
{
    _lbl_name.font = [UIFont fontWithSize:15.f];
    _lbl_name.textColor = K_COLOR_DARK;
    _lbl_grouptitle.font = [UIFont fontWithSize:12.f];
    _lbl_grouptitle.textColor = K_COLOR_DARK_Cell;
    _lbl_grouptitle.numberOfLines = 1;
    self.iv_avatar.layer.cornerRadius = 48/2;
    _iv_avatar.contentMode = UIViewContentModeScaleAspectFill;
    _iv_avatar.clipsToBounds = YES;
    self.iv_avatar.backgroundColor = [UIColor blackColor];
    self.iv_line.image = [Util imageWithColor:K_COLOR_MOST_LIGHT_GRAY];
    self.backgroundColor = [UIColor clearColor];    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
