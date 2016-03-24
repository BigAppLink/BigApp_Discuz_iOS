//
//  ArticleCell.m
//  Clan
//
//  Created by chivas on 15/9/6.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ArticleCell.h"
#import "ArticleListModel.h"
@implementation ArticleCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [_articleImage sd_setImageWithURL:[NSURL URLWithString:_articleModel.pic] placeholderImage:nil];
    _articleTitle.text = _articleModel.title;
    _articleCentent.text = _articleModel.summary;
    _articleCentent.lineBreakMode = NSLineBreakByTruncatingTail;
    _articleCentent.numberOfLines = 2;
    _articleTime.text = _articleModel.dateline ? _articleModel.dateline : @"没有时间";
    if (_articleModel.pic.length > 0) {
        _articleImageWidthLayout.constant = 81;
        _articleCentent.preferredMaxLayoutWidth = ScreenWidth - 30 - 81;
        
        _articleImage.hidden = NO;
    }else{
        _articleImageWidthLayout.constant = 0;
        _articleCentent.preferredMaxLayoutWidth = ScreenWidth - 30;
        _titleLeftLayout.constant = 0;
        _articleImage.hidden = YES;
    }

}
- (void)setArticleModel:(ArticleListModel *)articleModel
{
    _articleModel = articleModel;
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
