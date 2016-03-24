//
//  Constants.h
//  Clan
//
//  Created by 昔米 on 15/4/1.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#ifndef Clan_Constants_h
#define Clan_Constants_h

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

typedef enum
{
    LoginTypeQQ = 0,  //QQ登录
    LoginTypeWechat,  //微信登录
    LoginTypeWeibo,  //微博登录
}LoginType;

typedef NS_ENUM(NSInteger, CollcetionType) {
    myPost = 0, //帖子收藏
    myPlate,    //版块儿收藏
    myArticle   //文章收藏
};

//*  根据Id 1 2 3 4 5 分别为
//*  判断类型 1:自定义TAB 2:版块 3:发帖 4:消息 5:我的
//*  自定义TAB 1:单页面 2:导航页面 3:WAP页面

typedef NS_ENUM(NSInteger, DZTabType) {
    DZTabType_Custom_SinglePage = 1, //单页面
    DZTabType_Custom_NavigationPage, //导航页面
    DZTabType_Custom_WapPage, //WAP页面
    DZTabType_ForumPage, //版块儿页面
    DZTabType_PostingPage, //发帖页面
    DZTabType_MessagePage, //消息页面
    DZTabType_MePage, //我的页面
    DZTabType_NonePage=100, //空页面
};

/*
 * 活动参数
 *
 */
typedef NS_ENUM(NSInteger, DZActivityFormType) {
    DZActivityFormType_Text = 1, //文本框
    DZActivityFormType_Select, //单选选择器
    DZActivityFormType_DatePicker, //日期选择器
    DZActivityFormType_Provincepicker, //地址选择器
    DZActivityFormType_TextArea, //文本区域
    DZActivityFormType_Checkbox, //复选
    DZActivityFormType_File, //图片
    DZActivityFormType_Message, //留言
    DZActivityFormType_Other, //其他
};

/*
 * 发帖类型
 */
typedef NS_ENUM(NSInteger, DZPostingType) {
    DZPostingType_Default = 0, //正常贴
    DZPostingType_Activity,    //活动贴
};


#pragma mark - Colors
//十六进制色值
#define kUIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//十六进制色值+透明度
#define kUIColorFromRGBWithTransparent(rgbValue,transparentValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:transparentValue]

//RGB色值
#define kColourWithRGB(r,g,b) [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0]
#define kColorWithRGB(r,g,b,alphaVal) [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:alphaVal]

//透明色值
#define kCLEARCOLOR [UIColor clearColor]


#pragma mark - Size ,X,Y, View ,Frame
//get the  size of the Screen
#define kSCREEN_HEIGHT [[UIScreen mainScreen]bounds].size.height
#define kSCREEN_WIDTH [[UIScreen mainScreen]bounds].size.width
#define kVISIBLE_WIDTH kSCREEN_WIDTH - ((0.7*kSCREEN_WIDTH/2)-30)
#define kSCREEN_BOUNDS [[UIScreen mainScreen]bounds]
#define kVIEW_HEIGHT  self.view.bounds.size.height
#define kVIEW_WIDTH  self.view.bounds.size.width
#define kTABBAR_HEIGHT 49

//get the left top origin's x,y of a view
#define kVIEW_TX(view) (view.frame.origin.x)
#define kVIEW_TY(view) (view.frame.origin.y)

//get the width size of the view:width,height
#define kVIEW_W(view)  (view.frame.size.width)
#define kVIEW_H(view)  (view.frame.size.height)

//get the right bottom origin's x,y of a view
#define kVIEW_BX(view) (view.frame.origin.x + view.frame.size.width)
#define kVIEW_BY(view) (view.frame.origin.y + view.frame.size.height )

#define kVIEW_CENTERX(view) view.center.x
#define kVIEW_CENTERY(view) view.center.y

//是否为空
#ifndef isNull
#define isNull(a)  ( (a==nil) || ((NSNull*)a==[NSNull null]) )
#define isNotNull(a)  (!isNull(a))
#define avoidNullStr(a) isNull(a) ? @"" : a
#endif //isNull


#pragma mark - Device

//iphone6Plus判断
#define kDEVICE_IS_IPHONE6Plus ([[UIScreen mainScreen] bounds].size.height >= 736)

//iphone6判断
#define kDEVICE_IS_IPHONE6 ([[UIScreen mainScreen] bounds].size.height == 667)

//iphone5判断
#define kDEVICE_IS_IPHONE5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

//iphone4判断
#define kDEVICE_IS_IPHONE4 ([[UIScreen mainScreen] bounds].size.height == 480)

//iphone7判断
#define kIOS7 [[[UIDevice currentDevice]systemVersion] floatValue] >= 7.0
#define kIOS8 [[[UIDevice currentDevice]systemVersion] floatValue] >= 8.0

#pragma mark - 图片
#define kIMG(iname) [UIImage imageNamed:iname]
#define kIMG_FILE(fileName, fileType) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:fileType]]

#define DlogMethod  DLog(@"%s,%d" , __FUNCTION__ , __LINE__ );

#pragma mark -

#define kWeiXinDownloadURL @"itms://itunes.apple.com/cn/app/wei-xin/id414478124?mt=8"
#define kQQDownloadURL @"itms://itunes.apple.com/cn/app/qq/id444934666?mt=8"
#define kWeiBoDownloadURL @"itms://itunes.apple.com/cn/app/wei-bo/id350962117?mt=8"

#endif
