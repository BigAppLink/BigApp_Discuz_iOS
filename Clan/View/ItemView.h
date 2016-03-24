//
//  ItemView.h
//  Clan
//
//  Created by chivas on 15/7/1.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ItemView;
@class LinkModel;
@protocol ItemViewDelegate <NSObject>

@optional
- (void)didItemView:(ItemView *)itemView atIndex:(NSInteger)index;

@end
@interface ItemView : UIView
@property (nonatomic, strong) UIImageView *item;
@property (nonatomic, strong) UILabel     *title;
@property (nonatomic, assign) id <ItemViewDelegate> delegate;
@property (nonatomic, strong) LinkModel *linkmodel;

@end
