//
//  UserDefaultsHelper.h
//  Clan
//
//  Created by 昔米 on 15/9/15.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kUserDefaultsKey_ClanZipMd5 @"kUserDefaultsKey_ClanZipMd5"
#define kUserDefaultsKey_ForumsStore @"kUserDefaultsKey_ForumsStore"
#define kUserDefaultsKey_ClanArticleList @"kUserDefaultsKey_ClanArticleList"
#define kUserDefaultsKey_ClanSearchSetting @"kUserDefaultsKey_ClanSearchSetting"
#define kUserDefaultsKey_ClanCustomVc @"kUserDefaultsKey_ClanCustomVc"
#define kUserDefaultsKey_ClanZipJsonInfo @"kUserDefaultsKey_ClanZipJsonInfo"
#define kUserDefaultsKey_ClanZipTempMd5 @"kUserDefaultsKey_ClanZipTempMd5"
#define kUserDefaultsKey_ClanZipIsDown @"kUserDefaultsKey_ClanZipIsDown"
#define kUserDefaultsKey_ClanZipPath @"kUserDefaultsKey_ClanZipPath"
#define kUserDefaultsKey_searchsetting @"kUserDefaultsKey_searchsetting"
#define kUserDefaultsKey_threadconfig @"kUserDefaultsKey_threadconfig"
#define kUserDefaultsKey_ClanSearchSetWithForum @"kUserDefaultsKey_ClanSearchSetWithForum"
#define kUserDefaultsKey_ClanSearchSetWithGroup @"kUserDefaultsKey_ClanSearchSetWithGroup"
#define kUserDefaultsKey_S_FAVOTYPE_PLATE @"kUserDefaultsKey_S_FAVOTYPE_PLATE"
#define kUserDefaultsKey_zipFileName @"kUserDefaultsKey_zipFileName"
#define kUserDefaultsKey_ClanFaceImage @"kUserDefaultsKey_ClanFaceImage"
#define kUserDefaultsKey_ClanFaceJson @"kUserDefaultsKey_ClanFaceJson"

//#define kUserDefaultsKey @""
//#define kUserDefaultsKey @""
//#define kUserDefaultsKey @""
//#define kUserDefaultsKey @""
//#define kUserDefaultsKey @""
//#define kUserDefaultsKey @""
//#define kUserDefaultsKey @""
//#define kUserDefaultsKey @""


@interface UserDefaultsHelper : NSObject

//保存defaults key
+ (void)saveDefaultsValue:(id)obj forKey:(NSString *)key;
//取defaults key
+ (id)valueForDefaultsKey:(NSString *)key;
//存储bool值
+ (void)saveBoolValue:(BOOL)boolValue forKey:(NSString *)key;
//取出bool值
+ (BOOL)boolValueForDefaultsKey:(NSString *)key;

+ (void)cleanDefaultsForKey:(NSString *)key;
@end

