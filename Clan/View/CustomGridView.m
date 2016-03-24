//
//  CustomGridView.m
//  Clan
//
//  Created by chivas on 15/8/19.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "CustomGridView.h"

@implementation CustomGridView
- (void)addCardDone{
    [self resetViews];
}

- (void)initScrollView{
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:_scrollView];
}

- (void)addCardWithTitle:(NSString *)title withSel:(SEL)selector
{

    if ([Util isBlankString:title]) {
        return;
    }
    if (!_titleArray) {
        _titleArray = [NSMutableArray new];
    }
    if (!_actionDic) {
        _actionDic = [NSMutableDictionary new];
    }
    [_titleArray addObject:title];
    [_actionDic setObject:NSStringFromSelector(selector) forKey:title];
}

- (void)resetViews
{
//    for (UIView *v in self.subviews) {
//        [v removeFromSuperview];
//    }
    if (_titleArray.count <= 0) {
        return;
    }
    float width = 0;
    if (_titleArray.count > 3) {
        width = kVIEW_W(self)/4 - 1;
    }else{
        width = ((kVIEW_W(self)-(_titleArray.count-1)*1)/_titleArray.count)-1;
    }
    float height = kVIEW_H(self);
    float scrollWidth = 0;
    for (int i = 0; i < _titleArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitleColor:UIColorFromRGB(0x424242)  forState:UIControlStateSelected];
        [btn setTitleColor:_textColor?:UIColorFromRGB(0xa6a6a6)  forState:UIControlStateNormal];
        btn.backgroundColor = kCLEARCOLOR;
        [btn setTitle:_titleArray[i] forState:UIControlStateNormal];
        btn.titleLabel.font = _textFont ? :[UIFont systemFontOfSize:15.0f];
        [btn addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(width*i+i*1, 0, width, height);
        btn.tag = 1000+i;
        if (i == 0) {
            _tempBtn = btn;
            _tempBtn.selected = YES;
        }
        scrollWidth = width*i+i*1 + width;
        [_scrollView addSubview:btn];
        if (i != _titleArray.count-1) {
            UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(btn.right, (btn.height/2)-(13/2), 0.5, 13)];
            lineLabel.backgroundColor = UIColorFromRGB(0xd6d6d6);
            [_scrollView addSubview:lineLabel];
        }
        
    }
    _scrollView.contentSize = CGSizeMake(scrollWidth, _scrollView.height);
}

- (IBAction)tapAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if ([btn isEqual:_tempBtn]) {
        return;
    }
    _tempBtn.selected = NO;
    btn.selected = YES;
    _tempBtn = btn;

    int i = (int)btn.tag - 1000;
    NSString *title = _titleArray[i];
    [self.target performSelector:NSSelectorFromString(_actionDic[title]) withObject:_tempBtn];
}

- (void)changeTitleAtIndex:(int)index withNewTitle:(NSString *)title
{
    [_titleArray replaceObjectAtIndex:index withObject:title];
    //    [self changeView];
    //    [self resetViews];
}


- (void)dealloc
{
    _target = nil;
    _titleArray = nil;
    _actionDic = nil;
    
    DLog(@"YZCardView dealloc");
}

@end
