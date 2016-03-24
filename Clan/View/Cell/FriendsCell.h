//
//  FriendsCell.h
//  Clan
//
//  Created by 昔米 on 15/7/17.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iv_avatar;
@property (weak, nonatomic) IBOutlet UILabel *lbl_grouptitle;
@property (weak, nonatomic) IBOutlet UILabel *lbl_name;
@property (weak, nonatomic) IBOutlet UIImageView *iv_line;
@end
