//
//  ClanAPostCell.m
//  Clan
//
//  Created by chivas on 15/11/5.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ClanAPostCell.h"
#import "PostModel.h"
#import "ClassifiedViewController.h"
#import "UIView+Additions.h"
#import "NSString+Common.h"
#import "PostViewController.h"
#import "ForumsModel.h"
@implementation ClanAPostCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //头像
        [self.contentView addSubview:self.iv_avatar];
        //名字
        [self.contentView addSubview:self.lbl_name];
        //时间
        [self.contentView addSubview:self.lbl_time];
        //精华
        [self.contentView addSubview:self.digestsView];
        //标题
        [self.contentView addSubview:self.lbl_title];
        //摘要
        [self.contentView addSubview:self.lbl_content];
        //单图
        [self.contentView addSubview:self.singleImage];
        //多图
        [self.contentView addSubview:self.v_images];
        //底部版块
        [self.contentView addSubview:self.forumView];
        //尾部间距
        [self.contentView addSubview:self.bottomView];
        //无图模式
        [self.contentView addSubview:self.noImageView];
        
    }
    
    return self;
}
//- (void)awakeFromNib {
//    // Initialization code
//}
- (void)setPostModel:(PostModel *)postModel{
    _postModel = postModel;
    if (_postModel.attachment_urls.count == 0) {
        //无图
        _imageType = KNoImage;
    }else if (_postModel.attachment_urls.count > 0  && _postModel.attachment_urls.count < 3){
        //单图
        _imageType = KSingleImage;
    }else if (_postModel.attachment_urls.count > 2){
        //多图
        _imageType = KMoreImage;
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self viewForData];
}

- (void)viewForData{
    if (!_postModel) {
        return;
    }
//    NSLog(@"%@",[NSString returnPlistWithKeyValue:kOpenImageMode]);
    if (_type && [_type isEqualToString:@"1"]) {
        //首页
        if ([[NSString returnPlistWithKeyValue:kOpenImageMode] isEqualToString:@"2"]) {
            //无图模式
            _isImage = NO;
            _noImageView.hidden = ![_postModel.attachment isEqualToString:@"2"];
        }else{
            _isImage = YES;
            _noImageView.hidden = YES;
        }
    }else{
        if ([[NSString returnPlistWithKeyValue:kOpenImageMode] isEqualToString:@"0"]) {
            //无图模式
            _noImageView.hidden = ![_postModel.attachment isEqualToString:@"2"];
            _isImage = NO;
        }else{
            _noImageView.hidden = YES;
            _isImage = YES;
        }
    }
    _noImageView.frame = CGRectMake(ScreenWidth - 16 - 19, _postModel.frame/2 - 19/2, 19, 19);
    _lbl_content.hidden = _imageType != KNoImage;
    _singleImage.hidden = _imageType != KSingleImage;
    _v_images.hidden = _imageType != KMoreImage;
    //头像
    [_iv_avatar sd_setImageWithURL:[NSURL URLWithString:_postModel.avatar] placeholderImage:[UIImage imageNamed:@"list_avatar"]];
    //名字
    _lbl_name.text = _postModel.author;
    //日期
    _lbl_time.text = _postModel.dateline ? _postModel.dateline : @"没有日期";
    //精 推荐 最热
    for (UIView *view in _digestsView.subviews) {
        [view removeFromSuperview];
    }
    if (_postModel.icon.integerValue > 0 && ([_postModel.icon isEqualToString:@"10"] || [_postModel.icon isEqualToString:@"14"])) {
        //推荐 14 热帖 10 精华
        UIImageView *iconView = (UIImageView *)[self.contentView viewWithTag:1111];
        if (!iconView) {
            iconView = [[UIImageView alloc]initWithFrame:CGRectMake(_digestsView.width-25-10, 0, 25, 25)];
        }
        iconView.tag = 1111;
        NSString *imName = [NSString stringWithFormat:@"t_%@",_postModel.icon];
        iconView.image = kIMG(imName);
        [_digestsView addSubview:iconView];
    }
    
    if ((_postModel.digest && _postModel.digest.integerValue > 0) || (_postModel.icon.integerValue > 0 && [_postModel.icon isEqualToString:@"9"])) {
        UIImageView *digestView = (UIImageView *)[self.contentView viewWithTag:1112];
        if (!digestView) {
            digestView = [[UIImageView alloc]initWithFrame:CGRectMake(_digestsView.width-25-10, 0, 25, 25)];
            digestView.tag = 1112;
        }
        digestView.image = kIMG(@"t_jing");
        [_digestsView addSubview:digestView];
        if ([_postModel.icon isEqualToString:@"10"] || [_postModel.icon isEqualToString:@"14"]) {
            UIImageView *iconView = (UIImageView *)[self.contentView viewWithTag:1111];
            digestView.left = iconView.left - 35;
        }
    }
    //标题
    NSString *titleString = _postModel.subject;
    BOOL isShowType = _showTopic && !_postModel.hide_type && _postModel.type_id && ![@"0" isEqualToString:_postModel.type_id] &&_postModel.type_name && _postModel.type_name.length > 0;
    if (isShowType) {
        titleString = [NSString stringWithFormat:@"[%@] %@",_postModel.type_name,_postModel.subject];
    }
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:avoidNullStr(titleString)];
    [attributedString addAttribute:NSFontAttributeName value:_lbl_title.font range:NSMakeRange(0, attributedString.length)];

    if (isShowType) {
        if (self.listable) {
            [attributedString addAttribute:NSForegroundColorAttributeName value:kUIColorFromRGB(0x6ea3e5) range:NSMakeRange(0, _postModel.type_name.length+2)];
        } else {
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, _postModel.type_name.length+2)];
        }
    }
    
    if (_postModel.icon && _postModel.icon.integerValue > 0) {
        if (![_postModel.icon isEqualToString:@"10"] && ![_postModel.icon isEqualToString:@"14"] && ![_postModel.icon isEqualToString:@"9"]) {
            NSAttributedString *spaceString = [[NSAttributedString alloc] initWithString:@" "];
            NSTextAttachment * textAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil ] ;
            textAttachment.image = kIMG(_postModel.icon);
            textAttachment.bounds = CGRectMake(0, -1, textAttachment.image.size.width, textAttachment.image.size.height);
            NSAttributedString * textAttachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
            [attributedString appendAttributedString:spaceString];
            [attributedString appendAttributedString:textAttachmentString];
        }
    }
    CGFloat titleWidth = ScreenWidth - 32;
    if (_imageType == KSingleImage) {
        titleWidth = ScreenWidth-70-50-16;
    }
    if (!_isImage) {
        //无图模式
        titleWidth = ScreenWidth - 32 - 19 - 16;
    }
    CGSize maxSize = CGSizeMake(titleWidth, 1000);
    CGRect boundingRect = [attributedString boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    _lbl_title.height = boundingRect.size.height + 2;
    _lbl_title.width = titleWidth;
    _lbl_title.attributedText = attributedString;
    [_lbl_title sizeToFit];
    
    if (isShowType) {
        UIButton *typeBtn = (UIButton *)[self.contentView viewWithTag:7788];
        if (!typeBtn) {
            typeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.contentView addSubview:typeBtn];
            typeBtn.backgroundColor = [UIColor clearColor];
            
            [typeBtn addTarget:self action:@selector(goToThemePost) forControlEvents:UIControlEventTouchUpInside];
            [typeBtn setTitle:[NSString stringWithFormat:@" %@ ",_postModel.type_name] forState:UIControlStateNormal];
            [typeBtn setTitleColor:kCLEARCOLOR forState:UIControlStateNormal];
            [typeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(_lbl_title.mas_leading).offset(0);
                make.top.equalTo(_lbl_title.mas_top).offset(-5);
                make.height.equalTo(@28);
            }];
            typeBtn.tag = 7788;
        }
    }
    //摘要
    _lbl_content.text = _postModel.message_abstract;
    _lbl_content.top = _lbl_title.top + _lbl_title.height+10;
    CGSize contentSize = [_postModel.message_abstract sizeWithConstrainedToWidth:ScreenWidth-32 fromFont:[UIFont systemFontOfSize:14.0f] lineSpace:10];
    _lbl_content.height = _imageType != KNoImage ? 0: contentSize.height + 2;
    
    //单图
    if (_imageType == KSingleImage) {
        if (_postModel.attachment_urls.count > 0) {
            [_singleImage sd_setImageWithURL:[NSURL URLWithString:_postModel.attachment_urls[0]] placeholderImage:kIMG(@"default_image")];
            _singleImage.center = _lbl_title.center;
            _singleImage.left = ScreenWidth-25-70;
            _singleImage.clipsToBounds = YES;
            _singleImage.contentMode = UIViewContentModeScaleAspectFill;
        }
    }
    //多图
    if (_imageType == KMoreImage) {
        if (_postModel.attachment_urls.count > 0) {
            CGFloat imageWidth = (ScreenWidth-32-10)/3;
            _v_images.frame = CGRectMake(0, _lbl_title.bottom+12, ScreenWidth, imageWidth);
            NSInteger x = 0;
            NSInteger left = 16;
            for (NSInteger index = 0; index < _postModel.attachment_urls.count; index++) {
                if (x > 2) {
                    //最多显示3张
                    break;
                }
                UIImageView *imageListView = (UIImageView *)[_v_images viewWithTag:100+index];
                if (!imageListView) {
                    imageListView = [[UIImageView alloc]initWithFrame:CGRectMake(left, 0, imageWidth, imageWidth)];
                    imageListView.clipsToBounds = YES;
                    imageListView.contentMode = UIViewContentModeScaleAspectFill;
                    [_v_images addSubview:imageListView];
                    imageListView.tag = 100 + index;
                    
                }
                [imageListView sd_setImageWithURL:_postModel.attachment_urls[index] placeholderImage:kIMG(@"default_image")];
                x += 1;
                left += imageListView.width + 5;
                if (index == 2 && _postModel.attachment_urls.count > 3) {
                    [imageListView addSubview:self.picCountBtn];
                    [_picCountBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(imageListView.mas_top).offset(6);
                        make.trailing.equalTo(imageListView.mas_trailing).offset(-3);
                        make.height.equalTo(@16);
                    }];
                    
                    [_picCountBtn setImage:kIMG(@"icon_tupian") forState:UIControlStateNormal];
                    [_picCountBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
                    [_picCountBtn setTitle:[NSString stringWithFormat:@"   %luP ",(unsigned long)_postModel.attachment_urls.count] forState:UIControlStateNormal];
                    break;
                }
            }
        }
        
    }
    //底部
    CGFloat forumViewTop = _lbl_content.bottom + 12;
    if (_imageType == KSingleImage) {
        forumViewTop = _lbl_title.bottom + 32;
    }else if (_imageType == KMoreImage){
        forumViewTop = _v_images.bottom + 12;
    }
    _forumView.frame = CGRectMake(_iv_avatar.left, forumViewTop, ScreenWidth-32, 15);
    [_forumView addSubview:self.forumButton];
    CGSize buttonSize = [_postModel.forum_name sizeWithConstrainedToWidth:ScreenWidth fromFont:[UIFont systemFontOfSize:10.0f] lineSpace:5];
    _forumButton.width = buttonSize.width + 20;
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 7, 0, 7);
    UIImage *image = kIMG(@"forumBg");
    image = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    [_forumButton setBackgroundImage:image forState:UIControlStateNormal];
    [_forumButton setTitle:_postModel.forum_name forState:UIControlStateNormal];
    
    //浏览
    [_forumView addSubview:self.lbl_views];
    _lbl_views.frame = CGRectMake(_forumButton.right + 10, 0, ScreenWidth - _forumButton.right + 10, _forumView.height);
    _lbl_views.text = [NSString stringWithFormat:@"|  回帖 %@ • 阅读 %@",_postModel.replies,_postModel.views];
    NSMutableAttributedString * string = [_lbl_views.attributedText mutableCopy];
    [string addAttribute:NSForegroundColorAttributeName value:kUIColorFromRGB(0xececec) range:NSMakeRange(7+_postModel.replies.length,1)];
//    NSMutableParagraphStyle *paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
//    [string addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, string.length)];
    _lbl_views.attributedText = string;
    
    //尾部视图
    _bottomView.frame = CGRectMake(0, self.contentView.height-10.5, ScreenWidth, 10.5);
    [self greatLabelWithBottomView];
}
#pragma mark - 创建视图
- (UIImageView *)iv_avatar{
    if (!_iv_avatar) {
        _iv_avatar = [[UIImageView alloc]initWithFrame:CGRectMake(16, 15, 34, 34)];
        UIImageView *cornerRadiusView = [[UIImageView alloc]initWithFrame:_iv_avatar.bounds];
        cornerRadiusView.tag = 5000;
        cornerRadiusView.image = kIMG(@"faceCornerRadius");
        [_iv_avatar addSubview:cornerRadiusView];
//        _iv_avatar.layer.cornerRadius = _iv_avatar.width/2;
//        _iv_avatar.clipsToBounds = YES;
    }
    return _iv_avatar;
}

- (UILabel *)lbl_name{
    if (!_lbl_name) {
        _lbl_name = [[UILabel alloc]initWithFrame:CGRectMake(_iv_avatar.right+7, _iv_avatar.top, ScreenWidth-_iv_avatar.right+7+75+30, 17)];
        _lbl_name.textColor = [UIColor returnColorWithPlist:YZSegMentColor];
        _lbl_name.font = [UIFont systemFontOfSize:14.0f];
    }
    return _lbl_name;
}

- (UILabel *)lbl_time{
    if (!_lbl_time) {
        _lbl_time = [[UILabel alloc]initWithFrame:CGRectMake(_lbl_name.left, _lbl_name.bottom+3, 100, 12)];
        _lbl_time.textColor = UIColorFromRGB(0x999999);
        _lbl_time.font = [UIFont systemFontOfSize:10.0f];
    }
    return _lbl_time;
}

- (UIView *)digestsView{
    if (!_digestsView) {
        _digestsView = [[UIView alloc]initWithFrame:CGRectMake(ScreenWidth-200, 0, 200, 25)];
        _digestsView.backgroundColor = [UIColor clearColor];
    }
    return _digestsView;
}

- (UILabel *)lbl_title{
    if (!_lbl_title) {
        _lbl_title = [[UILabel alloc]initWithFrame:CGRectMake(_iv_avatar.left, _lbl_time.bottom+12, 0, 0)];
        _lbl_title.numberOfLines = 2;
        _lbl_title.textColor = [UIColor blackColor];
        _lbl_title.font = [UIFont systemFontOfSize:17.0f];
    }
    return _lbl_title;
}

-(UILabel *)lbl_content{
    if (!_lbl_content) {
        _lbl_content = [[UILabel alloc]initWithFrame:CGRectMake(_iv_avatar.left, _lbl_title.bottom+10, ScreenWidth-32, 0)];
        _lbl_content.numberOfLines = 2;
        _lbl_content.textColor = UIColorFromRGB(0x303030);
        _lbl_content.font = [UIFont systemFontOfSize:14.0f];
    }
    return _lbl_content;
}

- (UIImageView *)singleImage{
    if (!_singleImage) {
        _singleImage = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth-25-70, 0, 70, 70)];
    }
    return _singleImage;
}

- (UIView *)v_images{
    if (!_v_images) {
        _v_images = [[UIView alloc]init];
        _v_images.backgroundColor = [UIColor clearColor];
    }
    return _v_images;
}

- (UIView *)forumView{
    if (!_forumView) {
        _forumView = [[UIView alloc]init];
        _forumView.backgroundColor = [UIColor clearColor];
    }
    return _forumView;
}

- (UIButton *)forumButton{
    if (!_forumButton) {
        _forumButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 0, 15)];
        _forumButton.titleLabel.font = [UIFont systemFontOfSize:10.0f];
        NSMutableArray *arr =  [NSMutableArray arrayWithArray:self.additionsViewController.navigationController.viewControllers];
        if (arr.count == 1) {
            [_forumButton addTarget:self action:@selector(getForumAction) forControlEvents:UIControlEventTouchUpInside];
        }
        [_forumButton setTitleColor:[UIColor returnColorWithPlist:YZSegMentColor] forState:UIControlStateNormal];
    }
    return _forumButton;
}

- (UILabel *)lbl_views{
    if (!_lbl_views) {
        _lbl_views = [[UILabel alloc]init];
        _lbl_views.font = [UIFont systemFontOfSize:10.0f];
        _lbl_views.textColor = UIColorFromRGB(0xc9c9c9);
    }
    return _lbl_views;
}

- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc]init];
    }
    return _bottomView;
}

- (UIImageView *)noImageView{
    if (!_noImageView) {
        _noImageView = [[UIImageView alloc]init];
        _noImageView.image = kIMG(@"noImageType");
    }
    return _noImageView;
}
- (UIButton *)picCountBtn{
    if (!_picCountBtn) {
        _picCountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageWithColor:[UIColor blackColor] alpha:0.5];
        _picCountBtn.tag = 234;
        [_picCountBtn setBackgroundImage:image forState:UIControlStateNormal];
        _picCountBtn.layer.cornerRadius = 8.f;
        _picCountBtn.clipsToBounds = YES;
        _picCountBtn.titleLabel.font = [UIFont fitFontWithSize:11.f];
        [_picCountBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _picCountBtn;
}

- (void)greatLabelWithBottomView{
    if (!_label1) {
        _label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.5)];
        _label1.backgroundColor = UIColorFromRGB(0xdedede);
    }
    [_bottomView addSubview:_label1];
    if (!_label2) {
        _label2 = [[UILabel alloc]initWithFrame:CGRectMake(0, _label1.bottom, ScreenWidth, 10)];
        _label2.backgroundColor = UIColorFromRGB(0xf3f3f3);

    }
    [_bottomView addSubview:_label2];
}

#pragma mark - 点击版块跳转
- (void)getForumAction{
    PostViewController *postVc = [[PostViewController alloc]init];
    ForumsModel *forumModel = [ForumsModel new];
    forumModel.fid = _postModel.fid;
    postVc.hidesBottomBarWhenPushed = YES;
    postVc.forumsModel = forumModel;
    [self.additionsViewController.navigationController pushViewController:postVc animated:YES];
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

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
//    
//}
//
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setSelected:highlighted animated:animated];
    if (highlighted) {
        UIImageView *bgView = (UIImageView *)[_iv_avatar viewWithTag:5000];
        bgView.image = kIMG(@"faceHightCornerRadius");
    }else{
        UIImageView *bgView = (UIImageView *)[_iv_avatar viewWithTag:5000];
        bgView.image = kIMG(@"faceCornerRadius");
    }
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        UIImageView *bgView = (UIImageView *)[_iv_avatar viewWithTag:5000];
        bgView.image = kIMG(@"faceHightCornerRadius");
    }
    // Configure the view for the selected state
}

@end
