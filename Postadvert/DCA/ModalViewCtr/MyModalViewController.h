//
//  MyModalViewController.h
//  Stroff
//
//  Created by Ray on 1/21/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyModalViewController : UIViewController

@property (nonatomic, weak) UIView *rootView;
- (IBAction)closeModalView:(id)sender;

@end
