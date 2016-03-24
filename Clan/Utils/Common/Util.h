//
//  Util.h
//  Clan
//
//  Created by 昔米 on 15/4/2.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    CellButtonTypeAdded = 0,
    CellButtonTypeAdd,
    CellButtonTypeIgnore,
    CellButtonTypeIgnored,
    CellButtonTypeApplyed,
    CellButtonTypeAlreadyFriend,
}CellButtonType;

@interface Util : NSObject
/**
 * 复制plist
 */

+(void)copyFile2Documents:(NSString*)fileName;

/**
 * 拿到plist ISReadDone
 */
+ (BOOL)returnIsReadBoolWithPlist:(NSString *)boolValuekey;
/**
 * 邮箱验证
 */
+ (BOOL) validateEmail:(NSString *)email;
/**
 * 判断字符串是否为空
 */
+ (BOOL)isBlankString:(NSString *)string;

/**
 * 计算text的size
 */
+ (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font constraintSize:(CGSize)constraintSize;

/**
 *将 timestamp 格式转化成 NSString
 */
+ (NSString *)changeTimestampToStr:(NSString *)time;

//毫秒改变成NSdate
+ (NSDate *)changeTimestamp:(NSString *)time;

/**
 * 时间比较
 */
+ (NSString *)compareTime:(NSDate *)date1 withTime:(NSDate *)date2;

//获取当前时间
+ (NSDate *)getCurrentTime;

//去掉table多余的线
+ (void)setExtraCellLineHidden: (UITableView *)tableView;

//判断是否收藏
+ (BOOL)isFavoed_withID:(NSString *)sid forType:(CollcetionType)type;

//删除本地收藏
+ (void)deleteFavoed_withID:(NSString *)sid forType:(CollcetionType)type;

//增加本地收藏
+ (BOOL)addFavoed_withID:(NSString *)sid withFavoID:(NSString *)favoID forType:(CollcetionType)type;

//清除收藏
+ (void)cleanUpLocalFavoArray;

//通过帖子或者版块ID 得到收藏ID
+ (NSString *)getFavoIDFromID:(NSString *)fid forType:(CollcetionType)type;

+ (BOOL)isNetWorkAvalible;

+ (BOOL)isNetWorkWifiAvalible;

+ (NSString *)currentBuildID;

+ (NSString *)currentBuildVersion;

+ (NSString *)currentAppVersion;
//分辨率
+ (NSString *)currentResulostion;

+ (NSString *)appName;


+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color withFrame:(CGRect)aFrame;
+ (NSString *)formatHtmlString:(NSString *) htmlString;

+ (BOOL)returnBoolWithPlist:(NSString *)boolValuekey;

+ (BOOL)hasRead:(NSString *)pid;

+ (void)readPost:(NSString *)pid;

+ (NSString *)identifierForAdvertising;

+ (NSString *)networkStatus;

+ (UIImage *)xuxian;

+ (void)cleanUpReadPosts;

+ (void)cleanUserInfo;

+ (UIImageView *)portraitImageViewWithFrame:(CGRect)rect;

+ (void)addBorderForImageView:(UIImageView *)iv;

//返回plist文件里的bool
+ (void)dayinplist;

+ (UIColor *)mainThemeColor;
+ (UIImage *)mainThemeImage;

+ (void)setButton:(UIButton *)btn withCellButtonType:(CellButtonType)type;

+ (ForumsModel *)boardFormCache:(NSString *)fid;

#pragma mark - Custom Methods
+ (void)saveCookieData;

+ (void)resetLocalFile:(NSString*)fileName;

+ (UIImage *)imageResize :(UIImage*)img andResizeTo:(CGSize)newSize;

//获取启动图的名称
+ (NSString *)splashImageName;

+ (NSDictionary *)dictionaryWithPropertiesOfObject:(id)obj;

+ (UIImage *)circleCoveredImage;

@end
