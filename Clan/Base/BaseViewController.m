//
//  BaseViewController.m
//  Clan
//
//  Created by chivas on 15/2/27.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "BaseViewController.h"
//#import <AGCommon/UIDevice+Common.h>
//#import <AGCommon/UIImage+Common.h>
//#import <AGCommon/UINavigationBar+Common.h>
//#import <AGCommon/NSString+Common.h>
#import <ShareSDK/ShareSDK.h>
#import "LoginViewController.h"
#import "MLBlackTransition.h"
#import "ShareItem.h"
#import "ShareMenu.h"
#import "SharedMenuItemButton.h"
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <ShareSDK/NSMutableDictionary+SSDKShare.h>
#import "UIAlertView+BlocksKit.h"

@interface BaseViewController () <UIGestureRecognizerDelegate,UIAlertViewDelegate>

@end

@implementation BaseViewController

#pragma mark - lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addBackBtn];
    self.view.backgroundColor = kCOLOR_BG_GRAY;
    if (kIOS8) {
        
    } else {
        //适配ios 7上面的导航
        self.navigationController.navigationBar.translucent = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.extendedLayoutIncludesOpaqueBars = NO;
    }
    [MLBlackTransition validatePanPackWithMLBlackTransitionGestureRecognizerType:MLBlackTransitionGestureRecognizerTypePan];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    //隐藏页面的进度条
    [self hideProgressHUDSuccess:YES andTipMess:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)dealloc
{
    [self hideProgressHUDSuccess:YES andTipMess:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - custom methods
//返回按钮
- (void)navback:(id)sender
{
    if (self.navigationController)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

//分享
- (void)doShareWithTitle:(NSString *)title
             withcontent:(NSString *)content
                 withURL:(NSString *)url
            withShareImg:(UIImage *)img
         withShareImgURL:(NSString *)imgURL
         withDescription:(NSString *)des
{
    __block UIImage *shareImg = nil;
    if (imgURL && imgURL.length > 0) {
        [self showProgressHUDWithStatus:@"" withLock:YES];
        WEAKSELF
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:imgURL] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            [weakSelf dissmissProgress];
            if (finished) {
                NSData *fData = UIImageJPEGRepresentation(image, 0.5);
                UIImage *imag = [UIImage imageWithData:fData];
                UIImage *resizeImg = [Util imageResize:imag andResizeTo:CGSizeMake(60, 60)];
                //                NSData *imgData = UIImageJPEGRepresentation(resizeImg, 1); //1 it represents the quality of the image.
                //                NSLog(@"Size of Image(bytes):%ld",[imgData length]);
                //                if ([imgData length]>15*1024) {
                ////                    float bili = (15*1024.f)/[imgData length];
                ////                    NSData *fData1 = UIImageJPEGRepresentation(resizeImg, bili);
                //                    UIImage *newimg = [weakSelf compressImage:resizeImg toMaxFileSize:15*1024];
                //                    newimg = [Util imageResize:newimg andResizeTo:CGSizeMake(60, 60)];
                //                    resizeImg = newimg;
                //                }
                shareImg = resizeImg;
                
            } else {
                shareImg = img;
            }
            [weakSelf ShareWithTitle:title withcontent:content withURL:url withShareImg:shareImg withDescription:des];
            return ;
        }];
    } else {
        shareImg = img;
        [self ShareWithTitle:title withcontent:content withURL:url withShareImg:shareImg withDescription:des];
    }
}


- (NSData *)compressImage:(UIImage *)image toMaxFileSize:(NSInteger)maxFileSize
{
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    while ([imageData length] > maxFileSize && compression > maxCompression) {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    UIImage *compressedImage = [UIImage imageWithData:imageData];
    return imageData;
}

- (void)ShareWithTitle:(NSString *)title
           withcontent:(NSString *)content
               withURL:(NSString *)url
          withShareImg:(UIImage *)img
       withDescription:(NSString *)des

{
    NSData *imgData = UIImageJPEGRepresentation(img, 1); //1 it represents the quality of the image.
    if ([imgData length]>5*1024) {
        //微信的图压缩到5k
        NSData *newimg = [self compressImage:img toMaxFileSize:5*1024];
        NSLog(@"%lu",(unsigned long)newimg.length);
        img = [UIImage imageWithData:newimg];
    }
    //创建分享参数
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    NSArray* imageArray = nil;
    if (img) {
        imageArray = @[img];
    }
    NSURL *newsUrl = [NSURL URLWithString:url];
    //定制新浪微博的分享内容
    NSString *sianContent = [NSString stringWithFormat:@"%@ %@ 来自“%@”",title,url,[NSString returnStringWithPlist:YZBBSName]];
    [shareParams SSDKSetupSinaWeiboShareParamsByText:sianContent
                                               title:title
                                               image:img
                                                 url:newsUrl
                                            latitude:0
                                           longitude:0
                                            objectID:nil
                                                type:SSDKContentTypeText];
    //定制QQ的分享内容
    [shareParams SSDKSetupQQParamsByText:content
                                   title:title
                                     url:newsUrl
                              thumbImage:img
                                   image:img
                                    type:SSDKContentTypeWebPage
                      forPlatformSubType:SSDKPlatformSubTypeQQFriend];
    
    //定制QQ空间的分享内容
    [shareParams SSDKSetupQQParamsByText:content
                                   title:title
                                     url:newsUrl
                              thumbImage:img
                                   image:img
                                    type:SSDKContentTypeWebPage
                      forPlatformSubType:SSDKPlatformSubTypeQZone];
    
    //定制拷贝
    [shareParams SSDKSetupCopyParamsByText:url
                                    images:nil
                                       url:newsUrl
                                      type:SSDKContentTypeText];
    
    //定制微信好友
    [shareParams SSDKSetupWeChatParamsByText:content
                                       title:title
                                         url:newsUrl
                                  thumbImage:img
                                       image:img
                                musicFileURL:nil
                                     extInfo:nil
                                    fileData:nil
                                emoticonData:nil
                                        type:SSDKContentTypeWebPage
                          forPlatformSubType:SSDKPlatformSubTypeWechatSession];
    
    [shareParams SSDKSetupWeChatParamsByText:content
                                       title:title
                                         url:newsUrl
                                  thumbImage:img
                                       image:img
                                musicFileURL:nil
                                     extInfo:nil
                                    fileData:nil
                                emoticonData:nil
                                        type:SSDKContentTypeWebPage
                          forPlatformSubType:SSDKPlatformSubTypeWechatTimeline];
    
    
    //微信好友
    ShareItem *shareitemWeiXinSession = [ShareItem new];
    shareitemWeiXinSession.title = @"微信好友";
    shareitemWeiXinSession.image = kIMG(@"share_wechat");
    shareitemWeiXinSession.shareType = SSDKPlatformSubTypeWechatSession;
    //微信朋友圈
    ShareItem *shareitemWeiXinTimeline = [ShareItem new];
    shareitemWeiXinTimeline.title = @"朋友圈";
    shareitemWeiXinTimeline.image = kIMG(@"share_moments");
    shareitemWeiXinTimeline.shareType = SSDKPlatformSubTypeWechatTimeline;
    //新浪微博
    ShareItem *shareitemSina = [ShareItem new];
    shareitemSina.title = @"新浪微博";
    shareitemSina.image = kIMG(@"share_sina");
    shareitemSina.shareType = SSDKPlatformTypeSinaWeibo;
    //QQ
    ShareItem *shareitemQQ = [ShareItem new];
    shareitemQQ.title = @"QQ";
    shareitemQQ.image = kIMG(@"share_qq");
    shareitemQQ.shareType = SSDKPlatformSubTypeQQFriend;
    //QQ空间
    ShareItem *shareitemQQSpace = [ShareItem new];
    shareitemQQSpace.title = @"QQ空间";
    shareitemQQSpace.image = kIMG(@"share_tecent");
    shareitemQQSpace.shareType = SSDKPlatformSubTypeQZone;
    //拷贝链接
    ShareItem *shareitemCopy = [ShareItem new];
    shareitemCopy.title = @"拷贝链接";
    shareitemCopy.image = kIMG(@"share_copy");
    shareitemCopy.shareType = SSDKPlatformTypeCopy;
    
    NSArray *shareListArr = @[shareitemWeiXinSession, shareitemWeiXinTimeline, shareitemSina, shareitemQQ, shareitemQQSpace, shareitemCopy];
    ShareMenu *menu = [[ShareMenu alloc]initWithFrame:CGRectMake(0, 70, kSCREEN_WIDTH, 400) withShareList:shareListArr];
    [menu show];
    WEAKSELF
    [menu setSelectedBlock:^(id data) {
        [weakSelf ggggggggggwithData:data shareParas:shareParams];
    }];
}

- (void)ggggggggggwithData:(id)data shareParas:(NSMutableDictionary *)shareParams
{
    if (data)
    {
        NSNumber *typenum = (NSNumber *)data;
        SSDKPlatformType sharetype = typenum.intValue;
        if ((sharetype == SSDKPlatformSubTypeWechatTimeline
             || sharetype == SSDKPlatformTypeWechat
             || sharetype == SSDKPlatformSubTypeWechatSession) && ![WXApi isWXAppInstalled]) {
            [UIAlertView bk_showAlertViewWithTitle:@"提醒" message:@"您尚未安装微信客户端，无法进行分享!" cancelButtonTitle:@"取消" otherButtonTitles:@[@"前往下载"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kWeiXinDownloadURL]];
                }
            }];
            return ;
        }
        else if ((sharetype == SSDKPlatformSubTypeQZone
                  || sharetype == SSDKPlatformSubTypeQQFriend
                  || sharetype == SSDKPlatformTypeQQ) && ![QQApiInterface isQQInstalled]) {
            [UIAlertView bk_showAlertViewWithTitle:@"提醒" message:@"您尚未安装QQ客户端，无法进行分享!" cancelButtonTitle:@"取消" otherButtonTitles:@[@"前往下载"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kQQDownloadURL]];
                }
            }];
            return;
        }
        WEAKSELF
        [ShareSDK share:sharetype parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
            switch (state) {
                case SSDKResponseStateBegin:
                    if (sharetype != SSDKPlatformTypeCopy) {
                        [weakSelf showProgressHUDWithStatus:@"分享中..."];
                    }
                    break;
                case SSDKResponseStateCancel:
                    [weakSelf hideProgressHUD];
                    [weakSelf showHudTipStr:@"分享已取消"];
                    break;
                case SSDKResponseStateFail:
                {
                    [weakSelf hideProgressHUD];
                    NSString *error_message = [[error userInfo] objectForKey:@"error_message"];
                    if (!error_message) {
                        error_message = [error userInfo][@"user_data"][@"error"];
                    }
                    [weakSelf showHudTipStr:error_message];
                    break;
                }
                case SSDKResponseStateSuccess:
                    [weakSelf hideProgressHUD];
                    if (sharetype == SSDKPlatformTypeCopy) {
                        [weakSelf showHudTipStr:@"已复制到剪切板"];
                        
                    } else {
                        [weakSelf showHudTipStr:@"分享成功"];
                    }
                    break;
                    
                default:
                    [weakSelf hideProgressHUD];
                    break;
            }
        }];
    }
}

//跳转到登录页面
- (void)goToLoginPage
{
    UserModel *_cuser = [UserModel currentUserInfo];
    if (!_cuser || !_cuser.logined) {
        //没有登录 跳出登录页面
        LoginViewController *login = [[LoginViewController alloc]init];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:login];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark - progress view
- (void)showProgressHUDWithStatus:(NSString *)string
{
    [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    if (!string || [@"" isEqualToString:string]) {
        [SVProgressHUD show];
        return;
    }
    [SVProgressHUD showWithStatus:string];
}

- (void)showProgressHUDWithStatus:(NSString *)string withLock:(BOOL)lock
{
    [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    if (!string || [@"" isEqualToString:string]) {
        if (lock) {
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
            return;
        }
        [SVProgressHUD show];
        return;
    }
    if (lock) {
        [SVProgressHUD showWithStatus:string maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    [SVProgressHUD showWithStatus:string];
}

- (void)hideProgressHUD
{
    [self performSelector:@selector(dissmissProgress) withObject:nil afterDelay:0.2];
}

- (void)dissmissProgress
{
    [SVProgressHUD dismiss];
}

- (void)hideProgressHUDSuccess:(BOOL)success andTipMess:(NSString *)tip
{
    [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    if (!tip || [@"" isEqualToString:tip]) {
        [SVProgressHUD dismiss];
        return;
    }
    if (success)
        [SVProgressHUD showSuccessWithStatus:tip];
    else
        [SVProgressHUD showErrorWithStatus:tip];
}

//显示登录页
- (BOOL)checkLoginState
{
    UserModel *_cuser = [UserModel currentUserInfo];
    if (!_cuser || !_cuser.logined) {
        //没有登录 跳出登录页面
        LoginViewController *login = [[LoginViewController alloc]init];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:login];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
        if (self.sideMenuViewController) {
            [self.sideMenuViewController hideMenuViewController];
        }
        return NO;
    } else {
        return YES;
    }
}


- (void)addBackBtn
{
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1) {
        UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.backgroundColor = [UIColor clearColor];
        leftButton.frame = CGRectMake(0, 0, 26, 26);
        [leftButton setBackgroundImage :[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(navback:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    }
}

@end
