//
//  HomeItemViewModel.h
//  Clan
//
//  Created by chivas on 15/11/18.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ViewModelClass.h"
@class CustomRightItemModel;
@interface HomeItemViewModel : ViewModelClass
- (void)request_CustomType:(CustomRightItemModel *)model Block:(void(^)(id data))block;
@end
