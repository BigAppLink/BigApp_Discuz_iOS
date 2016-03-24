//
//  TicklingPostCell.h
//  Clan
//
//  Created by chivas on 15/8/27.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"

@interface TicklingPostCell : UITableViewCell<UITextViewDelegate,UITextFieldDelegate>
@property (strong, nonatomic) UIPlaceHolderTextView *tweetContentView;
@property (nonatomic,copy) void(^subjectValueChangedBlock)(NSString*);
@property (nonatomic,copy) void(^messageValueChangedBlock)(NSString*);
+ (CGFloat)cellHeight;

@end
