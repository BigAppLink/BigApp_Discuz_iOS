//
//  ApplyActItemCell.m
//  Clan
//
//  Created by 昔米 on 15/11/19.
//  Copyright © 2015年 Youzu. All rights reserved.
//

#import "ApplyActItemCell.h"

@implementation ApplyActItemCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self buildUI];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (!_btn_name) {
            [self buildUI];
        }
    }
    return self;
}

#pragma mark - 搭建UI
- (void)buildUI
{
    UIView *contentview = self.contentView;
    //选中按钮
    self.btn_select = [YZButton buttonWithType:UIButtonTypeCustom];
    self.btn_select.frame = CGRectMake(0, 0, 55, 45);
    [self.btn_select setImage:kIMG(@"act_select_n") forState:UIControlStateNormal];
    [contentview addSubview:_btn_select];
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(kVIEW_BX(_btn_select), 0, kSCREEN_WIDTH-kVIEW_BX(_btn_select)-110, 45)];
    nameLabel.textColor = [Util mainThemeColor];
    nameLabel.tag = 1133;
    nameLabel.font = [UIFont systemFontOfSize:17.f];
    [contentview addSubview:nameLabel];
    
    //申请日期
    self.lbl_date = [[UILabel alloc]initWithFrame:CGRectMake(kVIEW_TX(nameLabel), kVIEW_BY(nameLabel)-10, kSCREEN_WIDTH-32, 15)];
    self.lbl_date.textColor = UIColorFromRGB(0x666666);
    self.lbl_date.font = [UIFont systemFontOfSize:10.f];
    [contentview addSubview:_lbl_date];

    //名字标签
    self.btn_name = [YZButton buttonWithType:UIButtonTypeCustom];
    self.btn_name.frame = CGRectMake(kVIEW_BX(_btn_select), 0, kSCREEN_WIDTH-kVIEW_BX(_btn_select)-110, 45);
    self.btn_name.titleLabel.textAlignment = NSTextAlignmentLeft;
    [contentview addSubview:_btn_name];
    
    
    //审核btn
    self.btn_deal = [YZButton buttonWithType:UIButtonTypeCustom];
    self.btn_deal.layer.cornerRadius = 4;
    self.btn_deal.clipsToBounds = YES;
    self.btn_deal.frame = CGRectMake(0, 0, 70, 24);
    self.btn_deal.titleLabel.font = [UIFont systemFontOfSize:12.f];
    self.btn_deal.center = CGPointMake(kSCREEN_WIDTH-16-35, kVIEW_CENTERY(_btn_select));
    [_btn_deal setBackgroundImage:[Util imageWithColor:kUIColorFromRGB(0xf3f3f3)] forState:UIControlStateNormal];
    _btn_deal.enabled = NO;
    [contentview addSubview:_btn_deal];
    
    //textview
    UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(55, kVIEW_BY(_lbl_date), kSCREEN_WIDTH-55-16, 100)];
    textView.selectable = YES;
    textView.dataDetectorTypes = UIDataDetectorTypeLink;
    [textView setEditable:NO];
    textView.scrollEnabled = NO;
    self.tv_content = textView;
    [contentview addSubview:textView];

    //底部
    self.v_bottom = [[UIView alloc]initWithFrame:CGRectMake(0, kVIEW_BY(_tv_content)+10.f, kSCREEN_WIDTH, 34)];
    [contentview addSubview:_v_bottom];
    //添加边线
    self.iv_seperator = [[UIImageView alloc]initWithFrame:CGRectMake(kVIEW_TX(_tv_content), 0, kVIEW_W(_v_bottom), 0.5)];
    self.iv_seperator.image = [Util imageWithColor:kUIColorFromRGB(0xefefef)];
    [_v_bottom addSubview:_iv_seperator];
    //添加折叠按钮
    self.btn_expand = [YZButton buttonWithType:UIButtonTypeCustom];
    self.btn_expand.frame = _v_bottom.bounds;
    self.btn_expand.titleLabel.font = [UIFont systemFontOfSize:12.f];
    [self.btn_expand setTitleColor:kUIColorFromRGB(0x999999) forState:UIControlStateNormal];
    [self.btn_expand setTitle:@"展开" forState:UIControlStateNormal];
    [self.btn_expand setImage:kIMG(@"act_more") forState:UIControlStateNormal];
    [_v_bottom addSubview:_btn_expand];
    
    _btn_select.exclusiveTouch = YES;
    _btn_deal.exclusiveTouch = YES;
    _btn_name.exclusiveTouch = YES;
    _btn_expand.exclusiveTouch = YES;
}

- (void)setPath:(NSIndexPath *)path
{
    _path = path;
    _btn_select.path = path;
    _btn_name.path = path;
    _btn_expand.path = path;
    _btn_deal.path = path;
}

- (void)setApplyitem:(ApplyActivityItem *)applyitem
{
    _applyitem = applyitem;
    
    BOOL expanded = applyitem.expanded;
    BOOL showExpandBtn = YES;
    NSString *htmlStr = applyitem.ufielddata;
    htmlStr = [htmlStr stringByAppendingString:@"<style>body{font-size:14px;color:#303030;}</style>"];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithData:[htmlStr dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    _tv_content.attributedText = attributedString;
    [_tv_content sizeToFit];
    CGRect rect = _tv_content.bounds;
    CGRect rectR = _tv_content.frame;
    if (expanded) {
        _tv_content.frame = CGRectMake(rectR.origin.x, rectR.origin.y, kSCREEN_WIDTH-55-16, rect.size.height);
        [self.btn_expand setTitle:@"收起" forState:UIControlStateNormal];
        [self.btn_expand setImage:kIMG(@"act_up") forState:UIControlStateNormal];
    } else {
        _tv_content.frame = CGRectMake(rectR.origin.x, rectR.origin.y, kSCREEN_WIDTH-55-16, rect.size.height < 100.f ? rect.size.height : 100.f);
        if (rect.size.height <= 100.f) {
            //隐藏展开按钮
            showExpandBtn = NO;
        }
        [self.btn_expand setTitle:@"展开" forState:UIControlStateNormal];
        [self.btn_expand setImage:kIMG(@"act_down") forState:UIControlStateNormal];
    }
    CGRect bottomFrame = _v_bottom.frame;
    if (showExpandBtn) {
        bottomFrame.origin.y = kVIEW_BY(_tv_content);
        _v_bottom.hidden = NO;
    } else {
        bottomFrame.origin.y = kVIEW_BY(_tv_content);
        bottomFrame.size.height = 0;
        _v_bottom.hidden = YES;
    }
    _v_bottom.frame = bottomFrame;
    UILabel *nameLabel = [self.contentView viewWithTag:1133];
    nameLabel.text = applyitem.username;
    _lbl_date.text = [NSString stringWithFormat:@"申请时间：%@",applyitem.dateline];
    [self setVerificationStatus:applyitem.verified.integerValue];
}

- (void)setVerificationStatus:(NSInteger)verified
{
//    verified：用户是否通过审核，0：等待审核，1：已通过审核，2：打回完善资料
    if (verified == 0) {
        //等待审核
        [_btn_deal setTitle:@"等待审核" forState:UIControlStateNormal];
        [_btn_deal setTitleColor:kUIColorFromRGB(0x666666) forState:UIControlStateNormal];
    }
    else if (verified == 1) {
        //已通过审核
        [_btn_deal setTitle:@"审核通过" forState:UIControlStateNormal];
        [_btn_deal setTitleColor:[Util mainThemeColor] forState:UIControlStateNormal];
    }
    else if (verified == 2) {
        //打回完善资料
        [_btn_deal setTitle:@"已打回" forState:UIControlStateNormal];
        [_btn_deal setTitleColor:kUIColorFromRGB(0x666666) forState:UIControlStateNormal];
    }
}

- (void)setItemSleceted:(BOOL)itemSleceted
{
    _itemSleceted = itemSleceted;
    if (itemSleceted) {
        [self.btn_select setImage:[[UIImage imageNamed:@"act_select_h"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    } else {
        [self.btn_select setImage:kIMG(@"act_select_n") forState:UIControlStateNormal];
    }
}

@end
