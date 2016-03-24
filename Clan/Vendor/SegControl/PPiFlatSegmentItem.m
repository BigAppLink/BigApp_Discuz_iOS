//
//  PPiFlatSegmentItem.m
//  PPiFlatSegmentedControl-Demo
//
//  Created by Pedro Piñera Buendía on 14/09/14.
//  Copyright (c) 2014 PPinera. All rights reserved.
//

#import "PPiFlatSegmentItem.h"

@implementation PPiFlatSegmentItem

- (id)initWithTitle:(NSString*)title andIcon:(NSObject*)icon
{
    self = [super init];
    if (self) {
        self.title = title;
        self.icon = icon;
    }
    return self;
}

@end
