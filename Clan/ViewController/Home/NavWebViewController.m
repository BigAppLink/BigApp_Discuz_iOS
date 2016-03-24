//
//  NavWebViewController.m
//  Clan
//
//  Created by chivas on 15/10/10.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "NavWebViewController.h"

@interface NavWebViewController ()

@end

@implementation NavWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect rect = self.view.bounds;
    rect.size.height = rect.size.height - 38;
    self.webView.frame = rect;
    // Do any additional setup after loading the view.
}

#pragma mark - XLPagerTabStripViewControllerDelegate

-(NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return _navi_name;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
