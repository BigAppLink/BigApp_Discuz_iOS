//
//  PostActivitySelectCell.h
//  Clan
//
//  Created by chivas on 15/11/3.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ActivitySelectInfoDelegate <NSObject>
- (void)activitySelectInfoWithInfoDic:(NSDictionary *)dic;
@end

@interface PostActivitySelectCell : UITableViewCell
@property (strong, nonatomic) NSArray *selectArray;
@property (copy, nonatomic, readwrite) NSString *key;
@property (strong, nonatomic,readwrite) UILabel *titleLabel;
- (CGFloat )heightWithSelectCell:(NSArray *)array;
@property (assign, nonatomic) id<ActivitySelectInfoDelegate>delegate;
@end
