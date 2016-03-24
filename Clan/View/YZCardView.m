//
//  YZCardView.m
//  Clan
//
//  Created by 昔米 on 15/4/3.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "YZCardView.h"

@implementation YZCardView

- (void)dealloc
{
    _target = nil;
    _titleArray = nil;
    _actionDic = nil;
    DLog(@"YZCardView dealloc");
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
    if (NSStringFromSelector(selector)) {
        [_actionDic setObject:NSStringFromSelector(selector) forKey:title];
    }
    [self addTag:title];
}

- (void)addTag:(NSString *)tag
{
    self.backgroundColor = [UIColor returnColorWithPlist:YZSegMentColor];
    if (!_segment) {
        _segment = [[UISegmentedControl alloc]init];
        [_segment addTarget:self action:@selector(segmentAction:)forControlEvents:UIControlEventValueChanged];  //添加委托方法
        [_segment setTintColor:[UIColor whiteColor]];
        UIFont *font = [UIFont fitFontWithSize:K_FONTSIZE_SUBTITLE];
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                               forKey:NSFontAttributeName];
        [_segment setTitleTextAttributes:attributes
                                        forState:UIControlStateNormal];
        [self addSubview:_segment];
    }
    [_segment insertSegmentWithTitle:tag atIndex:_titleArray.count animated:NO];
    _segment.selectedSegmentIndex = 0;
    UIView *superview = self;
    [_segment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(superview.mas_centerY);
        make.centerX.equalTo(superview.mas_centerX);
        make.leading.equalTo(superview.mas_leading).offset(30);
        make.trailing.equalTo(superview.mas_trailing).offset(-30);
        make.height.equalTo(@30);
    }];
}

-(void)segmentAction:(UISegmentedControl *)Seg
{
    NSInteger Index = Seg.selectedSegmentIndex;
    if (Index <= _titleArray.count-1) {
        NSString *title = _titleArray[Index];
        [self.target performSelector:NSSelectorFromString(_actionDic[title]) withObject:nil];
    }
}

- (IBAction)tapAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    _defaultIndex = btn.tag - 1000;
    [self changeBtnFrameAndTime:0.2];
    NSString *title = _titleArray[_defaultIndex];
    [self.target performSelector:NSSelectorFromString(_actionDic[title]) withObject:nil];
}

- (void)changeBtnFrameAndTime:(NSTimeInterval)time{
    UIView *indicatorView = [self viewWithTag:5555];
    [UIView animateWithDuration:time animations:^{
        indicatorView.frame = CGRectMake(_defaultIndex * (kVIEW_W(self)-(_titleArray.count-1)*1)/_titleArray.count, kVIEW_H(self)-2, (kVIEW_W(self)-(_titleArray.count-1)*1)/_titleArray.count, 2);
    }];
    
}
- (void)changeSelectBtn:(NSInteger)index
{
    [_segment setSelectedSegmentIndex:index];
    [self segmentAction:_segment];
}

- (void)changeTitleAtIndex:(int)index withNewTitle:(NSString *)title
{
    [_segment setTitle:title forSegmentAtIndex:index];
}

@end
