//
//  PostNoImageCell.m
//  Clan
//
//  Created by chivas on 15/5/4.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "PostNoImageCell.h"
#import "PostModel.h"
#import "ClassifiedViewController.h"
#import "UIView+Additions.h"

@implementation PostNoImageCell

- (void)awakeFromNib
{
    _titleLabel.numberOfLines = 0;
    _titleLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_TITLE];
    _contentLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_SUBTITLE];
    _nameLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_ELEMENT];
    _datelineLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_ELEMENT-1];
    _viewsLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_ELEMENT];
    _replysLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_ELEMENT];
    _titleLabel.preferredMaxLayoutWidth = kSCREEN_WIDTH-30;
    _iv_seper.image = [Util imageWithColor:kUIColorFromRGB(0xeaeae9)];
    self.titleLabel.preferredMaxLayoutWidth = kSCREEN_WIDTH-30;
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setPostModel:(PostModel *)postModel
{
    _postModel = postModel;
    _faceImage.layer.cornerRadius = 15;
    _faceImage.clipsToBounds = YES;
    
    [_faceImage sd_setImageWithURL:[NSURL URLWithString:_postModel.avatar] placeholderImage:[UIImage imageNamed:@"portrait"]];
    _nameLabel.text = _postModel.author;
    _datelineLabel.text = _postModel.dateline;
    _contentLabel.text = _postModel.message_abstract;
    _contentLabel.preferredMaxLayoutWidth = ScreenWidth - 30;
    if ([Util hasRead:_postModel.tid]) {
        _titleLabel.textColor = K_COLOR_HAS_READED_GRAY;
        _contentLabel.textColor = K_COLOR_HAS_READED_LIGHTGRAY;
    } else {
        _titleLabel.textColor = K_COLOR_DARK;
        _contentLabel.textColor = K_COLOR_GRAY;
    }
    _viewsLabel.text = _postModel.views;
    _replysLabel.text = _postModel.replies;
    _titleLabel.text = _postModel.subject;
    _titleLabel.preferredMaxLayoutWidth = ScreenWidth - 30;
    [self configFonts];
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
        NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:avoidNullStr(_titleLabel.text)];
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
