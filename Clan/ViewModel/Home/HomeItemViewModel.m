//
//  HomeItemViewModel.m
//  Clan
//
//  Created by chivas on 15/11/18.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "HomeItemViewModel.h"
#import "HomeViewModel.h"
@implementation HomeItemViewModel
- (void)request_CustomType:(CustomRightItemModel *)model Block:(void(^)(id data))block{
    [[ClanNetAPI sharedJsonClient]requestJsonDataWithPath:model.view_link withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            HomeViewModel *homeviewmodel = [HomeViewModel new];
            CustomHomeMode *customHomeModel = nil;
            CustomRightItemModel *customRightItemModel = nil;
            NSDictionary *dic = data[@"Variables"];
            if ([model.tab_type isEqualToString:@"1"]) {
                //单页面
                //拉取首页基础数据
                if (dic[@"tab_cfg"][@"home_page"]) {
                    NSArray *array = dic[@"tab_cfg"][@"home_page"];
                    customHomeModel = [homeviewmodel request_homeWithDataArray:array];
                } else {
                    customHomeModel = [CustomHomeMode new];
                }
                //拉取右侧视图配置
                if (dic[@"tab_cfg"][@"title_cfg"]) {
                    NSArray *itemArray = dic[@"tab_cfg"][@"title_cfg"];
                    NSMutableArray *tempCustomItemArray = [NSMutableArray array];
                    for (NSDictionary *dic  in itemArray) {
                        customRightItemModel = [CustomRightItemModel objectWithKeyValues:dic];
                        [tempCustomItemArray addObject:customRightItemModel];
                    }
                    customHomeModel.title_cfg = tempCustomItemArray;
                }
                block(customHomeModel);
            }else if ([model.tab_type isEqualToString:@"2"]){
                //导航页面
                if (dic[@"tab_cfg"][@"navi_page"]) {
                    NSMutableArray *navGetArray = [NSMutableArray array];
                    for (NSDictionary *navDic in dic[@"tab_cfg"][@"navi_page"]) {
                        CustomNavModel *customNav = [CustomNavModel objectWithKeyValues:navDic];
                        customNav.customHomeModel = [homeviewmodel request_homeWithDataArray:navDic[@"navi_setting"][@"home_page"]];
                        //拉取右侧视图配置
                        if (dic[@"tab_cfg"][@"title_cfg"]) {
                            NSArray *itemArray = dic[@"tab_cfg"][@"title_cfg"];
                            NSMutableArray *tempCustomItemArray = [NSMutableArray array];
                            for (NSDictionary *dic  in itemArray) {
                                customRightItemModel = [CustomRightItemModel objectWithKeyValues:dic];
                                [tempCustomItemArray addObject:customRightItemModel];
                            }
                            customNav.customHomeModel.title_cfg = tempCustomItemArray;
                        }
                        
                        [navGetArray addObject:customNav];
                    }
                    block(navGetArray);
                }
            }else if ([model.tab_type isEqualToString:@"3"]){
                //拉取右侧视图配置
                if (dic[@"tab_cfg"][@"title_cfg"]) {
                    NSArray *itemArray = dic[@"tab_cfg"][@"title_cfg"];
                    NSMutableArray *tempCustomItemArray = [NSMutableArray array];
                    for (NSDictionary *dic  in itemArray) {
                        customRightItemModel = [CustomRightItemModel objectWithKeyValues:dic];
                        [tempCustomItemArray addObject:customRightItemModel];
                    }
                    customHomeModel = [CustomHomeMode new];
                    customHomeModel.title_cfg = tempCustomItemArray;
                    customHomeModel.wap_page = dic[@"tab_cfg"][@"wap_page"];
                    customHomeModel.navTitle = dic[@"tab_cfg"][@"title"];
                    customHomeModel.use_wap_name = dic[@"tab_cfg"][@"use_wap_name"];
                }
                block(customHomeModel);
            }
        }
    }];
}
@end
