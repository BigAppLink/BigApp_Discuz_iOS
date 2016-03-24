//
//  AppConfigViewModel.h
//  Clan
//
//  Created by 昔米 on 15/9/1.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ViewModelClass.h"

@interface AppConfigViewModel : ViewModelClass

//来自站长中心的app的基本配置信息
- (void)getAppBaseConfigWithBlock:(void(^)(BOOL result))block;

//来自插件后台的配置
- (void)getAppPlugcfgWithBlock:(void(^)(BOOL result))block;

//获取所有的版块儿信息
- (void)requestBoardListWithBlock:(void(^)(BOOL result))block;

//app tab整体的配置信息
- (void)getAppHomeIndexcfgWithBlock:(void(^)(BOOL result))block;

@end
