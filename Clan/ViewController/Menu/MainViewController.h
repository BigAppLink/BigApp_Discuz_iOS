//
//  MainViewController.h
//  Clan
//
//  Created by chivas on 15/6/16.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UITabBarController<UINavigationControllerDelegate>
- (void)sendPost;
- (BOOL)checkLoginState;

@end
