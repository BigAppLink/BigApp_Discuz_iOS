//
//  BannerCell.m
//  Clan
//
//  Created by chivas on 15/7/1.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "BannerCell.h"
#import "BannerModel.h"
#import "CustomHomeMode.h"
#import "UIView+Additions.h"
#import "PostDetailViewController.h"
#import "PostModel.h"
#import "PostViewController.h"
#import "ForumsModel.h"
#import "TOWebViewController.h"
#import "ArticleCustomViewController.h"
#import "ArticleDetailViewController.h"
#import "ArticleListModel.h"
#import "ArticleModel.h"
#import "PostDetailVC.h"
@implementation BannerCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setCustomHomeModel:(CustomHomeMode *)customHomeModel{
    _customHomeModel = customHomeModel;
    for (UIView *v in self.contentView.subviews) {
        [v removeFromSuperview];
    }
    [self imageScrollWithArray:_customHomeModel.banner];
}

#pragma mark - 轮播图
- (void)imageScrollWithArray:(NSArray *)array
{
    NSMutableArray *imageArray = [NSMutableArray array];
    NSMutableArray *titleArray = [NSMutableArray array];
    for (BannerModel *banner in array) {
        [imageArray addObject:banner.pic];
        [titleArray addObject:banner.title];
    }
    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kVIEW_H(self)) imageURLStringsGroup:imageArray];
    cycleScrollView.autoScrollTimeInterval = 5;
    cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    cycleScrollView.delegate = self;
    cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
    cycleScrollView.titlesGroup = titleArray;
    cycleScrollView.dotColor = [UIColor whiteColor];
    //    cycleScrollView2.placeholderImage = [UIImage imageNamed:@"placeholder"];
    [self.contentView addSubview:cycleScrollView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    BannerModel *banner = _customHomeModel.banner[index];
    if ([banner.type isEqualToString:@"1"]) {
        //跳webview
        TOWebViewController *web = [[TOWebViewController alloc]initWithURLString:banner.url];
        web.hidesBottomBarWhenPushed = YES;
        [self.additionsViewController.navigationController pushViewController:web animated:YES];
    }else if ([banner.type isEqualToString:@"2"]){
        //跳帖子详情
//        PostDetailViewController *detail = [[PostDetailViewController alloc]init];
//        PostModel *postModel = [PostModel new];
//        postModel.tid = banner.pid;
//        detail.postModel =  postModel;
//        detail.hidesBottomBarWhenPushed = YES;
//        [self.additionsViewController.navigationController pushViewController:detail animated:YES];
        PostDetailVC *detail = [[PostDetailVC alloc]init];
        PostModel *postModel = [PostModel new];
        postModel.tid = banner.pid;
        detail.postModel =  postModel;
        detail.hidesBottomBarWhenPushed = YES;
        [self.additionsViewController.navigationController pushViewController:detail animated:YES];
        
    }else if ([banner.type isEqualToString:@"3"]){
        //跳版块链接
        PostViewController *postVc = [[PostViewController alloc]init];
        ForumsModel *forumModel = [Util boardFormCache:banner.pid];
        if (!forumModel) {
            forumModel = [ForumsModel new];
        }
        forumModel.fid = banner.pid;
        postVc.hidesBottomBarWhenPushed = YES;
        postVc.forumsModel = forumModel;
        [self.additionsViewController.navigationController pushViewController:postVc animated:YES];
    }else if ([banner.type isEqualToString:@"4"]){
//        PostDetailVC *detail = [[PostDetailVC alloc]init];
//        detail.isArticle = YES;
//        PostModel *postModel = [PostModel new];
//        postModel.tid = banner.pid;
//        detail.postModel =  postModel;
//        detail.hidesBottomBarWhenPushed = YES;
//        [self.additionsViewController.navigationController pushViewController:detail animated:YES];
        ArticleDetailViewController *articleDetailVc = [[ArticleDetailViewController alloc]init];
        ArticleListModel *listModel = [ArticleListModel new];
        listModel.aid = banner.pid;
        articleDetailVc.articleModel = listModel;
        articleDetailVc.hidesBottomBarWhenPushed = YES;
        [self.additionsViewController.navigationController pushViewController:articleDetailVc animated:YES];
    }else if ([banner.type isEqualToString:@"5"]){
        ArticleCustomViewController *customVc = [[ArticleCustomViewController alloc]init];
        ArticleModel *articleModel = [ArticleModel new];
        articleModel.articleId = banner.pid;
        customVc.articleModel = articleModel;
        customVc.hidesBottomBarWhenPushed = YES;
        [self.additionsViewController.navigationController pushViewController:customVc animated:YES];
    }
}
@end
