//
//  LinkCell.m
//  Clan
//
//  Created by chivas on 15/7/1.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "LinkCell.h"
#import "CustomHomeMode.h"
#import "LinkModel.h"
#import "UIView+Additions.h"
#import "PostDetailViewController.h"
#import "PostDetailVC.h"
#import "PostModel.h"
#import "PostViewController.h"
#import "ForumsModel.h"
#import "TOWebViewController.h"
#import "UIImageView+MJWebCache.h"

static const CGFloat itemHeight = 106;
@implementation LinkCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setCustomHomeModel:(CustomHomeMode *)customHomeModel
{
    _customHomeModel = customHomeModel;
    int x = 0;
    for (int index = 0; index < _customHomeModel.link.count; index++) {
        LinkModel *link = _customHomeModel.link[index];
        ItemView *itemView = [[ItemView alloc]initWithFrame:CGRectMake(x+(self.contentView.width/2 - itemHeight/2 - itemHeight), 0, itemHeight, 90)];
        itemView.tag = 100+index;
        itemView.delegate = self;
//        [itemView.item sd_setImageWithURL:[NSURL URLWithString:link.pic] placeholderImage:nil];
        [itemView.item setImageURL:[NSURL URLWithString:link.pic] placeholder:[UIImage imageNamed:@"board_icon"]];
        itemView.title.text = link.title;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectLinkView:)];
        [itemView addGestureRecognizer:tap];
        [self.contentView addSubview:itemView];
        x += itemHeight;
    }
}

- (void)selectLinkView:(UITapGestureRecognizer *)tap
{
    UIView *tagView = tap.view;
    LinkModel *link = _customHomeModel.link[tagView.tag - 100];
    if ([link.type isEqualToString:@"1"]) {
        //跳webview
        TOWebViewController *web = [[TOWebViewController alloc]initWithURLString:link.url];
        web.hidesBottomBarWhenPushed = YES;
        [self.additionsViewController.navigationController pushViewController:web animated:YES];
    }else if ([link.type isEqualToString:@"2"]){
        //跳帖子详情
        PostDetailVC *detail = [[PostDetailVC alloc]init];
        PostModel *postModel = [PostModel new];
        postModel.tid = link.pid;
        detail.postModel =  postModel;
        detail.hidesBottomBarWhenPushed = YES;
        [self.additionsViewController.navigationController pushViewController:detail animated:YES];

//        //跳帖子详情
//        PostDetailViewController *detail = [[PostDetailViewController alloc]init];
//        PostModel *postModel = [PostModel new];
//        postModel.tid = link.pid;
//        detail.postModel =  postModel;
//        detail.hidesBottomBarWhenPushed = YES;
//        [self.additionsViewController.navigationController pushViewController:detail animated:YES];
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
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)didItemView:(ItemView *)itemView atIndex:(NSInteger)index{
    
}
@end
