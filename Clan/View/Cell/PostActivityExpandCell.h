//
//  PostActivityExpandCell.h
//  Clan
//
//  Created by chivas on 15/12/7.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ActivityExpandDelegate <NSObject>
- (void)activityExpandString:(NSString *)string;
@end
@interface PostActivityExpandCell : UITableViewCell
@property (copy, nonatomic) NSString *activityextnum;
@property (assign, nonatomic) id<ActivityExpandDelegate>delegate;
@end
