//
//  MyInfoThreeCell.h
//  Clan
//
//  Created by chivas on 15/7/17.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserModel;

@interface MyInfoThreeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *centerValue;
@property (weak, nonatomic) IBOutlet UILabel *centerName;
@property (strong, nonatomic)UserModel *userModel;

@end
