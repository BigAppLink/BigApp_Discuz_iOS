//
//  boardTextField.h
//  Clan
//
//  Created by chivas on 15/5/4.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface boardTextField : UITextField
-(CGRect)textRectForBounds:(CGRect)bounds;
-(CGRect)editingRectForBounds:(CGRect)bounds;

@end
