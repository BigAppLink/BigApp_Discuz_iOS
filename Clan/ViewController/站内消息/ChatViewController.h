//
//  ChatViewController.h
//  Clan
//
//  Created by 昔米 on 15/4/15.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "DialogListModel.h"

@interface ChatViewController : BaseViewController

@property (strong, nonatomic) DialogListModel *dialogModel;

@end
