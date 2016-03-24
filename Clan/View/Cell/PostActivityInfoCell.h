//
//  PostActivityInfoCell.h
//  Clan
//
//  Created by chivas on 15/11/19.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostActivityInfoCell : UITableViewCell
@property (strong, nonatomic) UIImage *coverImage;
@property (copy, nonatomic) void(^addPicturesBlock)();
@property (copy, nonatomic) void (^deleteCoverImageBlock)();
@property (nonatomic,copy) void(^messageValueChangedBlock)(NSString*);

@end
