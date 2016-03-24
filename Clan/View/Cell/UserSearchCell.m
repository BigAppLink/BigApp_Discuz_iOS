//
//  UserSearchCell.m
//  Clan
//
//  Created by chivas on 15/7/9.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "UserSearchCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UserInfoModel.h"
#import "UIView+Additions.h"
#import "ChatViewController.h"
@implementation UserSearchCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setInfoModel:(UserInfoModel *)infoModel{
    _infoModel = infoModel;
    _faceImageView.layer.cornerRadius = _faceImageView.width / 2;
    _faceImageView.clipsToBounds = YES;
    [_faceImageView sd_setImageWithURL:[NSURL URLWithString:_infoModel.avatar] placeholderImage:kIMG(@"portrait")];
    _usernameLabel.text = _infoModel.username;
    _groupnameLabel.text = _infoModel.groupname;
    _postImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(postMessage)];
    [_postImageView addGestureRecognizer:tap];
}

- (void)postMessage{
    ChatViewController *chat = [[ChatViewController alloc]initWithNibName:NSStringFromClass([ChatViewController class]) bundle:nil];
    DialogListModel *model = [DialogListModel new];
    model.msgtoid = _infoModel.uid;
    model.tousername = _infoModel.username;
    chat.dialogModel = model;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:chat];
    [self.additionsViewController presentViewController:nav animated:YES completion:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
