//
//  InputTextCell.h
//  Clan
//
//  Created by chivas on 15/3/12.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InputTextCell : UITableViewCell
@property (assign, nonatomic) BOOL isRegister,isCaptcha;
@property (strong, nonatomic) UIImageView *captchaView;
@property (strong, nonatomic) UIImage *captchaImage;

@property (strong, nonatomic) UIView *lineView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *clearBtn;
@property (nonatomic,copy) void(^textValueChangedBlock)(NSString*);
@property (nonatomic,copy) void(^editDidEndBlock)(NSString*);
@property (nonatomic,copy) void(^sessionIdBlock)(NSString*);

@end
