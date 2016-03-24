//
//  RateCell.m
//  Clan
//
//  Created by 昔米 on 15/11/24.
//  Copyright © 2015年 Youzu. All rights reserved.
//

#import "RateCell.h"
#import "IQKeyboardManager.h"

@implementation RateCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self buildUI];
    }
    return self;
}

- (void)dealloc
{
    _tf_value.delegate = nil;
}

- (void)buildUI
{
    UIView *v_content = [[UIView alloc]initWithFrame:CGRectMake(40, 15, kSCREEN_WIDTH-80, 150)];
    v_content.backgroundColor = kUIColorFromRGB(0xfcfcfc);
    v_content.userInteractionEnabled = YES;
    [self.contentView addSubview:v_content];
    
    UILabel *lbl_name = [[UILabel alloc]initWithFrame:CGRectMake(0, 14, kVIEW_W(v_content)/2-40, 45)];
    lbl_name.font = [UIFont systemFontOfSize:18.f];
    lbl_name.text = @"积分";
    lbl_name.textAlignment = NSTextAlignmentCenter;
    lbl_name.textColor = [UIColor darkTextColor];
    self.lbl_name = lbl_name;
    [v_content addSubview:lbl_name];
    
    UIView *v_btnback = [[UIView alloc]initWithFrame:CGRectMake(kVIEW_BX(lbl_name), 14, kVIEW_W(v_content)/2, 45)];
    v_btnback.backgroundColor = kCOLOR_BG_GRAY;
    [v_content addSubview:v_btnback];
    
    UIImageView *downIv = [[UIImageView alloc]initWithFrame:CGRectMake(kVIEW_W(v_btnback)-30, 0, 30, 45)];
    downIv.image = kIMG(@"rate_down");
    downIv.contentMode = UIViewContentModeCenter;
    [v_btnback addSubview:downIv];
    
    UILabel *displayLabel = [UILabel new];
    displayLabel.frame = CGRectMake(0, 0, kVIEW_W(v_btnback), 45);
    displayLabel.text = @"0";
    displayLabel.font = [UIFont systemFontOfSize:19.f];
    displayLabel.textColor = kColorWithRGB(8, 8, 8, 0.5);
    displayLabel.textAlignment = NSTextAlignmentCenter;
    self.lbl_display = displayLabel;
    [v_btnback addSubview:displayLabel];
    
    IQDropDownTextField *tf = [[IQDropDownTextField alloc]initWithFrame:v_btnback.bounds];
    tf.delegate = self;
    tf.text = @"0";
    tf.textColor = [UIColor clearColor];
    self.tf_value = tf;
    [v_btnback addSubview:tf];
    
//    UITextField *tf_zidingyi = [[UITextField alloc]initWithFrame:v_btnback.bounds];
//    tf_zidingyi.textAlignment = NSTextAlignmentCenter;
//    tf_zidingyi.placeholder = @"我要自定义";
//    tf_zidingyi.backgroundColor = kCOLOR_BG_GRAY;
//    tf_zidingyi.textColor = kColorWithRGB(8, 8, 8, 0.5);
//    tf_zidingyi.font = [UIFont systemFontOfSize:19.f];
//    tf_zidingyi.frame = CGRectMake(kVIEW_TX(v_btnback), kVIEW_BY(v_btnback)+10, kVIEW_W(v_btnback), kVIEW_H(v_btnback));
//    tf_zidingyi.delegate = self;
//    tf_zidingyi.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
//    self.tf_zidingyi = tf_zidingyi;
//    [v_content addSubview:tf_zidingyi];
    
    UILabel *lbl_pingfenqujian = [[UILabel alloc]initWithFrame:CGRectMake(0, kVIEW_BY(v_btnback)+20, kVIEW_W(v_content)/2, 30)];
    lbl_pingfenqujian.text = @"评分区间";
    lbl_pingfenqujian.textAlignment = NSTextAlignmentCenter;
    lbl_pingfenqujian.textColor = kColorWithRGB(102,102,102,0.5);
    lbl_pingfenqujian.font = [UIFont systemFontOfSize:14.f];
    [v_content addSubview:lbl_pingfenqujian];
    
    UILabel *lbl_jinrishengyu = [[UILabel alloc]initWithFrame:CGRectMake(kVIEW_BX(lbl_pingfenqujian), kVIEW_BY(v_btnback)+20, kVIEW_W(v_content)/2, 30)];
    lbl_jinrishengyu.text = @"今日剩余";
    lbl_jinrishengyu.textAlignment = NSTextAlignmentCenter;
    lbl_jinrishengyu.textColor = kColorWithRGB(102,102,102,0.5);
    lbl_jinrishengyu.font = [UIFont systemFontOfSize:14.f];
    [v_content addSubview:lbl_jinrishengyu];
    
    UILabel *lbl_pingfen = [[UILabel alloc]initWithFrame:CGRectMake(0, kVIEW_BY(lbl_pingfenqujian), kVIEW_W(v_content)/2, 30)];
    lbl_pingfen.text = @"0 ~ 0";
    lbl_pingfen.textAlignment = NSTextAlignmentCenter;
    lbl_pingfen.textColor = kColorWithRGB(8, 8, 8, 0.5);
    lbl_pingfen.font = [UIFont systemFontOfSize:22.f];
    self.lbl_pingfen = lbl_pingfen;
    [v_content addSubview:lbl_pingfen];
    
    UILabel *lbl_jinri = [[UILabel alloc]initWithFrame:CGRectMake(kVIEW_BX(lbl_pingfen), kVIEW_BY(lbl_jinrishengyu), kVIEW_W(v_content)/2, 30)];
    lbl_jinri.textAlignment = NSTextAlignmentCenter;
    lbl_jinri.text = @"0";
    lbl_jinri.textColor = kColorWithRGB(8, 8, 8, 0.5);
    lbl_jinri.font = [UIFont systemFontOfSize:22.f];
    self.lbl_jirishengyu = lbl_jinri;
    [v_content addSubview:lbl_jinri];
}

- (void)setRateItem:(RateItem *)rateItem
{
    _rateItem = rateItem;
    [_tf_value setItemList:rateItem.choices];
    _tf_value.text = (rateItem.inputValue && rateItem.inputValue.length>0) ? rateItem.inputValue : @"0";
    _lbl_display.text = _tf_value.text;
    _lbl_name.text = rateItem.title;
    _lbl_pingfen.text = [NSString stringWithFormat:@"%@ ~ %@",rateItem.min,rateItem.max];
    _lbl_jirishengyu.text = [NSString stringWithFormat:@"%@", rateItem.todayleft];
}

- (void)textField:(IQDropDownTextField*)textField didSelectItem:(NSString*)item
{
    if (_lbl_display) {
        _lbl_display.text = item ? item : @"0";
        _rateItem.inputValue = item;
//        if (item && ![@"0" isEqualToString:item]) {
//            _tf_zidingyi.text = @"";
//        }
//        if ([item isEqualToString:@"自定义"]) {
//            _rateItem.inputValue = @"0";
//            _lbl_display.text = @"0";
//            _tf_value.text = @"0";
//            _tf_value.selectedItem = nil;
//            _tf_value.selectedRow = 0;
//            [self performSelector:@selector(showAlerttt) withObject:nil];
//        }
    }
}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (alertView && self) {
//        if (buttonIndex == 0) {
//            //取消按钮
////            [self.tf_value becomeFirstResponder];
//        } else {
//            UITextField *tf = [alertView textFieldAtIndex:0];
//            if (tf.text && tf.text.length > 0) {
//                if (tf.text.intValue) {
//                    int i = tf.text.intValue;
//                    if (i<_rateItem.min.intValue || i > _rateItem.max.intValue) {
//                        [self showHudTipStr:@"您输入的值不在范围内，请重新输入"];
//                        return;
//                    }
//                    _rateItem.inputValue = tf.text;
//                    _lbl_display.text = tf.text;
//                    _tf_value.text = tf.text;
//                    _tf_value.selectedItem = nil;
//                } else {
//                    [self showHudTipStr:@"请输入数值哦~"];
//                }
//            }
//        }
//    }
//}

//- (void)showAlerttt
//{
//    [_tf_value resignFirstResponder];
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"输入自定义值" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
//    UITextField *tf = [alert textFieldAtIndex:0];
//    tf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
//    [alert show];
//}

//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    if (textField && textField == _tf_zidingyi) {
//        [self.tf_value resignFirstResponder];
//    }
//}
//
//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    if (textField && textField == _tf_zidingyi) {
//        if (textField.text && textField.text.length > 0) {
//            if (textField.text.intValue) {
//                int i = textField.text.intValue;
//                if (i < _rateItem.min.intValue || i > _rateItem.max.intValue) {
//                    textField.text = @"";
//                    _rateItem.inputValue = nil;
//                    [self showHudTipStr:@"您输入的值不在范围内，请重新输入"];
//                    return;
//                }
//                if (i == 0) {
//                    textField.text = @"";
//                    _rateItem.inputValue = nil;
//                    [self showHudTipStr:@"您输入的值有误哦~，请重新输入"];
//                    return;
//                }
//                _rateItem.inputValue = textField.text;
//                _lbl_display.text = @"0";
//            } else {
//                [self showHudTipStr:@"请输入数值哦~"];
//            }
//        }
//    }
//}
@end
