//
//  DetailViewController.h
//  Clan
//
//  Created by 昔米 on 15/5/9.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "BaseViewController.h"
#import "PostModel.h"

@interface PostDetailViewController : BaseViewController

@property (strong, nonatomic) PostModel *postModel;
@property(copy, nonatomic) NSString *shareImageURL;

@end
