//
//  PostAddImageCell.h
//  Clan
//
//  Created by chivas on 15/3/26.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PostSendModel;
@interface PostAddImageCell : UITableViewCell<UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic)PostSendModel *sendModel;
@property (copy, nonatomic) void(^addPicturesBlock)();
+ (CGFloat)cellHeightWithObj:(id)obj;
@end
