//
//  UserSearchCell.h
//  Clan
//
//  Created by chivas on 15/7/9.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserInfoModel;
@interface UserSearchCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *faceImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupnameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property(strong, nonatomic) UserInfoModel *infoModel;
@end
