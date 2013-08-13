//
//  UILable_Margin.m
//  Stroff
//
//  Created by Ray on 8/7/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import "UILable_Margin.h"

@implementation UILable_Margin

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _insets = UIEdgeInsetsZero;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
#pragma mark - Overwrite UILable

- (void)drawTextInRect:(CGRect)rect {
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.insets)];
}

@end
