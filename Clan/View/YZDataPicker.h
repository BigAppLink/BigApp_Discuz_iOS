//
//  YZDataPicker.h
//  Clan
//
//  Created by chivas on 15/10/30.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YZDataPicker;
@protocol YZDataPickerDelegate<NSObject>
@optional
-(void)toobarCancelClick;
-(void)toobarDonBtnHaveClick:(YZDataPicker *)pickView resultString:(NSString *)resultString;
@end
@interface YZDataPicker : UIView
@property(nonatomic,weak) id<YZDataPickerDelegate> delegate;

- (void)show;
- (void)remove;
@end
