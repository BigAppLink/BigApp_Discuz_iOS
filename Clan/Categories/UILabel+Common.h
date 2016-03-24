//
//  UILabel+Common.h
//  Clan
//
//  Created by chivas on 15/7/23.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Common)
+ (UILabel *)yzAttributedLabelWithText:(NSString *)text andFrame:(CGRect)frame andFont:(UIFont *)font;
@end
