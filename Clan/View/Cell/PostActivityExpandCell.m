//
//  PostActivityExpandCell.m
//  Clan
//
//  Created by chivas on 15/12/7.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "PostActivityExpandCell.h"
#import "UIPlaceHolderTextView.h"
@interface PostActivityExpandCell()<UITextViewDelegate>
@property (strong, nonatomic) UILabel *titleLabel;
@property (copy, nonatomic) NSString *tempExpand;
@property (strong, nonatomic) UIPlaceHolderTextView *textView;
@property (strong, nonatomic) NSMutableArray *extfieldArray;//扩展项
@end
@implementation PostActivityExpandCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_extfieldArray) {
            _extfieldArray = [NSMutableArray array];
        }
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.textView];

    }
    return self;
}

- (void)setActivityextnum:(NSString *)activityextnum{
    _activityextnum = activityextnum;
    _textView.placeholder = [NSString stringWithFormat:@"请输入扩展字段信息(如果有多项，以英文逗号隔开，最多支持%@项)",_activityextnum];

}
#pragma mark - getter
- (UIPlaceHolderTextView *)textView{
    if (!_textView) {
        _textView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(15, _titleLabel.bottom + 5 , ScreenWidth-30, 60)];
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.font = [UIFont fitFontWithSize:17.f];
        _textView.delegate = self;
        _textView.returnKeyType = UIReturnKeyDefault;
    }
    return _textView;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(18, 0, 200, 44)];
        _titleLabel.text = @"扩展字段信息(选填)";
        _titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _titleLabel.textColor = UIColorFromRGB(0x303030);
    }
    return _titleLabel;
}

#pragma mark - textview delegate
- (void)textViewDidChange:(UITextView *)textView{
    _tempExpand = textView.text;
    NSArray *array = [textView.text componentsSeparatedByString:@","];
    _extfieldArray = [array mutableCopy];
    if (_extfieldArray.count > 0) {
        NSString *expandString;
        for (NSString *string in _extfieldArray) {
            NSString *tempString = [NSString stringWithFormat:@"%@",string];
            expandString = expandString ? [NSString stringWithFormat:@"%@\r\n%@",expandString,tempString]: tempString;
        }
        if ([self.delegate respondsToSelector:@selector(activityExpandString:)]) {
            [self.delegate activityExpandString:expandString];
        }
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (!_tempExpand || _tempExpand.length == 0) {
        if ([text isEqualToString:@","]) {
            return NO;
        }
    }
    if (_extfieldArray.count == _activityextnum.integerValue) {
        if ([text isEqualToString:@","]) {
            return NO;
        }
    }
    return YES;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
