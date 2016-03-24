//
//  ForumCell.m
//  Clan
//
//  Created by chivas on 15/7/2.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ForumCell.h"
#import "ForumModel.h"
#import "UIView+Additions.h"
#import "PostDetailViewController.h"
#import "PostModel.h"
#import "PostViewController.h"
#import "ForumsModel.h"
#import "TOWebViewController.h"
#import "ArticleDetailViewController.h"
#import "ArticleCustomViewController.h"
#import "ArticleModel.h"
#import "ArticleListModel.h"
#import "PostDetailVC.h"
@implementation ForumCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setForumArray:(NSArray *)forumArray
{
    _forumArray = forumArray;
    ForumModel *model1 = forumArray[0];
    _titleLabel1.text = model1.title;
    _desLabel1.text = model1.desc;
    _imageView1.layer.cornerRadius = 44/2;
    _imageView1.contentMode = UIViewContentModeScaleAspectFill;
    _imageView1.clipsToBounds = YES;
    _imageView2.layer.cornerRadius = 44/2;
    _imageView2.contentMode = UIViewContentModeScaleAspectFill;
    _imageView2.clipsToBounds = YES;
    [_imageView1 sd_setImageWithURL:[NSURL URLWithString:model1.pic] placeholderImage:[UIImage imageNamed:@"board_icon"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    _view1.tag = 100;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectForumView:)];
    [_view1 addGestureRecognizer:tap];
    if (forumArray.count > 1) {
        ForumModel *model2 = forumArray[1];
        _view2.tag = 101;
        _titleLabel2.text = model2.title;
        _desLabel2.text = model2.desc;
        [_imageView2 sd_setImageWithURL:[NSURL URLWithString:model2.pic] placeholderImage:nil];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectForumView:)];
        [_view2 addGestureRecognizer:tap];

    }
    _view2.hidden = forumArray.count < 2;
}


- (void)selectForumView:(UITapGestureRecognizer *)tap
{
    UIView *tagView = tap.view;
    ForumModel *forumMOdel = _forumArray[tagView.tag - 100];
    if ([forumMOdel.type isEqualToString:@"1"]) {
        //跳webview
        TOWebViewController *web = [[TOWebViewController alloc]initWithURLString:forumMOdel.url];
        web.hidesBottomBarWhenPushed = YES;
        [self.additionsViewController.navigationController pushViewController:web animated:YES];
    }
    else if ([forumMOdel.type isEqualToString:@"2"]){
        //跳帖子详情 for test
        PostDetailVC *detail = [[PostDetailVC alloc]init];
        PostModel *postModel = [PostModel new];
        postModel.tid = forumMOdel.pid;
        detail.postModel =  postModel;
        detail.hidesBottomBarWhenPushed = YES;
        [self.additionsViewController.navigationController pushViewController:detail animated:YES];
    }
    else if ([forumMOdel.type isEqualToString:@"3"]){
        //跳版块链接
        PostViewController *postVc = [[PostViewController alloc]init];
        ForumsModel *forumModel = [Util boardFormCache:forumMOdel.pid];
        if (!forumModel) {
            forumModel = [ForumsModel new];
        }
        forumModel.fid = forumMOdel.pid;
        postVc.hidesBottomBarWhenPushed = YES;
        postVc.forumsModel = forumModel;
        [self.additionsViewController.navigationController pushViewController:postVc animated:YES];
    }else if ([forumMOdel.type isEqualToString:@"4"]){
        
//        PostDetailVC *detail = [[PostDetailVC alloc]init];
//        detail.isArticle = YES;
//        PostModel *postModel = [PostModel new];
//        postModel.tid = forumMOdel.pid;
//        detail.postModel =  postModel;
//        detail.hidesBottomBarWhenPushed = YES;
//        [self.additionsViewController.navigationController pushViewController:detail animated:YES];
        ArticleDetailViewController *articleDetailVc = [[ArticleDetailViewController alloc]init];
        ArticleListModel *listModel = [ArticleListModel new];
        listModel.aid = forumMOdel.pid;
        articleDetailVc.articleModel = listModel;
        articleDetailVc.hidesBottomBarWhenPushed = YES;
        [self.additionsViewController.navigationController pushViewController:articleDetailVc animated:YES];
    }else if ([forumMOdel.type isEqualToString:@"5"]){
        ArticleCustomViewController *customVc = [[ArticleCustomViewController alloc]init];
        ArticleModel *articleModel = [ArticleModel new];
        articleModel.articleId = forumMOdel.pid;
        customVc.articleModel = articleModel;
        customVc.hidesBottomBarWhenPushed = YES;
        [self.additionsViewController.navigationController pushViewController:customVc animated:YES];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
