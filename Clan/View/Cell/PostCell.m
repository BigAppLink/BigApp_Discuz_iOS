//
//  PostCell.m
//  Clan
//
//  Created by chivas on 15/3/23.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "PostCell.h"
#import "PostModel.h"
#import "ClassifiedViewController.h"
#import "UIView+Additions.h"

@implementation PostCell

- (void)awakeFromNib
{
    // Initialization code
    _titleLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_TITLE];
    _titleLabel.textColor = K_COLOR_DARK;
    _titleLabel.numberOfLines = 0;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _titleLabel.preferredMaxLayoutWidth = kSCREEN_WIDTH-30;
    _authorLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_ELEMENT];
    _authorLabel.textColor = K_COLOR_LIGHT_DARK;
    _viewsLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_ELEMENT];
    _viewsLabel.textColor = K_COLOR_LIGHTGRAY;
    _dateline.font = [UIFont fitFontWithSize:K_FONTSIZE_ELEMENT];
    _dateline.textColor = K_COLOR_LIGHTGRAY;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)setPostModel:(PostModel *)postModel
{
    _postModel = postModel;
    _authorLabel.text = _postModel.author;
    _viewsLabel.text = [NSString stringWithFormat:@"%@ / %@",_postModel.replies,_postModel.views];
//    _isImageView.hidden = ![_postModel.attachment isEqualToString:@"2"];
    _isImageView.hidden = !(_postModel.attachment.intValue == 2);

    _dateline.text = _postModel.dateline;
    if ([Util hasRead:_postModel.tid]) {
        _titleLabel.textColor = K_COLOR_HAS_READED_GRAY;
    } else {
        _titleLabel.textColor = K_COLOR_DARK;
    }
    [self configFonts];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)goToThemePost
{
    if (!_postModel.type_id || _postModel.type_id.length == 0) {
        return;
    }
    ClassifiedViewController *classifed = [[ClassifiedViewController alloc]init];
    classifed.fid = _postModel.fid;
    classifed.type_id = _postModel.type_id;
    classifed.title = _postModel.type_name;
    [self.additionsViewController.navigationController pushViewController:classifed animated:YES];
}

- (void)configFonts
{
    //把帖子分类拼接进去
    if (self.showTopic && !_postModel.hide_type && _postModel.type_id && ![@"0" isEqualToString:_postModel.type_id] && _postModel.type_name && _postModel.type_name.length > 0) {
        _titleLabel.text = [NSString stringWithFormat:@"[%@] %@",_postModel.type_name,_postModel.subject];
        NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:avoidNullStr( _titleLabel.text)];
        if (self.listable) {
            [attributedString addAttribute:NSForegroundColorAttributeName value:kUIColorFromRGB(0x6ea3e5) range:NSMakeRange(0, _postModel.type_name.length+2)];
            
        } else {
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, _postModel.type_name.length+2)];
        }
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 1.5;
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:NSFontAttributeName value:_titleLabel.font range:NSMakeRange(0, attributedString.length)];
        self.titleLabel.attributedText = attributedString;
        _titleLabel.preferredMaxLayoutWidth = ScreenWidth - 30;
        if (self.listable) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.contentView addSubview:btn];
            btn.backgroundColor = [UIColor clearColor];
            
            [btn addTarget:self action:@selector(goToThemePost) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitle:[NSString stringWithFormat:@" %@ ",_postModel.type_name] forState:UIControlStateNormal];
            [btn setTitleColor:kCLEARCOLOR forState:UIControlStateNormal];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(_titleLabel.mas_leading).offset(0);
                make.top.equalTo(_titleLabel.mas_top).offset(-5);
                make.height.equalTo(@28);
            }];
            btn.tag = 7788;
        } else {
            UIView *v = [self.contentView viewWithTag:7788];
            [v removeFromSuperview];
        }
    } else {
        UIView *v = [self.contentView viewWithTag:7788];
        [v removeFromSuperview];
        _titleLabel.text = _postModel.subject;
        _titleLabel.preferredMaxLayoutWidth = ScreenWidth - 30;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:avoidNullStr(_titleLabel.text)];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:NSFontAttributeName value:_titleLabel.font range:NSMakeRange(0, attributedString.length)];
        self.titleLabel.attributedText = attributedString;
        _titleLabel.preferredMaxLayoutWidth = ScreenWidth - 30;
    }
    //添加各种标签
    if (_postModel.icon && _postModel.icon.length > 0 ) {
        NSMutableAttributedString * string = [self.titleLabel.attributedText mutableCopy];
        NSAttributedString *spaceString = [[NSAttributedString alloc] initWithString:@" "];
        NSTextAttachment * textAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil ] ;
        
        textAttachment.image = kIMG(_postModel.icon);
        textAttachment.bounds = CGRectMake(0, -2, textAttachment.image.size.width, textAttachment.image.size.height);
        NSAttributedString * textAttachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [string appendAttributedString:spaceString];
        [string appendAttributedString:textAttachmentString];
        [string addAttribute:NSFontAttributeName value:self.titleLabel.font range:(NSRange){0, string.length}];
        self.titleLabel.attributedText = string;
        _titleLabel.preferredMaxLayoutWidth = ScreenWidth - 30;
    }
    if (_postModel.digest && _postModel.digest.length > 0) {
        NSMutableAttributedString * string = [self.titleLabel.attributedText mutableCopy];
        NSAttributedString *spaceString = [[NSAttributedString alloc] initWithString:@" "];
        NSTextAttachment * textAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil ] ;
        NSString *imName = [NSString stringWithFormat:@"d%@",_postModel.digest];
        textAttachment.image = kIMG(imName);
        textAttachment.bounds = CGRectMake(0, -2, textAttachment.image.size.width, textAttachment.image.size.height);
        NSAttributedString * textAttachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment] ;
        [string appendAttributedString:spaceString];
        [string appendAttributedString:textAttachmentString];
        self.titleLabel.attributedText = string;
        _titleLabel.preferredMaxLayoutWidth = ScreenWidth - 30;
    }
}
@end
