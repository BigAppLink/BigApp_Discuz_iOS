//
//  PostActivityInfoCell.m
//  Clan
//
//  Created by chivas on 15/11/19.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "PostActivityInfoCell.h"
#import "UIPlaceHolderTextView.h"
#import "AGEmojiKeyBoardView.h"
#import "NSString+Common.h"

static const NSInteger kKeyboardView_Height = 216;
@interface PostActivityInfoCell()<UITextViewDelegate,AGEmojiKeyboardViewDelegate, AGEmojiKeyboardViewDataSource>
@property (strong, nonatomic,readwrite) UIPlaceHolderTextView *textView;
//封面view
@property (strong, nonatomic) UIImageView *coverView;
@property (strong, nonatomic) UIButton *deleteBtn;
@property (nonatomic, strong) UIView *keyboardToolBar;
@property (strong, nonatomic) AGEmojiKeyboardView *emojiKeyboardView;
@property (strong, nonatomic) UIButton *emotionButton;

@end
@implementation PostActivityInfoCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.coverView];
        [self.contentView addSubview:self.textView];
        BOOL isDown = [UserDefaultsHelper boolValueForDefaultsKey:kUserDefaultsKey_ClanZipIsDown];
        if (isDown) {
            if (!_emojiKeyboardView) {
                _emojiKeyboardView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, kKeyboardView_Height) dataSource:self];
                _emojiKeyboardView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
                _emojiKeyboardView.delegate = self;
                [_emojiKeyboardView setDoneButtonTitle:@"完成"];
            }
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];

    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (_coverImage) {
        _coverView.image = _coverImage;
        _deleteBtn.hidden = NO;
    }else{
        _coverView.image = kIMG(@"add_cover");
        _deleteBtn.hidden = YES;
    }
}
#pragma mark -创建上传封面按钮
- (UIImageView *)coverView{
    if (!_coverView) {
        _coverView = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth - 16 - 60, 21, 60, 60)];
        _coverView.userInteractionEnabled = YES;
        _coverView.contentMode = UIViewContentModeScaleAspectFill;
        _coverView.clipsToBounds = YES;
        _coverView.image = kIMG(@"add_cover");
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectCover:)];
        [_coverView addGestureRecognizer:tap];
        [_coverView addSubview:self.deleteBtn];

    }
    return _coverView;
}

#pragma mark -创建删除按钮
- (UIButton *)deleteBtn{
    if (!_deleteBtn) {
        _deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(_coverView.width-22, 0, 22, 22)];
        [_deleteBtn setImage:[UIImage imageNamed:@"deleteBtn"] forState:UIControlStateNormal];
        _deleteBtn.backgroundColor = [UIColor clearColor];
//        _deleteBtn.layer.cornerRadius = CGRectGetWidth(_deleteBtn.bounds)/2;
//        _deleteBtn.layer.masksToBounds = YES;
        
        [_deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _deleteBtn.hidden = YES;

    }
    return _deleteBtn;
}

- (void)deleteBtnClicked:(id)sender{
    if (_deleteCoverImageBlock) {
        _deleteCoverImageBlock();
    }
}

#pragma mark -创建textview
- (UIPlaceHolderTextView *)textView{
    if (!_textView) {
        _textView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(14, 9 , _coverView.left - 14, 220-14-20)];
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.font = [UIFont fitFontWithSize:17.f];
        _textView.delegate = self;
        _textView.placeholder = @"请输入活动详情介绍";
        _textView.returnKeyType = UIReturnKeyDefault;
    }
    return _textView;
}

#pragma mark - 添加封面
- (void)selectCover:(UITapGestureRecognizer *)tap{
    if (_addPicturesBlock) {
        _addPicturesBlock();
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

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    BOOL isDown = [UserDefaultsHelper boolValueForDefaultsKey:kUserDefaultsKey_ClanZipIsDown];
    if (isDown) {
        [kKeyWindow addSubview:self.keyboardToolBar];
    }
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self.keyboardToolBar removeFromSuperview];
    return YES;
}

#pragma mark KeyboardToolBar
- (UIView *)keyboardToolBar{
    if (!_keyboardToolBar) {
        _keyboardToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 40)];
        [_keyboardToolBar addLineUp:YES andDown:NO andColor:[UIColor colorWithHexString:@"0xc8c7cc"]];
        _keyboardToolBar.backgroundColor = [UIColor colorWithHexString:@"0xf8f8f8"];
        
        CGFloat toolBarHeight = CGRectGetHeight(_keyboardToolBar.frame);
        _emotionButton = [[UIButton alloc] initWithFrame:CGRectMake(15, (toolBarHeight - 30)/2, 30, 30)];
        [_emotionButton setImage:[UIImage imageNamed:@"keyboard_emotion"] forState:UIControlStateNormal];
        [_emotionButton addTarget:self action:@selector(emotionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_keyboardToolBar addSubview:_emotionButton];
    }
    return _keyboardToolBar;
}

- (void)emotionButtonClicked:(id)sender
{
    if (self.textView.inputView != self.emojiKeyboardView) {
        self.textView.inputView = self.emojiKeyboardView;
        [_emotionButton setImage:[UIImage imageNamed:@"keyboard_keyboard"] forState:UIControlStateNormal];
    }else{
        self.textView.inputView = nil;
        [_emotionButton setImage:[UIImage imageNamed:@"keyboard_emotion"] forState:UIControlStateNormal];
    }
    [self.textView resignFirstResponder];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.textView becomeFirstResponder];
    });
}

#pragma mark - KeyBoard Notification Handlers
- (void)keyboardChange:(NSNotification*)aNotification
{
    NSDictionary* userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGRect keyboardEndFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:animationDuration delay:0.0f options:[UIView animationOptionsForCurve:animationCurve] animations:^{
        CGFloat keyboardY =  keyboardEndFrame.origin.y;
        self.keyboardToolBar.top = keyboardY- CGRectGetHeight(self.keyboardToolBar.frame);
    } completion:^(BOOL finished) {
    }];
}

#pragma mark AGEmojiKeyboardView

- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji {
    NSRange selectedRange = self.textView.selectedRange;
    
    NSString *emotion_monkey = [emoji emotionWithCategory:emojiKeyBoardView.category];
    if (emotion_monkey) {
        self.textView.text = [self.textView.text stringByReplacingCharactersInRange:selectedRange withString:emotion_monkey];
        self.textView.selectedRange = NSMakeRange(selectedRange.location +emotion_monkey.length, 0);
        [self textViewDidChange:self.textView];
    }else{
        self.textView.text = [self.textView.text stringByReplacingCharactersInRange:selectedRange withString:emoji];
        self.textView.selectedRange = NSMakeRange(selectedRange.location +emoji.length, 0);
        [self textViewDidChange:self.textView];
    }
}

- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView {
    [self.textView deleteBackward];
}

- (void)emojiKeyBoardViewDidPressSendButton:(AGEmojiKeyboardView *)emojiKeyBoardView{
    [self.textView resignFirstResponder];
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    return [UIImage imageNamed:@"keyboard_emotion_emoji"];
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForNonSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    return [UIImage imageNamed:@"keyboard_emotion_emoji"];
}

- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView {
    UIImage *img = [UIImage imageNamed:@"keyboard_emotion_delete"];
    return img;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
