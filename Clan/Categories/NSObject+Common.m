//
//  NSObject+Common.m
//  Clan
//
//  Created by chivas on 15/3/4.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "NSObject+Common.h"
#import "MBProgressHUD.h"
#import "JDStatusBarNotification.h"
#import "ClanError.h"
#import "SVProgressHUD.h"

@implementation NSObject (Common)
//修改plist值
//- (void)updatePlistWithName:(NSString *)name andString:(NSString *)string
//{
//    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)       objectAtIndex:0]stringByAppendingPathComponent:@"ThemeStyle.plist"];
//    NSMutableDictionary *applist = [[[NSMutableDictionary alloc]initWithContentsOfFile:path]mutableCopy];
//    NSString *keyvalue = [applist objectForKey:name];
//    keyvalue = string;
//    [applist setObject:avoidNullStr(keyvalue) forKey:name];
//    [applist writeToFile:path atomically:YES];
//}
//判断沙盒里是否有表情图片
+ (BOOL)faceImageWithDocument:(NSString *)folderName fileName:(NSString *)fileName{
    NSString *documentPath = [[[[NSObject pathInDocumentDirectory:@"ClanFaceImage"]stringByAppendingPathComponent:@"smiley"]stringByAppendingPathComponent:folderName]stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:documentPath]){
        return YES;
    }else{
        return NO;
    }
}
+ (void)updatePlistWithName:(NSString *)name andString:(NSString *)string
{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)       objectAtIndex:0]stringByAppendingPathComponent:@"ThemeStyle.plist"];
    NSMutableDictionary *applist = [[[NSMutableDictionary alloc]initWithContentsOfFile:path]mutableCopy];
    NSString *keyvalue = [applist objectForKey:name];
    keyvalue = string;
    [applist setObject:avoidNullStr(keyvalue) forKey:name];
    [applist writeToFile:path atomically:YES];
}

//获取fileName的完整地址
+ (NSString* )pathInDocumentDirectory:(NSString *)fileName
{
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cachePaths objectAtIndex:0];
    return [cachePath stringByAppendingPathComponent:fileName];
}


+ (void)removedLocalPlistFile
{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)       objectAtIndex:0]stringByAppendingPathComponent:@"ThemeStyle.plist"];
   BOOL removefile = [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    DLog(@"----删除theme plist file: %@", removefile ? @"成功" : @"失败");
}

+ (NSString *)returnPlistWithKeyValue:(NSString *)key{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",ThemeStyle]];
    NSMutableDictionary *applist = [[[NSMutableDictionary alloc]initWithContentsOfFile:path]mutableCopy];
    NSString *value = [applist objectForKey:key];
    return value;
}

+ (BOOL)deleteLocalThemePlist
{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",ThemeStyle]];
    BOOL bb = [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    DLog(@"deleteLocalThemePlist %@", bb ? @"成功" : @"失败");
    return bb;
}
//返回plist文件里的bool
+ (BOOL )returnBoolWithPlist:(NSString *)StringValue
{
    NSString *themePath = [[NSBundle mainBundle]pathForResource:ThemeStyle ofType:@"plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:themePath];
    return YES;
}
//返回plist文件里的string
+ (NSString *)returnStringWithPlist:(NSString *)StringValue
{
    NSString *themePath = [[NSBundle mainBundle]pathForResource:ThemeStyle ofType:@"plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:themePath];
    return dic[StringValue];
}

#pragma mark File M
-(id)handleResponseWithUpdataImage:(NSString*)responseString
{
    if ([responseString isEqualToString:@"0"]) {
        responseString = NetError;
    }else if ([responseString isEqualToString:@"-10"]){
        responseString = @"";
    }else if ([responseString isEqualToString:@"-2"] || [responseString isEqualToString:@"-9"] || [responseString isEqualToString:@"-8"]){
        responseString = @"附件上传失败";
    }
    else if ([responseString isEqualToString:@"-6"] || [responseString isEqualToString:@"-11"]){
        responseString = @"今日上传数已满";
    }
    else if ([responseString isEqualToString:@"-1"] || [responseString isEqualToString:@"-4"]){
        responseString = @"不允许的上传类型";
    }
    else if ([responseString isEqualToString:@"-3"]){
        responseString = @"文件过大,请重新上传";
    }
    else if ([responseString isEqualToString:@"-5"]){
        responseString = @"该类附件空间不足";
    }
    else if ([responseString isEqualToString:@"-7"]){
        responseString = @"附件后缀与实际类型不符";
    }
    return responseString;
}

- (void)showHudTipStr:(NSString *)tipStr{
    if (tipStr && tipStr.length > 0) {
        MBProgressHUD *mbhud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        mbhud.mode = MBProgressHUDModeText;
        mbhud.labelText = tipStr;
        mbhud.margin = 10.f;
        mbhud.removeFromSuperViewOnHide = YES;
        [mbhud hide:YES afterDelay:1.0];
    }
}

- (void)showStatusBarQueryStr:(NSString *)tipStr{
    [JDStatusBarNotification showWithStatus:tipStr styleName:JDStatusBarStyleSuccess];
    [JDStatusBarNotification showActivityIndicator:YES indicatorStyle:UIActivityIndicatorViewStyleWhite];
}

- (void)showStatusBarSuccessStr:(NSString *)tipStr{
    if ([JDStatusBarNotification isVisible]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [JDStatusBarNotification showActivityIndicator:NO indicatorStyle:UIActivityIndicatorViewStyleWhite];
            [JDStatusBarNotification showWithStatus:tipStr dismissAfter:1.5 styleName:JDStatusBarStyleSuccess];
        });
    }else{
        [JDStatusBarNotification showActivityIndicator:NO indicatorStyle:UIActivityIndicatorViewStyleWhite];
        [JDStatusBarNotification showWithStatus:tipStr dismissAfter:1.0 styleName:JDStatusBarStyleSuccess];
    }
}
- (void)showStatusBarError:(NSString *)error
{
    if ([JDStatusBarNotification isVisible]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [JDStatusBarNotification showActivityIndicator:NO indicatorStyle:UIActivityIndicatorViewStyleWhite];
            [JDStatusBarNotification showWithStatus:[self handleResponseWithUpdataImage:error] dismissAfter:1.5 styleName:JDStatusBarStyleError];
        });
    }else{
        [JDStatusBarNotification showActivityIndicator:NO indicatorStyle:UIActivityIndicatorViewStyleWhite];
        [JDStatusBarNotification showWithStatus:[self handleResponseWithUpdataImage:error] dismissAfter:1.5 styleName:JDStatusBarStyleError];
    }
}

//获取fileName的完整地址
+ (NSString* )pathInCacheDirectory:(NSString *)fileName
{
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cachePaths objectAtIndex:0];
    return [cachePath stringByAppendingPathComponent:fileName];
}
//创建缓存文件夹
+ (BOOL) createDirInCache:(NSString *)dirName
{
    NSString *dirPath = [self pathInCacheDirectory:dirName];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
    BOOL isCreated = NO;
    if ( !(isDir == YES && existed == YES) )
    {
        isCreated = [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (existed) {
        isCreated = YES;
    }
    return isCreated;
}

- (NSString *)URLEncodedString:(NSString *)string
{
    CFStringRef stringRef = CFBridgingRetain(string);
    CFStringRef encoded = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                  stringRef,
                                                                  NULL,
                                                                  CFSTR("!*'\"();:@&=+$,/?%#[]% "),
                                                                  kCFStringEncodingUTF8);
    CFRelease(stringRef);
    return CFBridgingRelease(encoded);
}

- (MBProgressHUD *)hudWithTitle:(NSString *)title
{
    MBProgressHUD *_hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    _hud.labelFont = [UIFont systemFontOfSize:14];
    _hud.labelText = title;
    return _hud;
}

- (void)hudHide1:(MBProgressHUD *)hud
{
    [hud hide:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud = nil;
}

@end
