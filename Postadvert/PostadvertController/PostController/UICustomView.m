//
//  UICustomView.m
//  Stroff
//
//  Created by Ray on 4/6/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import "UICustomView.h"

@implementation UICustomView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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
- (void)didAddSubview:(UIView *)subview
{
    [super didAddSubview:subview];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:subview forKey:@"subview"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didAddSubview" object:self userInfo:dict];
}

- (void)willRemoveSubview:(UIView *)subview
{
    [subview willRemoveSubview:subview];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:subview forKey:@"subview"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"willRemoveSubview" object:self userInfo:dict];
}
@end
