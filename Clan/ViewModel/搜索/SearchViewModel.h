//
//  SearchViewModel.h
//  Clan
//
//  Created by chivas on 15/7/8.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ViewModelClass.h"

@interface SearchViewModel : ViewModelClass
- (void)requestSearchWithType:(NSString *)type andkeyWord:(NSString *)keyword andPage:(NSString *)page andBlock:(void(^)(NSArray *searchArray,BOOL isMore))block;
@end
