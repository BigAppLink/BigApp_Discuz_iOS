//
//  ApplyActivityItem.h
//  Clan
//
//  Created by 昔米 on 15/11/19.
//  Copyright © 2015年 Youzu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplyActivityItem : NSObject
@property (copy, nonatomic) NSString *applyid;
@property (copy, nonatomic) NSString *can_select;
@property (copy, nonatomic) NSString *dateline;
@property (copy, nonatomic) NSString *message;
@property (copy, nonatomic) NSString *payment;
@property (copy, nonatomic) NSString *tid;
@property (copy, nonatomic) NSString *ufielddata;
@property (copy, nonatomic) NSString *uid;
@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *verified;

@property (assign) BOOL expanded;
@property (assign) CGFloat expandedHeight;
@property (assign) CGFloat normalHeight;
@end
