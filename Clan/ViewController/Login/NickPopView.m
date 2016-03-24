//
//  NickPopView.m
//  Clan
//
//  Created by chivas on 15/5/4.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "NickPopView.h"
@implementation NickPopView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSBundle mainBundle] loadNibNamed:[[self class] description] owner:self options:nil];
        _innerView.frame = frame;
        [self addSubview:_innerView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        _nickNameField.layer.borderWidth = 0.5;
        _nickNameField.layer.borderColor = UIColorFromRGB(0xafafaf).CGColor;
        [_nickNameField addTarget:self action:@selector(nicknamechange:) forControlEvents:UIControlEventEditingChanged];
        _nickbtn.enabled = NO;

    }
    return self;
}

+ (instancetype)defaultPopupView
{
    return [[NickPopView alloc]initWithFrame:CGRectMake(0, 0, 270, 175)];
}

- (IBAction)nickAction:(id)sender
{
    [_nickNameField resignFirstResponder];
    if (_nickKeyBlock) {
        _nickKeyBlock(_nickNameField.text);
    }
}
#pragma mark 键盘即将显示
- (void)keyBoardWillShow:(NSNotification *)note{
    
    CGRect rect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    CGRect frame = [self convertRect:self.bounds toView:window];
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        if (ScreenHeight - rect.size.height < frame.origin.y + frame.size.height) {
            self.transform = CGAffineTransformMakeTranslation(0, -((frame.origin.y + frame.size.height) - (ScreenHeight - rect.size.height)));
        }
    }];
    
}
#pragma mark 键盘即将退出
- (void)keyBoardWillHide:(NSNotification *)note{
    
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        self.transform = CGAffineTransformIdentity;
    }];
}

- (void)nicknamechange:(UITextField *)textfield{
    if (textfield.text.length == 0) {
        _nickbtn.enabled = NO;
    }else{
        _nickbtn.enabled = YES;
    }
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


@end
