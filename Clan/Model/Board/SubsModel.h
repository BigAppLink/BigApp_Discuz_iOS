//
//  SubsModel.h
//  Clan
//
//  Created by chivas on 15/3/18.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ViewModelClass.h"

@interface SubsModel : ViewModelClass
/**
 *  今日发帖数
 */
@property (copy, nonatomic)NSString *todayposts;
/**
 *  父id
 */
@property (copy, nonatomic)NSString *fup;
/**
 *  组名
 */
@property (copy, nonatomic)NSString *name;
/**
 *  主题个数
 */
@property (copy, nonatomic)NSString *threads;
/**
 *  帖子个数
 */
@property (copy, nonatomic)NSString *posts;
/**
 *  今日排名
 */
@property (copy, nonatomic)NSString *rank;
/**
 *  icon
 */
@property (copy, nonatomic)NSString *icon;
/**
 *  组id
 */
@property (copy, nonatomic)NSString *fid;
/**
 *  type
 */
@property (copy, nonatomic)NSString *type;
@end
