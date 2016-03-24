//
//  UIView+Common.m
//  Clan
//
//  Created by chivas on 15/3/26.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//
#define kTagBadgeView  1000
#define kTagLineView 1007
#import "UIView+Common.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Common)
static char LoadingViewKey, BlankPageViewKey;

- (void)addLineUp:(BOOL)hasUp andDown:(BOOL)hasDown{
    [self addLineUp:hasUp andDown:hasDown andColor:[UIColor colorWithHexString:@"0xc8c7cc"]];
}

- (void)addLineUp:(BOOL)hasUp andDown:(BOOL)hasDown andColor:(UIColor *)color{
    [self removeViewWithTag:kTagLineView];
    if (hasUp) {
        UIView *upView = [UIView lineViewWithPointYY:0 andColor:color];
        upView.tag = kTagLineView;
        [self addSubview:upView];
    }
    if (hasDown) {
        UIView *downView = [UIView lineViewWithPointYY:CGRectGetMaxY(self.bounds)-0.5 andColor:color];
        downView.tag = kTagLineView;
        [self addSubview:downView];
    }
    return [self addLineUp:hasUp andDown:hasDown andColor:color andLeftSpace:0];
}
- (void)addLineUp:(BOOL)hasUp andDown:(BOOL)hasDown andColor:(UIColor *)color andLeftSpace:(CGFloat)leftSpace{
    [self removeViewWithTag:kTagLineView];
    if (hasUp) {
        UIView *upView = [UIView lineViewWithPointYY:0 andColor:color andLeftSpace:leftSpace];
        upView.tag = kTagLineView;
        [self addSubview:upView];
    }
    if (hasDown) {
        UIView *downView = [UIView lineViewWithPointYY:CGRectGetMaxY(self.bounds)-0.5 andColor:color andLeftSpace:leftSpace];
        downView.tag = kTagLineView;
        [self addSubview:downView];
    }
}

+ (UIView *)lineViewWithPointYY:(CGFloat)pointY{
    return [self lineViewWithPointYY:pointY andColor:[UIColor colorWithHexString:@"0xc8c7cc"]];
}

+ (UIView *)lineViewWithPointYY:(CGFloat)pointY andColor:(UIColor *)color{
    return [self lineViewWithPointYY:pointY andColor:color andLeftSpace:0];
}

+ (UIView *)lineViewWithPointYY:(CGFloat)pointY andColor:(UIColor *)color andLeftSpace:(CGFloat)leftSpace{
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(leftSpace, pointY, ScreenWidth - leftSpace, 0.5)];
    lineView.backgroundColor = color;
    return lineView;
}
- (void)removeViewWithTag:(NSInteger)tag{
    for (UIView *aView in [self subviews]) {
        if (aView.tag == tag) {
            [aView removeFromSuperview];
        }
    }
}

+ (UIViewAnimationOptions)animationOptionsForCurve:(UIViewAnimationCurve)curve
{
    switch (curve) {
        case UIViewAnimationCurveEaseInOut:
            return UIViewAnimationOptionCurveEaseInOut;
            break;
        case UIViewAnimationCurveEaseIn:
            return UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseOut:
            return UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveLinear:
            return UIViewAnimationOptionCurveLinear;
            break;
    }
    
    return kNilOptions;
}

+ (UIView *)viewForHeaderInSectionWithHeight:(float)viewHeight{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, viewHeight)];
    headerView.backgroundColor = UIColorFromRGB(0xf0eff5);
    UILabel *topLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 1)];
    topLabel.backgroundColor = UIColorFromRGB(0xd4d4d4);
    [headerView addSubview:topLabel];
    UILabel *bottomLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, headerView.bottom-1, ScreenWidth, 1)];
    bottomLabel.backgroundColor = UIColorFromRGB(0xd4d4d4);
    [headerView addSubview:bottomLabel];
    return headerView;
}

#pragma mark LoadingView
- (void)setLoadingView:(EaseLoadingView *)loadingView{
    [self willChangeValueForKey:@"LoadingViewKey"];
    objc_setAssociatedObject(self, &LoadingViewKey,
                             loadingView,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"LoadingViewKey"];
}
- (EaseLoadingView *)loadingView{
    return objc_getAssociatedObject(self, &LoadingViewKey);
}

- (void)beginLoading{
    for (UIView *aView in [self.blankPageContainer subviews]) {
        if ([aView isKindOfClass:[EaseBlankPageView class]] && !aView.hidden) {
            return;
        }
    }
    if (!self.loadingView) {
        //        初始化LoadingView
        EaseLoadingView *view = [[EaseLoadingView alloc] initWithFrame:self.bounds];
        self.loadingView = view;
    }
    [self addSubview:self.loadingView];
    [self.loadingView startAnimating];
}

- (void)endLoading{
    if (self.loadingView) {
        [self.loadingView stopAnimating];
    }
}


#pragma mark BlankPageView
- (void)setBlankPageView:(EaseBlankPageView *)blankPageView{
    [self willChangeValueForKey:@"BlankPageViewKey"];
    objc_setAssociatedObject(self, &BlankPageViewKey,
                             blankPageView,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"BlankPageViewKey"];
}

- (EaseBlankPageView *)blankPageView{
    return objc_getAssociatedObject(self, &BlankPageViewKey);
}

- (void)configBlankPage:(EaseBlankPageType)blankPageType hasData:(BOOL)hasData hasError:(BOOL)hasError reloadButtonBlock:(void (^)(id))block
{
    if (hasData) {
        if (self.blankPageView) {
            self.blankPageView.hidden = YES;
            [self.blankPageView removeFromSuperview];
        }
    }else{
        if (!self.blankPageView) {
            DLog(@"--- %@", NSStringFromCGRect(self.bounds));
            EaseBlankPageView *view = [[EaseBlankPageView alloc] initWithFrame:self.bounds];
            self.blankPageView = view;
        }
        self.blankPageView.hidden = NO;
//        [self.blankPageContainer insertSubview:self.blankPageView atIndex:0];
        //By XIMI
        [self.blankPageContainer addSubview:self.blankPageView];
        [self.blankPageView configWithType:blankPageType hasData:hasData hasError:hasError reloadButtonBlock:block];
    }
}

- (UIView *)blankPageContainer
{
    UIView *blankPageContainer = self;
    for (UIView *aView in [self subviews]) {
        if ([aView isKindOfClass:[UITableView class]]) {
            blankPageContainer = aView;
            [aView addSubview:self.blankPageView];
            [aView sendSubviewToBack:self.blankPageView];
        }
    }
    return blankPageContainer;
}
@end

@implementation EaseBlankPageView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)configWithType:(EaseBlankPageType)blankPageType hasData:(BOOL)hasData hasError:(BOOL)hasError reloadButtonBlock:(void (^)(id))block{
    
    if (hasData) {
        [self removeFromSuperview];
        return;
    }
    self.alpha = 1.0;
    UIView *superview = self;
    //    图片
    if (!_dataView) {
        _dataView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blankpage_image_loadFail"]];
        _dataView.contentMode = UIViewContentModeCenter;
        [self addSubview:_dataView];
        [_dataView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(superview.mas_centerY).offset(-_dataView.height/2);
            make.centerX.equalTo(superview.mas_centerX);
        }];
    }
    //    文字
    if (!_tipTopLabel) {
        _tipTopLabel = [[UILabel alloc] init];
        _tipTopLabel.backgroundColor = [UIColor clearColor];
        _tipTopLabel.numberOfLines = 0;
        _tipTopLabel.font = [UIFont systemFontOfSize:21];
        _tipTopLabel.textColor = UIColorFromRGB(0x325377);
        _tipTopLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_tipTopLabel];
        [_tipTopLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_dataView.mas_bottom).offset(10);
            make.leading.equalTo(superview.mas_leading);
            make.trailing.equalTo(superview.mas_trailing);
        }];

    }
    
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.backgroundColor = [UIColor clearColor];
        _tipLabel.numberOfLines = 0;
        _tipLabel.font = [UIFont systemFontOfSize:14];
        _tipLabel.textColor = UIColorFromRGB(0xb0b0b0);
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_tipLabel];
        [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_tipTopLabel.mas_bottom).offset(10);
            make.leading.equalTo(superview.mas_leading);
            make.trailing.equalTo(superview.mas_trailing);
        }];

    }
    _r2eloadButtonBlock = nil;
    if (hasError) {
        //        加载失败
        if (!_reloadButton) {
            _reloadButton = [[UIButton alloc] init];
            _reloadButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
            [_reloadButton setTitleColor:UIColorFromRGB(0x325377) forState:UIControlStateNormal];
            [_reloadButton setTitle:@"刷新页面" forState:UIControlStateNormal];
            _reloadButton.adjustsImageWhenHighlighted = YES;
            _reloadButton.clipsToBounds = YES;
            _reloadButton.layer.cornerRadius = 6;
            _reloadButton.layer.borderWidth =1.0f;
            _reloadButton.layer.borderColor =UIColorFromRGB(0x325377).CGColor;
            [_reloadButton addTarget:self action:@selector(reloadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_reloadButton];
            [_reloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_tipLabel.mas_bottom).offset(10);
                make.height.equalTo(@(41));
                make.width.equalTo(@(120));
                make.centerX.equalTo(superview.mas_centerX);
            }];
        }
        _reloadButton.hidden = NO;
        _r2eloadButtonBlock = block;
        _tipTopLabel.text = @"糟糕! 好像出错了";
        _tipLabel.text = @"加载失败, 请点击刷新按钮重新加载";
    }else{
        //        空白数据
        if (_reloadButton) {
            _reloadButton.hidden = YES;
        }
        NSString *imageName, *tipStr;
        switch (blankPageType) {
            case DataIsNothingWithDefault:
            {
                imageName = @"dataNothing";
                tipStr = @"这里还什么都没有\n赶快起来弄出一点动静吧";
            }
                break;
            case DataIsNothingWithSearch:
            {
                imageName = @"sousuo2";
                tipStr = @"无搜索结果\n换个关键字试试";
            }
                break;
            default:
            {
                imageName = @"blankpage_image_Sleep";
                tipStr = @"这里还什么都没有\n赶快起来弄出一点动静吧";
            }
                break;
        }
        [_dataView setImage:[UIImage imageNamed:imageName]];
        _tipLabel.text = tipStr;
    }
}

- (void)reloadButtonClicked:(id)sender
{
    self.hidden = YES;
    [self.blankPageContainer sendSubviewToBack:self.blankPageView];
    [self removeFromSuperview];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_r2eloadButtonBlock) {
            _r2eloadButtonBlock(sender);
        }
    });
}

@end

@implementation EaseLoadingView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_activityIndicatorView];
        UIView *superview = self;
        [_activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(superview.mas_centerY).offset(-10);
            make.centerX.equalTo(superview.mas_centerX);
        }];

    }
    return self;
}

- (void)startAnimating{
    self.hidden = NO;
    [self.activityIndicatorView startAnimating];
}

- (void)stopAnimating{
    self.hidden = YES;
    [self.activityIndicatorView stopAnimating];
    [self removeFromSuperview];
}

@end

