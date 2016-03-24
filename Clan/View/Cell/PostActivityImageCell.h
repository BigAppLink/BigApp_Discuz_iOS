//
//  PostActivityImageCell.h
//  Clan
//
//  Created by chivas on 15/11/19.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostActivityImageCell : UITableViewCell
@property (copy, nonatomic) void (^deleteTweetImageBlock)(SendImage *toDelete);
@property (copy, nonatomic) void(^addPicturesBlock)();
@property (strong, nonatomic)PostSendModel *sendModel;

@end
