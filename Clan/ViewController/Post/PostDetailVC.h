//
//  PostDetailVC.h
//  Clan
//
//  Created by 昔米 on 15/10/19.
//  Copyright © 2015年 Youzu. All rights reserved.
//

#import "BaseViewController.h"
#import "PostModel.h"

@interface PostDetailVC : BaseViewController

@property (strong, nonatomic) PostModel *postModel;
@property (assign) BOOL isArticle;
@property (copy, nonatomic) NSString *postSummary;

//参加活动成功
- (void)joinActivitySuccess:(id)returnData;

//评分成功
- (void)ratePostSuccess:(id)returnData;

//点评成功
- (void)commentPostSuccess:(id)returnData;

//购买帖子成功
- (void)payThreadSuccess:(id)returnData;

@end
