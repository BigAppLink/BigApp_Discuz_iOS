//
//  CustomHomeMode.h
//  Clan
//
//  Created by chivas on 15/6/30.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomHomeMode : NSObject
@property (strong, nonatomic) NSArray *banner;
@property (strong, nonatomic) NSArray *link;
@property (strong, nonatomic) NSArray *forum;
@property (strong, nonatomic) NSArray *recommend;
@property (strong, nonatomic) NSArray *title_cfg;
@property (copy, nonatomic) NSString *wap_page;
@property (copy, nonatomic) NSString *use_wap_name;
@property (copy, nonatomic) NSString *navTitle;


/**
 *  1是内容型 2是推荐型
 */
@property (copy, nonatomic) NSString *recommendType;
@end

/**
 *  导航型model item+slider
 */


@interface CustomNavModel : NSObject
@property (copy, nonatomic) NSString *navi_name;
@property (strong, nonatomic) CustomHomeMode *customHomeModel;
@property (copy, nonatomic) NSString *wap_page;
@property (copy, nonatomic) NSString *tab_type;
@end

@interface CustomRightItemModel : NSObject
@property (copy, nonatomic) NSString *icon_type;
@property (copy, nonatomic) NSString *button_name;
@property (copy, nonatomic) NSString *title_button_type;
@property (copy, nonatomic) NSString *tab_type;
@property (copy, nonatomic) NSString *view_link;
@property (copy, nonatomic) NSString *wap_page;
@property (copy, nonatomic) NSString *use_wap_name;
@end