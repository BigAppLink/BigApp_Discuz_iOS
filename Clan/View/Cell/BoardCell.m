//
//  BoardCell.m
//  Clan
//
//  Created by chivas on 15/3/18.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "BoardCell.h"
#import "ForumsModel.h"
#import "BoardModel.h"
#import <QuartzCore/QuartzCore.h>

@implementation BoardCell

- (void)awakeFromNib
{
    _titleLabel.font = [UIFont fontWithSize:15.f];
    _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _titleLabel.textColor = K_COLOR_DARK;
    _detailLabel.font = [UIFont fontWithSize:12.f];
    _detailLabel.textColor = K_COLOR_DARK_Cell;
    _countLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_Icon-1];
    _countLabel.textColor = [UIColor whiteColor];
    _iv_line.image = [Util imageWithColor:K_COLOR_MOST_LIGHT_GRAY];
    _iconImageView.layer.cornerRadius = 6;
    _iconImageView.layer.masksToBounds = YES;
    _iconImageView.clipsToBounds = YES;
    _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
    _countImageView.layer.masksToBounds = YES;
}

- (void)setForumsModel:(ForumsModel *)forumsModel
{
    _forumsModel = forumsModel;
    if (!_forumsModel.todayposts) {
        _countImageView.hidden = YES;
        _countLabel.hidden = YES;
    }
    _countLabel.text = _forumsModel.todayposts;
    NSDictionary *attribute = [NSDictionary dictionaryWithObjectsAndKeys:_countLabel.font,NSFontAttributeName, nil];
    CGSize size = [_forumsModel.todayposts boundingRectWithSize:CGSizeMake(MAXFLOAT,30) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    /**约束**/
    _countLabel.width = size.width;
    //设置图片点9
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 5, 0, 5);
//    UIImage *image = [_countImageView.image resizableImageWithCapInsets:insets];
    _countImageView.image = [Util imageWithColor:[UIColor returnColorWithPlist:YZSegMentColor withAlphaValue:0.5]];
    _countImageView.width = _countLabel.width + 10;
    _countImageView.right = self.right - 30;
    _countImageView.layer.cornerRadius = _countImageView.height/2;
    _detailLabel.width = _countImageView.left - _detailLabel.left - (ScreenWidth/16);
    
    _countLabel.center = _countImageView.center;
    /**结束约束**/
    NSString *yzlogin = [NSString returnStringWithPlist:@"YouZuLogin"];
    BOOL isLogin = [@"1" isEqualToString:yzlogin] ? YES : NO;
//    _iconImageView.backgroundColor = [UIColor returnColorWithPlist:YZSegMentColor];
    //    _iconImageView.backgroundColor = isLogin ? [UIColor returnColorWithPlist:YZSegMentColor] : kCLEARCOLOR;
    
    [_iconImageView sd_setImageWithURL:[NSURL URLWithString:_forumsModel.icon] placeholderImage:[UIImage imageNamed:@"board_icon"]];
    _titleLabel.text = [NSString stringWithFormat:@"%@",_forumsModel.name];
    _detailLabel.text = [NSString stringWithFormat:@"主题:%@   |   帖子数:%@",_forumsModel.threads,_forumsModel.posts];
    _countLabel.text = [NSString stringWithFormat:@"今日:%@",_forumsModel.todayposts];
    
}

- (void) layoutSubviews
{
    [super layoutSubviews];
}

@end
