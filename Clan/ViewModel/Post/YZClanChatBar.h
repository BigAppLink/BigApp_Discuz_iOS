//
//  YZClanChatBar.h
//  Clan
//
//  Created by chivas on 15/11/25.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  functionView 类型
 */
typedef NS_ENUM(NSUInteger, YZFunctionViewShowType){
    YZFunctionViewShowNothing /**< 不显示functionView */,
    YZFunctionViewShowFace /**< 显示表情View */,
    YZFunctionViewShowMore /**< 显示更多view */,
    XMFunctionViewShowKeyboard /**< 显示键盘 */,
};

@interface YZClanChatBar : UIView
/**
 *  结束输入状态
 */
- (void)endInputing;

@end
