//
//  BindAccountController.h
//  Clan
//
//  Created by 昔米 on 15/8/4.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "BaseViewController.h"

@interface BindAccountController : BaseViewController

@property (copy, nonatomic) NSString *openid;
@property (copy, nonatomic) NSString *oauth_token;
@property (assign) LoginType bindtype;

@end
