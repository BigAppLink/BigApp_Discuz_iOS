//
//  SubsCell.m
//  Clan
//
//  Created by chivas on 15/6/23.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "SubsCell.h"
#import "SubsModel.h"
@implementation SubsCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setSubsModel:(SubsModel *)subsModel
{
    _subsModel = subsModel;
    _subName.text = [NSString stringWithFormat:@"%@ （%@）",_subsModel.name,_subsModel.todayposts];
    NSMutableAttributedString* attributedString = [_subName.attributedText mutableCopy];
    NSRange range = [_subName.text rangeOfString:[NSString stringWithFormat:@"（%@）",_subsModel.todayposts]];
    [attributedString addAttribute:NSForegroundColorAttributeName value:kUIColorFromRGB(0x6ea3e5) range:range];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 1.5;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, _subName.text.length)];
    _subName.attributedText = attributedString;
    
}

@end
