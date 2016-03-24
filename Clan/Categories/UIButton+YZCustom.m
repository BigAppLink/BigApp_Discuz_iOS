//
//  UIButton+YZCustom.m
//  Clan
//
//  Created by chivas on 15/3/4.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "UIButton+YZCustom.h"

@implementation UIButton (YZCustom)

+ (UIButton *)buttonWithTitle:(NSString *)title andImage:(NSString *)image andFrame:(CGRect)rect target:(id)target action:(SEL)selector
{
    UIButton *costomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    costomButton.frame = rect;
    if (title) {
        [costomButton setTitle:title forState:UIControlStateNormal];
    }
    [costomButton setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [costomButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return costomButton;
}

#pragma 发消息button
+ (UIButton *)createButtonWithTitle:(NSString *)title andFrame:(CGRect)rect andBgImage:(UIImage *)bgImage andImage:(UIImage *)image target:(id)target action:(SEL)selector{
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton.frame = rect;
    if (title) {
        [customButton setTitle:title forState:UIControlStateNormal];
    }
    if (bgImage) {
        [customButton setBackgroundImage:bgImage forState:UIControlStateNormal];
    }
    [customButton setImage:image forState:UIControlStateNormal];
    [customButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return customButton;
}

@end
