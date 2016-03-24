//
//  PostSendViewModel.h
//  Clan
//
//  Created by 昔米 on 15/8/13.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ViewModelClass.h"

@interface PostSendViewModel : ViewModelClass

//版块儿发帖前置检查
- (void)request_PermissionForSendPost:(NSString *)fid withBlock:(void(^)(id data))block;

//拉取分类信息
- (void)request_classifyForForumsId:(NSString *)fid withBlock:(void(^)(id data, BOOL success))block;

@end
