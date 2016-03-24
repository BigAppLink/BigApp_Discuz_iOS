//
//  BaseSegmentViewController.h
//  Clan
//
//  Created by chivas on 15/3/16.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, SegmentType) {
    segmentCollection = 0,
    segmentHome
};
@interface BaseSegmentViewController : BaseViewController

@property (assign,nonatomic)SegmentType segmentType;
@property (assign,nonatomic)int selectedIndex;

@end
