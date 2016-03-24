//
//  InputTextCell.m
//  Clan
//
//  Created by chivas on 15/3/12.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//
//#define kInput_OnlyText_Cell_LeftPading 18.0
#import "InputTextCell.h"
@interface InputTextCell ()
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation InputTextCell

- (IBAction)editDidBegin:(id)sender {
    _lineView.backgroundColor = [UIColor colorWithHexString:@"0xffffff"];
    self.clearBtn.hidden = _isRegister? YES: self.textField.text.length <= 0;
}
- (IBAction)editDidEnd:(id)sender {
    _lineView.backgroundColor = [UIColor colorWithHexString:@"0xffffff" andAlpha:0.5];
    self.clearBtn.hidden = YES;
    if (self.editDidEndBlock) {
        self.editDidEndBlock(self.textField.text);
    }
}
- (IBAction)textChangeValue:(id)sender {
    self.clearBtn.hidden = _isRegister? YES: self.textField.text.length <= 0;
    if (self.textValueChangedBlock) {
        self.textValueChangedBlock(self.textField.text);
    }
}

- (IBAction)cleanBtnAction:(id)sender {
    self.textField.text = @"";
    [self textChangeValue:nil];
}

#pragma mark - UIView
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backgroundColor = _isRegister? [UIColor whiteColor]: [UIColor clearColor];
    self.textField.font = [UIFont fitFontWithSize:17.f];
    self.textField.textColor = KCOLOR_TEXT_DARK;
    self.textField.clearButtonMode = _isRegister? UITextFieldViewModeWhileEditing: UITextFieldViewModeNever;
    self.textField.width = (self.contentView.width - 2*18) - 20;
    self.clearBtn.left = _textField.right;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
