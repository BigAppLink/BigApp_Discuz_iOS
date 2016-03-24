//
//  boardTextField.m
//  Clan
//
//  Created by chivas on 15/5/4.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "boardTextField.h"

@implementation boardTextField

-(CGRect)textRectForBounds:(CGRect)bounds {
    int margin =3;
    CGRect inset =CGRectMake(bounds.origin.x + margin, bounds.origin.y, bounds.size.width - margin, bounds.size.height);
    return inset;
}

-(CGRect)editingRectForBounds:(CGRect)bounds {
    int margin =3;
    CGRect inset =CGRectMake(bounds.origin.x + margin, bounds.origin.y, bounds.size.width - margin, bounds.size.height);
    return inset;
}


@end
