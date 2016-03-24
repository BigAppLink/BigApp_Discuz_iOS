//
//  Util.m
//  Clan
//
//  Created by 昔米 on 15/4/2.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "Util.h"
#import "AFNetworkReachabilityManager.h"
#import <AdSupport/AdSupport.h>
#import "ForumsModel.h"
#import "BoardModel.h"
#import <objc/runtime.h>

@implementation Util
+ (void)copyFile2Documents:(NSString*)fileName
{
    NSFileManager*fileManager =[NSFileManager defaultManager];
    NSError*error;
    NSArray*paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    NSString*destPath =[documentsDirectory stringByAppendingPathComponent:fileName];
    //  如果目标目录也就是(Documents)目录没有数据库文件的时候，才会复制一份，否则不复制
    if(![fileManager fileExistsAtPath:destPath]){
        NSString* sourcePath =[[NSBundle mainBundle] pathForResource:ThemeStyle ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:&error];
        NSLog(@"appkey 沙盒 = %@",[NSString returnStringWithPlist:YZBaseURL]);

    }
}

+ (void)resetLocalFile:(NSString*)fileName
{
    NSFileManager*fileManager =[NSFileManager defaultManager];
    NSError*error;
    NSArray*paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    NSString*destPath =[documentsDirectory stringByAppendingPathComponent:fileName];
    //  如果目标目录也就是(Documents)目录没有数据库文件的时候，才会复制一份，否则不复制
    if(![fileManager fileExistsAtPath:destPath]){
        NSString* sourcePath =[[NSBundle mainBundle] pathForResource:ThemeStyle ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:&error];
        NSLog(@"appkey 沙盒 = %@",[NSString returnStringWithPlist:YZBaseURL]);
    } else {
        NSString *pathVisible = [[NSBundle mainBundle] pathForResource:ThemeStyle ofType:@"plist"];
        NSMutableDictionary *applistVisble = [[[NSMutableDictionary alloc]initWithContentsOfFile:pathVisible]mutableCopy];
        NSMutableDictionary *applistInVisble = [[[NSMutableDictionary alloc]initWithContentsOfFile:destPath]mutableCopy];

        for (NSString *key in applistVisble.allKeys) {
            if (![applistInVisble.allKeys containsObject:key]) {
                DLog(@"多添加了参数。。。。。。。。 %@---- %@",key,applistVisble[key]);
                [applistInVisble setObject:avoidNullStr(applistVisble[key]) forKey:key];
            }
        }
        [applistInVisble writeToFile:destPath atomically:YES];
    }
}

//拿到plist ISReadDone
+ (BOOL)returnIsReadBoolWithPlist:(NSString *)boolValuekey
{
    return YES;
}

//邮箱验证
+ (BOOL) validateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

/**
 * 判断字符串是否为空
 */
+ (BOOL)isBlankString:(NSString *)string
{
    if (string == nil || string == NULL) {
        
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        
        return YES;
    }
    return NO;
}


/**
 * 计算text的size
 */
+ (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font constraintSize:(CGSize)constraintSize
{
    if (!string) {
        
        return CGSizeZero;
    }
    CGSize stringSize = CGSizeZero;
    if (kIOS7) {
        
        NSDictionary *attributes = @{NSFontAttributeName:font};
        NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
        CGRect stringRect = [string boundingRectWithSize:constraintSize options:options attributes:attributes context:NULL];
        stringSize = stringRect.size;
    }
    else {
        stringSize = [string sizeWithFont:font constrainedToSize:constraintSize];
        stringSize.height += font.lineHeight;
    }
    return stringSize;
}


/**
 *将 timestamp 格式转化成 NSString
 */

+ (NSString *)changeTimestampToStr:(NSString *)time
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[time doubleValue]];
    NSDateFormatter *fm = [[NSDateFormatter alloc] init];
    [fm setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateStr = [fm stringFromDate:date];
    return dateStr;
}

/**
 * 时间比较
 */
+ (NSString *)compareTime:(NSDate *)date1 withTime:(NSDate *)date2
{
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy.MM.dd HH:mm"];
    //用[NSDate date]可以获取系统当前时间
    NSString *dateStr = [dateFormatter stringFromDate:date1];
    NSTimeInterval time = [date2 timeIntervalSinceDate:date1];
    int days = ((int)time)/(3600*24);
    int hours = ((int)time)%(3600*24)/3600;
    int mins = ((int)time)%(3600*24)%3600/60;
    NSString *dateContent = [[NSString alloc] init];
    if (days == 0 && hours == 0 && mins <= 0) {
        dateContent = [dateContent stringByAppendingString:@"刚刚"];
    }
    else if (days == 0 && hours == 0 && mins <= 59) {
        dateContent = [dateContent stringByAppendingString:[NSString stringWithFormat:@"%d分钟前",mins]];
    }
    else if(days == 0 && hours <= 23) {
        dateContent = [dateContent stringByAppendingString:[NSString stringWithFormat:@"%d小时前",hours]];
    }
    else if (mins < 0) {
        dateContent = [dateContent stringByAppendingString:@"刚刚"];
    }
    else {
        dateContent = dateStr;
    }
    return dateContent;
}

//毫秒改变成NSdate
+ (NSDate *)changeTimestamp:(NSString *)time
{
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[time intValue]];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:confromTimesp];
    NSDate *localeDate = [confromTimesp  dateByAddingTimeInterval: interval];
    return localeDate;
}

//获取当前时间
+ (NSDate *)getCurrentTime
{
    return [NSDate date];
}

//隐藏tableview底部多余的线
+ (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [tableView backgroundColor];
    [tableView setTableFooterView:view];
}

//判断是否收藏
+ (BOOL)isFavoed_withID:(NSString *)sid forType:(CollcetionType)type
{
    NSString *fileKey = nil;
    switch (type) {
        case myPost:
            fileKey = kKEY_FAVO_THREADS;
            break;
        case myPlate:
            fileKey = kKEY_FAVO_FORUMS;
            break;
        case myArticle:
            fileKey = kKEY_FAVO_ARTICLES;
            break;
        default:
            fileKey = kKEY_FAVO_THREADS;
            break;
    }
    if (!fileKey) {
        return NO;
    }
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:fileKey];
    return [dic.allKeys containsObject:sid];
}

//删除本地收藏
+ (void)deleteFavoed_withID:(NSString *)sid forType:(CollcetionType)type
{
    NSString *fileKey = nil;
    switch (type) {
        case myPost:
            fileKey = kKEY_FAVO_THREADS;
            break;
        case myPlate:
            fileKey = kKEY_FAVO_FORUMS;
            break;
        case myArticle:
            fileKey = kKEY_FAVO_ARTICLES;
            break;
        default:
            fileKey = kKEY_FAVO_THREADS;
            break;
    }
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:fileKey];
    if (!dic) {
        dic = [NSDictionary new];
    }
    if (dic && [dic.allKeys containsObject:sid]) {
        DLog(@"删除帖子 %@",sid);
        NSMutableDictionary *dic1 = [NSMutableDictionary dictionaryWithDictionary:dic];
        [dic1 removeObjectForKey:sid];
        [[NSUserDefaults standardUserDefaults] setObject:dic1 forKey:fileKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//增加本地收藏
+ (BOOL)addFavoed_withID:(NSString *)sid withFavoID:(NSString *)favoID forType:(CollcetionType) type
{
    if (!favoID || !sid) {
        return NO;
    }
    NSString *fileKey = nil;
    switch (type) {
        case myPost:
            fileKey = kKEY_FAVO_THREADS;
            break;
        case myPlate:
            fileKey = kKEY_FAVO_FORUMS;
            break;
        case myArticle:
            fileKey = kKEY_FAVO_ARTICLES;
            break;
        default:
            fileKey = kKEY_FAVO_THREADS;
            break;
    }
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:fileKey];
    if (!dic) {
        dic = [NSDictionary new];
    }
    if (dic && ![dic.allKeys containsObject:sid]) {
        NSMutableDictionary *dic1 = [[NSMutableDictionary alloc]initWithDictionary:dic];
        if (favoID) {
            [dic1 setObject:favoID forKey:sid];
            [[NSUserDefaults standardUserDefaults] setObject:dic1 forKey:fileKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    return YES;
}

//清除收藏
+ (void)cleanUpLocalFavoArray
{
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:kKEY_FAVO_THREADS];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:kKEY_FAVO_FORUMS];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:kKEY_FAVO_ARTICLES];
}

//通过帖子或者版块ID 得到收藏ID
+ (NSString *)getFavoIDFromID:(NSString *)fid forType:(CollcetionType)type
{
    NSString *fileKey = nil;
    switch (type) {
        case myPost:
            fileKey = kKEY_FAVO_THREADS;
            break;
        case myPlate:
            fileKey = kKEY_FAVO_FORUMS;
            break;
        case myArticle:
            fileKey = kKEY_FAVO_ARTICLES;
            break;
        default:
            fileKey = kKEY_FAVO_THREADS;
            break;
    }
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:fileKey];
    return dic[fid];
}

+ (BOOL)isNetWorkAvalible
{
    AFNetworkReachabilityManager *afNetworkReachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [afNetworkReachabilityManager startMonitoring];  //开启网络监视器；
    
    //    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(afNetworkStatusChanged:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    [afNetworkReachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:{
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi:{
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWWAN:{
                break;
            }
            default:
                break;
        }
    }];
    
    return [AFNetworkReachabilityManager sharedManager].isReachable;
}


+ (BOOL)isNetWorkWifiAvalible
{
    __block BOOL _isAvalible;
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
            _isAvalible = YES;
        }
    }];
    return _isAvalible;
}


+ (NSString *)currentBuildID
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *currentBuildID = [infoDict objectForKey:@"CFBundleIdentifier"];
    return currentBuildID;
}

+ (NSString *)currentBuildVersion
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *currentBuildVersion = [infoDict objectForKey:@"CFBundleVersion"];
    return currentBuildVersion;
}

+ (NSString *)currentAppVersion
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *currentBuildVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
    return currentBuildVersion;
}

+ (NSString *)currentResulostion
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    CGSize screenSize = CGSizeMake(screenBounds.size.width * screenScale, screenBounds.size.height * screenScale);
    return [NSString stringWithFormat:@"%fx%f",screenSize.width,screenSize.height];
}

+ (NSString *)appName
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.f, 1.f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color withFrame:(CGRect)aFrame
{
    UIGraphicsBeginImageContext(aFrame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, aFrame);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


+ (NSString *)formatHtmlString:(NSString *) htmlString
{
    if ([Util isBlankString:htmlString]) {
        return @"";
    }
    NSScanner * scanner = [NSScanner scannerWithString:htmlString];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        htmlString = [htmlString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    // 定义HTML标签的正则表达式
    NSString * regEx = @"<([^>]*)>";
    htmlString = [htmlString stringByReplacingOccurrencesOfString:regEx withString:@""];
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<br/>" withString:@""];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<div>" withString:@""];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"</div>" withString:@""];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@" " withString:@""];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&mdash;" withString:@"--"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&ldquo;" withString:@"“"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&rdquo;" withString:@"”"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"/>" withString:@""];
    htmlString = [htmlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return htmlString;
}

+ (BOOL)returnBoolWithPlist:(NSString *)boolValuekey
{
    NSString *themePath = [[NSBundle mainBundle]pathForResource:ThemeStyle ofType:@"plist"];
    NSDictionary *myDict = [[NSDictionary alloc] initWithContentsOfFile:themePath];
    BOOL myBool = [[myDict objectForKey:boolValuekey] boolValue];
    return myBool;
}

//文章是否读过
+ (BOOL)hasRead:(NSString *)pid
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"k_read_list"]) {
        return NO;
    }
    NSMutableArray *Arr = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"k_read_list"]];
    if ([Arr containsObject:pid])
        return YES;
    else
        return NO;
}

#pragma mark - 已读
+ (void)readPost:(NSString *)pid
{
    NSMutableArray *Arr = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"k_read_list"]];
    if (![Arr containsObject:pid]) {
        [Arr addObject:pid];
        if (Arr.count > 10000) {
            [Arr removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(99, 10000-100)]];
        }
        [[NSUserDefaults standardUserDefaults] setObject:Arr forKey:@"k_read_list"];
    }
}

+ (void)cleanUpReadPosts
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray new] forKey:@"k_read_list"];

}

+ (void)cleanUserInfo
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"kLASTUSERNAME_YouZu"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"kLASTUSERNAME"];
}

+ (NSString *)identifierForAdvertising
{
    NSUUID *IDFA = [[ASIdentifierManager sharedManager] advertisingIdentifier];
    
    return [IDFA UUIDString];
}

+ (NSString *)networkStatus
{
    AFNetworkReachabilityStatus status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    switch (status) {
        case AFNetworkReachabilityStatusNotReachable:
            return @"无网络";
            break;
        case AFNetworkReachabilityStatusUnknown:
            return @"未知网络";
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            return @"wifi";
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            return @"WWAN";
            break;
        default:
            return @"未知";
            break;
    }
}

+ (UIImage *)xuxian
{
    UIImage *image = nil;
    UIGraphicsBeginImageContext(CGSizeMake(kSCREEN_WIDTH, 2));   //开始画线
    [image drawInRect:CGRectMake(0, 0, kSCREEN_WIDTH-30, 2)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);  //设置线条终点形状
    CGFloat lengths[] = {10,5};
    CGContextRef line = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(line, [UIColor redColor].CGColor);
    CGContextSetLineDash(line, 0, lengths, 2);  //画虚线
    CGContextMoveToPoint(line, 0.0, 20.0);    //开始画线
    CGContextAddLineToPoint(line, 310.0, 20.0);
    CGContextStrokePath(line);
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    return image;
}

+ (UIImageView *)portraitImageViewWithFrame:(CGRect)rect
{
    UIImageView * _portraitImageView = [[UIImageView alloc] initWithFrame:rect];
    [_portraitImageView.layer setCornerRadius:(rect.size.height/2)];
    [_portraitImageView.layer setMasksToBounds:YES];
    [_portraitImageView setContentMode:UIViewContentModeScaleAspectFill];
    [_portraitImageView setClipsToBounds:YES];
    _portraitImageView.userInteractionEnabled = YES;
    _portraitImageView.backgroundColor = [UIColor clearColor];
    return _portraitImageView;
}

+ (void)addBorderForImageView:(UIImageView *)iv
{
    //    iv.layer.shadowColor = [UIColor blackColor].CGColor;
    //    iv.layer.shadowOffset = CGSizeMake(4, 4);
    //    iv.layer.shadowOpacity = 0.5;
    //    iv.layer.shadowRadius = 2.0;
    iv.layer.borderColor = [[UIColor whiteColor] CGColor];
    iv.layer.borderWidth = 1.0f;
}

//返回plist文件里的bool
+ (void)dayinplist
{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)       objectAtIndex:0]stringByAppendingPathComponent:@"ThemeStyle.plist"];
    NSMutableDictionary *applist = [[[NSMutableDictionary alloc]initWithContentsOfFile:path]mutableCopy];
    DLog(@"app配置文件 --- 【%@】",applist);
}

//裁剪图片
+ (UIImage *)imageResize:(UIImage*)img andResizeTo:(CGSize)newSize
{
    CGFloat scale = [[UIScreen mainScreen]scale];
    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    [img drawInRect:CGRectMake(0, 0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIColor *)mainThemeColor
{
    return [UIColor returnColorWithPlist:YZSegMentColor];
}

+ (UIImage *)mainThemeImage
{
  return  [Util imageWithColor:[UIColor returnColorWithPlist:YZSegMentColor]];
}

+ (void)setButton:(UIButton *)btn withCellButtonType:(CellButtonType)type
{
    switch (type) {
        case CellButtonTypeAdd:
            btn.enabled = YES;
            btn.layer.borderColor = kCOLOR_BORDER.CGColor;
            btn.layer.borderWidth = 0.5f;
            [btn setTitleColor:K_COLOR_DARK forState:UIControlStateNormal];
            [btn setBackgroundImage:[Util imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
            [btn setTitle:@"加好友" forState:UIControlStateNormal];
            break;
        case CellButtonTypeAdded:
            btn.enabled = NO;
            btn.layer.borderColor = kCLEARCOLOR.CGColor;
            btn.layer.borderWidth = 0.f;
            [btn setTitleColor:K_COLOR_GRAY forState:UIControlStateNormal];
            [btn setBackgroundImage:nil forState:UIControlStateNormal];
            [btn setTitle:@"已添加" forState:UIControlStateNormal];
            break;
        case CellButtonTypeIgnore:
            btn.enabled = YES;
            btn.layer.borderColor = kCOLOR_BORDER.CGColor;
            btn.layer.borderWidth = 0.5f;
            [btn setTitleColor:K_COLOR_GRAY forState:UIControlStateNormal];
            [btn setBackgroundImage:[Util imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
            [btn setTitle:@"忽略" forState:UIControlStateNormal];
            break;
        case CellButtonTypeIgnored:
            btn.enabled = NO;
            btn.layer.borderColor = kCLEARCOLOR.CGColor;
            btn.layer.borderWidth = 0.f;
            [btn setTitleColor:K_COLOR_GRAY forState:UIControlStateNormal];
            [btn setBackgroundImage:nil forState:UIControlStateNormal];
            [btn setTitle:@"已忽略" forState:UIControlStateNormal];
            break;
        case CellButtonTypeApplyed:
            btn.enabled = NO;
            btn.layer.borderColor = kCLEARCOLOR.CGColor;
            btn.layer.borderWidth = 0.f;
            [btn setTitleColor:K_COLOR_GRAY forState:UIControlStateNormal];
            [btn setBackgroundImage:nil forState:UIControlStateNormal];
            [btn setTitle:@"已申请" forState:UIControlStateNormal];
            break;
        case CellButtonTypeAlreadyFriend:
            btn.enabled = NO;
            btn.layer.borderColor = kCLEARCOLOR.CGColor;
            btn.layer.borderWidth = 0.f;
            [btn setTitleColor:K_COLOR_GRAY forState:UIControlStateNormal];
            [btn setBackgroundImage:nil forState:UIControlStateNormal];
            [btn setTitle:@"已是好友" forState:UIControlStateNormal];
        default:
            break;
    }
}

+ (ForumsModel *)boardFormCache:(NSString *)fid
{
    [SVProgressHUD show];
    id cacheData = [[CacheManager sharedCacheManager] cacheForModule:kCacheModule_Forum];
    id resultData = [cacheData valueForKeyPath:@"Variables"];
    for (NSDictionary *dic in [resultData objectForKey:@"forums"]) {
        BoardModel *boardModel = [BoardModel objectWithKeyValues:dic];
        for (ForumsModel *forums in boardModel.forums) {
            if ([forums.fid isEqualToString:fid]) {
                return forums;
            }
        }
    }
    return nil;
}

+ (void)saveCookieData
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in cookies) {
        // Here I see the correct rails session cookie
        DebugLog(@"\nSave cookie: \n====================\n%@", cookie);
    }
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: cookiesData forKey: Code_CookieData];
    [defaults synchronize];
}

//获取启动图的名称
+ (NSString *)splashImageName
{
    CGSize viewSize = CGSizeMake(kSCREEN_WIDTH, kSCREEN_HEIGHT);
    NSString* viewOrientation = @"Portrait";
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict) {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
            return dict[@"UILaunchImageName"];
    }
    return nil;
}

+ (NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([obj class], &count);
    
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        if ([obj valueForKey:key] ) {
            [dict setObject:[obj valueForKey:key] forKey:key];
        }
    }
    
    free(properties);
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

+ (UIImage *)circleCoveredImage
{
    return kIMG(@"faceCornerRadius");
}

@end
