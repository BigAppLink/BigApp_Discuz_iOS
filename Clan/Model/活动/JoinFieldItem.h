//
//  JoinFieldItem.h
//  Clan
//
//  Created by 昔米 on 15/11/16.
//  Copyright © 2015年 Youzu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JoinFieldItem : NSObject

@property (copy, nonatomic) NSString *fieldid;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *formtype;
@property (copy, nonatomic) NSString *defaultValue;
@property (copy, nonatomic) NSString *validate;
@property (copy, nonatomic) NSString *size;
@property (copy, nonatomic) NSString *f_description;
@property (strong, nonatomic) NSArray *choices;
@property (assign, nonatomic) DZActivityFormType dz_formtype;

@property (strong, nonatomic) id fieldValue;
@end
