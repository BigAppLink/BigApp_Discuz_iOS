//
//  YZLabel.m
//  Clan
//
//  Created by 昔米 on 15/5/21.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "YZLabel.h"
static float LINESPACE = 1.5;

@implementation YZLabel

- (void)setMyLineSpacing:(CGFloat)myLineSpacing
{
    _myLineSpacing = myLineSpacing;
    self.text = self.text;
}

- (void)setText:(NSString *)text
{
    if (_myLineSpacing < 1) {
        _myLineSpacing = LINESPACE;
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = _myLineSpacing;
    paragraphStyle.alignment = self.textAlignment;
    NSDictionary *attributes = @{NSParagraphStyleAttributeName: paragraphStyle};
    if (!text) {
        text = @"";
    }
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:avoidNullStr(text)
                                                                         attributes:attributes];
    [attributedText addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, attributedText.length)];
    self.attributedText = attributedText;
}

@end
