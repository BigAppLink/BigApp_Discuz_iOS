//
//  BannerCell.h
//  Clan
//
//  Created by chivas on 15/7/1.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDCycleScrollView.h"
@class CustomHomeMode;
@interface BannerCell : UITableViewCell<SDCycleScrollViewDelegate>
@property (strong, nonatomic)CustomHomeMode *customHomeModel;
@end
