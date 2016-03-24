//
//  PostingMenuVC.m
//  Clan
//
//  Created by 昔米 on 15/11/26.
//  Copyright © 2015年 Youzu. All rights reserved.
//

#import "PostingMenuVC.h"
#import "YZButton.h"
#import "SharedMenuItemButton.h"

@interface PostingMenuVC ()
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) NSMutableArray *buttons;

@end


@implementation PostingMenuVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadModel];
    [self buildUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    DLog(@"PostingMenuVC 销毁了");
}

#pragma mark - 初始化
- (void)loadModel
{
    self.buttons = [[NSMutableArray alloc]initWithCapacity:_lists.count];
}

- (void)buildUI
{
    self.view.backgroundColor = kCLEARCOLOR;
    UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT)];
    contentView.backgroundColor = [UIColor yellowColor];
    _contentView.alpha = 0;
    self.contentView = contentView;
    [self.view addSubview:contentView];
    
    for (int i = 0; i < _lists.count ; i++ ) {
        NSDictionary *item = _lists[i];
        SharedMenuItemButton *btn = [[SharedMenuItemButton alloc]initWithFrame:CGRectZero andTitle:item[@"title"] andIcon:item[@"image"]];
        btn.exclusiveTouch = YES;
//        [btn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        btn.btnindex = i;
        [_buttons addObject:btn];
        [_contentView addSubview:btn];
    }
}

//- (CGRect)frameForButtonAtIndex:(NSUInteger)index
//{
//    NSUInteger columnIndex =  index % SMColumnCount;
//    
//    NSUInteger rowIndex = index / SMColumnCount;
//    
//    //    CGFloat itemWidth = (300 - (SMColumnCount - 1) * SMHorizontalMargin)/SMColumnCount;
//    CGFloat itemWidth = (kSCREEN_WIDTH-20 - (SMColumnCount - 1) * SMHorizontalMargin)/SMColumnCount;
//    
//    
//    CGFloat itemHeight = SMImageHeight + SMItemTitleHeight;
//    
//    CGFloat offsetY = rowIndex*itemHeight + SMVerticalPadding*rowIndex;
//    //  分享菜单偏左.2 (6&6+适配--A)
//    //    CGFloat offsetX = columnIndex*itemWidth+SMHorizontalMargin*columnIndex + columnIndex * (kSCREEN_WIDTH - 320) / 5;
//    CGFloat offsetX = columnIndex*itemWidth+SMHorizontalMargin*columnIndex;
//    
//    return CGRectMake(offsetX, offsetY, itemWidth, itemHeight);
//    
//}

@end
