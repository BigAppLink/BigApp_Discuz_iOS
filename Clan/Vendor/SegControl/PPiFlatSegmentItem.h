//
//  PPiFlatSegmentItem.h
//  PPiFlatSegmentedControl-Demo
//
//  Created by Pedro Piñera Buendía on 14/09/14.
//  Copyright (c) 2014 PPinera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PPiFlatSegmentItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSObject *icon;

- (id)initWithTitle:(NSString*)title andIcon:(NSObject*)icon;

@end
