//
//  PostCell.m
//  Clan
//
//  Created by chivas on 15/3/18.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "HotPostCell.h"
#import "PostModel.h"
#import <QuartzCore/QuartzCore.h>
#import "NSDate+Helper.h"
@implementation HotPostCell

- (void)awakeFromNib
{
    _titleLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_TITLE];
    _titleLabel.textColor = K_COLOR_DARK;
    _repliesLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_ELEMENT];
    _repliesLabel.textColor = K_COLOR_LIGHTGRAY;
    _forumname.font = [UIFont fitFontWithSize:K_FONTSIZE_ELEMENT];
    _forumname.textColor = K_COLOR_LIGHTGRAY;
    _authorLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_Icon];
    _authorLabel.textColor = K_COLOR_LIGHTGRAY;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setPostModel:(PostModel *)postModel{
    _postModel = postModel;

}
- (void)layoutSubviews
{
//    _isImage.hidden = ![_postModel.attachment isEqualToString:@"2"];
    _isImage.hidden = !(_postModel.attachment.intValue == 2);
    [_faceImage sd_setImageWithURL:[NSURL URLWithString:_postModel.avatar] placeholderImage:[UIImage imageNamed:@"portrait"]];
    _faceImage.layer.cornerRadius = 43 /2;
    _faceImage.clipsToBounds = YES;
    _titleLabel.text = _postModel.subject;
    _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _authorLabel.text = _postModel.author;
    _repliesLabel.text = [NSString stringWithFormat:@"%@ / %@",_postModel.views,_postModel.replies];
    _forumname.text = _postModel.forum_name;
    if ([Util hasRead:_postModel.tid]) {
        _titleLabel.textColor = K_COLOR_HAS_READED_GRAY;
    } else {
        _titleLabel.textColor = K_COLOR_DARK;
    }
    [super layoutSubviews];
}

@end
