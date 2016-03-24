//
//  AppConfigViewModel.m
//  Clan
//
//  Created by 昔米 on 15/9/1.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "AppConfigViewModel.h"
#import "FaceImageViewModel.h"
#import "HomeViewModel.h"
#import "ArticleModel.h"

@interface AppConfigViewModel()
@property (nonatomic, strong) FaceImageViewModel *faceViewModel;
@end
@implementation AppConfigViewModel

#pragma mark - request

//获取app的一些配置信息
- (void)requestAppConfig:(dispatch_group_t)group
{
    DLog(@"requestAppConfigrequestAppConfigrequestAppConfigrequestAppConfigrequestAppConfig");
    WEAKSELF
    [[Clan_NetAPIManager sharedManager]request_AppInfoWithBlock:^(id data, NSError *error) {
        if (!error && data) {
            dispatch_group_leave(group);
            NSDictionary *config = [data valueForKey:@"config"];
            NSDictionary *platform_login_dic = config[@"platform_login"];
            if (platform_login_dic && [platform_login_dic isKindOfClass:[NSDictionary class]]) {
                //QQ登录支持
                NSString *url_qqlogin = platform_login_dic[@"qqlogin"];
                NSString *url_qqlogin_end = platform_login_dic[@"qqlogin_end"];
                [NSString updatePlistWithName:kurl_qqlogin andString:avoidNullStr(url_qqlogin)];
                [NSString updatePlistWithName:kurl_qqlogin_end andString:avoidNullStr(url_qqlogin_end)];
                //微信登录支持
                NSString *wechat_login = platform_login_dic[@"wechat_login"];
                [NSString updatePlistWithName:kwechatSwitch andString:avoidNullStr(wechat_login)];
                //微博登录支持
                NSString *weibo_login = platform_login_dic[@"weibo_login"];
                [NSString updatePlistWithName:kweiboSwitch andString:avoidNullStr(weibo_login)];
            }
            
            //登录注册配置开关 调整到app配置接口
            NSDictionary *login_info_dic = config[@"login_info"];
            if (login_info_dic && [login_info_dic isKindOfClass:[NSDictionary class]] &&login_info_dic.count > 0) {
                NSString *login_mod = login_info_dic[@"login_mod"];
                if (login_mod && ![login_mod isKindOfClass:[NSNull class]] && login_mod.intValue == 1) {
                    //开启web登录
                    [NSString updatePlistWithName:@"URLWebLogin" andString:avoidNullStr(login_info_dic[@"login_url"])];
                }
                else if (login_mod && ![login_mod isKindOfClass:[NSNull class]] && login_mod.intValue == 0){
                    //关闭web登录
                    [NSString updatePlistWithName:@"URLWebLogin" andString:@""];
                }
                NSString *reg_mod = login_info_dic[@"reg_mod"];
                if (reg_mod && ![reg_mod isKindOfClass:[NSNull class]] && reg_mod.intValue == 1) {
                    //开启web注册
                    [NSString updatePlistWithName:@"URLWebReg" andString:avoidNullStr(login_info_dic[@"reg_url"])];
                }
                else if (reg_mod && ![reg_mod isKindOfClass:[NSNull class]] && reg_mod.intValue == 0){
                    //关闭web注册
                    [NSString updatePlistWithName:@"URLWebReg" andString:@""];
                }
                NSNumber *reg_switch = login_info_dic[@"reg_switch"];
                if (reg_switch && reg_switch.intValue == 0) {
                    //关闭注册入口
                    [NSString updatePlistWithName:@"RegSwitch" andString:@"0"];
                }
                else if(reg_switch && reg_switch.intValue == 1) {
                    //默认开启注册入口
                    [NSString updatePlistWithName:@"RegSwitch" andString:@"1"];
                }
                NSNumber *allow_avatar_change = login_info_dic[@"allow_avatar_change"];
                if (!allow_avatar_change || allow_avatar_change.intValue == 1) {
                    //打开头像上传
                    [NSString updatePlistWithName:KAllowAvatarChange andString:@"1"];
                }
                else if (!allow_avatar_change || allow_avatar_change.intValue == 0){
                    //关闭头像上传
                    [NSString updatePlistWithName:KAllowAvatarChange andString:@"0"];
                }
            }
            
            //判断是否需要下载zip包
            //临时MD5
            if (config[@"smiley_info"]) {
                [UserDefaultsHelper saveDefaultsValue:config[@"smiley_info"][@"md5"]  forKey:kUserDefaultsKey_ClanZipTempMd5];
                NSString *clanZipMd5 = [UserDefaultsHelper valueForDefaultsKey:kUserDefaultsKey_ClanZipMd5];
                if (isNull(config[@"smiley_info"][@"md5"])) {
                    [UserDefaultsHelper saveBoolValue:NO forKey:kUserDefaultsKey_ClanZipIsDown];
                } else {
                    BOOL isDownLoad = [clanZipMd5 isEqualToString:config[@"smiley_info"][@"md5"]] ? YES : NO;
                    [UserDefaultsHelper saveBoolValue:isDownLoad forKey:kUserDefaultsKey_ClanZipIsDown];
                }
                [UserDefaultsHelper saveDefaultsValue:config[@"smiley_info"][@"zip_url"]  forKey:kUserDefaultsKey_ClanZipPath];
                [UserDefaultsHelper saveDefaultsValue:config[@"smiley_info"][@"zip_info"] forKey:kUserDefaultsKey_ClanZipJsonInfo];
                [weakSelf faceImageType];
            }
            
            NSString *boardStyle = nil;
            //版块儿列表样式
            if (config && [config objectForKey:@"display_style"]) {
                id bs = [config objectForKey:@"display_style"];
                if ([bs isKindOfClass:[NSNumber class]]) {
                    boardStyle = [NSString stringWithFormat:@"%@",bs];
                } else {
                    boardStyle = [config objectForKey:@"display_style"];
                }
                if (boardStyle && boardStyle.length > 0) {
                    [NSString updatePlistWithName:kBOARDSTYLE andString:boardStyle];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"GET_kBOARDSTYLE" object:nil];
                }
            }
            //签到开关
            if (config && [config objectForKey:@"checkin_enabled"]) {
                NSString *checkin_enabled = config[@"checkin_enabled"];
                [NSString updatePlistWithName:kcheckin_enabled andString:checkin_enabled];
            }
            //搜索开关
            if (config[@"searchsetting"]) {
                [UserDefaultsHelper saveDefaultsValue:config[@"searchsetting"] forKey:kUserDefaultsKey_ClanSearchSetting];
            }
            //列表开关
            if (config[@"threadconfig"]) {
                [UserDefaultsHelper saveDefaultsValue:config[@"threadconfig"] forKey:kUserDefaultsKey_ClanCustomVc];
            }
            //文章开关
            if (config[@"portalconfig"]) {
                NSMutableArray *articleArray = nil;
                NSArray *array = config[@"portalconfig"];
                if (!isNull(array)) {
                    articleArray = [NSMutableArray arrayWithCapacity:array.count];
                    [articleArray removeAllObjects];
                    for (NSDictionary *dic in array) {
                        ArticleModel *articleModel = [ArticleModel objectWithKeyValues:dic];
                        NSData *udObject = [NSKeyedArchiver archivedDataWithRootObject:articleModel];
                        [articleArray addObject:udObject];
                    }

                }
                [UserDefaultsHelper saveDefaultsValue:articleArray forKey:kUserDefaultsKey_ClanArticleList];
            }
            //关于我们描述信息
            if (config && [config objectForKey:@"appdesc"]) {
                NSString *appdesc = config[@"appdesc"];
                [NSString updatePlistWithName:kAppDescription andString:isNull(appdesc) ? @"" : appdesc];
            }
        }else{
            dispatch_group_leave(group);
        }
    }];
}

- (void)requestHomeConfig:(dispatch_group_t)group{
    [[Clan_NetAPIManager sharedManager]request_HomeConfig:^(id data, NSError *error) {
        dispatch_group_leave(group);
            //首页
        if (data && [data objectForKey:@"Variables"][@"button_configs"]) {
            [[TMCache sharedCache] setObject:[data objectForKey:@"Variables"][@"button_configs"] forKey:@"ClanTabBarStyle"];
        }
    }];
}


#pragma mark - 拉取表情包
- (void)faceImageType
{
    if (!_faceViewModel) {
        _faceViewModel = [FaceImageViewModel new];
    }
    WEAKSELF
    BOOL isDown = [UserDefaultsHelper boolValueForDefaultsKey:kUserDefaultsKey_ClanZipIsDown];
    if (!isDown) {
        [weakSelf downZipAndJsonWithZipUrl:[UserDefaultsHelper valueForDefaultsKey:kUserDefaultsKey_ClanZipPath]];
    }
}

- (void)downZipAndJsonWithZipUrl:(NSString *)url
{
    __block NSInteger statusCount = 0;
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_async(group, queue, ^{
        [_faceViewModel request_downloadFaceJsonWithBlock:^(BOOL isDownload) {
            //拉取表情json文件
            if (isDownload) {
                statusCount ++;
                DLog(@"request_downloadFaceJsonWithBlock----- %ld",statusCount);
            }
            dispatch_group_leave(group);
        }];
    });
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^{
        [_faceViewModel request_downloadFaceWithUrl:url andBlock:^(BOOL isDownload) {
            if (isDownload) {
                statusCount ++;
                DLog(@"request_downloadFaceWithUrl----- %ld",statusCount);
            }
            dispatch_group_leave(group);
        }];
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //全部完成后回调
        NSString *documentPath = [[NSObject pathInDocumentDirectory:@"ClanFaceImage"]stringByAppendingPathComponent:@"smiley"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        DLog(@"dispatch_get_main_queue----- %ld",statusCount);
        if (statusCount == 2 && [fileManager fileExistsAtPath:documentPath]) {
            NSString *tempValue = [UserDefaultsHelper valueForDefaultsKey:kUserDefaultsKey_ClanZipTempMd5];
            [UserDefaultsHelper saveDefaultsValue:tempValue forKey:kUserDefaultsKey_ClanZipMd5];
            [UserDefaultsHelper saveBoolValue:YES forKey:kUserDefaultsKey_ClanZipIsDown];
        }
    });
}

#pragma mark - 重置plist文件
- (void)resetInitPlist
{
    //复制plist文件进沙盒
    [Util copyFile2Documents:[NSString stringWithFormat:@"%@.plist",ThemeStyle]];
}

- (void)resetLocalPlist
{
    //复制plist文件进沙盒
    [Util resetLocalFile:[NSString stringWithFormat:@"%@.plist",ThemeStyle]];
}

#pragma mark - public方法
//获取app的基础配置信息 来自站长中心
- (void)getAppBaseConfigWithBlock:(void(^)(BOOL result))block
{
    [self checkAndresetAppBaseDatas];
    block (YES);
}

//来自插件后台的配置
- (void)getAppPlugcfgWithBlock:(void(^)(BOOL result))block
{
    WEAKSELF
    [[Clan_NetAPIManager sharedManager]request_AppInfoWithBlock:^(id data, NSError *error) {
        if (!error && data) {
            [weakSelf dealWithPlugcfgDatas:data];
            block(YES);
        }else{
            block(NO);
        }
    }];
}

//app tab整体的配置信息
- (void)getAppHomeIndexcfgWithBlock:(void(^)(BOOL result))block
{
    [[Clan_NetAPIManager sharedManager]request_HomeConfig:^(id data, NSError *error) {
        //首页
        if (!error && data && [data isKindOfClass:[NSDictionary class]]) {
            id indexcfgData = [data objectForKey:@"Variables"][@"button_configs"];
            if (indexcfgData) {
                [[TMCache sharedCache] setObject:indexcfgData forKey:@"ClanTabBarStyle"];
                block(YES);
            }
            block(NO);
        } else {
            block(NO);
        }
    }];
}

//获取所有的版块儿信息
- (void)requestBoardList
{
    HomeViewModel *home = [HomeViewModel new];
    [home request_boardBlock:^(id data) {
        
    }];
}

//获取所有的版块儿信息
- (void)requestBoardListWithBlock:(void(^)(BOOL result))block
{
    HomeViewModel *home = [HomeViewModel new];
    [home request_boardBlock:^(id data) {
        block(YES);
    }];
}

#pragma mark - 自定义方法
//检查并重置app的基础数据
- (void)checkAndresetAppBaseDatas
{
    //把未加入的key加入
    [self resetLocalPlist];
}

//处理插件后台的配置信息
- (void)dealWithPlugcfgDatas:(id)data
{
    NSDictionary *config = [data valueForKey:@"config"];
    NSDictionary *platform_login_dic = config[@"platform_login"];
    if (platform_login_dic && [platform_login_dic isKindOfClass:[NSDictionary class]]) {
        //QQ登录支持
        NSString *url_qqlogin = platform_login_dic[@"qqlogin"];
        NSString *url_qqlogin_end = platform_login_dic[@"qqlogin_end"];
        [NSString updatePlistWithName:kurl_qqlogin andString:avoidNullStr(url_qqlogin)];
        [NSString updatePlistWithName:kurl_qqlogin_end andString:avoidNullStr(url_qqlogin_end)];
        //微信登录支持
        NSString *wechat_login = platform_login_dic[@"wechat_login"];
        [NSString updatePlistWithName:kwechatSwitch andString:avoidNullStr(wechat_login)];
        //微博登录支持
        NSString *weibo_login = platform_login_dic[@"weibo_login"];
        [NSString updatePlistWithName:kweiboSwitch andString:avoidNullStr(weibo_login)];
    }
    
    //登录注册配置开关 调整到app配置接口
    NSDictionary *login_info_dic = config[@"login_info"];
    if (login_info_dic && [login_info_dic isKindOfClass:[NSDictionary class]] &&login_info_dic.count > 0) {
        NSString *login_mod = login_info_dic[@"login_mod"];
        if (login_mod && ![login_mod isKindOfClass:[NSNull class]] && login_mod.intValue == 1) {
            //开启web登录
            [NSString updatePlistWithName:@"URLWebLogin" andString:avoidNullStr(login_info_dic[@"login_url"])];
        }
        else if (login_mod && ![login_mod isKindOfClass:[NSNull class]] && login_mod.intValue == 0){
            //关闭web登录
            [NSString updatePlistWithName:@"URLWebLogin" andString:@""];
        }
        NSString *reg_mod = login_info_dic[@"reg_mod"];
        if (reg_mod && ![reg_mod isKindOfClass:[NSNull class]] && reg_mod.intValue == 1) {
            //开启web注册
            [NSString updatePlistWithName:@"URLWebReg" andString:avoidNullStr(login_info_dic[@"reg_url"])];
        }
        else if (reg_mod && ![reg_mod isKindOfClass:[NSNull class]] && reg_mod.intValue == 0){
            //关闭web注册
            [NSString updatePlistWithName:@"URLWebReg" andString:@""];
        }
        NSNumber *reg_switch = login_info_dic[@"reg_switch"];
        if (reg_switch && reg_switch.intValue == 0) {
            //关闭注册入口
            [NSString updatePlistWithName:@"RegSwitch" andString:@"0"];
        }
        else if(reg_switch && reg_switch.intValue == 1) {
            //默认开启注册入口
            [NSString updatePlistWithName:@"RegSwitch" andString:@"1"];
        }
        NSNumber *allow_avatar_change = login_info_dic[@"allow_avatar_change"];
        if (!allow_avatar_change || allow_avatar_change.intValue == 1) {
            //打开头像上传
            [NSString updatePlistWithName:KAllowAvatarChange andString:@"1"];
        }
        else if (!allow_avatar_change || allow_avatar_change.intValue == 0){
            //关闭头像上传
            [NSString updatePlistWithName:KAllowAvatarChange andString:@"0"];
        }
    }
    
    //判断是否需要下载zip包
    //临时MD5
    if (config[@"smiley_info"]) {
        [UserDefaultsHelper saveDefaultsValue:config[@"smiley_info"][@"md5"]  forKey:kUserDefaultsKey_ClanZipTempMd5];
        NSString *clanZipMd5 = [UserDefaultsHelper valueForDefaultsKey:kUserDefaultsKey_ClanZipMd5];
        if (isNull(config[@"smiley_info"][@"md5"])) {
            [UserDefaultsHelper saveBoolValue:NO forKey:kUserDefaultsKey_ClanZipIsDown];
        } else {
            BOOL isDownLoad = [clanZipMd5 isEqualToString:config[@"smiley_info"][@"md5"]] ? YES : NO;
            [UserDefaultsHelper saveBoolValue:isDownLoad forKey:kUserDefaultsKey_ClanZipIsDown];
        }
        [UserDefaultsHelper saveDefaultsValue:config[@"smiley_info"][@"zip_url"]  forKey:kUserDefaultsKey_ClanZipPath];
        [UserDefaultsHelper saveDefaultsValue:config[@"smiley_info"][@"zip_info"] forKey:kUserDefaultsKey_ClanZipJsonInfo];
        [self faceImageType];
    }
    
    NSString *boardStyle = nil;
    //版块儿列表样式
    if (config && [config objectForKey:@"display_style"]) {
        id bs = [config objectForKey:@"display_style"];
        if ([bs isKindOfClass:[NSNumber class]]) {
            boardStyle = [NSString stringWithFormat:@"%@",bs];
        } else {
            boardStyle = [config objectForKey:@"display_style"];
        }
        if (boardStyle && boardStyle.length > 0) {
            [NSString updatePlistWithName:kBOARDSTYLE andString:boardStyle];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GET_kBOARDSTYLE" object:nil];
        }
    }
    //签到开关
    if (config && [config objectForKey:@"checkin_enabled"]) {
        NSString *checkin_enabled = config[@"checkin_enabled"];
        [NSString updatePlistWithName:kcheckin_enabled andString:checkin_enabled];
    }
    //搜索开关
    if (config[@"searchsetting"]) {
        [UserDefaultsHelper saveDefaultsValue:config[@"searchsetting"] forKey:kUserDefaultsKey_ClanSearchSetting];
    }
    //列表开关
    if (config[@"threadconfig"]) {
        [UserDefaultsHelper saveDefaultsValue:config[@"threadconfig"] forKey:kUserDefaultsKey_ClanCustomVc];
    }
    //文章开关
    if (config[@"portalconfig"]) {
        NSMutableArray *articleArray = nil;
        NSArray *array = config[@"portalconfig"];
        if (!isNull(array)) {
            articleArray = [NSMutableArray arrayWithCapacity:array.count];
            [articleArray removeAllObjects];
            for (NSDictionary *dic in array) {
                ArticleModel *articleModel = [ArticleModel objectWithKeyValues:dic];
                NSData *udObject = [NSKeyedArchiver archivedDataWithRootObject:articleModel];
                [articleArray addObject:udObject];
            }
            
        }
        [UserDefaultsHelper saveDefaultsValue:articleArray forKey:kUserDefaultsKey_ClanArticleList];
    }
    //关于我们描述信息
    if (config && [config objectForKey:@"appdesc"]) {
        NSString *appdesc = config[@"appdesc"];
        [NSString updatePlistWithName:kAppDescription andString:isNull(appdesc) ? @"" : appdesc];
    }
}
@end
