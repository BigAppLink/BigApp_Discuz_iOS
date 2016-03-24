//
//  BaseSegmentViewController.m
//  Clan
//
//  Created by chivas on 15/3/16.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "BaseSegmentViewController.h"
#import "SegmentView.h"
#import "CollectionViewController.h"
#import "YZCardView.h"
static float topbar_height = 44.f;

@interface BaseSegmentViewController ()
{
    NSMutableArray *_childViewControllers;
}
@end

@implementation BaseSegmentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"我的收藏";
    //设置segment
    [self initSegment];
}

- (void)initSegment
{
    YZCardView *card = [[YZCardView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, topbar_height)];
    card.target = self;
    [card addCardWithTitle:@"帖子收藏" withSel:@selector(changeToPostCOll)];
    [card addCardWithTitle:@"版块收藏" withSel:@selector(changeToFormColl)];
    [card addCardWithTitle:@"文章收藏" withSel:@selector(changeToArticleColl)];
    [self.view addSubview:card];
    
    _childViewControllers = [NSMutableArray new];
    //帖子收藏
    CollectionViewController *postCollection = [[CollectionViewController alloc]init];
    postCollection.collcetionType = myPost;
    postCollection.target = self;
    [_childViewControllers addObject:postCollection];
    
    //板块收藏
    CollectionViewController *plate = [[CollectionViewController alloc]init];
    plate.collcetionType = myPlate;
    plate.target = self;
    [_childViewControllers addObject:plate];
    
    //板块收藏
    CollectionViewController *article = [[CollectionViewController alloc]init];
    article.collcetionType = myArticle;
    article.target = self;
    [_childViewControllers addObject:article];
    
    [self changeToPostCOll];
    if (self.selectedIndex) {
        [card changeSelectBtn:_selectedIndex];
    }
}

#pragma mark - action 事件
- (void)changeToPostCOll
{
    [[NSUserDefaults standardUserDefaults] setObject:@(myPost) forKey:@"user_FAVOTYPE"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    CollectionViewController *vcpost = _childViewControllers[0];
    [self addChildViewController:vcpost];
    [self.view addSubview:vcpost.view];
    vcpost.view.frame = CGRectMake(0, topbar_height, kSCREEN_WIDTH, kSCREEN_HEIGHT-topbar_height-64);
    [vcpost setUpNavi];
    
    UIViewController *vc = _childViewControllers[1];
    [vc.view removeFromSuperview];
    [vc removeFromParentViewController];
    UIViewController *vc2 = _childViewControllers[2];
    [vc2.view removeFromSuperview];
    [vc2 removeFromParentViewController];
    
}

- (void)changeToFormColl
{
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"S_FAVOTYPE_PLATE"];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:@(myPlate) forKey:@"user_FAVOTYPE"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    CollectionViewController *vc = _childViewControllers[1];
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    vc.view.frame = CGRectMake(0, topbar_height, kSCREEN_WIDTH, kSCREEN_HEIGHT-topbar_height-64);
    [vc setUpNavi];
    
    UIViewController *vc0 = _childViewControllers[0];
    [vc0.view removeFromSuperview];
    [vc0 removeFromParentViewController];
    UIViewController *vc2 = _childViewControllers[2];
    [vc2.view removeFromSuperview];
    [vc2 removeFromParentViewController];
}

- (void)changeToArticleColl
{
    [[NSUserDefaults standardUserDefaults] setObject:@(myArticle) forKey:@"user_FAVOTYPE"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    CollectionViewController *vc = _childViewControllers[2];
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    vc.view.frame = CGRectMake(0, topbar_height, kSCREEN_WIDTH, kSCREEN_HEIGHT-topbar_height-64);
    [vc setUpNavi];
    
    UIViewController *vc1 = _childViewControllers[1];
    [vc1.view removeFromSuperview];
    [vc1 removeFromParentViewController];
    UIViewController *vc2 = _childViewControllers[0];
    [vc2.view removeFromSuperview];
    [vc2 removeFromParentViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc
{
    for (int i = 0; i < _childViewControllers.count; i++) {
        UIViewController *vc = _childViewControllers[i];
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
        [_childViewControllers removeObject:vc];
        vc = nil;
    }
    _childViewControllers = nil;
    DLog(@"base 收藏dealooc");
    [[NSNotificationCenter defaultCenter]removeObserver:self name:KDone_TableView object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:KDone_TableView object:nil];
}

@end
