//
//  SubsCell.h
//  Clan
//
//  Created by chivas on 15/6/23.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SubsModel;
@interface SubsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *subName;
@property (strong, nonatomic)SubsModel *subsModel;

@end
