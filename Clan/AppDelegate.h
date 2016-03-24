//
//  AppDelegate.h
//  Clan
//
//  Created by chivas on 15/2/27.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//
/**
 * ===================BigAppV1.0================
 * 　　　　　　　　┏┓　　　┏┓
 * 　　　　　　　┏┛┻━━  ━┛┻┓
 * 　　　　　　　┃　　　　　　　┃
 * 　　　　　　　┃　　　━　　 　┃
 * 　　　　　　　┃　 ┳┛　┗┳  　┃
 * 　　　　　　　┃　　　　　　　┃
 * 　　　　　　　┃   ╰┬┬┬╯  　┃
 * 　　　　　　　┃　　　　　　　┃
 * 　　　　　　　┗━┓　　　   ┏━┛
 * 　　　　　　　　　┃　　　┃
 * 　　　　　　　　　┃　　　┃    神兽保佑,代码无bug
 * 　　　　　　　　　┃　　　┃
 * 　　　　　　　　　┃　　　┃
 * 　　　　　　　　　┃　　　┃
 * 　　　　　　　　　┃　　　┃
 * 　　　　　　　　　┃　　　┗━━━┓
 * 　　　　　　　　　┃　　　　　　　┣┓
 * 　　　　　　　　　┃　　　　　　　┏┛
 * 　　　　　　　　　┗┓┓┏━┳┓┏┛
 * 　　　　　　　　　　┃┫┫　┃┫┫
 * 　　　　　　　　　　┗┻┛　┗┻┛
 */

#import <UIKit/UIKit.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;

+ (AppDelegate*)appDelegate;
- (void)showRootDDmenuController;
- (void)getUserAllFavos;
- (void)initWithRootStyle;
@end

