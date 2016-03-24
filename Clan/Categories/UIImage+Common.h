//
//  UIImage+Common.h
//  Clan
//
//  Created by chivas on 15/3/4.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface UIImage (Common)
+(UIImage *)imageWithColor:(UIColor *)aColor alpha:(CGFloat)alpha;
+(UIImage *)imageWithColor:(UIColor *)aColor withFrame:(CGRect)aFrame alpha:(CGFloat)alpha;
-(UIImage*)scaledToSize:(CGSize)targetSize;
-(UIImage*)scaledToSize:(CGSize)targetSize highQuality:(BOOL)highQuality;
+ (UIImage *)fullResolutionImageFromALAsset:(ALAsset *)asset;
- (UIImage*)transformWidth:(CGFloat)width
                    height:(CGFloat)height;
@end
