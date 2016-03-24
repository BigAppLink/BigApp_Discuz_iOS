//
//  ClanAPostCell.h
//  Clan
//
//  Created by chivas on 15/11/5.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PostModel;
typedef enum : NSUInteger {
    KNoImage,
    KSingleImage,
    KMoreImage,
} CellImageType;

@interface ClanAPostCell : UITableViewCell
@property (assign,nonatomic)CellImageType imageType;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) PostModel *postModel;
@property (strong, nonatomic,readwrite) UIImageView *iv_avatar;
@property (strong, nonatomic,readwrite) UILabel *lbl_name;
@property (strong, nonatomic,readwrite) UILabel *lbl_time;
@property (strong, nonatomic,readwrite) UILabel *lbl_views;
@property (strong, nonatomic,readwrite) UILabel *lbl_title;
@property (strong, nonatomic,readwrite) UILabel *lbl_content;
@property (strong, nonatomic,readwrite) UIImageView *singleImage;
@property (assign) BOOL showTopic; //是否显示
@property (assign) BOOL listable; //是否可点
@property (strong, nonatomic,readwrite) UIView *v_images;
@property (strong, nonatomic,readwrite) UIView *forumView;
@property (strong, nonatomic,readwrite) UIButton *forumButton;
@property (strong, nonatomic,readwrite) UIView *bottomView;
@property (strong, nonatomic,readwrite) UIImageView *iconView;
@property (strong, nonatomic,readwrite) UIImageView *digestView;
@property (strong, nonatomic,readwrite) UILabel *label1;
@property (strong, nonatomic,readwrite) UILabel *label2;
@property (strong, nonatomic,readwrite) UIButton *picCountBtn;
@property (strong, nonatomic,readwrite) UIView *digestsView;
@property (strong, nonatomic,readwrite) UIImageView *noImageView;
@property (assign, nonatomic,readwrite) BOOL isImage;

@end
