//
//  PostCell.h
//  Clan
//
//  Created by chivas on 15/3/18.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PostModel;
@interface HotPostCell : UITableViewCell
@property (weak, nonatomic) IBOutlet YZLabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *repliesLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UIImageView *faceImage;
@property (weak, nonatomic) IBOutlet UILabel *forumname;
@property (weak, nonatomic) IBOutlet UIImageView *isImage;
@property (strong, nonatomic)PostModel *postModel;
@end
