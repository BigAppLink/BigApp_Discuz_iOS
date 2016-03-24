//
//  UIViewController+NavibarDao.m
//  Clan
//
//  Created by 昔米 on 15/4/10.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "UIViewController+NavibarDao.h"

@implementation UIViewController (NavibarDao)

//恢复navi的背景
- (void)resetNaviBar
{
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor returnColorWithPlist:YZSegMentColor]]
//                                                  forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setBackgroundImage:kIMG(@"naviBg") forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundImage: [Util imageWithColor:[UIColor returnColorWithPlist:YZSegMentColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];

}
//使navi的背景透明
- (void)setNaviTransparent
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
}

@end
