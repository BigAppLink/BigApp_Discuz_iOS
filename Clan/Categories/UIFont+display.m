//
//  UIFont+display.m
//  Clan
//0
//  Created by 昔米 on 15/5/20.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "UIFont+display.h"

@implementation UIFont (display)

+ (UIFont *)fitFontWithSize:(CGFloat)fontsize
{
    if (kDEVICE_IS_IPHONE6Plus) {
        UIFont *font = [UIFont fontWithName:K_FONT_NAME size:fontsize-1];
        return font;
    } else {
        UIFont *font = [UIFont fontWithName:K_FONT_NAME size:fontsize-2];
        return font;
    }
}

+ (UIFont *)fontWithSize:(CGFloat)fontsize
{
    UIFont *font = [UIFont fontWithName:K_FONT_NAME size:fontsize];
    return font;
}

@end

