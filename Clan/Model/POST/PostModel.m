//
//  PostModel.m
//  Clan
//
//  Created by chivas on 15/3/18.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "PostModel.h"
#import "ClanAPostCell.h"
#import "NSString+Common.h"

@interface PostModel ()
@property (assign,nonatomic,readwrite)CellImageType imageType;

@end

@implementation PostModel
+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{
             @"type_id" : @"typeid",
             @"type_name":@"typename",
             };
}

- (CGFloat)frameWithModel{
    if (self.attachment_urls.count == 0) {
        //无图
        _imageType = KNoImage;
        
    }else if (self.attachment_urls.count > 0  && self.attachment_urls.count < 3){
        //单图
        _imageType = KSingleImage;
    }else if (self.attachment_urls.count > 2){
        //多图
        _imageType = KMoreImage;
    }
    
    CGFloat frame = 15+17+3+12+12;
    NSString *titleString = self.subject;
    if ([self.prefix isEqualToString:@"1"] && self.type_name && self.type_name.length > 0) {
        titleString = [NSString stringWithFormat:@"[%@] %@",self.type_name,self.subject];
    }
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:avoidNullStr(titleString)];
    if ([self.prefix isEqualToString:@"1"] && self.type_name && self.type_name.length > 0) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:kUIColorFromRGB(0x6ea3e5) range:NSMakeRange(0, self.type_name.length+2)];
    }
    if (self.icon && self.icon.integerValue > 0) {
        if (![self.icon isEqualToString:@"10"] && ![self.icon isEqualToString:@"14"] && ![self.icon isEqualToString:@"9"]) {
            NSAttributedString *spaceString = [[NSAttributedString alloc] initWithString:@" "];
            NSTextAttachment * textAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil ] ;
            textAttachment.image = kIMG(self.icon);
            textAttachment.bounds = CGRectMake(0, -1, textAttachment.image.size.width, textAttachment.image.size.height);
            NSAttributedString * textAttachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
            [attributedString appendAttributedString:spaceString];
            [attributedString appendAttributedString:textAttachmentString];
        }
    }
    UIFont *titleFont = [UIFont systemFontOfSize:17.0f];
    [attributedString addAttribute:NSFontAttributeName value:titleFont range:NSMakeRange(0, attributedString.length)];
    CGFloat titleWidth = ScreenWidth - 32;
    if (_modelType && [_modelType isEqualToString:@"1"]) {
        //说明是首页的
        titleWidth = [[NSString returnPlistWithKeyValue:kOpenImageMode] isEqualToString:@"2"] ? ScreenWidth - 32 - 19 - 16: ScreenWidth - 32;
    }else{
        //帖子列表的
        titleWidth = [[NSString returnPlistWithKeyValue:kOpenImageMode] isEqualToString:@"0"] ? ScreenWidth - 32 - 19 - 16: ScreenWidth - 32;
    }
    if (_imageType == KSingleImage) {
        titleWidth = ScreenWidth-70-50-16;
    }
    CGSize maxSize = CGSizeMake(titleWidth, CGFLOAT_MAX);
    CGRect boundingRect = [attributedString boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    textLabel.numberOfLines = 2;
    textLabel.font = [UIFont systemFontOfSize:17.0f];
    textLabel.attributedText = attributedString;
    textLabel.width = titleWidth;
    textLabel.height = boundingRect.size.height;
    [textLabel sizeToFit];
    
    frame += textLabel.height + 2;
    //title和content间隔
    if (_imageType == KNoImage) {
        frame += 20;
        if (self.message_abstract && self.message_abstract.length > 0) {
            CGSize contentSize = [self.message_abstract sizeWithConstrainedToWidth:ScreenWidth-32 fromFont:[UIFont systemFontOfSize:14.0f] lineSpace:10];
            UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth-32, 0)];
            contentLabel.numberOfLines = 2;
            contentLabel.font = [UIFont systemFontOfSize:14.0f];
            contentLabel.text = self.message_abstract;
            contentLabel.height = contentSize.height;
            [contentLabel sizeToFit];
            frame += contentSize.height + 2;
        }else{
            frame += 2;
        }
    }else if (_imageType == KSingleImage){
        frame += 32;
    }else if (_imageType == KMoreImage){
        frame += 12;
        frame += (ScreenWidth-32-10)/3;
        frame += 12;
    }
    
    //底部
    frame += 15+15+10.5;
    self.frame = frame;
    return frame;
}

@end
