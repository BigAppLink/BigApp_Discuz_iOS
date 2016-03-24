//
//  WebNaviViewController.h
//  Clan
//
//  Created by 昔米 on 15/10/14.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "TOWebViewController.h"
@class CustomHomeMode;
@protocol WebNavViewDelegate <NSObject>

@optional
- (void)webViewTitle:(NSString *)title;

@end
@interface WebNaviViewController : TOWebViewController
@property (copy, nonatomic) NSString *navTitle;
@property (assign, nonatomic) BOOL isTabBarItem;
@property (strong, nonatomic) CustomHomeMode *customHomeModel;
@property (assign, nonatomic) id<WebNavViewDelegate>delegate;

@end
