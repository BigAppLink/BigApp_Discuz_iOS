//
//  ItemView.m
//  Clan
//
//  Created by chivas on 15/7/1.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ItemView.h"

@implementation ItemView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews
{
    // 小图片
    _item = [[UIImageView alloc] initWithFrame:CGRectMake(self.width/2.0-24, 11, 48, 48)];
    _item.contentMode = UIViewContentModeScaleAspectFill;
    _item.userInteractionEnabled = YES;
    _item.layer.cornerRadius = 48/2;
    _item.clipsToBounds = YES;
    [self addSubview:_item];
    
    // 小标题
    _title = [[UILabel alloc] initWithFrame:CGRectMake(0, _item.bottom+6, self.width, 15)];
    _title.backgroundColor = [UIColor clearColor];
    _title.textColor = UIColorFromRGB(0x424242);
    _title.font = [UIFont systemFontOfSize:13];
    _title.textAlignment = NSTextAlignmentCenter;
    self.backgroundColor = [UIColor redColor];
    [self addSubview:_title];
}

@end
