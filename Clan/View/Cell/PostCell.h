//
//  PostCell.h
//  Clan
//
//  Created by chivas on 15/3/23.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PostModel;
@interface PostCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *isImageView;
@property (weak, nonatomic) IBOutlet UILabel *dateline;
@property (strong, nonatomic) PostModel *postModel;
@property (assign) BOOL showTopic; //是否显示
@property (assign) BOOL listable; //是否可点
@end
