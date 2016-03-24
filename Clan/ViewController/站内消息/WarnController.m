//
//  WarnController.m
//  Clan
//
//  Created by 昔米 on 15/9/9.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "WarnController.h"

@interface WarnController ()

@end

@implementation WarnController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view configBlankPage:DataIsNothingWithDefault hasData:NO hasError:NO reloadButtonBlock:^(id sender) {
        
    }];
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
