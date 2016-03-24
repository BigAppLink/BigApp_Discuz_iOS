//
//  MyInfoThreeCell.m
//  Clan
//
//  Created by chivas on 15/7/17.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "MyInfoThreeCell.h"
#import "UserModel.h"
@implementation MyInfoThreeCell

- (void)awakeFromNib {
    // Initialization code
}
- (void)setUserModel:(UserModel *)userModel{
    _userModel = userModel;
    _centerName.text = @"积分";
    _centerValue.text = _userModel.credits;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
