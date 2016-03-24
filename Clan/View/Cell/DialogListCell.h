//
//  DialogListCell.h
//  Clan
//
//  Created by 昔米 on 15/4/13.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DialogListModel.h"
#import "YZButton.h"

@interface DialogListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet YZButton *btn_avatar;
@property (weak, nonatomic) IBOutlet UILabel *lbl_name;
@property (weak, nonatomic) IBOutlet UILabel *lbl_content;
@property (strong, nonatomic) UIImageView *iv_newmess;

@property (weak, nonatomic) IBOutlet UIImageView *iv_line;
@property (strong, nonatomic) DialogListModel *dialog;
@end

