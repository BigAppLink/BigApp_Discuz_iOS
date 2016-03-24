//
//  ForumsModel.h
//  Clan
//
//  Created by chivas on 15/3/18.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ViewModelClass.h"
#import "threadtypesModel.h"
#import "PostActivityModel.h"
@interface ForumsModel : ViewModelClass
/**
 *  子版块
 */
@property (strong, nonatomic)NSArray *subs;
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
/**
 *  描述
 */
@property (copy, nonatomic)NSString *des;
/**
 *  版主
 */
@property (strong, nonatomic)NSArray *moderators;

/**
 *  是否支持特殊主体
 */
@property (copy, nonatomic)NSString *allowspecialonly;

/*新增,删除版块收藏用*/
@property (copy, nonatomic)NSString *favid;
@property (copy, nonatomic)NSString *idtype;
/*发帖用*/
@property (copy, nonatomic)NSString *uploadhash;
@property (copy, nonatomic)NSString *toDayPostImage;
/**
 *  帖子分类
 */
@property (strong, nonatomic)threadtypesModel *threadtypes;
/*回复用*/
//@property (copy, nonatomic)NSString *tid;
//@property (copy, nonatomic)NSString *reppid;
- (BOOL)reflectDataFromOtherObject:(NSObject*)dataSource;
/**
 *  活动帖信息
 */
@property (strong, nonatomic) PostActivityModel *postActivityModel;
@end
