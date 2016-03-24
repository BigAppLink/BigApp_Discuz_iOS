//
//  BoardModel.h
//  Clan
//
//  Created by chivas on 15/3/18.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ViewModelClass.h"
@interface BoardModel : ViewModelClass
/**
 *  版块组名
 */
@property (copy, nonatomic)NSString *name;
/**
 *  版块类型
 */
@property (copy, nonatomic)NSString *type;
/**
 *  版块下的分类版块
 */
@property (strong, nonatomic)NSArray *forums;
/**
 *  版块ID
 */
@property (copy, nonatomic)NSString *fid;

@end
