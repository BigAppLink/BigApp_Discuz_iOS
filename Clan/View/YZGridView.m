//
//  YZGridView.m
//  Clan
//
//  Created by 昔米 on 15/7/4.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "YZGridView.h"
#import "LinkModel.h"
#import "ItemView.h"
#import "UIImageView+MJWebCache.h"
#import "TOWebViewController.h"
#import "PostDetailViewController.h"
#import "PostViewController.h"
#import "ForumsModel.h"
#import "UIView+Additions.h"
#import "TAPageControl.h"
#import "ArticleDetailViewController.h"
#import "ArticleCustomViewController.h"
#import "ArticleModel.h"
#import "ArticleListModel.h"
#import "PostDetailVC.h"
static const CGFloat itemWidth = 93.f;
static const CGFloat itemHeight = 90.f;




@implementation YZGridView

- (void)setCustomHomeModel:(CustomHomeMode *)customHomeModel
{
    _customHomeModel = customHomeModel;
    BOOL isCenter = NO;
    self.linenum = 2;
    self.perline = kSCREEN_WIDTH/itemWidth;
    if (!_views) {
        _views = [NSMutableArray new];
    }
    for (UIView *v in self.subviews) {
        [v removeFromSuperview];
    }
    for (UIView *v in _scroll.subviews) {
        [v removeFromSuperview];
    }
    _scroll = nil;
    _pageControl = nil;
    if (!_scroll) {
        _scroll = [[UIScrollView alloc]init];
        _scroll.delegate = self;
        [self addSubview:_scroll];
    }
    _scroll.showsHorizontalScrollIndicator = NO;
    //6个为1页 页数 = （总个数 + 每页最大显示个数 - 1） / 每页显示最大的个数
    int perpage = _perline*_linenum;
    int page = ((int)_customHomeModel.link.count + perpage - 1) / perpage;
    if (page > 1) {
        _scroll.pagingEnabled = YES;
    } else {
        _scroll.pagingEnabled = NO;
    }
    CGRect rect = self.frame;
    rect.size.width = kSCREEN_WIDTH;
    if (!_customHomeModel.link || _customHomeModel.link.count==0) {
        rect.size.height = 0;
    } else {
        if (_customHomeModel.link.count <= _perline) {
            //单行
            isCenter = YES;
            rect.size.height = itemHeight;
        } else {
            //两行
            isCenter = NO;
            rect.size.height = itemHeight*_linenum+20;
        }
    }
    self.frame = rect;
    if (page > 1 ) {
        _scroll.frame = CGRectMake(0, 0, kVIEW_W(self), kVIEW_H(self)-20);
        if (!_pageControl) {
            TAPageControl *pageControl = [[TAPageControl alloc] initWithFrame:CGRectMake(0, kVIEW_H(self)-20, kVIEW_W(self), 20)];
            pageControl.numberOfPages = page;
            pageControl.dotColor = [UIColor lightGrayColor];
            pageControl.dotSize = CGSizeMake(4, 4);
            pageControl.spacingBetweenDots = 8;
            _pageControl = pageControl;
            [self addSubview:pageControl];
        }
    } else {
        _scroll.frame = CGRectMake(0, 0, kVIEW_W(self), kVIEW_H(self));
    }
    
    self.backgroundColor = [UIColor clearColor];
    for (int i = 0; i < page; i ++) {
        UIView *view_c = [UIView new];
        view_c.tag = 1000+i;
        view_c.backgroundColor = [UIColor clearColor];
        view_c.frame = CGRectMake(i*kVIEW_W(self), 0, kVIEW_W(self), kVIEW_H(self));
        [_scroll addSubview:view_c];
    }
    [_scroll setContentSize:CGSizeMake(page*kSCREEN_WIDTH, kVIEW_H(_scroll))];

    float margin_h = (kSCREEN_WIDTH-_perline*itemWidth)/2;
    for (int index = 0; index < _customHomeModel.link.count; index++) {
        LinkModel *link = _customHomeModel.link[index];
        int page_location = index/perpage;
        int loaction_inpage = index%perpage;
        UIView *superview = [self viewWithTag:1000+page_location];
        int row = loaction_inpage/_perline;//行号
        int loc = loaction_inpage%_perline;//列号
        ItemView *itemView = nil;
        if (isCenter) {
            int spcae_c = (kSCREEN_WIDTH>320) ? 20 : 15;
            int margin_c = (kSCREEN_WIDTH-_customHomeModel.link.count*itemWidth-(_customHomeModel.link.count-1)*spcae_c)/2;
            if (margin_c < 0) {
                itemView = [[ItemView alloc]initWithFrame:CGRectMake(margin_h+itemWidth*loc, row==0?0:itemHeight, itemWidth, itemHeight)];
            } else {
                itemView = [[ItemView alloc]initWithFrame:CGRectMake(margin_c+loc*itemWidth+spcae_c*loc, 0, itemWidth, itemHeight)];
            }
        } else {
            itemView = [[ItemView alloc]initWithFrame:CGRectMake(margin_h+itemWidth*loc, row==0?0:itemHeight, itemWidth, itemHeight)];
        }

        itemView.backgroundColor = [UIColor clearColor];
        itemView.tag = 100+loaction_inpage;
        itemView.linkmodel = link;
        itemView.title.text = link.title;
        [itemView.item setImageURL:[NSURL URLWithString:link.pic] placeholder:[UIImage imageNamed:@"board_icon"]];
        DLog(@"----- %@  图片是： %@", link.title,link.pic);
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectLinkView:)];
        [itemView addGestureRecognizer:tap];
        [superview addSubview:itemView];
    }
    [self addBottomLine];
}


- (void)selectLinkView:(UITapGestureRecognizer *)tap
{
    UIView *tagView = tap.view;
    if (![tagView isKindOfClass:[ItemView class]]) {
        return;
    }
    ItemView *itemview = (ItemView *)tagView;
    LinkModel *link = itemview.linkmodel;
    if (!link.type || link.type.length == 0) {
        return;
    }
    if ([link.type isEqualToString:@"1"]) {
        //跳webview
        TOWebViewController *web = [[TOWebViewController alloc]initWithURLString:link.url];
        web.hidesBottomBarWhenPushed = YES;
        [self.additionsViewController.navigationController pushViewController:web animated:YES];
    }else if ([link.type isEqualToString:@"2"]){
        //跳帖子详情
//        PostDetailViewController *detail = [[PostDetailViewController alloc]init];
        PostDetailVC *detail = [[PostDetailVC alloc]init];
        PostModel *postModel = [PostModel new];
        postModel.tid = link.pid;
        detail.postModel =  postModel;
        detail.hidesBottomBarWhenPushed = YES;
        [self.additionsViewController.navigationController pushViewController:detail animated:YES];
    }else if ([link.type isEqualToString:@"3"]){
        //跳版块链接
        PostViewController *postVc = [[PostViewController alloc]init];
        ForumsModel *forumModel = [Util boardFormCache:link.pid];
        if (!forumModel) {
            forumModel = [ForumsModel new];
        }
        forumModel.fid = link.pid;
        postVc.hidesBottomBarWhenPushed = YES;
        postVc.forumsModel = forumModel;
        [self.additionsViewController.navigationController pushViewController:postVc animated:YES];
    }else if ([link.type isEqualToString:@"4"]){
//        PostDetailVC *detail = [[PostDetailVC alloc]init];
//        detail.isArticle = YES;
//        PostModel *postModel = [PostModel new];
//        postModel.tid = link.pid;
//        detail.postModel =  postModel;
//        detail.hidesBottomBarWhenPushed = YES;
//        [self.additionsViewController.navigationController pushViewController:detail animated:YES];
        ArticleDetailViewController *articleDetailVc = [[ArticleDetailViewController alloc]init];
        ArticleListModel *listModel = [ArticleListModel new];
        listModel.aid = link.pid;
        articleDetailVc.articleModel = listModel;
        articleDetailVc.hidesBottomBarWhenPushed = YES;
        [self.additionsViewController.navigationController pushViewController:articleDetailVc animated:YES];
    }else if ([link.type isEqualToString:@"5"]){
        ArticleCustomViewController *customVc = [[ArticleCustomViewController alloc]init];
        ArticleModel *articleModel = [ArticleModel new];
        articleModel.articleId = link.pid;
        customVc.articleModel = articleModel;
        customVc.hidesBottomBarWhenPushed = YES;
        [self.additionsViewController.navigationController pushViewController:customVc animated:YES];
    }

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int itemIndex = _scroll.contentOffset.x / kVIEW_W(_scroll);
    if (_pageControl) {
        _pageControl.currentPage = itemIndex;
    }
}

- (void)addBottomLine
{
    UIImageView *bottonLine = [self viewWithTag:8877];
    if (!bottonLine) {
        bottonLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, kVIEW_H(self)-0.5, kSCREEN_WIDTH,0.5)];
        bottonLine.tag = 8877;
        [self addSubview:bottonLine];
    }
    bottonLine.frame = CGRectMake(0, kVIEW_H(self)-0.5, kSCREEN_WIDTH,0.5);
    bottonLine.image = [Util imageWithColor:K_COLOR_MOST_LIGHT_GRAY];
    [self bringSubviewToFront:bottonLine];

}
@end
