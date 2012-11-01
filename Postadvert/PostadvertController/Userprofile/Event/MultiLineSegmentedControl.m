//
//  MultiLineSegmentedControl.m
//  Stroff
//
//  Created by Ray on 10/29/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "MultiLineSegmentedControl.h"

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


static NSInteger MLSC_TAG = 0x666; // random number... hopefully unused.

@implementation MultiLineSegmentedControl


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)initialize
{
    if (!initialized)
    {
        for (UIView * segmentView in self.subviews)
        {
            UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont boldSystemFontOfSize:14];
            label.textAlignment = UITextAlignmentCenter;
            label.shadowColor = [UIColor darkGrayColor];
            label.tag = MLSC_TAG;
            
            [segmentView addSubview:label];
        }
        
        initialized = YES;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self initialize];
    
    // Iterate over each segment in the UISegmentedControl.
    for (UIView * segmentView in self.subviews)
    {
        // Iterate over each subview in the current segment.
        UILabel * titleLabel = nil;
        for (UIView * subview in segmentView.subviews)
        {
            // Search for the 'title' label, it can be identified b/c it has an unset tag (zero) and is of type UILabel.
            if ([subview isKindOfClass:[UILabel class]] && subview.tag == 0)
            {
                titleLabel = (UILabel *)subview;
                break;
            }
        }
        
        UILabel * subTitleLabel = (UILabel *)[segmentView viewWithTag:MLSC_TAG];
        if (titleLabel && subTitleLabel)
        {
            CGFloat h = [subTitleLabel.font lineHeight];
            
            CGRect f = titleLabel.frame;
            f.origin.y -= h / 2;
            titleLabel.frame = f;
            
            f.origin.y += h;
            f.origin.x = 0;
            f.size.width = segmentView.frame.size.width;
            subTitleLabel.frame = f;
        }
    }
}

- (void)setSubTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment
{
    UIView * segmentView = [self.subviews objectAtIndex:segment];
    if (segmentView)
    {
        UILabel * label = (UILabel *)[segmentView viewWithTag:MLSC_TAG];
        if (label)
        {
            label.text = title;
        }
    }
}

@end
