//
//  PostImageCell.m
//  Clan
//
//  Created by chivas on 15/4/27.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "PostImageCell.h"
#import "PostModel.h"
#import "IDMPhoto.h"
#import "IDMPhotoBrowser.h"
#import "UIView+Additions.h"
#import "ClassifiedViewController.h"
@implementation PostImageCell

- (void)awakeFromNib
{
    _contentLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_SUBTITLE];
    _nameLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_ELEMENT];
    _datelineLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_ELEMENT-1];
    _viewsLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_ELEMENT];
    _replysLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_ELEMENT];
    _iv_seper.image = [Util imageWithColor:kUIColorFromRGB(0xeaeae9)];
    self.titleLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_TITLE];
    self.titleLabel.preferredMaxLayoutWidth = kSCREEN_WIDTH-30;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.numberOfLines = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
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
    _titleLabel.text = _postModel.subject;
    _viewsLabel.text = _postModel.views;
    _replysLabel.text = _postModel.replies;
    _titleLabel.text = _postModel.subject;
    _titleLabel.preferredMaxLayoutWidth = ScreenWidth - 30;
    [self confifFont];
    [self configImages];
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
    classifed.title = _postModel.type_name;
    classifed.fid = _postModel.fid;
    classifed.type_id = _postModel.type_id;
    [self.additionsViewController.navigationController pushViewController:classifed animated:YES];
}

- (void)confifFont
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

- (void)configImages
{
    int x = 0;
    for (UIView *view in _imagesView.subviews) {
        view.hidden = YES;
    }
    if (_postModel.attachment_urls.count > 0) {
        for (int index = 0; index < _postModel.attachment_urls.count; index++) {
            if (x > 2) {
                //最多显示3张
                break;
            }
            UIImageView *imageListView = (UIImageView *)[_imagesView viewWithTag:100+index];
            if (!imageListView) {
                imageListView = [[UIImageView alloc]init];
                imageListView.clipsToBounds = YES;
                imageListView.contentMode = UIViewContentModeScaleAspectFill;
                [_imagesView addSubview:imageListView];
                imageListView.tag = 100 + index;
                imageListView.userInteractionEnabled = YES;
                [imageListView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_imagesView.mas_top).offset(0);
                    make.leading.equalTo(_imagesView.mas_leading).offset(79*index + x);
                    make.bottom.equalTo(_imagesView.mas_bottom).offset(0);
                    make.width.equalTo(@79);
                }];
            }
            imageListView.hidden = NO;
            [imageListView sd_setImageWithURL:_postModel.attachment_urls[index] placeholderImage:kIMG(@"default_image")];
            x += 1;
            //设置右下图片
            if (index == 2) {
                UIButton *btn = (UIButton *)[imageListView viewWithTag:234];
                if (!btn) {
                    btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    UIImage *image = [UIImage imageWithColor:[UIColor blackColor] alpha:0.8];
                    btn.tag = 234;
                    [btn setBackgroundImage:image forState:UIControlStateNormal];
                    btn.enabled = NO;
                    btn.titleLabel.font = [UIFont fitFontWithSize:12.f];
                    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [imageListView addSubview:btn];
                    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.trailing.equalTo(imageListView.mas_trailing).offset(0);
                        make.bottom.equalTo(imageListView.mas_bottom).offset(0);
                        make.height.equalTo(@20);
                        make.width.equalTo(@40);
                    }];
                }
                btn.hidden = NO;
                [btn setTitle:[NSString stringWithFormat:@"共%lu张",(unsigned long)_postModel.attachment_urls.count] forState:UIControlStateNormal];
                break;
            }
        }
    }
}

@end
