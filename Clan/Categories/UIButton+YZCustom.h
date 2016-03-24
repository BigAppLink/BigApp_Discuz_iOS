//
//  UIButton+YZCustom.h
//  Clan
//
//  Created by chivas on 15/3/4.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (YZCustom)

+ (UIButton *)buttonWithTitle:(NSString *)title andImage:(NSString *)image andFrame:(CGRect)rect target:(id)target action:(SEL)selector;
+ (UIButton *)createButtonWithTitle:(NSString *)title andFrame:(CGRect)rect andBgImage:(UIImage *)bgImage andImage:(UIImage *)image target:(id)target action:(SEL)selector;
@end
