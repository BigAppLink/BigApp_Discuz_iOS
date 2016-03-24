//
//  PostSendCell.h
//  Clan
//
//  Created by chivas on 15/3/25.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGEmojiKeyBoardView.h"
#import "UIPlaceHolderTextView.h"

@interface PostSendCell : UITableViewCell<UITextViewDelegate,UITextFieldDelegate>
@property (strong, nonatomic) UIPlaceHolderTextView *tweetContentView;
@property (nonatomic,copy) void(^subjectValueChangedBlock)(NSString*);
@property (nonatomic,copy) void(^messageValueChangedBlock)(NSString*);
//是否回帖 YES回帖 NO发新帖
@property (nonatomic,assign) BOOL isRelayPost;
//是否选择版块儿
@property (nonatomic,assign) BOOL selectedForums;
@property (strong, nonatomic) UIButton *selectedForumsBtn;
+ (CGFloat)cellHeight;

@end
