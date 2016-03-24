//
//  AboutViewController.m
//  Clan
//
//  Created by 昔米 on 15/6/16.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self buildUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buildUI
{
    self.title = @"关于我们";
    UIScrollView *scrolview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-64)];
    scrolview.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrolview];
    
    UIImageView *logoImage = [[UIImageView alloc]initWithFrame:CGRectMake((kSCREEN_WIDTH-60)/2, 58, 65, 65)];
    logoImage.contentMode = UIViewContentModeScaleAspectFill;
    logoImage.layer.cornerRadius = 5.0;
    logoImage.clipsToBounds = YES;
    logoImage.image = kIMG(@"AppIcon60x60");
    [scrolview addSubview:logoImage];
    
    UILabel *appinfo = [[UILabel alloc]initWithFrame:CGRectMake(15, kVIEW_BY(logoImage)+6, kSCREEN_WIDTH-30, 25)];
    appinfo.textAlignment = NSTextAlignmentCenter;
    appinfo.text = [NSString stringWithFormat:@"%@",[Util appName]];
    [scrolview addSubview:appinfo];
    
    UILabel *lbl_version = [[UILabel alloc]initWithFrame:CGRectMake(15, kVIEW_BY(appinfo)+4, kSCREEN_WIDTH-30, 20)];
    lbl_version.font = [UIFont fontWithSize:12.f];
    lbl_version.textColor = K_COLOR_DARK_Cell;
    lbl_version.textAlignment = NSTextAlignmentCenter;
    lbl_version.text = [NSString stringWithFormat:@"版本号：%@ (%@)",[Util currentAppVersion],[NSString returnStringWithPlist:kBIGAPPVERSION]];
    [scrolview addSubview:lbl_version];
    
    UIFont *desFont = [UIFont fontWithSize:12.f];
    NSString *des_app = [NSString returnPlistWithKeyValue:kAppDescription];
//    des_app = @"在iPhone上也能使用UIPopoverController。这个代码库不但让UIPopoverController的使用变得简单，同时也能在iPhone上使用UIPopoverController。点击任意控件，如按钮、导航条按钮、工具条按钮等，都会弹出视图。弹出的视图会自动定位在相应的按钮旁边，并且有小箭头指向这个按钮。可以在视图上加文字或者列表。在iPhone上也能使用UIPopoverController。这个代码库不但让UIPopoverController的使用变得简单，同时也能在iPhone上使用UIPopoverController。点击任意控件，如按钮、导航条按钮、工具条按钮等，都会弹出视图。弹出的视图会自动定位在相应的按钮旁边，并且有小箭头指向这个按钮。可以在视图上加文字或者列表。在iPhone上也能使用UIPopoverController。这个代码库不但让UIPopoverController的使用变得简单，同时也能在iPhone上使用UIPopoverController。点击任意控件，如按钮、导航条按钮、工具条按钮等，都会弹出视图。弹出的视图会自动定位在相应的按钮旁边，并且有小箭头指向这个按钮。可以在视图上加文字或者列表。在iPhone上也能使用UIPopoverController。这个代码库不但让UIPopoverController的使用变得简单，同时也能在iPhone上使用UIPopoverController。点击任意控件，如按钮、导航条按钮、工具条按钮等，都会弹出视图。弹出的视图会自动定位在相应的按钮旁边，并且有小箭头指向这个按钮。可以在视图上加文字或者列表。在iPhone上也能使用UIPopoverController。这个代码库不但让UIPopoverController的使用变得简单，同时也能在iPhone上使用UIPopoverController。点击任意控件，如按钮、导航条按钮、工具条按钮等，都会弹出视图。弹出的视图会自动定位在相应的按钮旁边，并且有小箭头指向这个按钮。可以在视图上加文字或者列表。在iPhone上也能使用UIPopoverController。这个代码库不但让UIPopoverController的使用变得简单，同时也能在iPhone上使用UIPopoverController。点击任意控件，如按钮、导航条按钮、工具条按钮等，都会弹出视图。弹出的视图会自动定位在相应的按钮旁边，并且有小箭头指向这个按钮。可以在视图上加文字或者列表。在iPhone上也能使用UIPopoverController。这个代码库不但让UIPopoverController的使用变得简单，同时也能在iPhone上使用UIPopoverController。点击任意控件，如按钮、导航条按钮、工具条按钮等，都会弹出视图。弹出的视图会自动定位在相应的按钮旁边，并且有小箭头指向这个按钮。可以在视图上加文字或者列表。在iPhone上也能使用UIPopoverController。这个代码库不但让UIPopoverController的使用变得简单，同时也能在iPhone上使用UIPopoverController。点击任意控件，如按钮、导航条按钮、工具条按钮等，都会弹出视图。弹出的视图会自动定位在相应的按钮旁边，并且有小箭头指向这个按钮。可以在视图上加文字或者列表。在iPhone上也能使用UIPopoverController。这个代码库不但让UIPopoverController的使用变得简单，同时也能在iPhone上使用UIPopoverController。点击任意控件，如按钮、导航条按钮、工具条按钮等，都会弹出视图。弹出的视图会自动定位在相应的按钮旁边，并且有小箭头指向这个按钮。可以在视图上加文字或者列表。";
    UITextView *tv = [[UITextView alloc]initWithFrame:CGRectMake(15, kVIEW_BY(lbl_version)+10, (kSCREEN_WIDTH-30), 0)];
    tv.text = des_app;
    tv.backgroundColor = kCLEARCOLOR;
    tv.textColor = K_COLOR_DARK_Cell;
    tv.font = desFont;
    tv.scrollEnabled = NO;
    tv.editable = NO;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 6;// 字体的行间距
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:15],
                                 NSParagraphStyleAttributeName:paragraphStyle,
                                 NSForegroundColorAttributeName:K_COLOR_DARK_Cell
                                 };
    tv.attributedText = [[NSAttributedString alloc] initWithString:avoidNullStr(des_app) attributes:attributes];
    [scrolview addSubview:tv];
    [tv sizeToFit];
    
    float height = kVIEW_BY(tv) > kSCREEN_HEIGHT ? kVIEW_BY(tv)+10 : kSCREEN_HEIGHT;
    scrolview.contentSize = CGSizeMake(kSCREEN_WIDTH, height);
}

@end
