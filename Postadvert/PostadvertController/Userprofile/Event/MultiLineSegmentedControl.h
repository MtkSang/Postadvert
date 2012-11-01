//
//  MultiLineSegmentedControl.h
//  Stroff
//
//  Created by Ray on 10/29/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MultiLineSegmentedControl : UISegmentedControl
{
    BOOL initialized;
}

- (void)setSubTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment;
@end
