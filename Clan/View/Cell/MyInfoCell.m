//
//  MyInfoCell.m
//  Clan
//
//  Created by chivas on 15/7/15.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "MyInfoCell.h"
#import "UserModel.h"
@implementation MyInfoCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setUserModel:(UserModel *)userModel{
    _userModel = userModel;
    _leftName.text = @"积分";
    _leftValue.text = _userModel.credits;
    _centerName.text = _userModel.extcredits[0][@"name"];
    _centerValue.text = _userModel.extcredits[0][@"value"];
    _rightName.text = _userModel.extcredits[1][@"name"];
    _rightValue.text = _userModel.extcredits[1][@"value"];


    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
