//
//  PayThreadVC.h
//  Clan
//
//  Created by 昔米 on 15/12/9.
//  Copyright © 2015年 Youzu. All rights reserved.
//

#import "BaseViewController.h"

@interface PayThreadVC : BaseViewController

@property (nonatomic, strong) id payInfo;
@property (nonatomic, copy) NSString *tid;
@property (nonatomic, weak) id targetVC;

@end
