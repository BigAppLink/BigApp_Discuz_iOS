//
//  PostSendCell.m
//  Clan
//
//  Created by chivas on 15/3/25.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//
#define kSendContentCell_ContentFont [UIFont systemFontOfSize:16]
static const NSInteger kKeyboardView_Height = 216;
#import "PostSendCell.h"
#import "NSString+Common.h"
@interface PostSendCell () <AGEmojiKeyboardViewDelegate, AGEmojiKeyboardViewDataSource>
@property (nonatomic, strong) UIView *keyboardToolBar;
@property (strong, nonatomic) UITextField *titleField;
@property (strong, nonatomic) AGEmojiKeyboardView *emojiKeyboardView;
@property (strong, nonatomic) UIButton *emotionButton;
@end


@implementation PostSendCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        _selectedForumsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectedForumsBtn setBackgroundImage:[Util imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        _selectedForumsBtn.exclusiveTouch = YES;
        [_selectedForumsBtn setTitle:@"请选择要发帖的版块儿" forState:UIControlStateNormal];
        _selectedForumsBtn.titleLabel.font = [UIFont fontWithSize:14.f];
        [_selectedForumsBtn setTitleColor:K_COLOR_DARK_Cell forState:UIControlStateNormal];
        [self.contentView addSubview:_selectedForumsBtn];
    }
    return self;
}

- (void)setIsRelayPost:(BOOL)isRelayPost
{
    if (_selectedForums) {
        _selectedForumsBtn.frame = CGRectMake(15, 7, kSCREEN_WIDTH-30, 40);
        _selectedForumsBtn.hidden = NO;
    } else {
        _selectedForumsBtn.frame = CGRectMake(15, 0, kSCREEN_WIDTH-30, 0);
        _selectedForumsBtn.hidden = YES;
    }
    _isRelayPost = isRelayPost;
    if (!_isRelayPost) {
        if (!_titleField) {
            _titleField = [[UITextField alloc]initWithFrame:CGRectMake(14, kVIEW_BY(_selectedForumsBtn)+7, ScreenWidth-7*2, 45)];
            [_titleField addTarget:self action:@selector(titleChange:) forControlEvents:UIControlEventEditingChanged];
            _titleField.placeholder = @"标题";
            _titleField.delegate = self;
            _titleField.font = [UIFont fitFontWithSize:17.f];
            _titleField.returnKeyType = UIReturnKeyDone;
            [self.contentView addSubview:_titleField];
            UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(0, _titleField.bottom, ScreenWidth, 1)];
            line.backgroundColor = UIColorFromRGB(0xd5d5d5);
            [self.contentView addSubview:line];
            
        }
    }
    if (!_tweetContentView) {
        _tweetContentView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(6, _isRelayPost ?kVIEW_BY(_selectedForumsBtn)+7:_titleField.bottom+5, ScreenWidth-7*2, 220-20-45)];
        _tweetContentView.backgroundColor = [UIColor clearColor];
        _tweetContentView.font = [UIFont fitFontWithSize:17.f];
        _tweetContentView.delegate = self;
        _tweetContentView.placeholder = @"说点什么吧~";
        _tweetContentView.returnKeyType = UIReturnKeyDefault;
        [self.contentView addSubview:_tweetContentView];
    }
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

+ (CGFloat)cellHeight
{
    CGFloat cellHeight = 220;
    return cellHeight;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    BOOL isDown = [UserDefaultsHelper boolValueForDefaultsKey:kUserDefaultsKey_ClanZipIsDown];
    if (isDown) {
        if ([textView isFirstResponder]) {
            [kKeyWindow addSubview:self.keyboardToolBar];
        }
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
    if (self.tweetContentView.inputView != self.emojiKeyboardView) {
        self.tweetContentView.inputView = self.emojiKeyboardView;
        [_emotionButton setImage:[UIImage imageNamed:@"keyboard_keyboard"] forState:UIControlStateNormal];
    }else{
        self.tweetContentView.inputView = nil;
        [_emotionButton setImage:[UIImage imageNamed:@"keyboard_emotion"] forState:UIControlStateNormal];
    }
    [self.tweetContentView resignFirstResponder];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tweetContentView becomeFirstResponder];
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
    NSRange selectedRange = self.tweetContentView.selectedRange;
    
    NSString *emotion_monkey = [emoji emotionWithCategory:emojiKeyBoardView.category];
    if (emotion_monkey) {
        self.tweetContentView.text = [self.tweetContentView.text stringByReplacingCharactersInRange:selectedRange withString:emotion_monkey];
        self.tweetContentView.selectedRange = NSMakeRange(selectedRange.location +emotion_monkey.length, 0);
        [self textViewDidChange:self.tweetContentView];
    }else{
        self.tweetContentView.text = [self.tweetContentView.text stringByReplacingCharactersInRange:selectedRange withString:emoji];
        self.tweetContentView.selectedRange = NSMakeRange(selectedRange.location +emoji.length, 0);
        [self textViewDidChange:self.tweetContentView];
    }
}

- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView {
    [self.tweetContentView deleteBackward];
}

- (void)emojiKeyBoardViewDidPressSendButton:(AGEmojiKeyboardView *)emojiKeyBoardView{
    [_tweetContentView resignFirstResponder];
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


@end
