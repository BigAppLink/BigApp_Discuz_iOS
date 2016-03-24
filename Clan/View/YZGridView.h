//
//  YZGridView.h
//  Clan
//
//  Created by 昔米 on 15/7/4.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomHomeMode.h"
#import "TAPageControl.h"

@interface YZGridView : UIView <UIScrollViewDelegate>

@property (strong, nonatomic) CustomHomeMode *customHomeModel;
@property (strong, nonatomic) UIScrollView *scroll;
@property (strong, nonatomic) NSMutableArray *views;
@property (assign, nonatomic) int perline;
@property (assign, nonatomic) int linenum;
@property (strong, nonatomic) TAPageControl *pageControl;
@property (strong, nonatomic) UIColor *bottomBorderColor;

@end
