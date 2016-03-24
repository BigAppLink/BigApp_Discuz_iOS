//
//  TicklingPostCell.m
//  Clan
//
//  Created by chivas on 15/8/27.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "TicklingPostCell.h"
#define kSendContentCell_ContentFont [UIFont systemFontOfSize:16]
static const NSInteger kKeyboardView_Height = 216;
@interface TicklingPostCell()
@property (strong, nonatomic) UITextField *titleField;
@property (strong, nonatomic) UIButton *emotionButton;
@end;
@implementation TicklingPostCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        if (!_tweetContentView) {
            _tweetContentView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(6, 7, ScreenWidth-7*2, 90-20)];
            _tweetContentView.backgroundColor = [UIColor whiteColor];
            _tweetContentView.font = [UIFont systemFontOfSize:17.0f];
            _tweetContentView.delegate = self;
            _tweetContentView.placeholder = @"在这里写下您的意见和建议吧";
            _tweetContentView.returnKeyType = UIReturnKeyDefault;
            [self.contentView addSubview:_tweetContentView];
        }
    }
    return self;
}

+ (CGFloat)cellHeight{
    CGFloat cellHeight = 90;
    return cellHeight;
}

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - KeyBoard Notification Handlers
- (void)keyboardChange:(NSNotification*)aNotification{
    NSDictionary* userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGRect keyboardEndFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSLog(@"userInfo------------------:%@", userInfo);
    [UIView animateWithDuration:animationDuration delay:0.0f options:[UIView animationOptionsForCurve:animationCurve] animations:^{
        CGFloat keyboardY =  keyboardEndFrame.origin.y;
    } completion:^(BOOL finished) {
    }];
}
#pragma mark FieldView Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)titleChange:(UITextField *)textField{
    if (self.subjectValueChangedBlock) {
        self.subjectValueChangedBlock(textField.text);
    }
}
#pragma mark TextView Delegate
- (void)textViewDidChange:(UITextView *)textView
{
    if (self.messageValueChangedBlock) {
        self.messageValueChangedBlock(textView.text);
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    return YES;
}


@end
