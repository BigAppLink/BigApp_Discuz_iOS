//
//  LinkCell.h
//  Clan
//
//  Created by chivas on 15/7/1.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CustomHomeMode;
#import "ItemView.h"
@interface LinkCell : UITableViewCell<ItemViewDelegate>
@property (strong, nonatomic)CustomHomeMode *customHomeModel;

@end
