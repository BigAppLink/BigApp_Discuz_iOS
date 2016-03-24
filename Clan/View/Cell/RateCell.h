//
//  RateCell.h
//  Clan
//
//  Created by 昔米 on 15/11/24.
//  Copyright © 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQDropDownTextField.h"
#import "RateItem.h"


@interface RateCell : UITableViewCell <IQDropDownTextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UILabel *lbl_name;
@property (nonatomic, strong) UILabel *lbl_display;
@property (nonatomic, strong) UILabel *lbl_pingfen;
@property (nonatomic, strong) UILabel *lbl_jirishengyu;
@property (nonatomic, strong) IQDropDownTextField *tf_value;
//@property (nonatomic, strong) UITextField *tf_zidingyi;
@property (nonatomic, strong) RateItem *rateItem;

@end
