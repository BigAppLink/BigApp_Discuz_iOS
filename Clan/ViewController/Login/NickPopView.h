//
//  NickPopView.h
//  Clan
//
//  Created by chivas on 15/5/4.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "boardTextField.h"
@interface NickPopView : UIView<UITextFieldDelegate>
@property (nonatomic, weak)UIViewController *parentVC;
@property (nonatomic, strong)IBOutlet UIView *innerView;
@property (weak, nonatomic) IBOutlet boardTextField *nickNameField;
@property (copy, nonatomic) void (^nickKeyBlock)(NSString *);
@property (weak, nonatomic) IBOutlet UIButton *nickbtn;
+ (instancetype)defaultPopupView;

@end
