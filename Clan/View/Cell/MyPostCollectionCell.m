//
//  MyPostCollectionCell.m
//  Clan
//
//  Created by chivas on 15/3/17.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "MyPostCollectionCell.h"
#import "CollectionListModel.h"
#import "Util.h"

@implementation MyPostCollectionCell

- (void)awakeFromNib
{
    [self.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [self.titleLabel setNumberOfLines:0];
    [self.titleLabel setTextAlignment:NSTextAlignmentLeft];
    self.titleLabel.font = [UIFont fitFontWithSize:17.f];
    self.titleLabel.textColor = K_COLOR_DARK;
    self.authorLabel.font = [UIFont fitFontWithSize:14.f];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


- (void)setModel:(id)model
{
    CollectionListModel *listmodel = (CollectionListModel *)model;
    _titleLabel.text = listmodel.title;
    NSString *time = [Util changeTimestampToStr:listmodel.dateline];
    NSString *info = [NSString stringWithFormat:@"%@  %@", listmodel.author, time];
    if ([listmodel.idtype isEqualToString:@"aid"]) {
        info = [NSString stringWithFormat:@" %@",avoidNullStr(listmodel.dateline)];
        NSMutableAttributedString * string = [[NSMutableAttributedString alloc ] initWithString:@"" attributes:nil];
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        NSTextAttachment * textAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil ] ;
        textAttachment.image = kIMG(@"icon_clock") ;
        textAttachment.bounds = CGRectMake(-1, -1, 10, 10);
        NSAttributedString * textAttachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment] ;
        [string appendAttributedString:textAttachmentString];
        [string appendAttributedString:[[NSMutableAttributedString alloc ] initWithString:avoidNullStr(info) attributes:nil]];
        _authorLabel.attributedText = string ;
    } else {
        _authorLabel.text = info;
    }
    _titleLabel.preferredMaxLayoutWidth = kSCREEN_WIDTH-2*15;
    
}
@end
