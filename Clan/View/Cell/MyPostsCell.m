//
//  PostCell.m
//  demoSizeCell
//
//  Created by 昔米 on 15/4/8.
//  Copyright (c) 2015年 游族. All rights reserved.
//

#import "MyPostsCell.h"
#import "PostModel.h"

@implementation MyPostsCell

- (void)awakeFromNib
{
    _lbl_name.font = [UIFont fitFontWithSize:15.f];
    _lbl_name.textColor = K_COLOR_LIGHT_DARK;
    _lbl_dateline.font = [UIFont fitFontWithSize:12.f];
    _lbl_dateline.textColor = K_COLOR_DARK_Cell;
    _lbl_views.font = [UIFont fitFontWithSize:12.f];
    _lbl_views.textColor = K_COLOR_LIGHT_GRAY_Cell;
    _lbl_replys.font = [UIFont fitFontWithSize:12.f];
    _lbl_replys.textColor = K_COLOR_LIGHT_GRAY_Cell;
    _lbl_domain.font = [UIFont fitFontWithSize:12.f];
    _lbl_domain.textColor = K_COLOR_LIGHT_GRAY_Cell;
//    _lbl_lastpost_info.font = [UIFont fitFontWithSize:K_FONTSIZE_ELEMENT];
//    _lbl_lastpost_info.textColor = K_COLOR_LIGHTGRAY;
    _lbl_subject.font = [UIFont fitFontWithSize:17.f];
    _lbl_subject.textColor = K_COLOR_DARK;
    _lbl_subject.preferredMaxLayoutWidth = kSCREEN_WIDTH-2*15;
    _v_line2.backgroundColor = [UIColor whiteColor];
    
    // Initialization code
    _iv_avatar.layer.cornerRadius = 34/2;
    _iv_avatar.contentMode = UIViewContentModeScaleAspectFill;
    _iv_avatar.clipsToBounds = YES;
    [self.lbl_subject setLineBreakMode:NSLineBreakByTruncatingTail];
    [self.lbl_subject setNumberOfLines:0];
    [self.lbl_subject setTextAlignment:NSTextAlignmentLeft];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPost:(PostModel *)post
{
    _post = post;
    _lbl_name.text = _post.author;
    _lbl_subject.numberOfLines = 0;
    _lbl_dateline.text = _post.dateline;
    _lbl_domain.text = _post.forum_name;
    _lbl_replys.text = _post.replies;
    _lbl_views.text = _post.views;
    _lbl_subject.text = _post.subject;
    [_iv_avatar sd_setImageWithURL:[NSURL URLWithString:_post.avatar]];
//    NSString *str = [NSString stringWithFormat:@"最后发表:  %@  %@",_post.lastposter,_post.lastpost];
//    _lbl_lastpost_info.text = str;
    _lbl_subject.preferredMaxLayoutWidth = kSCREEN_WIDTH-2*15;
}
@end
