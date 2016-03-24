//
//  UserInfoViewModel.h
//  Clan
//
//  Created by 昔米 on 15/4/1.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ViewModelClass.h"

@interface UserInfoViewModel : ViewModelClass

- (void)requestApi:(NSString *)uid andReturnBlock:(void(^)(bool success, id data, bool isSelf))returnBlock;


- (void)upLoadAvatar:(UIImage *)image andReturenBlock:(void(^)(bool success, id data))block;

//签到
- (void)doCheckIn:(NSString *)uid docheckInAction:(BOOL)checkInAction andReturenBlock:(void(^)(bool success, id data))block;


+ (NSString *)infoForUser:(UserModel *)user;
@end
