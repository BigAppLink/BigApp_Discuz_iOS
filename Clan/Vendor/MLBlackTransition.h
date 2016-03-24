//
//  MLBlackTransition.h
//  LeShuGameObserve
//
//  Created by leshu02 on 14-12-26.
//  Copyright (c) 2014年 leshu02. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    MLBlackTransitionGestureRecognizerTypePan, //拖动模式
    MLBlackTransitionGestureRecognizerTypeScreenEdgePan, //边界拖动模式
} MLBlackTransitionGestureRecognizerType;
@interface MLBlackTransition : NSObject
+ (void)validatePanPackWithMLBlackTransitionGestureRecognizerType:(MLBlackTransitionGestureRecognizerType)type;
@end
@interface UIView(__MLBlackTransition)
//使得此view不响应拖返
@property (nonatomic, assign) BOOL disableMLBlackTransition;
@end
@interface UINavigationController(DisableMLBlackTransition)
- (void)enabledMLBlackTransition:(BOOL)enabled;
@end