//
//  UIView+Additions.m
//  Clan
//
//  Created by chivas on 15/3/23.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "UIView+Additions.h"

@implementation UIView (Additions)
- (UIViewController *)additionsViewController
{
    //下一个响应者
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}

@end
