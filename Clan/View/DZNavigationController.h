//
//  DZNavigationController.h
//  Clan
//
//  Created by 昔米 on 15/10/10.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DZNavigationController : UINavigationController

@property (assign) DZTabType tabType;
//在tabbarvc.viewcontrollers的位置
@property (assign) NSInteger controllerIndex;
//tabbar上 button所对应的位置
@property (assign) NSInteger tabBarButtonIndex;

@end
