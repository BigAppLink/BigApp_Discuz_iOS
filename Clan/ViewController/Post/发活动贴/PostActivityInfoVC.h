//
//  PostActivityInfoVC.h
//  Clan
//
//  Created by chivas on 15/10/28.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "BaseViewController.h"
@class ForumsModel;
@class SendActivity;
@interface PostActivityInfoVC : BaseViewController
@property (strong, nonatomic)ForumsModel *forumModel;
@property (copy, nonatomic) void(^returnPostActivityModel)(SendActivity *);

@end
