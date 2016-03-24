//
//  YZButton.h
//  Clan
//
//  Created by 昔米 on 15/4/13.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YZButton : UIButton

@property (nonatomic, strong) NSIndexPath *path;
@property (nonatomic) BOOL agree;
//底部导航buttons
@property (assign) DZTabType tabtype;
@property (assign) NSInteger tabIndex;
@end
