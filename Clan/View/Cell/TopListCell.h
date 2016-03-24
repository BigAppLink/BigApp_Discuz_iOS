//
//  TopListCell.h
//  Clan
//
//  Created by chivas on 15/4/9.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPLabel.h"
@class ForumsModel;
@protocol BoardFavDelegate <NSObject>

- (void)boardFavWithBool:(BOOL)isFav;

@end
@interface TopListCell : UITableViewCell<PPLabelDelegate>
{
    BOOL _isFav;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic)ForumsModel *forumsModel;
@property (weak, nonatomic) IBOutlet UIImageView *faceImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *themeLabel;
@property (weak, nonatomic) IBOutlet UILabel *postLabel;
@property (weak, nonatomic) IBOutlet UILabel *todayLabel;
@property (weak, nonatomic) IBOutlet PPLabel *masterLabel;
@property (weak, nonatomic) IBOutlet UIButton *favBtn;
@property (assign, nonatomic)id<BoardFavDelegate>delegate;
@property (assign, nonatomic,readonly) int scrollWidth;

@end
