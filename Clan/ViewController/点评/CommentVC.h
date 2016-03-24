//
//  CommentVC.h
//  Clan
//
//  Created by 昔米 on 15/11/24.
//  Copyright © 2015年 Youzu. All rights reserved.
//

#import "BaseViewController.h"

@interface CommentVC : BaseViewController
@property (nonatomic, strong) NSArray *commentFeild;
@property (nonatomic, copy) NSString *tid;
@property (nonatomic, copy) NSString *pid;
@property (nonatomic, weak) id targetVC;
@end
