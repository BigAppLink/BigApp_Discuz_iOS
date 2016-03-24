//
//  PostAddImageCCell.h
//  Clan
//
//  Created by chivas on 15/3/26.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SendImage;
@interface PostAddImageCCell : UICollectionViewCell
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) UIButton *deleteBtn;
@property (copy, nonatomic) void (^deleteTweetImageBlock)(SendImage *toDelete);
@property (strong, nonatomic)SendImage *sendImage;
+(CGSize)ccellSize;
@end
