//
//  ViewPagerController.m
//  CustomSliderTabbar
//
//  Created by wallstreetcn on 14-2-13.
//  Copyright (c) 2014年 wallstreetcn. All rights reserved.
//

#import "ViewPagerController.h"
#pragma mark - custom button
@interface MyButton : UIButton
{
    int index;
}
@property int index;
@end

@implementation MyButton
@synthesize index;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}
@end

#pragma mark - ViewPagerController.m
@interface ViewPagerController ()
{
    UIView *indicatorViewBg;
    UIView *indicatorView;
    UIScrollView *tagScroll;
    UIScrollView *contentScroll;
    int selectedIndex;
    CGFloat lastOffsetX;
    BOOL isTaped;
    CGFloat lastIndicatorX;
    NSMutableArray *_titleArray;
    NSMutableArray *_contentArray;
    UIScrollView *_scrollview;
}
@end

@implementation ViewPagerController

#pragma mark - viewController life cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadDatas];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    tagScroll.frame = CGRectMake(0, 0, kSCREEN_WIDTH, kTopSegmentBarHeight);
    CGSize size = tagScroll.contentSize;
    tagScroll.contentSize = CGSizeMake(size.width, kTopSegmentBarHeight);
    DLog(@"--- %@",NSStringFromCGSize(tagScroll.contentSize));
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    tagScroll.frame = CGRectMake(0, 0, kSCREEN_WIDTH, kTopSegmentBarHeight);
    CGSize size = tagScroll.contentSize;
    tagScroll.contentSize = CGSizeMake(size.width, kTopSegmentBarHeight);
    DLog(@"--- %@",NSStringFromCGSize(tagScroll.contentSize));
}

#pragma mark - init methods
-(void)drawView1
{
    UIButton *defaultBtn = nil;
    for (UIView *view in [self.view subviews]) {
        [view removeFromSuperview];
    }
//    CGRect rect = CGRectMake(0, 0, kSCREEN_WIDTH, kTopSegmentBarHeight);
//    if (self.dataSource && [self.dataSource respondsToSelector:@selector(frameForTopbar)]) {
//        rect = [self.dataSource frameForTopbar];
//    }
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kTopSegmentBarHeight)];
    tagScroll = sv;
    sv.scrollEnabled = YES;
    sv.backgroundColor = kUIColorFromRGB(0xF9F9F9);
    sv.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:sv];
    UIView *containerView = [[UIView alloc]initWithFrame:sv.bounds];
    [sv addSubview:containerView];
    
    UIView *seperator = [[UIView alloc]initWithFrame:CGRectMake(0, kVIEW_BY(sv), kSCREEN_WIDTH, 0.5)];
    seperator.backgroundColor = kUIColorFromRGB(0xEAF4F4);
    [self.view addSubview:seperator];
    CGPoint point = CGPointZero;
    CGFloat xOffset = 0;
    float eeeewidth = 0;
    if (_equelWidth) {
        eeeewidth = kSCREEN_WIDTH/_titleArray.count;
    }
    for (int i = 0; i < [_titleArray count]; i++) {
        NSString *strTitle = [_titleArray objectAtIndex:i];
        CGSize size = [strTitle sizeWithFont:kTitleFont constrainedToSize:CGSizeMake(kSCREEN_WIDTH, 20) lineBreakMode:NSLineBreakByWordWrapping];
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(xOffset, 0, size.width+kSpace, kTopSegmentBarHeight)];
        if (_equelWidth) {
            v.frame = CGRectMake(xOffset, 0, eeeewidth, kTopSegmentBarHeight);
        }
        v.tag = kTagBgView+i;
        [containerView addSubview:v];
        UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake((kVIEW_W(v)-size.width)/2, 0, size.width, v.frame.size.height)];
        lb.font = kTitleFont;
        lb.tag = kTagLb+i;
        lb.backgroundColor = kCLEARCOLOR;
        lb.textAlignment = NSTextAlignmentCenter;
        if (i == selectedIndex) {
            //初始位置
            lastIndicatorX = (kVIEW_W(v)-size.width)/2;
            if (_equelWidth) {
                lastIndicatorX = kVIEW_TX(v);
            }
            //            [lb convertRect:lb.bounds toView:[v superview]];
            point = [lb convertPoint:lb.bounds.origin toView:sv];
            lb.textColor= kTitleColorH;
        }
        else {
            lb.textColor = kTitleColorN;
        }
        lb.text = strTitle;
        [v addSubview:lb];
        MyButton *btn = [MyButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, v.frame.size.width, v.frame.size.height);
        btn.index = i;
        btn.tag = kTagButton+i;
        btn.backgroundColor = kCLEARCOLOR;
        btn.exclusiveTouch = YES;
        [btn addTarget:self action:@selector(clickTopBar:) forControlEvents:UIControlEventTouchUpInside];
        [v addSubview:btn];
        xOffset = v.frame.origin.x+v.frame.size.width;
        if (i == selectedIndex) {
            defaultBtn = btn;
        }
    }
    containerView.frame = CGRectMake(0,0,xOffset, kTopSegmentBarHeight);
    sv.contentSize = CGSizeMake(xOffset, kTopSegmentBarHeight);
    //指示条
    NSString *title = @"测试";
    if (_titleArray.count > selectedIndex) {
        title = [_titleArray objectAtIndex:selectedIndex];
    }
    CGSize indicatorSize = [title sizeWithFont:kTitleFont constrainedToSize:CGSizeMake(260, 20) lineBreakMode:NSLineBreakByClipping];
    UIView *indicatorV = [[UIView alloc] initWithFrame:CGRectMake(point.x, kTopSegmentBarHeight-3, indicatorSize.width, 3)];
    if (_equelWidth) {
        indicatorV.frame = CGRectMake(selectedIndex*eeeewidth, kTopSegmentBarHeight-3, eeeewidth, 3);
    }
    indicatorView = indicatorV;
    indicatorV.backgroundColor = kIndicatorColor;
    [containerView addSubview:indicatorV];
    CGRect contentRect = CGRectMake(0, kVIEW_BY(seperator), kSCREEN_WIDTH, kSCREEN_HEIGHT-kVIEW_BY(seperator));
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(frameForContentView)]) {
        contentRect = [self.dataSource frameForContentView];
    }
    contentScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kTopSegmentBarHeight, kSCREEN_WIDTH, kSCREEN_HEIGHT-64-kTopSegmentBarHeight)];
    contentScroll.pagingEnabled = YES;
    contentScroll.delegate = self;
    [self.view addSubview:contentScroll];
    for (int i = 0; i < [_titleArray count]; i++) {
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(viewPager:viewForTabAtIndex:)]) {
            UIView *view = [self.dataSource viewPager:self viewForTabAtIndex:i];
            if (!view) {
                view = [[UIView alloc]init];
            }
            view.tag = i + kTagContentView;
            view.frame = CGRectMake(kSCREEN_WIDTH*i, 0, kSCREEN_WIDTH, kVIEW_H(contentScroll));
            [contentScroll addSubview:view];
        } else {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(kSCREEN_WIDTH*i, 0, kSCREEN_WIDTH, kVIEW_H(contentScroll))];
            view.tag = i + kTagContentView;
            [contentScroll addSubview:view];
        }
    }
    UIView *lineview = [[UIView alloc]initWithFrame:CGRectMake(0, kTopSegmentBarHeight-0.5, kSCREEN_WIDTH, 0.5)];
    lineview.backgroundColor = kUIColorFromRGB(0xe5e5e5);
    [self.view addSubview:lineview];
    contentScroll.contentSize = CGSizeMake(kSCREEN_WIDTH*[_titleArray count], contentScroll.frame.size.height);
    contentScroll.showsHorizontalScrollIndicator = NO;
    if (defaultBtn) {
        [self clickTopBar:defaultBtn];
    }
}

#pragma mark - custom methods
- (void)changeTagState:(int)tagIndex
{
    if (tagIndex == selectedIndex) {
    }
    else {
        [self changeTagColor:tagIndex];
        [self selectTag:tagIndex];
    }
    selectedIndex = tagIndex;
    lastOffsetX = contentScroll.contentOffset.x;
    lastIndicatorX = indicatorView.frame.origin.x;
}

- (void)changeTagColor:(int)tagIndex
{
    UIView *currV = (UIView *)[tagScroll viewWithTag:kTagBgView+tagIndex];
    UIView *lastV = (UIView *)[tagScroll viewWithTag:kTagBgView+selectedIndex];
    UILabel *currLb = (UILabel *)[currV viewWithTag:kTagLb+tagIndex];
    UILabel *lastLb = (UILabel *)[lastV viewWithTag:kTagLb+selectedIndex];
    currLb.textColor = kTitleColorH;
    lastLb.textColor = kTitleColorN;
    //通知view 消失还是显示
    [self doViewAppear:tagIndex];
    [self doViewDisappear:selectedIndex];
}

- (void)selectTag:(int)tagIndex
{
    UIView *v = (UIView *)[tagScroll viewWithTag:kTagBgView+tagIndex];
    if (tagIndex == 0) {
        [tagScroll setContentOffset:CGPointMake(0, 0) animated:YES];
    } else if (tagIndex == [_titleArray count]-1) {
        if (tagScroll.contentSize.width-tagScroll.frame.size.width > 0) {
            [tagScroll setContentOffset:CGPointMake(tagScroll.contentSize.width-tagScroll.frame.size.width, 0) animated:YES];
        }
    } else {
        NSString *frontStr = [_titleArray objectAtIndex:tagIndex-1];
        CGSize frontSize = [frontStr sizeWithFont:kTitleFont constrainedToSize:CGSizeMake(260, 20) lineBreakMode:NSLineBreakByWordWrapping];
        NSString *behindStr = [_titleArray objectAtIndex:tagIndex+1];
        CGSize behindSize = [behindStr sizeWithFont:kTitleFont constrainedToSize:CGSizeMake(260, 20) lineBreakMode:NSLineBreakByWordWrapping];
        //如果前端有未显示完的tag，点击此tag或者此tag后的tag，scroll都滑到点击的tag的前一个tag的位置
        if (v.frame.origin.x-frontSize.width-kSpace < tagScroll.contentOffset.x) {
            [tagScroll setContentOffset:CGPointMake(v.frame.origin.x-frontSize.width-kSpace, 0) animated:YES];
        } else if(v.frame.origin.x+v.frame.size.width+behindSize.width+kSpace > tagScroll.contentOffset.x+tagScroll.frame.size.width) {
            //如果后端有未显示完的tag，点击此tag或者此tag前的tag，scroll都滑到能显示完此tag后一个tag的位置
            [tagScroll setContentOffset:CGPointMake(v.frame.origin.x+v.frame.size.width+behindSize.width+kSpace-tagScroll.frame.size.width, 0) animated:YES];
        } else { }
    }
}

#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //    AppDelegate *dele = [AppDelegate sharedAppDelegate];
    if (!isTaped) {
        if (scrollView.contentOffset.x > lastOffsetX) {//向左滑动
            if (selectedIndex == [_titleArray count]-1) {
                
            } else {
                NSString *behindStr = [_titleArray objectAtIndex:selectedIndex+1];
                CGSize behindSize = [behindStr sizeWithFont:kTitleFont constrainedToSize:CGSizeMake(260, 20) lineBreakMode:NSLineBreakByWordWrapping];
                NSString *currentStr = [_titleArray objectAtIndex:selectedIndex];
                CGSize currentSize = [currentStr sizeWithFont:kTitleFont constrainedToSize:CGSizeMake(260, 20) lineBreakMode:NSLineBreakByWordWrapping];
                CGFloat dValue = scrollView.contentOffset.x-lastOffsetX;
                if (_equelWidth) {
                    behindSize.width = kSCREEN_WIDTH/_titleArray.count;
                    currentSize.width = kSCREEN_WIDTH/_titleArray.count;
                    indicatorView.frame = CGRectMake(lastIndicatorX+(currentSize.width)*(dValue/kSCREEN_WIDTH), indicatorView.frame.origin.y, kSCREEN_WIDTH/_titleArray.count, indicatorView.frame.size.height);
                } else {
                    indicatorView.frame = CGRectMake(lastIndicatorX+(currentSize.width+kSpace)*(dValue/kSCREEN_WIDTH), indicatorView.frame.origin.y, currentSize.width+(behindSize.width-currentSize.width)*(dValue/kSCREEN_WIDTH), indicatorView.frame.size.height);
                }
            }
        }
        else if(scrollView.contentOffset.x < lastOffsetX){//向右滑动
            if (selectedIndex == 0) {
                
            } else {
                NSString *frontStr = [_titleArray objectAtIndex:selectedIndex-1];
                CGSize frontSize = [frontStr sizeWithFont:kTitleFont constrainedToSize:CGSizeMake(260, 20) lineBreakMode:NSLineBreakByWordWrapping];
                NSString *currentStr = [_titleArray objectAtIndex:selectedIndex];
                CGSize currentSize = [currentStr sizeWithFont:kTitleFont constrainedToSize:CGSizeMake(260, 20) lineBreakMode:NSLineBreakByWordWrapping];
                CGFloat dValue = -scrollView.contentOffset.x+lastOffsetX;
                if (_equelWidth) {
                    frontSize.width = kSCREEN_WIDTH/_titleArray.count;
                    currentSize.width = kSCREEN_WIDTH/_titleArray.count;
                    indicatorView.frame = CGRectMake(lastIndicatorX-(frontSize.width)*(dValue/kSCREEN_WIDTH), indicatorView.frame.origin.y, kSCREEN_WIDTH/_titleArray.count, indicatorView.frame.size.height);
                } else {
                    indicatorView.frame = CGRectMake(lastIndicatorX-(frontSize.width+kSpace)*(dValue/kSCREEN_WIDTH), indicatorView.frame.origin.y, currentSize.width+(frontSize.width-currentSize.width)*(dValue/kSCREEN_WIDTH), indicatorView.frame.size.height);
                }
            }
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    isTaped = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int temp = scrollView.contentOffset.x/kSCREEN_WIDTH;
    //    [self changeTagState:temp];
    UIView *v = [tagScroll viewWithTag:temp + kTagBgView];
    MyButton *button = (MyButton *)[v viewWithTag:temp+kTagButton];
    [self clickTopBar:button];
}

#pragma mark - Quote View delegate
-(void)didSelectedSysmbol
{
    [self performSegueWithIdentifier:@"toQuoteDetail" sender:nil];
}

#pragma mark - 事件方法

- (void)clickTopBar:(id)sender
{
    isTaped = YES;
    MyButton *btn = (MyButton *)sender;
    UIView *v = [btn superview];
    NSString *str = [_titleArray objectAtIndex:btn.index];
    UILabel *lb = (UILabel *) [v viewWithTag:(kTagLb + btn.index)];
    CGRect rect = [lb convertRect:lb.bounds toView:[v superview]];
    CGSize size = [str sizeWithFont:kTitleFont constrainedToSize:CGSizeMake(260, 20) lineBreakMode:NSLineBreakByWordWrapping];
    if (_equelWidth) {
        [UIView animateWithDuration:.2 animations:^{
            indicatorView.frame = CGRectMake(v.frame.origin.x, indicatorView.frame.origin.y, v.frame.size.width, indicatorView.frame.size.height);
        }];
    } else {
        
        [UIView animateWithDuration:.2 animations:^{
            indicatorView.frame = CGRectMake(rect.origin.x, indicatorView.frame.origin.y, size.width, indicatorView.frame.size.height);
        }];
    }
    [contentScroll setContentOffset:CGPointMake(kSCREEN_WIDTH*btn.index, 0) animated:NO];
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewPager:didChangeTabToIndex:)]) {
        [self.delegate viewPager:self didChangeTabToIndex:btn.index];
    }
    [self changeTagState:btn.index];
}

#pragma mark - view appear & view disappear
-(void)doViewAppear:(int)index
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewPager:viewAppearAtIndex:)]) {
        [self.delegate viewPager:self viewAppearAtIndex:index];
    }
}

-(void)doViewDisappear:(int)index
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewPager:viewDisappearAtIndex:)]) {
        [self.delegate viewPager:self viewDisappearAtIndex:index];
    }
}

#pragma mark - public methods reload data
-(void)reloadDatas
{
    selectedIndex = 0;
    lastOffsetX = 0.0;
    lastIndicatorX = 0.0;
    if (!_titleArray) {
        _titleArray = [[NSMutableArray alloc]initWithCapacity:0];
    }
    NSArray *array = nil;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(titleArrayForViewPager:)]) {
        array = [self.dataSource titleArrayForViewPager:self];
        if (array && array.count > 0) {
            [_titleArray removeAllObjects];
            [_titleArray addObjectsFromArray:array];
        }
    }
    if (_titleArray.count == 0) {
        return;
    }
    [self drawView1];
}
@end
