//
//  threadtypesModel.h
//  Clan
//
//  Created by chivas on 15/5/29.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface threadtypesModel : NSObject
/**
 *  是否必须要选择分类才能发帖
 */
@property(copy, nonatomic)NSString *required;
/**
 *  是否允许按类别浏览(分类是否可点) 0-不可点  1-可点
 */
@property(copy, nonatomic)NSString *listable;
/**
 *  0—列表展示时不显示分类；1—显示文字分类；2—显示图标分类
 */
@property(copy, nonatomic)NSString *prefix;
/**
 *  types 分类Id及名称
 */
@property(strong, nonatomic)NSArray *types;
/**
 *  types 分类图标及名称
 */
@property(strong, nonatomic)NSArray *icons;
@end
