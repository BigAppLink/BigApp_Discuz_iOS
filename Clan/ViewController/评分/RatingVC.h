//
//  RatingVC.h
//  Clan
//
//  Created by 昔米 on 15/11/23.
//  Copyright © 2015年 Youzu. All rights reserved.
//

#import "BaseViewController.h"

@interface RatingVC : BaseViewController
@property (nonatomic, strong) NSArray *reasons;
@property (nonatomic, strong) NSArray *ratelist;
@property (nonatomic, copy) NSString *pid;
@property (nonatomic, copy) NSString *tid;
@property (nonatomic, weak) id targetVC;
@end
