//
//  ViewRatingItem.h
//  Clan
//
//  Created by 昔米 on 15/11/24.
//  Copyright © 2015年 Youzu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViewRatingItem : NSObject

@property (copy, nonatomic) NSString *credit;
@property (copy, nonatomic) NSString *reason;
@property (copy, nonatomic) NSString *score;
@property (copy, nonatomic) NSString *uid;
@property (copy, nonatomic) NSString *username;

@property(assign) CGFloat cellHeight;
@end
