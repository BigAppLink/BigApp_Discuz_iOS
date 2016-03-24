//
//  UILabel+Common.m
//  Clan
//
//  Created by chivas on 15/7/23.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "UILabel+Common.h"

@implementation UILabel (Common)
+ (UILabel *)yzAttributedLabelWithText:(NSString *)text andFrame:(CGRect)frame andFont:(UIFont *)font{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:avoidNullStr(label.text)];
    [attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [label.text length])];
    [label setAttributedText:attributedString];
    [label sizeToFit];
    return label;
}

@end
