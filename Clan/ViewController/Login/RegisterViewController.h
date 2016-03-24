//
//  RegisterViewController.h
//  Clan
//
//  Created by chivas on 15/5/12.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "BaseViewController.h"

@interface RegisterViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic)NSString *fid;

@property (assign) BOOL bindAction;
@property (assign) LoginType bindtype;

@property (copy, nonatomic) NSString *openid;
@property (copy, nonatomic) NSString *oauth_token;

@end
