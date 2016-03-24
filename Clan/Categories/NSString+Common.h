//
//  NSString+Common.h
//  Clan
//
//  Created by chivas on 15/3/26.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+Emojize.h"

@interface NSString (Common)
+ (NSString *)flattenHTML:(NSString *)html;
- (NSString *)emotionMonkeyName;
- (NSString *)emotionWithCategory:(NSString *)category;
+ (NSString *)flattenHTMLExceptBiaoQing:(NSString *)html;
+ (CGSize) boundingRectWithSize:(CGSize)size font:(UIFont *)font text:(NSString *)text;
- (CGSize)sizeWithConstrainedToWidth:(float)width fromFont:(UIFont *)font1 lineSpace:(float)lineSpace;
- (CGSize)sizeWithConstrainedToSize:(CGSize)size fromFont:(UIFont *)font1 lineSpace:(float)lineSpace;


@end
