//
//  RulesViewController.m
//  Clan
//
//  Created by chivas on 15/8/31.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "RulesViewController.h"

@interface RulesViewController ()

@end

@implementation RulesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"使用条款及隐私政策";
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(15, 20, ScreenWidth - 30, 30)];
    label1.text = @"应用服务条款";
    label1.font = [UIFont boldSystemFontOfSize:15.0f];
    [self.view addSubview:label1];
    
    NSString *label2String = @"应用注册许可协议(你有权停止注册，确认注册即表明接受该协议所有条款)";
    CGSize size2 = [label2String sizeWithFont:[UIFont boldSystemFontOfSize:15] constrainedToSize:CGSizeMake(ScreenWidth - 30,10000.0f)lineBreakMode:UILineBreakModeWordWrap];
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(15, label1.bottom + 10, size2.width, size2.height)];
    label2.text = label2String;
    label2.font = [UIFont boldSystemFontOfSize:15.0f];
    label2.numberOfLines = 0;
    [self.view addSubview:label2];
    
    NSString *label3String = @"不得利用本应用危害国家安全、泄露国家秘密，不得侵犯国家社会集体的和公民的合法权益，不得利用本应用制作、复制和传播下列信息：";
    CGSize size3 = [label3String sizeWithFont:[UIFont boldSystemFontOfSize:15] constrainedToSize:CGSizeMake(ScreenWidth - 30,10000.0f)lineBreakMode:UILineBreakModeWordWrap];
    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(15, label2.bottom + 10, size3.width, size3.height)];
    label3.text = label3String;
    label3.numberOfLines = 0;
    label3.font = [UIFont boldSystemFontOfSize:15.0f];
    [self.view addSubview:label3];
    
    NSArray *array = @[@"（1）煽动抗拒、破坏宪法和法律、行政法规实施的；",@"（2）煽动颠覆国家政权，推翻社会主义制度的；",@"（3）煽动分裂国家、破坏国家统一的；",@"（4）煽动民族仇恨、民族歧视，破坏民族团结的；",@"（5）捏造或者歪曲事实，散布谣言，扰乱社会秩序的；",@"（6）宣扬封建迷信、淫秽、色情、赌博、暴力、凶杀、恐怖、教唆犯罪的；",@"（7）公然侮辱他人或者捏造事实诽谤他人的，或者进行其他恶意攻击的；",@"（8）损害国家机关信誉的；",@"（9）其他违反宪法和法律行政法规的；",@"（10）禁止任何团体及个人的侵权行为，包括盗版、破解版等侵权行为；为此产生的法律责任均为发布者所承担；"];
    CGFloat x = 5;
    for (int index = 0; index<array.count ; index++) {
        NSString *labelString = array[index];
        CGSize size = [labelString sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(ScreenWidth - 60,10000.0f)lineBreakMode:UILineBreakModeWordWrap];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(30, label3.bottom + x, size.width, size.height)];
        label.text = labelString;
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:13.0f];
        [self.view addSubview:label];
        x+= (size.height + 5);

    }
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
