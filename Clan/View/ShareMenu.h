//
//  ShareMenu.h
//  TumblrMenu
//
//  Created by wallstreetcn on 14-6-16.
//  Copyright (c) 2014年 HangChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedMenuItemButton.h"
#import "QBlurView.h"

static int SMTag = 1999;
static float SMTitleHeight = 40.f;
static float SMBottomBarHeight = 70.f;
//static float SMImageHeight = 44.f;
static float SMVerticalPadding = 10.f;
static float SMHorizontalMargin = 10.f;
//static NSString * SMRriseAnimationID = @"SMRriseAnimationID";
//static NSString *  SMDismissAnimationID = @"SMDismissAnimationID";
//static float SMAnimationTime = 0.36;
static float SMAnimationTime = 0.5;

//static float SMAnimationInterval = 0.002;
static float SMAnimationInterval = 0.005;

static int SMColumnCount = 3;

typedef NS_ENUM(NSInteger, MenuViewMode) {
    MenuViewMode_FromBottom = 0, //帖子收藏
    MenuViewMode_FullScreen,   //文章收藏
};
//typedef void (^ShareMenuViewSelectedBlock)selectedBlock(void);

typedef void (^SelectedBlock) (id returnValue);

@interface ShareMenu : UIView
@property (nonatomic, strong) NSMutableArray *datasources;
@property (copy, nonatomic) SelectedBlock selectedBlock;
@property (assign, nonatomic) MenuViewMode menuMode;
@property (nonatomic, strong) QBlurView *abview;
@property (assign) CGFloat startCenterX;

- (id)initWithFrame:(CGRect)frame withShareList:(NSArray *)array;
- (void)show;
@end
