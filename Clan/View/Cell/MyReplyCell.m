//
//  MyReplyCell.m
//  Clan
//
//  Created by 昔米 on 15/4/8.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "MyReplyCell.h"
#import "ReplyModel.h"

@implementation MyReplyCell

- (void)awakeFromNib
{
    _lbl_name.font = [UIFont fitFontWithSize:15.f];
    _lbl_name.textColor = K_COLOR_LIGHT_DARK;
    _lbl_dateline.font = [UIFont fitFontWithSize:12.f];
    _lbl_dateline.textColor = K_COLOR_DARK_Cell;
    _lbl_domain.font = [UIFont fitFontWithSize:12.f];
    _lbl_domain.textColor = K_COLOR_LIGHT_GRAY_Cell;
    _lbl_comments.font = [UIFont fitFontWithSize:17.f];
    _lbl_comments.textColor = K_COLOR_DARK;
    _lbl_subject.font = [UIFont fitFontWithSize:16.f];
    _lbl_subject.textColor = kUIColorFromRGB(0x6c6c6c);
    _lbl_views.font = [UIFont fitFontWithSize:12.f];
    _lbl_views.textColor = K_COLOR_LIGHT_GRAY_Cell;
    _lbl_reply.font = [UIFont fitFontWithSize:12.f];
    _lbl_reply.textColor = K_COLOR_LIGHT_GRAY_Cell;
    self.iv_avatar.layer.cornerRadius = 34/2;
    self.iv_avatar.clipsToBounds = YES;
    _iv_avatar.contentMode = UIViewContentModeScaleAspectFill;
    _iv_avatar.clipsToBounds = YES;
    _v_postbg.backgroundColor = kCLEARCOLOR;
    [self.lbl_subject setLineBreakMode:NSLineBreakByTruncatingTail];
    [self.lbl_subject setNumberOfLines:0];
    [self.lbl_subject setTextAlignment:NSTextAlignmentLeft];
    UIEdgeInsets insets = UIEdgeInsetsMake(15, 30, 10, 30);
    UIImage *image = kIMG(@"beijing_tiezi");
    image = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    self.v_postbg.image = image;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(ReplyModel *)model
{
    _model = model;
    self.lbl_comments.text = _model.message;
    self.lbl_dateline.text = _model.dateline;
    self.lbl_subject.text = _model.subject;
    self.lbl_domain.text = _model.forum_name;
    self.lbl_name.text = _model.author;
    self.lbl_reply.text = _model.replies;
    self.lbl_views.text = _model.views;
    [self.iv_avatar sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:kIMG(@"portrait")];
    _lbl_subject.preferredMaxLayoutWidth = kSCREEN_WIDTH-2*23;
    _lbl_comments.preferredMaxLayoutWidth = kSCREEN_WIDTH-2*15;
}

@end

