//
//  HDBSubItemImageCollectionViewCell.m
//  Stroff
//
//  Created by Ray on 7/8/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import "HDBSubItemImageCollectionViewCell.h"

#import <QuartzCore/QuartzCore.h>


@interface HDBSubItemImageCollectionViewCell ()

@property (nonatomic, strong, readwrite) UIImageView *imageView;

@end

@implementation HDBSubItemImageCollectionViewCell

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
//        self.layer.borderColor = [UIColor whiteColor].CGColor;
//        self.layer.borderWidth = 3.0f;
        self.layer.shadowColor = [UIColor blueColor].CGColor;
        self.layer.shadowRadius = 3.0f;
        self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        self.layer.shadowOpacity = 0.3f;
        // make sure we rasterize nicely for retina
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.shouldRasterize = YES;
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self.contentView addSubview:self.imageView];
    }
    
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.imageView.image = nil;
}

//-(void) setHighlighted:(BOOL)highlighted {
//    [super setHighlighted:highlighted];
//    [self setNeedsDisplay];
//}
//-(void) drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    
//    if (self.selected) {
//        CGContextRef context = UIGraphicsGetCurrentContext();
//        CGContextSetRGBFillColor(context, 1, 0, 0, 1);
//        CGContextFillRect(context, self.bounds);
//        self.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
//        
//        self.layer.borderColor = [UIColor whiteColor].CGColor;
//        self.layer.borderWidth = 3.0f;
//        self.layer.shadowColor = [UIColor blackColor].CGColor;
//    }else
//    {
//        self.backgroundColor = [UIColor clearColor];
//    }
//}

@end