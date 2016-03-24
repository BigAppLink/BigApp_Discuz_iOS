//
//  PostAddImageCell.m
//  Clan
//
//  Created by chivas on 15/3/26.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//
#define kCCellIdentifier_PostAddImageCCell @"PostAddImageCCell"
#import "PostAddImageCell.h"
#import "PostAddImageCCell.h"
#import "MJPhotoBrowser.h"
#import "PostSendModel.h"
@interface PostAddImageCell()
@property (strong, nonatomic) NSMutableDictionary *imageViewsDict;
@property (strong, nonatomic) UICollectionView *mediaView;

@end
@implementation PostAddImageCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        if (!self.mediaView) {
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            self.mediaView = [[UICollectionView alloc] initWithFrame:CGRectMake(15, 0, ScreenWidth-2*15, 80) collectionViewLayout:layout];
            self.mediaView.scrollEnabled = NO;
            [self.mediaView setBackgroundView:nil];
            [self.mediaView setBackgroundColor:[UIColor clearColor]];
            [self.mediaView registerClass:[PostAddImageCCell class] forCellWithReuseIdentifier:kCCellIdentifier_PostAddImageCCell];
            self.mediaView.dataSource = self;
            self.mediaView.delegate = self;
            [self.contentView addSubview:self.mediaView];
        }
        if (!_imageViewsDict) {
            _imageViewsDict = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (void)setSendModel:(PostSendModel *)sendModel{
    if (_sendModel != sendModel) {
        _sendModel = sendModel;
    }
    [self.mediaView setHeight:[PostAddImageCell cellHeightWithObj:_sendModel]];
    [_mediaView reloadData];
}

+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[PostSendModel class]]) {
        PostSendModel *postModel = (PostSendModel *)obj;
        NSInteger row = ceilf((float)(postModel.imageArray.count +1)/4.0);
        cellHeight = ([PostAddImageCCell ccellSize].height +10) *row;
    }
    return cellHeight;
}

#pragma mark Collection M
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return  _sendModel.imageArray.count +1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    
    PostAddImageCCell *ccell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCellIdentifier_PostAddImageCCell forIndexPath:indexPath];
    if (indexPath.row < _sendModel.imageArray.count) {
        SendImage *senimage = [weakSelf.sendModel.imageArray objectAtIndex:indexPath.row];
        ccell.sendImage = senimage;
    }else{
        ccell.sendImage = nil;
    }
    ccell.deleteTweetImageBlock = ^(SendImage *toDelete){
        NSMutableArray *sendImages = [weakSelf.sendModel mutableArrayValueForKey:@"imageArray"];
        [sendImages removeObject:toDelete];
        [weakSelf.mediaView reloadData];
    };
    [_imageViewsDict setObject:ccell.imgView forKey:indexPath];
    return ccell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [PostAddImageCCell ccellSize];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsZero;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == _sendModel.imageArray.count) {
                if (_sendModel.imageArray.count >= 9) {
                    kTipAlert(@"最多只可选择9张照片");
                    return;
                }
        if (_addPicturesBlock) {
            _addPicturesBlock();
        }
    }else{
        NSMutableArray *photos = [NSMutableArray arrayWithCapacity:_sendModel.imageArray.count];
        for (int i = 0; i < _sendModel.imageArray.count; i++) {
            SendImage *imageItem = [_sendModel.imageArray objectAtIndex:i];
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.srcImageView = [_imageViewsDict objectForKey:indexPath]; // 来源于哪个UIImageView
            photo.image = imageItem.image; // 图片路径
            [photos addObject:photo];
        }
        // 2.显示相册
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
        browser.currentPhotoIndex = indexPath.row; // 弹出相册时显示的第一张图片是？
        browser.photos = photos; // 设置所有的图片
        browser.showSaveBtn = NO;
        [browser show];
    }
}



@end
