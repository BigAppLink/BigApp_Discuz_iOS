//
//  UserInfoCell.m
//  Clan
//
//  Created by 昔米 on 15/4/12.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "UserInfoCell.h"

@implementation UserInfoCell

- (void)awakeFromNib
{
    _lbl_brith.font = [UIFont fitFontWithSize:K_FONTSIZE_NORMAL];
    _lbl_regdate.font = [UIFont fitFontWithSize:K_FONTSIZE_NORMAL];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

@end
