//
//  NSString+Emojize.m
//  Field Recorder
//
//  Created by Jonathan Beilin on 11/5/12.
//  Copyright (c) 2014 DIY. All rights reserved.
//

#import "NSString+Emojize.h"
#import "emojis.h"

@implementation NSString (Emojize)

- (NSString *)emojizedString
{
    return [NSString emojizedStringWithString:self];
}

+ (NSString *)emojizedStringWithString:(NSString *)text
{
    return text;
}

- (NSString *)emojizedString1
{
//    return [NSString replaceAllEmotionStrs:self];
    return [NSString emojizedStringWithString1:self];
}

+ (NSString *)emojizedStringWithString1:(NSString *)text
{
//    NSDictionary *dic = [self emojiForAliases];
//    NSArray *arr = [dic allKeys];
//    for (NSString *name in arr) {
//        text = [text stringByReplacingOccurrencesOfString:name withString:dic[name]];
//    }
    return text;
    
//    static dispatch_once_t onceToken;
//    static NSRegularExpression *regex = nil;
//    dispatch_once(&onceToken, ^{
//        regex = [[NSRegularExpression alloc] initWithPattern:@"(:[a-z0-9-+_]+:)" options:NSRegularExpressionCaseInsensitive error:NULL];
//    });
//    
//    __block NSString *resultText = text;
//    NSRange matchingRange = NSMakeRange(0, [resultText length]);
//    [regex enumerateMatchesInString:resultText options:NSMatchingReportCompletion range:matchingRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
//        if (result && ([result resultType] == NSTextCheckingTypeRegularExpression) && !(flags & NSMatchingInternalError)) {
//            NSRange range = result.range;
//            if (range.location != NSNotFound) {
//                NSString *code = [text substringWithRange:range];
//                NSString *unicode = self.emojiForAliases[code];
//                if (unicode) {
//                    resultText = [resultText stringByReplacingOccurrencesOfString:code withString:unicode];
//                }
//            }
//        }
//    }];
//    
//    return resultText;
}

+ (NSString *)replaceAllEmotionStrs:(NSString *)text
{
    DLog(@"------- %@",text);
    static dispatch_once_t onceToken;
    static NSRegularExpression *regex = nil;
    static NSRegularExpression *regex1 = nil;
    
    dispatch_once(&onceToken, ^{
        regex = [[NSRegularExpression alloc] initWithPattern:@"<div +class=\"reply_wrap\">.*?</div>" options:NSRegularExpressionCaseInsensitive error:NULL];
        //为了兼容2.5版本
        regex1 = [[NSRegularExpression alloc] initWithPattern:@"<div +class=\"quote\">.*?</div>" options:NSRegularExpressionCaseInsensitive error:NULL];
    });
    
    __block NSString *resultText = text;
    if (text == nil) {
        return @"";
    }
    NSRange matchingRange = NSMakeRange(0, [resultText length]);
    [regex enumerateMatchesInString:resultText options:NSMatchingReportCompletion range:matchingRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if (result && ([result resultType] == NSTextCheckingTypeRegularExpression) && !(flags & NSMatchingInternalError)) {
            NSRange range = result.range;
            if (range.location != NSNotFound) {
                NSString *code = [text substringWithRange:range];
                resultText = [text stringByReplacingOccurrencesOfString:code withString:[code emojizedString1]];
            }
        }
    }];
    
    NSRange matchingRange1 = NSMakeRange(0, [resultText length]);
    [regex1 enumerateMatchesInString:resultText options:NSMatchingReportCompletion range:matchingRange1 usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if (result && ([result resultType] == NSTextCheckingTypeRegularExpression) && !(flags & NSMatchingInternalError)) {
            NSRange range = result.range;
            if (range.location != NSNotFound) {
                NSString *code = [text substringWithRange:range];
                resultText = [text stringByReplacingOccurrencesOfString:code withString:[code emojizedString1]];
            }
        }
    }];
    DLog(@"------- %@",resultText);
    return resultText;
}


- (NSString *)removeEmoji
{
    NSString *tempStr = [self aliasedString];
    NSString *ResultStr = tempStr;
    NSDictionary *dic = [NSString emojiForAliases];
    for (NSString *key in dic.allKeys) {
        ResultStr = [ResultStr stringByReplacingOccurrencesOfString:key withString:@""];
    }
    return ResultStr;
}

- (NSString *)aliasedString
{
    NSString *str = [NSString aliasedStringWithString:self];
    str = [str stringByReplacingOccurrencesOfString:@"✌️" withString:@":victory:"];
    return str;
}

+ (NSString *)aliasedStringWithString:(NSString *)text
{
    if (!text || text.length <= 0) {
        return text;
    }
    __block NSString *resultText = text;
    [text enumerateSubstringsInRange:NSMakeRange(0, text.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        if (self.aliaseForEmojis[substring]) {
            NSString *aliase = self.aliaseForEmojis[substring];
            resultText = [resultText stringByReplacingOccurrencesOfString:substring withString:aliase];
        }
    }];
    return resultText;
}

+ (NSDictionary *)emojiForAliases {
    static NSDictionary *_emojiForAliases;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _emojiForAliases = EMOJI_HASH;
    });
    return _emojiForAliases;
}

+ (NSDictionary *)aliaseForEmojis {
    static NSMutableDictionary *_aliaseForEmojis;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _aliaseForEmojis = [[NSMutableDictionary alloc] init];
        [[self emojiForAliases] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [_aliaseForEmojis setObject:key forKey:obj];
        }];
    });
    return _aliaseForEmojis;
}

- (NSString *)toAliase{
    return self.class.aliaseForEmojis[self];
}
- (NSString *)toEmoji{
    return self.class.emojiForAliases[self];
}


@end
