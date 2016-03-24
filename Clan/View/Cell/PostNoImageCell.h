//
//  PostNoImageCell.h
//  Clan
//
//  Created by chivas on 15/5/4.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PostModel;

@interface PostNoImageCell : UITableViewCell 
@property (weak, nonatomic) IBOutlet UIImageView *faceImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *datelineLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet YZLabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewsLabel;
@property (weak, nonatomic) IBOutlet UILabel *replysLabel;
@property (strong, nonatomic)PostModel *postModel;
@property (weak, nonatomic) IBOutlet UIImageView *iv_seper;
@property (assign) BOOL showTopic; //是否显示
@property (assign) BOOL listable; //是否可点
@end
