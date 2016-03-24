//
//  SharedMenuItemButton.h
//  Clan
//
//  Created by 昔米 on 15/7/14.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ShareSDK/SSDKTypeDefine.h>

static NSString * SMRriseAnimationID = @"SMRriseAnimationID";
static NSString *  SMDismissAnimationID = @"SMDismissAnimationID";
static float SMImageHeight = 55.f;
static float  SMItemTitleHeight = 30.f;

@interface SharedMenuItemButton : UIButton
{
    UIImageView *iconView_;
    UILabel *titleLabel_;
}
@property (assign) SSDKPlatformType shareType;
@property (assign) int btnindex;
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) UIFont *textFont;



- (id)initWithFrame:(CGRect)frame andTitle:(NSString *)title andIcon:(UIImage *)icon;
@end
