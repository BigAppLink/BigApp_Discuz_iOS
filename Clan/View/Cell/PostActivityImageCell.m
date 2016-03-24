//
//  PostActivityImageCell.m
//  Clan
//
//  Created by chivas on 15/11/19.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "PostActivityImageCell.h"
#import "PostSendModel.h"
@interface PostActivityImageCell()
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) UIButton *deleteBtn;
@property (strong, nonatomic) UIImageView *addImageBtn;
@property (strong, nonatomic) UIScrollView *scrollView;
@end
@implementation PostActivityImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.scrollView];
        
    }
    return self;
}

- (void)setSendModel:(PostSendModel *)sendModel{
    _sendModel = sendModel;
    CGFloat x = _addImageBtn.right + 10;
    CGFloat scrollContentSizeWidth = 0;
    for (UIImageView *imageView in _scrollView.subviews) {
        if ([imageView isEqual:_addImageBtn]) {
            continue;
        }
        [imageView removeFromSuperview];
    }
    if (_sendModel && _sendModel.imageArray.count > 0) {
        for (NSInteger index = 0; index < _sendModel.imageArray.count; index ++) {
            SendImage *sendImage = _sendModel.imageArray[index];
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(x, _addImageBtn.top, 60, 60)];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.userInteractionEnabled = YES;
            imageView.layer.cornerRadius = 5;
            imageView.layer.masksToBounds = YES;
            imageView.clipsToBounds = YES;
            imageView.image = sendImage.image;
            [_scrollView addSubview:imageView];
            UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(imageView.width-22, 0, 22, 22)];
            [deleteBtn setImage:[UIImage imageNamed:@"deleteBtn"] forState:UIControlStateNormal];
            deleteBtn.tag = index + 1000;
            [deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [imageView addSubview:deleteBtn];
            x += 70;
            scrollContentSizeWidth = x + 10 + 29;
        }
        _scrollView.contentSize = CGSizeMake(scrollContentSizeWidth, 110);
    }
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 110)];
         _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.backgroundColor = [UIColor whiteColor];
        [_scrollView addSubview:self.addImageBtn];
    }
    return _scrollView;
}

- (UIImageView *)addImageBtn{
    if (!_addImageBtn) {
        _addImageBtn = [[UIImageView alloc]initWithFrame:CGRectMake(29, 23, 60, 60)];
        _addImageBtn.image = kIMG(@"addImage");
        _addImageBtn.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addImageAction)];
        [_addImageBtn addGestureRecognizer:tap];
    }
    return _addImageBtn;
}

- (void)deleteBtnClicked:(UIButton *)btn{
    SendImage *sendImage = _sendModel.imageArray[btn.tag-1000];
    if (_deleteTweetImageBlock) {
        _deleteTweetImageBlock(sendImage);
    }
}


- (void)addImageAction{
    if (_sendModel.imageArray.count >= 9) {
        kTipAlert(@"最多只可选择9张照片");
        return;
    }
    if (self.addPicturesBlock) {
        self.addPicturesBlock();
    }
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
