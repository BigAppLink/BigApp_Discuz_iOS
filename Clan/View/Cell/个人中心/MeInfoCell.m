//
//  MeInfoCell.m
//  Clan
//
//  Created by chivas on 15/9/15.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "MeInfoCell.h"

@implementation MeInfoCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setUserModel:(UserModel *)userModel{
    for (UIView *v in self.contentView.subviews) {
        [v removeFromSuperview];
    }
    float width = 0;
    if (userModel) {
        _userModel = userModel;
        width = (kVIEW_W(self)/((_userModel.extcredits.count+1)*1))-1;
        if (_userModel.extcredits.count == 0) {
            UILabel *jifenLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 8, ScreenWidth, 17)];
            jifenLabel.font = [UIFont systemFontOfSize:14.0f];
            jifenLabel.text = @"积分";
            jifenLabel.textColor = UIColorFromRGB(0x424242);
            jifenLabel.textAlignment = NSTextAlignmentCenter;
            [self.contentView addSubview:jifenLabel];
            
            UILabel *jifenValue = [[UILabel alloc]initWithFrame:CGRectMake(0, 45-14-5, ScreenWidth, 14)];
            jifenValue.font = [UIFont systemFontOfSize:11.0f];
            jifenValue.text = _userModel.credits;
            jifenValue.textColor = UIColorFromRGB(0xa6a6a6);
            jifenValue.textAlignment = NSTextAlignmentCenter;
            [self.contentView addSubview:jifenValue];
            
        }else{
            for (NSInteger index = 0; index <= _userModel.extcredits.count; index++) {
                if (index > _userModel.extcredits.count) {
                    break;
                }
                UIView *infoView = [[UIView alloc]initWithFrame:CGRectMake(width*index+index*1, 0, width, 45)];
                UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 8, infoView.width, 17)];
                [self.contentView addSubview:infoView];
                
                nameLabel.font = [UIFont systemFontOfSize:14.0f];
                nameLabel.textColor = UIColorFromRGB(0x424242);
                nameLabel.textAlignment = NSTextAlignmentCenter;
                [infoView addSubview:nameLabel];
                
                UILabel *nameValue = [[UILabel alloc]initWithFrame:CGRectMake(0, 45-14-5, infoView.width, 14)];
                nameValue.font = [UIFont systemFontOfSize:11.0f];
                nameValue.textAlignment = NSTextAlignmentCenter;
                nameValue.textColor = UIColorFromRGB(0xa6a6a6);
                [infoView addSubview:nameValue];
                if (index == 0) {
                    nameLabel.text = @"积分";
                    nameValue.text = _userModel.credits;
                }else{
                    NSDictionary *dic = _userModel.extcredits[index-1];
                    nameLabel.text = dic[@"name"];
                    nameValue.text = dic[@"value"];
                }
                
                if (index != _userModel.extcredits.count) {
                    UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(infoView.right, (infoView.height/2)-(13/2), 0.5, 13)];
                    lineLabel.backgroundColor = UIColorFromRGB(0xd6d6d6);
                    [self.contentView addSubview:lineLabel];
                }
                
            }
        }
    }
    
    
}
-(void)layoutSubviews{
    [super layoutSubviews];
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
