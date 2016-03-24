//
//  CustomRightItemView.h
//  Clan
//
//  Created by chivas on 15/11/17.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CustomHomeMode;
@protocol CustomRightItemDelegate <NSObject>
@optional
- (void)customRightPostSend;

@end
@interface CustomRightItemView : UIView
@property (strong, nonatomic)CustomHomeMode *customHomeModel;
@property (assign, nonatomic)id<CustomRightItemDelegate>delegate;
@end
