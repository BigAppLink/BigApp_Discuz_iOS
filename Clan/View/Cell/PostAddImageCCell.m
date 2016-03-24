//
//  PostAddImageCCell.m
//  Clan
//
//  Created by chivas on 15/3/26.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "PostAddImageCCell.h"
#import "PostSendModel.h"
#define kTweetSendImageCCell_Width floorf((ScreenWidth - 15*2- 10*3)/4)

@implementation PostAddImageCCell
- (void)setSendImage:(SendImage *)sendImage{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kTweetSendImageCCell_Width, kTweetSendImageCCell_Width)];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = YES;
        _imgView.layer.masksToBounds = YES;
        _imgView.layer.cornerRadius = 2.0;
        [self.contentView addSubview:_imgView];
    }
    _sendImage = sendImage;
    if (_sendImage) {
        _imgView.image = [_sendImage.image scaledToSize:_imgView.bounds.size highQuality:YES];
        if (!_deleteBtn) {
            _deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(kTweetSendImageCCell_Width-20, 0, 20, 20)];
            [_deleteBtn setImage:[UIImage imageNamed:@"btn_delete_tweetimage"] forState:UIControlStateNormal];
            _deleteBtn.backgroundColor = [UIColor blackColor];
            _deleteBtn.layer.cornerRadius = CGRectGetWidth(_deleteBtn.bounds)/2;
            _deleteBtn.layer.masksToBounds = YES;
            
            [_deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_deleteBtn];
        }
        _deleteBtn.hidden = NO;
    }else{
        UIImage *addimage = [UIImage imageNamed:@"addPictureBgImage"];
        _imgView.image = addimage;
        if (_deleteBtn) {
            _deleteBtn.hidden = YES;
        }
    }
}
- (void)deleteBtnClicked:(id)sender{
    if (_deleteTweetImageBlock) {
        _deleteTweetImageBlock(_sendImage);
    }
}
+(CGSize)ccellSize{
    return CGSizeMake(kTweetSendImageCCell_Width, kTweetSendImageCCell_Width);
}


@end
