//
//  ViewPagerController.h
//  CustomSliderTabbar
//
//  Created by wallstreetcn on 14-2-13.
//  Copyright (c) 2014年 wallstreetcn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#define kTagBgView     200
#define kTagLb         1000
#define kTagButton     2000
#define kTagContentView     3000
#define kIndictorHeight 3
#define kTitleFont [UIFont systemFontOfSize:13.0f]
#define kTopSegmentBGColor [UIColor whiteColor]
#define kTitleColorN K_COLOR_DARK_Cell

#define kTitleColorH [UIColor returnColorWithPlist:YZSegMentColor]
#define kIndicatorColor [UIColor returnColorWithPlist:YZSegMentColor]
//#define kTitleColorH kUIColorFromRGB(0xff9900)
//#define kIndicatorColor kUIColorFromRGB(0xff9900)
#define kSpace 20.f
#define kTopSegmentBarHeight 40.f

@protocol ViewPagerDataSource;
@protocol ViewPagerDelegate;

@interface ViewPagerController : BaseViewController <UIScrollViewDelegate>

@property id<ViewPagerDataSource> dataSource;
@property id<ViewPagerDelegate> delegate;
@property (assign, nonatomic)  int selectedIndex;
@property (assign, nonatomic) BOOL equelWidth;

- (void)reloadDatas;
@end

#pragma mark dataSource
@protocol ViewPagerDataSource <NSObject>
- (NSArray *)titleArrayForViewPager:(ViewPagerController *)viewpager;
- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index;
- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager;
@optional
- (CGRect)frameForTopbar;
- (CGRect)frameForContentView;


@end

#pragma mark delegate
@protocol ViewPagerDelegate <NSObject>
@optional
//当tab发生切换的时候 实现此代理方法
- (void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index;
- (void)viewPager:(ViewPagerController *)viewPager viewAppearAtIndex:(NSUInteger)index;
- (void)viewPager:(ViewPagerController *)viewPager viewDisappearAtIndex:(NSUInteger)index;
@end
