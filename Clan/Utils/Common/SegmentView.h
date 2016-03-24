//
//  SegmentView.h
//  Clan
//
//  Created by chivas on 15/3/5.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SegmentView : UIView
-(id)initWithFrameRect:(CGRect)rect andTitleArray:(NSArray *)titleArray clickBlock:(void(^)(NSInteger index))segIndexBlock;

@end
