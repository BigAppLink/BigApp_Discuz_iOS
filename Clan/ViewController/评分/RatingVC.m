//
//  RatingVC.m
//  Clan
//
//  Created by 昔米 on 15/11/23.
//  Copyright © 2015年 Youzu. All rights reserved.
//

#import "RatingVC.h"
#import "NSObject+MJKeyValue.h"
#import "IQTextView.h"
#import "IQDropDownTextField.h"
#import "RateCell.h"
#import "PostDetailVC.h"

@interface RatingVC () <UITableViewDataSource, UITableViewDelegate, IQDropDownTextFieldDelegate>
@property (nonatomic, strong) BaseTableView *table;
@property (nonatomic, strong) IQTextView *tv_reason;
@property (nonatomic, strong) IQDropDownTextField *tf_reason;

@end

@implementation RatingVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadModel];
    [self buildUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    _table.delegate = nil;
    _table.dataSource = nil;
    _tf_reason.delegate = nil;
    _tv_reason.delegate = nil;
    DLog(@"RatingVC 已销毁");
}

#pragma mark - 初始化
//初始化数据源
- (void)loadModel
{
//    NSArray *tempChoice = @[@(-4),@(-2),@(-1),@(1),@(2),@(4),@(6),@(8)];
    NSMutableArray *arr = [[NSMutableArray alloc]initWithCapacity:_ratelist.count];
    for (NSDictionary *dic in _ratelist) {
        RateItem *item = [RateItem objectWithKeyValues:dic];
        [arr addObject:item];
        int min = item.min.intValue;
        int max = item.max.intValue;
        NSMutableArray *arr = [NSMutableArray new];
        for (int i = min; i <= max; i++) {
            if (i > 0) {
                [arr addObject:[NSString stringWithFormat:@"+%d",i]];
            } else {
                [arr addObject:[NSString stringWithFormat:@"%d",i]];
            }
        }
//        for (NSNumber *num in tempChoice) {
//            int numVal = num.intValue;
//            if (numVal >= min && numVal <= max) {
//                if (numVal < 0) {
//                    [arr addObject:[NSString stringWithFormat:@"%d",numVal]];
//                } else {
//                    [arr addObject:[NSString stringWithFormat:@"+%d",numVal]];
//                }
//            }
//        }
//        [arr addObject:@"自定义"];
        item.choices = arr;
    }
    self.ratelist = arr;
    
}

//构建视图
- (void)buildUI
{
    self.title = @"我要评分";
    UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.backgroundColor = [UIColor clearColor];
    leftButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
    leftButton.frame = CGRectMake(0, 0, 40, 26);
    [leftButton setTitle:@"提 交" forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(commitAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    
    IQTextView *tv = [[IQTextView alloc] initWithFrame:CGRectMake(55, 10, kSCREEN_WIDTH-55-15, 150.f-20)];
    tv.placeholder = @"有更多理由要说？炫一下吧~ (理由不要太长哦~20个文字之内哦)";
    tv.font = [UIFont fitFontWithSize:15.f];
    self.tv_reason = tv;
    
    IQDropDownTextField *tf = [[IQDropDownTextField alloc]init];
    tf.placeholder = @"评分理由";
    tf.font = [UIFont fitFontWithSize:15.f];
    tf.delegate = self;
    tf.dropDownMode = IQDropDownModeTextPicker;
    [tf setItemList:self.reasons];
    self.tf_reason = tf;
    
    BaseTableView *table = [[BaseTableView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
    table.backgroundColor = kCLEARCOLOR;
    table.separatorColor = kfsc_table_border;
    table.delegate = self;
    table.dataSource = self;
    self.table = table;
    [self.view addSubview:table];
}

#pragma mark - tabelview datasource & delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _ratelist.count == 0 ? 0 : _ratelist.count+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == _ratelist.count) {
        //最后一行是评分理由
        UITableViewCell *lastCell = [[UITableViewCell alloc]init];
        lastCell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *downimage = [[UIImageView alloc]initWithFrame:CGRectMake(kSCREEN_WIDTH-40, 0, 40, 44)];
        downimage.image = kIMG(@"down");
        downimage.contentMode = UIViewContentModeCenter;
        downimage.userInteractionEnabled = YES;
        [lastCell.contentView addSubview:downimage];
        [lastCell.contentView addSubview:_tf_reason];
        [lastCell.contentView addSubview:_tv_reason];
        _tf_reason.frame = CGRectMake(23, 0, kSCREEN_WIDTH-23, 44);
        _tv_reason.frame = CGRectMake(18, kVIEW_BY(_tf_reason)+2, kSCREEN_WIDTH-18, 174);
        UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(23, 44, kSCREEN_WIDTH-23, 0.5)];
        line.backgroundColor = kfsc_table_border;
        [lastCell.contentView addSubview:line];
        return lastCell;
    } else {
        static NSString *cellidentifer = @"rateCell";
        RateCell *Cell = [tableView dequeueReusableCellWithIdentifier:cellidentifer];
        if (!Cell) {
            Cell = [[RateCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifer];
            Cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        RateItem *item = _ratelist[indexPath.section];
        [Cell setRateItem:item];
        return Cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == _ratelist.count) {
        //最后一行
        return 220.f;
    } else {
        return 185.f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.f;
}

#pragma mark - 
- (void)textField:(IQDropDownTextField*)textField didSelectItem:(NSString*)item
{
    if (textField == _tf_reason) {
        _tv_reason.text = item;
        _tf_reason.text = nil;
    }
}

#pragma mark - commitAction
- (void)commitAction
{
    [self.view endEditing:YES];
    NSMutableDictionary *paras = [NSMutableDictionary new];
    for (int i = 0; i < _ratelist.count; i++) {
        RateItem *item = _ratelist[i];
        if (item.inputValue && ![@"0" isEqualToString:item.inputValue] && item.inputValue.length > 0) {
            [paras setObject:[NSString stringWithFormat:@"%d",item.inputValue.intValue] forKey:[NSString stringWithFormat:@"score%@",item.extcredits]];
        }
    }
    if (paras.count == 0) {
        [self showHudTipStr:@"至少请选择一项打分哦~"];
        return;
    }
    WEAKSELF
    [[Clan_NetAPIManager sharedManager] request_RatingsPostWithtid:_tid
                                                           withPid:_pid
                                                   withRateResults:paras
                                                        withReason:_tv_reason.text ? _tv_reason.text : @""
                                                          andBlock:^(id data, NSError *error) {
                                                              if (data && [data valueForKey:@"Message"]) {
                                                                  NSDictionary *messDic = [data valueForKey:@"Message"];
                                                                  NSString *messval = messDic[@"messageval"];
                                                                  NSString *messTip = messDic[@"messagestr"];
                                                                  if ([messval isEqualToString:@"thread_rate_succeed"]) {
                                                                      //活动申请成功
                                                                      [weakSelf showHudTipStr:messTip];
                                                                      if (weakSelf.navigationController) {
                                                                          //把当前页面销毁 返回上一个页面
                                                                          if (weakSelf.targetVC && [weakSelf.targetVC isKindOfClass:[PostDetailVC class]]) {
                                                                              PostDetailVC *vc = (PostDetailVC *)weakSelf.targetVC;
                                                                              [vc ratePostSuccess:data];
                                                                          }
                                                                          [weakSelf.navigationController popViewControllerAnimated:YES];
                                                                      }
                                                                  } else {
                                                                      //活动申请失败 提示原因
                                                                      [weakSelf showHudTipStr:messTip];
                                                                  }
                                                              } else {
                                                                  [weakSelf showHudTipStr:@"评分失败，请检查网络或重试"];
                                                              }
                                                          }];
}
@end
