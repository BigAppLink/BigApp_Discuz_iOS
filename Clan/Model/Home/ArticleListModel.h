//
//  ArticleListModel.h
//  Clan
//
//  Created by chivas on 15/9/6.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArticleListModel : NSObject
@property (copy, nonatomic) NSString *aid;
@property (copy, nonatomic) NSString *catid;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *url;
@property (copy, nonatomic) NSString *summary;
@property (copy, nonatomic) NSString *pic;
@property (copy, nonatomic) NSString *dateline;
@property (copy, nonatomic) NSString *catname;

@end
