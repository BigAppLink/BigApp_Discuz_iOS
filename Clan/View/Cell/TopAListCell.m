//
//  TopAListCell.m
//  Clan
//
//  Created by chivas on 15/4/9.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "TopAListCell.h"
#import "PostModel.h"
#import <QuartzCore/QuartzCore.h>
@implementation TopAListCell

- (void)awakeFromNib
{
    _topLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_Icon];
    _titleLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_NORMAL];
    _titleLabel.textColor = K_COLOR_LIGHT_DARK;
    _line.image = [Util imageWithColor:kUIColorFromRGB(0xeaeae9)];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

- (void)setPostModel:(PostModel *)postModel
{
    _postModel = postModel;
    
    if (_isHideLine) {
        //        _line.hidden = YES;
    }
    _topLabel.clipsToBounds = YES;
    _topLabel.layer.cornerRadius = 2;
    _topLabel.layer.borderWidth = 1.0f;
    _topLabel.layer.borderColor =UIColorFromRGB(0x0fa7ff).CGColor;
    _titleLabel.text = _postModel.subject;
}
@end
