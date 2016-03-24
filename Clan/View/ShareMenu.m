//
//  ShareMenu.m
//  TumblrMenu
//
//  Created by wallstreetcn on 14-6-16.
//  Copyright (c) 2014年 HangChen. All rights reserved.
//

#import "ShareMenu.h"
#import "UIImage+ImageEffects.h"
#import "ShareItem.h"
#import "QBlurView.h"

static float topspace = 26.f;

@implementation ShareMenu
{
    NSMutableArray *buttons_;
    UIView *_contentView;
    UIImageView *_contentBGView;
    UIView *bgview_;
    UIControl *control_;
    UIButton *dismissBtn_;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
        _datasources = [NSMutableArray new];
        buttons_ = [[NSMutableArray alloc] initWithCapacity:6];
        bgview_ = [UIControl new];
        bgview_.alpha = 0;
        bgview_.backgroundColor = [UIColor colorWithRed:.0 green:.0 blue:.0 alpha:0.2];
        //        bgview_.backgroundColor = [UIColor whiteColor];
        [self addSubview:bgview_];
        
        control_ = [UIControl new];
        [control_ addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
        control_.backgroundColor = [UIColor clearColor];
        [self addSubview:control_];
        
        _contentBGView = [UIImageView new];
        _contentBGView.contentMode = UIViewContentModeScaleAspectFill;
        _contentBGView.clipsToBounds = YES;
        _contentBGView.userInteractionEnabled = YES;
//
        
        [self addSubview:_contentBGView];
        
        _contentView = [[UIView alloc]initWithFrame:CGRectZero];
        _contentView.backgroundColor = [UIColor clearColor];
        [_contentBGView addSubview:_contentView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withShareList:(NSArray *)array
{
    self = [self initWithFrame:frame];
    if (self) {
        [_datasources addObjectsFromArray:array];
        [self buildUI];
    }
    return self;
}

- (void)buildUI
{
    for (int i = 0; i < _datasources.count ; i++ ) {
        ShareItem *item = _datasources[i];
        SharedMenuItemButton *btn = [[SharedMenuItemButton alloc]initWithFrame:CGRectZero andTitle:item.title andIcon:item.image];
        //        btn.userInteractionEnabled = NO;
        btn.exclusiveTouch = YES;
        [btn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        btn.btnindex = i;
        btn.shareType = item.shareType;
        [buttons_ addObject:btn];
        
        [_contentView addSubview:btn];
    }
}


//- (void)addMenuItemWithTitle:(NSString*)title andIcon:(UIImage*)icon andSelectedBlock:(ShareMenuViewSelectedBlock)block
//{
////    SharedMenuItemButton *button = [[SharedMenuItemButton alloc] initWithTitle:title andIcon:icon andSelectedBlock:block];
////    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
//
////    [_contentView addSubview:button];
//}

- (CGRect)frameForButtonAtIndex:(NSUInteger)index
{
    NSUInteger columnIndex =  index % SMColumnCount;
    
    NSUInteger rowIndex = index / SMColumnCount;
    
    //    CGFloat itemWidth = (300 - (SMColumnCount - 1) * SMHorizontalMargin)/SMColumnCount;
    CGFloat itemWidth = (kSCREEN_WIDTH-20 - (SMColumnCount - 1) * SMHorizontalMargin)/SMColumnCount;
    
    
    CGFloat itemHeight = SMImageHeight + SMItemTitleHeight;
    
    CGFloat offsetY = rowIndex*itemHeight + SMVerticalPadding*rowIndex;
    //  分享菜单偏左.2 (6&6+适配--A)
    //    CGFloat offsetX = columnIndex*itemWidth+SMHorizontalMargin*columnIndex + columnIndex * (kSCREEN_WIDTH - 320) / 5;
    CGFloat offsetX = columnIndex*itemWidth+SMHorizontalMargin*columnIndex;
    
    return CGRectMake(offsetX, offsetY, itemWidth, itemHeight);
    
}

- (IBAction)buttonTapped:(SharedMenuItemButton *)sender
{
    DLog(@"-----响应了 ");
    //    double delayInSeconds = SMAnimationTime  + SMAnimationInterval * (buttons_.count + 1);
    //    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    //    WEAKSELF
    //    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    //        sender.selectedBlock();
    //        STRONGSELF
    if (self.selectedBlock) {
        self.selectedBlock(@(sender.shareType));
    }
    [self dismiss:nil];
    //    });
    
}

- (void)show
{
    if (!_menuMode) {
        self.menuMode = MenuViewMode_FromBottom;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *appRootViewController;
        UIWindow *window;
        window = [UIApplication sharedApplication].keyWindow;
        appRootViewController = window.rootViewController;
        UIViewController *topViewController = appRootViewController;
        while (topViewController.presentedViewController != nil)
        {
            topViewController = topViewController.presentedViewController;
        }
        
        if ([topViewController.view viewWithTag:SMTag]) {
            [[topViewController.view viewWithTag:SMTag] removeFromSuperview];
        }
        self.frame = topViewController.view.bounds;
        if (_menuMode == MenuViewMode_FullScreen) {
            QBlurView *blurView = [[QBlurView alloc] initWithFrame:self.bounds];
            blurView.synchronized = YES;
            self.abview = blurView;
            [topViewController.view addSubview:blurView];
        }
        [topViewController.view addSubview:self];
        
        //改变contentview的frame
        NSUInteger rowCount = buttons_.count / SMColumnCount + (buttons_.count%SMColumnCount>0?1:0);
        CGFloat height = (SMImageHeight + SMItemTitleHeight) * rowCount + (rowCount > 1?(rowCount - 1) * SMHorizontalMargin:0);
        _contentBGView.frame = CGRectMake(0, kSCREEN_HEIGHT, kVIEW_W(self), height+topspace+SMBottomBarHeight);
        //    _contentView.frame =  CGRectMake(SMHorizontalMargin, SMTitleHeight, kVIEW_W(_contentBGView)-2*SMHorizontalMargin, height);
        _contentView.frame =  CGRectMake(SMHorizontalMargin, topspace, kVIEW_W(_contentBGView)-2*SMHorizontalMargin, height);
        //    _contentView.backgroundColor = [UIColor clearColor];
        bgview_.frame = CGRectMake(0, 0, kVIEW_W(self), kVIEW_H(self));
        bgview_.alpha = 0;
        control_.frame = bgview_.frame;
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kVIEW_W(_contentBGView), 40)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor darkTextColor];
        titleLabel.text = @"分享到";
        titleLabel.hidden = YES;
        titleLabel.font = [UIFont systemFontOfSize:17.f];
        [_contentBGView addSubview:titleLabel];
        
        [self addRemoveBtn];
        
        CGFloat lastOne = 0.f;
        for (int i = 0; i < buttons_.count; i++) {
            SharedMenuItemButton *button = buttons_[i];
            button.frame = [self frameForButtonAtIndex:i];
            if (_menuMode == MenuViewMode_FullScreen) {
                button.textColor = [UIColor darkTextColor];
                button.textFont = [UIFont systemFontOfSize:15.f];
            }
//            button.backgroundColor = [UIColor greenColor];
            lastOne = kVIEW_BX(button);
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            bgview_.alpha = 1;
            if (self.menuMode == MenuViewMode_FullScreen) {
                _contentBGView.frame = CGRectMake(0, kVIEW_H(self)-height-topspace-SMBottomBarHeight+49-150, kSCREEN_WIDTH, height+topspace+SMBottomBarHeight-49);

//                _contentBGView.frame = CGRectMake((kSCREEN_WIDTH-lastOne-10)/2, kVIEW_H(self)-height-topspace-SMBottomBarHeight+49-150, lastOne+10, height+topspace+SMBottomBarHeight-49);
            } else {
                _contentBGView.frame = CGRectMake(0, kVIEW_H(self)-height-topspace-SMBottomBarHeight, kVIEW_W(self), height+topspace+SMBottomBarHeight);
            }
            [self riseAnimation];
            if (self.menuMode == MenuViewMode_FullScreen) {
                dismissBtn_.transform = CGAffineTransformIdentity;
            }
            //        [self riseAnimation];
        } completion:^(BOOL finished) {
            if (self.menuMode == MenuViewMode_FullScreen) {
                if (!_startCenterX) {
                    dismissBtn_.frame = CGRectMake(0, kVIEW_H(self)-49, kSCREEN_WIDTH, 49);
                    return ;
                }
                [UIView animateWithDuration:0.25 animations:^{
                    dismissBtn_.frame = CGRectMake(0, kVIEW_H(self)-49, kSCREEN_WIDTH, 49);
                }];
            }
        }];
        
    });
}

- (void)addRemoveBtn
{
    if (!dismissBtn_) {
        UIButton *dissMissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        dissMissBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17.f];
        [dissMissBtn addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
        [dissMissBtn setTitleColor:K_COLOR_DARK forState:UIControlStateNormal];
        dismissBtn_ = dissMissBtn;
    }
    if (self.menuMode == MenuViewMode_FullScreen) {
        
        UIView *bgviewss = [[UIView alloc]initWithFrame:CGRectMake(0, kVIEW_H(self)-49, kSCREEN_WIDTH, 49)];
        bgviewss.backgroundColor = [UIColor whiteColor];
        [self addSubview:bgviewss];
//        _contentBGView.backgroundColor = [UIColor yellowColor];
        if (_startCenterX) {
            dismissBtn_.frame = CGRectMake(_startCenterX-(49/2), kVIEW_H(self)-49, 49, 49);
        } else {
            dismissBtn_.frame = CGRectMake((kSCREEN_WIDTH-49)/2, kVIEW_H(self)-49, 49, 49);
        }
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI/4.0);
        dismissBtn_.transform = transform;
        [self addSubview:dismissBtn_];
        [self bringSubviewToFront:dismissBtn_];
//        UIImageView *line = [UIImageView new];
//        line.frame = CGRectMake(0, kVIEW_H(self)-50, kSCREEN_WIDTH, 0.5);
//        line.image = [Util imageWithColor:kCOLOR_BORDER];
//        [self addSubview:line];
        [dismissBtn_ setBackgroundColor:[UIColor clearColor]];
        [dismissBtn_ setImage:kIMG(@"shouye_guanbi") forState:UIControlStateNormal];
    } else {
        [dismissBtn_ setTitle:@"取消" forState:UIControlStateNormal];
        dismissBtn_.frame = CGRectMake(0, kVIEW_H(_contentBGView)-49, kVIEW_W(_contentBGView), 49);
        [_contentBGView addSubview:dismissBtn_];
        dismissBtn_.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
        UIImageView *line = [UIImageView new];
        line.frame = CGRectMake(0, kVIEW_H(_contentBGView)-49, kVIEW_W(_contentBGView), 0.5);
        line.image = [Util imageWithColor:kCOLOR_BORDER];
        [_contentBGView addSubview:line];
    }
}


- (void)dismiss:(id)sender
{
    //    NSUInteger rowCount = buttons_.count / SMColumnCount + (buttons_.count%SMColumnCount>0?1:0);
    //    CGFloat height = (SMImageHeight + SMItemTitleHeight) * rowCount + (rowCount > 1?(rowCount - 1) * SMHorizontalMargin:0);
    [control_ removeFromSuperview];
    //    dismissBtn_.hidden = YES;
    //    [self dropAnimation];
    if (self.menuMode == MenuViewMode_FullScreen) {
        if (!_startCenterX) {
            dismissBtn_.frame = CGRectMake((kSCREEN_WIDTH-49)/2, kVIEW_H(self)-49, 49, 49);
            [self resetAnimation];
            return;
        }
        [UIView animateWithDuration:0.3 animations:^{
            if(_startCenterX) {
                dismissBtn_.frame = CGRectMake(_startCenterX-(49/2), kVIEW_H(self)-49, 49, 49);
            } else {
                dismissBtn_.frame = CGRectMake((kSCREEN_WIDTH-49)/2, kVIEW_H(self)-49, 49, 49);
            }
        } completion:^(BOOL finished) {
            [self resetAnimation];
            return ;
        }];
    } else {
        [self resetAnimation];
    }
}

- (void)resetAnimation
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (self.menuMode == MenuViewMode_FullScreen) {
            CGAffineTransform transform = CGAffineTransformMakeRotation(-M_PI/4.0);
            dismissBtn_.transform = transform;
        }
        //        [self dropAnimation];
        _contentBGView.frame = CGRectMake(0, kSCREEN_HEIGHT, kVIEW_W(self), _contentBGView.frame.size.height);
        //        UIImage *imagetm = kIMG(@"touming");
        //        [imagetm applyDarkEffect];
        //        _contentBGView.image = imagetm;
        bgview_.alpha = 0;
    } completion:^(BOOL finished) {
        if (self.menuMode == MenuViewMode_FromBottom) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShareCompleted" object:nil];
        }
        if (_abview) {
            [_abview removeFromSuperview];
        }
        [self removeFromSuperview];
    }];
}

- (void)riseAnimation
{
    for (NSUInteger index = 0; index < buttons_.count; index++) {
        SharedMenuItemButton *button = buttons_[index];
        button.layer.opacity = 0;
        CGRect frame = [self frameForButtonAtIndex:index];
        CGRect reletiveFrame = [self convertRect:frame toView:self];
//        if (_menuMode == MenuViewMode_FullScreen) {
//            frame = reletiveFrame;
//        }
        NSUInteger rowIndex = index / SMColumnCount;
        NSUInteger columnIndex = index % SMColumnCount;
        
        //        CGPoint fromPosition = CGPointMake(frame.origin.x + frame.size.width/2,frame.origin.y + frame.size.height/2+200-frame.size.height-frame.origin.y);
        CGPoint fromPosition = CGPointMake(frame.origin.x + frame.size.width/2,frame.origin.y + frame.size.height/2+400-frame.size.height-frame.origin.y);
        
        CGPoint toPosition = CGPointMake(frame.origin.x + frame.size.width/2, frame.origin.y + frame.size.height/2);
        
                double delayInSeconds = rowIndex * SMColumnCount * SMAnimationInterval+columnIndex * 0.15;
//        double delayInSeconds = rowIndex * SMColumnCount * SMAnimationInterval+columnIndex * 0.05;
        
        CABasicAnimation *positionAnimation;
        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:fromPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:toPosition];
        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.45f :1.2f :0.75f :1.0f];
        positionAnimation.duration = SMAnimationTime;
        positionAnimation.beginTime = [button.layer convertTime:CACurrentMediaTime() fromLayer:nil] + delayInSeconds;
        [positionAnimation setValue:[NSNumber numberWithUnsignedInteger:index] forKey:SMRriseAnimationID];
        positionAnimation.delegate = self;
        
        [button.layer addAnimation:positionAnimation forKey:@"riseAnimation"];
    }
}

- (void)dropAnimation
{
    NSUInteger rowCount = buttons_.count / SMColumnCount + (buttons_.count%SMColumnCount>0?1:0);
    for (int index = (int) buttons_.count-1; index >= 0; index--) {
        SharedMenuItemButton *button = buttons_[index];
        CGRect frame = [self frameForButtonAtIndex:index];
        NSUInteger rowIndex = index / SMColumnCount;
        NSUInteger columnIndex = index % SMColumnCount;
        CGPoint toPosition = CGPointMake(frame.origin.x + frame.size.width/2,frame.origin.y + frame.size.height/2+400-frame.size.height-frame.origin.y);
        CGPoint fromPosition = CGPointMake(frame.origin.x + frame.size.width/2, frame.origin.y + frame.size.height/2);
//        double delayInSeconds = (rowCount-1-rowIndex) * SMColumnCount * SMAnimationInterval+(SMColumnCount-1-columnIndex) * 0.03;
        double delayInSeconds = (rowCount-1-rowIndex) * SMColumnCount * SMAnimationInterval+(SMColumnCount-1-columnIndex) * 0.01;

        CABasicAnimation *positionAnimation;
        
        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:fromPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:toPosition];
        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.3 :0.5f :1.0f :1.0f];
        positionAnimation.duration = SMAnimationTime;
        positionAnimation.beginTime = [button.layer convertTime:CACurrentMediaTime() fromLayer:nil] + delayInSeconds;
        [positionAnimation setValue:[NSNumber numberWithUnsignedInteger:index] forKey:SMDismissAnimationID];
        positionAnimation.delegate = self;
        [button.layer addAnimation:positionAnimation forKey:@"dropAnimation"];
    }
}

- (void)animationDidStart:(CAAnimation *)anim
{
    if([anim valueForKey:SMRriseAnimationID]) {
        NSUInteger index = [[anim valueForKey:SMRriseAnimationID] unsignedIntegerValue];
        UIView *view = buttons_[index];
        CGRect frame = [self frameForButtonAtIndex:index];
        //        CGPoint toPosition = CGPointMake(frame.origin.x + frame.size.width/2, frame.origin.y + frame.size.height/2);
        CGPoint toPosition = CGPointMake(frame.origin.x + frame.size.width/2, frame.origin.y + frame.size.height/2);
        CGFloat toAlpha = 1.0;
        
        view.layer.position = toPosition;
        view.layer.opacity = toAlpha;
        
    }
    else if([anim valueForKey:SMDismissAnimationID]) {
        NSUInteger index = [[anim valueForKey:SMDismissAnimationID] unsignedIntegerValue];
        //        NSUInteger rowIndex = index / columnCount;
        UIView *view = buttons_[index];
        CGRect frame = [self frameForButtonAtIndex:index];
        CGPoint toPosition = CGPointMake(frame.origin.x + frame.size.width/2,frame.origin.y + frame.size.height/2+400-frame.size.height-frame.origin.y);
        
        view.layer.position = toPosition;
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
}

- (void)setSelectedBlock:(SelectedBlock)selectedBlock
{
    _selectedBlock = selectedBlock;
}

- (void)dealloc
{
    DLog(@"分享面板销毁了");
    self.selectedBlock = nil;
}

- (void)setMenuMode:(MenuViewMode)menuMode
{
    _menuMode = menuMode;
    switch (menuMode) {
        case MenuViewMode_FromBottom:
        {
            bgview_.backgroundColor = [UIColor colorWithRed:.0 green:.0 blue:.0 alpha:0.2];
            _contentBGView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.97];
            break;
        }
        case MenuViewMode_FullScreen:
        {
            bgview_.backgroundColor = kUIColorFromRGBWithTransparent(0xf3f3f3, 0.5);
            _contentBGView.backgroundColor = [UIColor clearColor];
            
//            bgview_.backgroundColor = [UIColor clearColor];
//            AMBlurView *blurView = [AMBlurView new];
//            blurView.blurTintColor = [UIColor redColor];
//            [blurView setFrame:bgview_.bounds];
//            [bgview_ addSubview:blurView];
//            [self addRemoveBtn];
//            AMBlurView *v = [[AMBlurView alloc]initWithFrame:bgview_.bounds];
//            v.tintColor = [UIColor whiteColor];
//            v.backgroundColor = [UIColor whiteColor];
//            [bgview_ insertSubview:v atIndex:0];
            break;
        }
        default:
            break;
    }
}
@end
