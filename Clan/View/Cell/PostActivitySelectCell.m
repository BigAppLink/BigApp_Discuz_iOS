//
//  PostActivitySelectCell.m
//  Clan
//
//  Created by chivas on 15/11/3.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "PostActivitySelectCell.h"
#import "NSString+Common.h"
@implementation PostActivitySelectCell
- (void)setSelectArray:(NSArray *)selectArray{
    _selectArray = selectArray;
    [self.contentView addSubview:self.titleLabel];
    NSInteger x = 0;
    NSInteger y = _titleLabel.bottom + 23;
    for (NSInteger index = 0; index<_selectArray.count; index++) {
        NSDictionary *dic = _selectArray[index];
        CGSize rect = [NSString boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0) font:[UIFont systemFontOfSize:14.0f] text:dic[@"fieldtext"]];
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(16+x, y, rect.width+20, 26)];
        if (button.right > ScreenWidth - 16) {
            x = 0;
            button.left = 16;
            y = button.bottom+16;
            button.top = y;
        }
        button.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        button.backgroundColor = UIColorFromRGB(0xfcfcfc);
        [button setTitle:dic[@"fieldtext"] forState:UIControlStateNormal];
        [button setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
        [button setTitleColor:UIColorFromRGB(0x1ABC9C) forState:UIControlStateSelected];
        [button addTarget:self action:@selector(selectBtn:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 1000 + index;
        [self.contentView addSubview:button];
        x += button.width+16;
    }
}

- (CGFloat )heightWithSelectCell:(NSArray *)array{
    CGFloat height = 0;
    NSInteger x = 0;
    NSInteger y = 44 + 23;
    
    for (NSInteger index = 0; index<array.count; index++) {
        NSDictionary *dic = array[index];
        CGSize rect = [NSString boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0) font:[UIFont systemFontOfSize:14.0f] text:dic[@"fieldtext"]];
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(16+x, y, rect.width+20, 26)];
        if (button.right > ScreenWidth - 16) {
            x = 0;
            button.left = 16;
            y = button.bottom+16;
            button.top = y;
        }
        button.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        button.backgroundColor = UIColorFromRGB(0xfcfcfc);
        [button setTitle:dic[@"fieldtext"] forState:UIControlStateNormal];
        [button setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
        [button setTitleColor:UIColorFromRGB(0x1ABC9C) forState:UIControlStateSelected];
        button.tag = 1000 + index;
        x += button.width+16;
        height = (button.bottom + 16);
    }
    return height;
    
}
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(18, 0, 200, 44)];
        _titleLabel.text = @"必填资料项";
        _titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _titleLabel.textColor = UIColorFromRGB(0x303030);
    }
    return _titleLabel;
}

- (void)selectBtn:(UIButton *)button{
    NSDictionary *dic = _selectArray[button.tag-1000];
    button.selected =! button.selected;
    if ([self.delegate respondsToSelector:@selector(activitySelectInfoWithInfoDic:)]) {
        [self.delegate activitySelectInfoWithInfoDic:dic];
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
