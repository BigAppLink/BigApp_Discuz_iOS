//
//  NavWebViewController.h
//  Clan
//
//  Created by chivas on 15/10/10.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "TOWebViewController.h"
#import "XLPagerTabStripViewController.h"

@interface NavWebViewController : TOWebViewController<XLPagerTabStripChildItem>
@property (copy, nonatomic) NSString *navi_name;
@end
