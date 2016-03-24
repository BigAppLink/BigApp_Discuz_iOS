//
//  MyInfoTwoCell.h
//  Clan
//
//  Created by chivas on 15/7/17.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserModel;
@interface MyInfoTwoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *leftValue;
@property (weak, nonatomic) IBOutlet UILabel *leftName;
@property (weak, nonatomic) IBOutlet UILabel *rightValue;
@property (weak, nonatomic) IBOutlet UILabel *rightName;
@property (strong, nonatomic)UserModel *userModel;
@end
