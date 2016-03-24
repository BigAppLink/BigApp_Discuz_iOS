//
//  MyPostViewModel.h
//  Clan
//
//  Created by 昔米 on 15/4/3.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ViewModelClass.h"

@interface MyPostViewModel : ViewModelClass

/**
 * 我的主贴
 */
- (void)requestPostsForPage:(NSNumber *)page withUserID:(NSString *)uid andReturnBlock:(void(^)(bool success, id data))block;

/**
 * 我的回复
 */
- (void)requestReplysForPage:(NSNumber *)page withUserID:(NSString *)uid andReturnBlock:(void(^)(bool success, id data))block;

@end
