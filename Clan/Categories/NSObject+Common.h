//
//  NSObject+Common.h
//  Clan
//
//  Created by chivas on 15/3/4.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Common)
//判断沙盒里是否有表情图片
+ (BOOL)faceImageWithDocument:(NSString *)folderName fileName:(NSString *)fileName;
//取沙盒plist
+ (NSString *)returnPlistWithKeyValue:(NSString *)key;
//修改plist值
+ (void)updatePlistWithName:(NSString *)name andString:(NSString *)string;
//获取fileName的完整地址
+ (NSString* )pathInCacheDirectory:(NSString *)fileName;
+ (NSString* )pathInDocumentDirectory:(NSString *)fileName;
//创建缓存文件夹   
+ (BOOL)createDirInCache:(NSString *)dirName;
- (void)showHudTipStr:(NSString *)tipStr;
-(id)handleResponseWithUpdataImage:(NSString *)responseString;
- (void)showStatusBarSuccessStr:(NSString *)tipStr;
- (void)showStatusBarError:(NSString *)error;
- (void)showStatusBarQueryStr:(NSString *)tipStr;
- (NSString *)URLEncodedString:(NSString *)string;
+ (NSString *)returnStringWithPlist:(NSString *)StringValue;
+ (BOOL )returnBoolWithPlist:(NSString *)StringValue;
+ (void)printplist;

//清除本地的缓存文件
+ (BOOL)deleteLocalThemePlist;

//- (MBProgressHUD *)hudWithTitle:(NSString *)title;
//- (void)hudHide1:(MBProgressHUD *)hud;

@end
