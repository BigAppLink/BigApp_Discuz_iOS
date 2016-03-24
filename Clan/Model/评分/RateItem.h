//
//  RateItem.h
//  Clan
//
//  Created by 昔米 on 15/11/23.
//  Copyright © 2015年 Youzu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RateItem : NSObject
@property (nonatomic, copy) NSString *extcredits;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *min;
@property (nonatomic, copy) NSString *max;
@property (nonatomic, copy) NSString *mrpd;
@property (nonatomic, copy) NSString *isself;
@property (nonatomic, copy) NSString *todayleft;

@property (nonatomic, strong) NSArray *choices;
@property (nonatomic, copy) NSString *inputValue;

@end
