//
//  YZPickView.h
//  Clan
//
//  Created by chivas on 15/5/29.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YZPickView;

@protocol YZPickViewDelegate <NSObject>

@optional
-(void)toobarDonBtnHaveClick:(YZPickView *)pickView resultString:(NSString *)resultString;
-(void)toobarCancelClick;
@end

@interface YZPickView : UIView

@property(nonatomic,weak) id<YZPickViewDelegate> delegate;

-(instancetype)initPickviewWithArray:(NSArray *)array isHaveNavControler:(BOOL)isHaveNavControler;

/**
 *   移除控件
 */
-(void)remove;
/**
 *  显示本控件
 */
-(void)show;
/**
 *  设置PickView的颜色
 */
-(void)setPickViewColer:(UIColor *)color;
/**
 *  设置toobar的文字颜色
 */
-(void)setTintColor:(UIColor *)color;
/**
 *  设置toobar的背景颜色
 */
-(void)setToolbarTintColor:(UIColor *)color;
@end