//
//  ReportViewController.h
//  Clan
//
//  Created by chivas on 15/8/4.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Report;
@protocol PostActivityDelegate <NSObject>

@optional
- (void) postActivityType:(NSString *)type;

@end
typedef enum : NSUInteger {
    /** 普通闲置状态 */
    ClanReportDefault,
    /** 用户举报状态 */
    ClanReportUser,
    /** 帖子举报状态 */
    ClanReportTPost,
    /** 主题帖子类型*/
    ClanActivityPost
} ClanReport;
@interface ReportViewController : BaseViewController
@property (strong, nonatomic) Report *reportModel;
//举报控件状态
@property (assign, nonatomic) ClanReport state;
@property (strong, nonatomic) NSArray *activityArray;
@property (assign, nonatomic) id<PostActivityDelegate>delegate;
@end
