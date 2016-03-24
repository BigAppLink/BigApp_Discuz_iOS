//
//  YZClanChatBar.m
//  Clan
//
//  Created by chivas on 15/11/25.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "YZClanChatBar.h"
static CGFloat const chatBarHeight = 50;
@interface YZClanChatBar()<UITextViewDelegate>
@property (strong, nonatomic) UIButton *moreButton;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UIButton *faceButton;
@property (strong, nonatomic) UITextView *textView;
@end
@implementation YZClanChatBar

- (instancetype)initWithFrame:(CGRect)frame{
    self =  [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView{
    [self addSubview:self.moreButton];
    [self addSubview:self.faceButton];
    [self addSubview:self.sendButton];
    [self addSubview:self.textView];

}

#pragma mark - Getters
- (UIButton *)moreButton{
    if (!_moreButton) {
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreButton.frame = CGRectMake(6, chatBarHeight/2 - 28/2, 28, 28);
        _moreButton.tag = YZFunctionViewShowMore;
        [_moreButton setBackgroundImage:[UIImage imageNamed:@"reply_more"] forState:UIControlStateNormal];
        [_moreButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_moreButton sizeToFit];
    }
    return _moreButton;
}

- (UIButton *)faceButton{
    if (!_faceButton) {
        _faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _faceButton.frame = CGRectMake(_moreButton.right + 6, _moreButton.top, 28, 28);
        _faceButton.tag = YZFunctionViewShowFace;
        [_faceButton setBackgroundImage:[UIImage imageNamed:@"reply_face"] forState:UIControlStateNormal];
        [_faceButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_faceButton sizeToFit];
    }
    return _faceButton;
}

- (UIButton *)sendButton{
    if (!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.frame = CGRectMake(ScreenWidth-49, 10, 43, 30);
        [_sendButton setTintColor:UIColorFromRGB(0x303030)];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_sendButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_sendButton sizeToFit];
    }
    return _sendButton;

}
- (UITextView *)textView{
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(_faceButton.right + 6, 10, (_sendButton.left - 6) - (_faceButton.right + 6), 30)];
        _textView.font = [UIFont systemFontOfSize:16.0f];
        _textView.delegate = self;
        _textView.layer.cornerRadius = 5.0f;
        _textView.layer.borderColor = [UIColor colorWithRed:204.0/255.0f green:204.0/255.0f blue:204.0/255.0f alpha:1.0f].CGColor;
        _textView.returnKeyType = UIReturnKeySend;
        _textView.layer.borderWidth = .5f;
        _textView.layer.masksToBounds = YES;
    }
    return _textView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
