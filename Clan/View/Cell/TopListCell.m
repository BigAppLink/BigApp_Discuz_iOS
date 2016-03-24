//
//  TopListCell.m
//  Clan
//
//  Created by chivas on 15/4/9.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "TopListCell.h"
#import "ForumsModel.h"
#import "Util.h"
#import "MeViewController.h"
#import "UIView+Additions.h"
#import "UILabel+Common.h"

@implementation TopListCell

- (void)awakeFromNib
{
    _titleLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_TITLE];
    _titleLabel.textColor = K_COLOR_DARK;
//    _themeLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_ELEMENT];
//    _postLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_ELEMENT];
//    _todayLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_ELEMENT];
    _masterLabel.textColor = UIColorFromRGB(0x0FA7FF);
    _masterLabel.font = [UIFont systemFontOfSize:K_FONTSIZE_Icon];
    _masterLabel.numberOfLines = 1;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
}

- (void)setForumsModel:(ForumsModel *)forumsModel
{
    _forumsModel = forumsModel;
    _scrollWidth = 0;
    [_favBtn addTarget:self action:@selector(favAction:) forControlEvents:UIControlEventTouchUpInside];
    _isFav = [Util isFavoed_withID:_forumsModel.fid forType:myPlate];
    if (_isFav) {
        _favBtn.selected = YES;
        [_favBtn setImage:[UIImage imageNamed:@"fav_Action"] forState:UIControlStateNormal];
    }else{
        _favBtn.selected = NO;
        [_favBtn setImage:[UIImage imageNamed:@"fav_unAction"] forState:UIControlStateNormal];
    }
    
    [_faceImageView sd_setImageWithURL:[NSURL URLWithString:_forumsModel.icon] placeholderImage:[UIImage imageNamed:@"board_icon"]];
    _faceImageView.contentMode = UIViewContentModeScaleAspectFill;
    _faceImageView.clipsToBounds = YES;
    _faceImageView.layer.cornerRadius = 4;
    _titleLabel.text = _forumsModel.name;
    _themeLabel.text = _forumsModel.threads;
    _postLabel.text = _forumsModel.posts;
    _todayLabel.text = _forumsModel.todayposts;
    
    //创建版主图标
    int x = 0;
    for (int index = 0; index < _forumsModel.moderators.count; index++) {
        UILabel *moderatorLabel = [[UILabel alloc]initWithFrame:CGRectMake(0+x, 0, 0, _scrollView.height)];
        moderatorLabel.userInteractionEnabled = YES;
        moderatorLabel.tag = 1000 + index;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(checkName:)];
        [moderatorLabel addGestureRecognizer:tap];
        moderatorLabel.font = [UIFont systemFontOfSize:12.0f];
        moderatorLabel.textColor = UIColorFromRGB(0x666666);
        moderatorLabel.text = _forumsModel.moderators[index][@"username"];
        moderatorLabel.width = [UILabel yzAttributedLabelWithText:moderatorLabel.text andFrame:moderatorLabel.frame andFont:moderatorLabel.font].width;
        x += (moderatorLabel.width+10);
        _scrollWidth += (moderatorLabel.width+10);
        
        [_scrollView addSubview:moderatorLabel];
    }
    _scrollView.contentSize = CGSizeMake(_scrollWidth, _scrollView.height);


    if ([_forumsModel.moderators isKindOfClass:[NSArray class]] && _forumsModel.moderators.count == 0) {
        UILabel *moderatorLabel = [[UILabel alloc]initWithFrame:CGRectMake(0+x, 0, 100, _scrollView.height)];
        moderatorLabel.font = [UIFont systemFontOfSize:14.0f];
        moderatorLabel.textColor = UIColorFromRGB(0x666666);
        moderatorLabel.text = @"没有版主哦~";
        [_scrollView addSubview:moderatorLabel];
    }
}

- (void)checkName:(UITapGestureRecognizer *)tap{
    UILabel *label = (UILabel *)tap.view;
    NSString *uid = nil;
    for (NSDictionary *dic  in _forumsModel.moderators) {
        if ([dic[@"username"] isEqualToString:label.text]) {
            uid = dic[@"uid"];
            break;
        }
    }
    MeViewController *home = [[MeViewController alloc]init];
    UserModel *user = [UserModel new];
    user.uid = uid;
    home.user = user;
    [self.additionsViewController.navigationController pushViewController:home animated:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

- (void)favAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(boardFavWithBool:)]) {
        [self.delegate boardFavWithBool:_isFav];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}



@end
