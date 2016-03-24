//
//  SharedMenuItemButton.m
//  Clan
//
//  Created by 昔米 on 15/7/14.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "SharedMenuItemButton.h"


@implementation SharedMenuItemButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame andTitle:(NSString *)title andIcon:(UIImage *)icon
{
    self = [self initWithFrame:frame];
    if (self) {
        iconView_ = [UIImageView new];
        iconView_.contentMode = UIViewContentModeScaleAspectFit;
        iconView_.image = icon;
        iconView_.userInteractionEnabled = NO;
        titleLabel_ = [UILabel new];
        titleLabel_.userInteractionEnabled = NO;
        titleLabel_.textAlignment = NSTextAlignmentCenter;
        titleLabel_.backgroundColor = [UIColor clearColor];
        if (_textColor) {
            titleLabel_.textColor = _textColor;
        } else {
            titleLabel_.textColor = K_COLOR_DARK_Cell;
        }
        if (_textFont) {
            titleLabel_.font = _textFont;
        } else {
            titleLabel_.font = [UIFont systemFontOfSize:13.f];
        }
        titleLabel_.text = title;
        [self addSubview:iconView_];
        [self addSubview:titleLabel_];
//        [iconView_ mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(self.mas_centerX);
//            make.centerY.equalTo(self.mas_centerY).offset(-10);
//            make.width.equalTo(@(SMImageHeight));
//            make.height.equalTo(@(SMImageHeight));
//        }];
//        [titleLabel_ mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(self.mas_centerX);
//            make.bottom.equalTo(self.mas_bottom).offset(-20);
//        }];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];// 分享菜单偏左.1 (6&6+适配--A)
//    iconView_.frame = CGRectMake((kSCREEN_WIDTH - 320) / 5, 0, frame.size.width, SMImageHeight);
//    titleLabel_.frame = CGRectMake((kSCREEN_WIDTH - 320) / 5, SMImageHeight, frame.size.width, SMItemTitleHeight);
    iconView_.frame = CGRectMake(0, 0, frame.size.width, SMImageHeight);
    titleLabel_.frame = CGRectMake(0, SMImageHeight, frame.size.width, SMItemTitleHeight);
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    titleLabel_.textColor = textColor;
}

- (void)setTextFont:(UIFont *)textFont
{
    _textFont = textFont;
    titleLabel_.font = textFont;
}
@end
