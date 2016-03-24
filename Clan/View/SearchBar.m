//
//  SearchBar.m
//  News
//
//  Created by fallen on 14-12-17.
//  Copyright (c) 2014年 wallstreetcn. All rights reserved.
//

#import "SearchBar.h"

@implementation SearchBar

- (id)initWithFrame:(CGRect)frame ShowCancelButton:(BOOL)flag
{
    self = [super initWithFrame:frame];
    if (self) {
        _showCanecelButton = flag;
        [self buildUI];
    }
    return self;
}

- (void)buildUI
{
    self.backgroundColor = [UIColor clearColor];
    
//    int searchViewWidth = _showCanecelButton ? kVIEW_W(self) - 10 - 58 : kVIEW_W(self) - 20;
    _searchView = [[UIView alloc] initWithFrame:CGRectMake(10, 11, kSCREEN_WIDTH-20, 31)];//searchViewWidth
    _searchView.backgroundColor = [UIColor whiteColor];
    _searchView.layer.cornerRadius = 4;
    _searchView.layer.borderWidth = 0.5;
    [self addSubview:_searchView];
    _searchView.backgroundColor = [UIColor whiteColor];
    _textField.textColor = kUIColorFromRGB(0x333333);
//    [_textField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    _searchView.layer.borderColor = kUIColorFromRGB(0xCCCCCC).CGColor;
    
    UIImage *icomImage = kIMG(@"sousuoshouye");
    _searchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(5, 8, icomImage.size.width, icomImage.size.height)];
    _searchIcon.image = icomImage;
    [_searchView addSubview:_searchIcon];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(kVIEW_BX(_searchIcon) + 5, 0, kSCREEN_WIDTH-20 - 5 - kVIEW_BX(_searchIcon), 31)];//searchViewWidth - 5 - kVIEW_BX(_searchIcon)
    _textField.font = [UIFont systemFontOfSize:15];
    _textField.placeholder = @"请输入关键字";
    _textField.clearButtonMode = UITextFieldViewModeAlways;
    _textField.font = [UIFont systemFontOfSize:15];
    _textField.returnKeyType = UIReturnKeySearch;
    _textField.delegate = self;
    _textField.exclusiveTouch = YES;
    
    [_searchView addSubview:_textField];
    if (_showCanecelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.frame = CGRectMake(10+kVIEW_BX(_searchView), 11, 58, 31);
        _cancelButton.backgroundColor = [UIColor clearColor];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//        [_cancelButton setTitleColor:kAppMainColor forState:UIControlStateNormal];
        [self addSubview:_cancelButton];
    }

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addJumpButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = _textField.frame;
    _textField.userInteractionEnabled = YES;
    button.backgroundColor = [UIColor clearColor];
    button.exclusiveTouch = NO;
    _jumpButton = button;
    _textField.placeholder = @"输入关键词";
    [_textField addSubview:button];
}

#pragma mark - 点击取消按钮
- (void)cancelButtonClicked
{
    int searchViewWidth = kSCREEN_WIDTH-20;
    [UIView animateWithDuration:.3 animations:^{
        _searchView.frame = CGRectMake(10, 11, searchViewWidth, 31);
        _cancelButton.frame = CGRectMake(10+kVIEW_BX(_searchView), 11, 58, 31);
        
    } completion:^(BOOL finished) {
        _textField.frame = CGRectMake(_textField.frame.origin.x, _textField.frame.origin.y, searchViewWidth - 5 - kVIEW_BX(_searchIcon), _textField.frame.size.height);
    }];
    
    if (_delegate && [_delegate respondsToSelector:@selector(searchBarCancelButtonClicked:)]) {
        [_delegate searchBarCancelButtonClicked:self];
    }
}
#pragma mark - 监听文本输入框变化
- (void)textDidChange:(NSNotification *)notification
{
    NSString* text = _textField.text;
    if (_delegate && [_delegate respondsToSelector:@selector(searchBar:textDidChange:)]) {
        if (_textField.markedTextRange == nil) {
            DLog(@"textDidChange: %@", text);
            [_delegate searchBar:self textDidChange:text];
        }
    }
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (_delegate && [_delegate respondsToSelector:@selector(searchBarSearchButtonClicked:)]) {
        [_delegate searchBarSearchButtonClicked:self];
    }
    return true;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    int searchViewWidth = _showCanecelButton ? kVIEW_W(self) - 10 - 58 : kVIEW_W(self) - 20;
    [UIView animateWithDuration:.3 animations:^{
        _searchView.frame = CGRectMake(_searchView.frame.origin.x, kVIEW_TY(_searchView), searchViewWidth, kVIEW_H(_searchView));
        _cancelButton.frame = CGRectMake(kVIEW_BX(_searchView), 11, 58, 31);
    
    } completion:^(BOOL finished) {
        
        _textField.frame = CGRectMake(_textField.frame.origin.x, _textField.frame.origin.y, searchViewWidth - 5 - kVIEW_BX(_searchIcon), _textField.frame.size.height);

    }];
    if (_delegate && [_delegate respondsToSelector:@selector(searchBarTextDidBeginEditing:)]) {
        [_delegate searchBarTextDidBeginEditing:self];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (_delegate && [_delegate respondsToSelector:@selector(searchBar:textDidChange:)]) {
        [_delegate searchBar:self textDidChange:@""];
    }
    return true;
}

@end
