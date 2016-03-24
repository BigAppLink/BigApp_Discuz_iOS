//
//  APostCell.m
//  Clan
//
//  Created by 昔米 on 15/7/8.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "APostCell.h"
#import "ClassifiedViewController.h"
#import "UIView+Additions.h"

@implementation APostCell

- (void)awakeFromNib
{
    _lbl_title.font = [UIFont fontWithSize:15.f];
    _lbl_title.preferredMaxLayoutWidth = kSCREEN_WIDTH-30;
    _lbl_title.lineBreakMode = NSLineBreakByWordWrapping;
    _lbl_title.numberOfLines = 0;
    _lbl_title.textColor = K_COLOR_DARK;
    _lbl_abstract.font = [UIFont fontWithSize:13.f];
    _lbl_abstract.numberOfLines = 0;
    _lbl_abstract.lineBreakMode = NSLineBreakByWordWrapping;
    _lbl_replys.textColor = K_COLOR_LIGHT_GRAY_Cell;
    _lbl_views.textColor = K_COLOR_LIGHT_GRAY_Cell;
    _iv_bottomline.image = [Util imageWithColor:K_COLOR_MOST_LIGHT_GRAY];
    _iv_topline.image = [Util imageWithColor:K_COLOR_MOST_LIGHT_GRAY];
    
    _iv_topline.hidden = YES;
    _iv_avatar.layer.cornerRadius = 15;
    _iv_avatar.contentMode = UIViewContentModeScaleAspectFill;
    _iv_avatar.clipsToBounds = YES;
    _lbl_name.font = [UIFont fontWithSize:10.f];
    _lbl_name.textColor = K_COLOR_DARK_Cell;
    _lbl_time.textColor = K_COLOR_LIGHT_GRAY_Cell;
    _lbl_time.font = [UIFont fontWithSize:9.f];
    _lbl_views.font = [UIFont fontWithSize:9.f];
    _lbl_replys.font = [UIFont fontWithSize:9.f];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPostModel:(PostModel *)postModel
{
    _postModel = postModel;
    [_iv_avatar sd_setImageWithURL:[NSURL URLWithString:_postModel.avatar] placeholderImage:[UIImage imageNamed:@"list_avatar"]];
    _lbl_name.text = _postModel.author;
    _lbl_time.text = _postModel.dateline ? _postModel.dateline : @"没有日期";
    if ([Util hasRead:_postModel.tid]) {
        _lbl_title.textColor = K_COLOR_HAS_READED_GRAY;
        _lbl_abstract.textColor = K_COLOR_HAS_READED_LIGHTGRAY;
    } else {
        _lbl_title.textColor = K_COLOR_DARK;
        _lbl_abstract.textColor = K_COLOR_GRAY;
    }
    _lbl_views.text = _postModel.views;
    _lbl_replys.text = _postModel.replies;
    _lbl_title.text = _postModel.subject;
    _lbl_title.preferredMaxLayoutWidth = ScreenWidth - 30;
    [self confifFont];
    [self configImages];
    _lbl_abstract.text = _postModel.message_abstract;
    _lbl_abstract.preferredMaxLayoutWidth = ScreenWidth - 30;
}

- (void)confifFont
{
    //把帖子分类拼接进去
    if (self.showTopic && !_postModel.hide_type && _postModel.type_id && ![@"0" isEqualToString:_postModel.type_id] && _postModel.type_name && _postModel.type_name.length > 0) {
        _lbl_title.text = [NSString stringWithFormat:@"[%@] %@",_postModel.type_name,_postModel.subject];
        NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:avoidNullStr(_lbl_title.text)];
        if (self.listable) {
            [attributedString addAttribute:NSForegroundColorAttributeName value:kUIColorFromRGB(0x6ea3e5) range:NSMakeRange(0, _postModel.type_name.length+2)];
            
        } else {
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, _postModel.type_name.length+2)];
        }
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 1.5;
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:NSFontAttributeName value:_lbl_title.font range:NSMakeRange(0, attributedString.length)];
        self.lbl_title.attributedText = attributedString;
        _lbl_title.preferredMaxLayoutWidth = ScreenWidth - 30;
        if (self.listable) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.contentView addSubview:btn];
            btn.backgroundColor = [UIColor clearColor];
            
            [btn addTarget:self action:@selector(goToThemePost) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitle:[NSString stringWithFormat:@" %@ ",_postModel.type_name] forState:UIControlStateNormal];
            [btn setTitleColor:kCLEARCOLOR forState:UIControlStateNormal];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(_lbl_title.mas_leading).offset(0);
                make.top.equalTo(_lbl_title.mas_top).offset(-5);
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
        _lbl_title.text = _postModel.subject;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:avoidNullStr(_lbl_title.text)];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:NSFontAttributeName value:_lbl_title.font range:NSMakeRange(0, attributedString.length)];
        self.lbl_title.attributedText = attributedString;
        _lbl_title.preferredMaxLayoutWidth = ScreenWidth - 30;
    }
    //添加各种标签
    if (_postModel.icon && _postModel.icon.length > 0 ) {
        NSMutableAttributedString * string = [self.lbl_title.attributedText mutableCopy];
        NSAttributedString *spaceString = [[NSAttributedString alloc] initWithString:@" "];
        NSTextAttachment * textAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil ] ;
        textAttachment.image = kIMG(_postModel.icon);
        textAttachment.bounds = CGRectMake(0, -2, textAttachment.image.size.width, textAttachment.image.size.height);
        NSAttributedString * textAttachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [string appendAttributedString:spaceString];
        [string appendAttributedString:textAttachmentString];
        [string addAttribute:NSFontAttributeName value:_lbl_title.font range:(NSRange){0, string.length}];
        
        _lbl_title.attributedText = string;
        _lbl_title.preferredMaxLayoutWidth = ScreenWidth - 30;
    }
    if (_postModel.digest && _postModel.digest.length > 0) {
        NSMutableAttributedString * string = [_lbl_title.attributedText mutableCopy];
        NSAttributedString *spaceString = [[NSAttributedString alloc] initWithString:@" "];
        NSTextAttachment * textAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil ] ;
        NSString *imName = [NSString stringWithFormat:@"d%@",_postModel.digest];
        textAttachment.image = kIMG(imName);
        textAttachment.bounds = CGRectMake(0, -2, textAttachment.image.size.width, textAttachment.image.size.height);
        NSAttributedString * textAttachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment] ;
        [string appendAttributedString:spaceString];
        [string appendAttributedString:textAttachmentString];
        _lbl_title.attributedText = string;
        _lbl_title.preferredMaxLayoutWidth = ScreenWidth - 30;
    }
}

- (void)configImages
{
    int x = 0;
    for (UIView *view in _v_images.subviews) {
        view.hidden = YES;
    }
    NSString *open_mode = [NSString returnPlistWithKeyValue:kOpenImageMode];
    if ((open_mode && open_mode.intValue == 1) && (_postModel.attachment_urls && _postModel.attachment_urls.count > 0)) {
        float imagesspace = 5.f;
        float imagewidth = (kSCREEN_WIDTH-30-2*imagesspace)/3.f;
        float imageheight = (imagewidth*90.f)/110.f;
        self.constraint_height_imagesview.constant = imageheight+1;
        self.v_images.hidden = NO;
        for (int index = 0; index < _postModel.attachment_urls.count; index++) {
            if (x > 2) {
                //最多显示3张
                break;
            }
            UIImageView *imageListView = (UIImageView *)[_v_images viewWithTag:100+index];
            if (!imageListView) {
                imageListView = [[UIImageView alloc]init];
                imageListView.clipsToBounds = YES;
                imageListView.contentMode = UIViewContentModeScaleAspectFill;
                [_v_images addSubview:imageListView];
                imageListView.tag = 100 + index;
                imageListView.userInteractionEnabled = YES;
                [imageListView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_v_images.mas_top).offset(0);
                    make.leading.equalTo(_v_images.mas_leading).offset(imagewidth*index + imagesspace*index);
                    make.bottom.equalTo(_v_images.mas_bottom).offset(0);
                    make.width.equalTo(@(imagewidth));
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
                    UIImage *image = [UIImage imageWithColor:[UIColor blackColor] alpha:0.5];
                    btn.tag = 234;
                    [btn setBackgroundImage:image forState:UIControlStateNormal];
                    btn.layer.cornerRadius = 8.f;
                    btn.clipsToBounds = YES;
                    btn.titleLabel.font = [UIFont fitFontWithSize:11.f];
                    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [imageListView addSubview:btn];
                    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(imageListView.mas_top).offset(6);
                        make.trailing.equalTo(imageListView.mas_trailing).offset(-3);
                        make.height.equalTo(@16);
                    }];
                }
                btn.hidden = NO;
                [btn setImage:kIMG(@"icon_tupian") forState:UIControlStateNormal];
                [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
                [btn setTitle:[NSString stringWithFormat:@"   %luP ",(unsigned long)_postModel.attachment_urls.count] forState:UIControlStateNormal];
                break;
            }
        }
    } else {
        self.constraint_height_imagesview.constant = 0;
        self.v_images.hidden = YES;
    }
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

@end
