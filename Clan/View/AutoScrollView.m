//
//  AutoScrollView.m
//  AutoScrollView
//
//  Created by KindAzrael on 13-2-18.
//  Copyright (c) 2013年 KindAzrael. All rights reserved.
//

#import "AutoScrollView.h"

@interface AutoScrollView ()

// add the keybord notification
- (void)setup;

// remove the keybord notification
- (void)tearDown;


- (void)keyboardWillShow:(NSNotification *)notification;


- (void)keyboardWillHide:(NSNotification *)notification;

@end

@implementation AutoScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [self setup];
    self.contentSize = CGSizeMake(320, 504);
}

- (void)dealloc {
    [self tearDown];
}

// hide keybord when touch croll view
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self endEditing:YES];
}

- (void)setup
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)tearDown {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// scroll contentOffset when keybord will show
- (void)keyboardWillShow:(NSNotification *)notification
{
    self.previousOffset = self.contentOffset;
    NSDictionary *userInfo = [notification userInfo];
    
    // get keyboard rect in windwo coordinate
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // convert keyboard rect from window coordinate to scroll view coordinate
    keyboardRect = [self convertRect:keyboardRect fromView:nil];
    
    // get keybord anmation duration
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // get first responder textfield
    UIView *currentResponder = [self findFirstResponderBeneathView:self];
    if (currentResponder != nil) {
        // convert textfield left bottom point to scroll view coordinate
        CGPoint point = [currentResponder convertPoint:CGPointMake(0, currentResponder.frame.size.height) toView:self];
        // 计算textfield左下角和键盘上面20像素 之间是不是差值
        float scrollY = point.y - (keyboardRect.origin.y - 20);
        if (scrollY > 0) {
            [UIView animateWithDuration:animationDuration animations:^{
                //移动textfield到键盘上面20个像素
                self.contentOffset = CGPointMake(self.contentOffset.x, self.contentOffset.y + scrollY);
            }];
        }
        self.contentSize = CGSizeMake(320, 504+268);
    }
}

// roll back content offset
-(void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:animationDuration animations:^{
        self.contentOffset = self.previousOffset;
    }];
    self.contentSize = CGSizeMake(320, 504);
}

- (UIView*)findFirstResponderBeneathView:(UIView*)view
{
    // Search recursively for first responder
    for ( UIView *childView in view.subviews ) {
        if ( [childView respondsToSelector:@selector(isFirstResponder)] && [childView isFirstResponder] ) return childView;
        UIView *result = [self findFirstResponderBeneathView:childView];
        if ( result ) return result;
    }
    return nil;
}
@end