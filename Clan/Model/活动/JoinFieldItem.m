//
//  JoinFieldItem.m
//  Clan
//
//  Created by 昔米 on 15/11/16.
//  Copyright © 2015年 Youzu. All rights reserved.
//

#import "JoinFieldItem.h"

@implementation JoinFieldItem

+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{
             @"defaultValue" : @"default",
             @"f_description": @"description"
             };
}

- (void)setFormtype:(NSString *)formtype
{
    _formtype = formtype;
    if (!formtype || formtype.length <= 0) {
        return;
    }
    if ([@"text" isEqualToString:formtype]) {
        if (_dz_formtype && _dz_formtype == DZActivityFormType_Provincepicker) {
            return;
        }
        //文本类型
        _dz_formtype = DZActivityFormType_Text;
    }
    else if ([@"select" isEqualToString:formtype] || [@"radio" isEqualToString:formtype]) {
        //单选
        _dz_formtype = DZActivityFormType_Select;
    }
    else if ([@"datepicker" isEqualToString:formtype]) {
        //日期选择器
        _dz_formtype = DZActivityFormType_DatePicker;
    }
    else if ([@"textarea" isEqualToString:formtype]) {
        //多文本
        _dz_formtype = DZActivityFormType_TextArea;
    }
    else if ([@"checkbox" isEqualToString:formtype] || [@"list" isEqualToString:formtype]) {
        //多选
        _dz_formtype = DZActivityFormType_Checkbox;
    }
    else if ([@"file" isEqualToString:formtype]) {
        //上传图片
        _dz_formtype = DZActivityFormType_File;
    }
}

- (void)setFieldid:(NSString *)fieldid
{
    _fieldid = fieldid;
    if ([@"birthprovince" isEqualToString:fieldid] || [@"resideprovince" isEqualToString:fieldid]) {
        //省份选择器
        _dz_formtype = DZActivityFormType_Provincepicker;
    }
    
}
@end
