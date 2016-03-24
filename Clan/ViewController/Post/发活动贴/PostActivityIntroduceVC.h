//
//  PostActivityIntroduceVC.h
//  Clan
//
//  Created by chivas on 15/10/28.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "BaseViewController.h"
@class SendActivity;

@interface PostActivityIntroduceVC : BaseViewController
@property (copy, nonatomic) void(^returnPostActivityModel)(SendActivity *);

@end
