//
//  DialogListViewModel.h
//  Clan
//
//  Created by 昔米 on 15/4/13.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ViewModelClass.h"

@interface DialogListViewModel : ViewModelClass

/**
 * 消息列表
 */
- (void)requestDialogListWithReturnBlock:(void(^)(bool success, id data))block;

/**
 * 删除消息列表
 */
- (void)delete_DialogListwithDeletepm_deluid:(NSString *)deletepm_deluid andReturnBlock:(void(^)(bool success, id data))block;
@end
