//
//  SegmentView.m
//  Clan
//
//  Created by chivas on 15/3/5.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "SegmentView.h"
#import "PPiFlatSegmentedControl.h"

@implementation SegmentView

- (id)initWithFrameRect:(CGRect)rect andTitleArray:(NSArray *)titleArray clickBlock:(void(^)(NSInteger index))segIndexBlock
{
    if ((self=[super initWithFrame:rect])) {
        NSMutableArray *segItems = [NSMutableArray array];
        for (NSString *title in titleArray) {
            PPiFlatSegmentItem *segItem = [[PPiFlatSegmentItem alloc]initWithTitle:title andIcon:nil];
            [segItems addObject:segItem];
            }
        PPiFlatSegmentedControl *segmented=[[PPiFlatSegmentedControl alloc] initWithFrame:self.bounds
                                                                                    items:segItems
                                                                             iconPosition:IconPositionRight
                                                                        andSelectionBlock:^(NSUInteger segmentIndex) {
                                                                            segIndexBlock(segmentIndex);
//                                                                            NSLog(@"%lu",(unsigned long)segmentIndex);
                                                                        }
                                                                           iconSeparation:0];
        segmented.color=[UIColor whiteColor];
        segmented.borderWidth=0.5;
        segmented.borderColor=[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1];
        segmented.selectedColor=[UIColor returnColorWithPlist:YZSegMentColor];
        segmented.textAttributes=@{NSFontAttributeName:[UIFont systemFontOfSize:13],
                                   NSForegroundColorAttributeName:[UIColor returnColorWithPlist:YZSegMentColor]};
        segmented.selectedTextAttributes=@{NSFontAttributeName:[UIFont systemFontOfSize:13],
                                           NSForegroundColorAttributeName:[UIColor whiteColor]};
        [self addSubview:segmented];
    }
    return self;
}


@end
