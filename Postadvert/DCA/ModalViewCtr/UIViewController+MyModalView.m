//
//  UIViewController+MyModalView.m
//  Stroff
//
//  Created by Ray on 1/21/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import "UIViewController+MyModalView.h"

@implementation UIViewController(MyModalView)

- (void) presentSemiModalViewController:(MyModalViewController*)vc {
	UIView* modalView = vc.view;
    UIView *rootView = vc.rootView;
    
//	coverView.frame = rootView.bounds;
//    coverView.alpha = 0.0f;
    
    modalView.frame = rootView.bounds;
	modalView.center = self.offscreenCenter;
	
	//[rootView addSubview:coverView];
	[rootView addSubview:modalView];
	
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.6];
	
	modalView.frame = CGRectMake(0, 0, modalView.frame.size.width, modalView.frame.size.height);
//	coverView.alpha = 0.5;
    
	[UIView commitAnimations];
    
}

-(void) dismissSemiModalViewController:(MyModalViewController*)vc {
	double animationDelay = 0.7;
	UIView* modalView = vc.view;
    
    
	[UIView beginAnimations:nil context:(__bridge void *)(modalView)];
	[UIView setAnimationDuration:animationDelay];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(dismissSemiModalViewControllerEnded:finished:context:)];
	
    modalView.center = self.offscreenCenter;
//	coverView.alpha = 0.0f;
    
	[UIView commitAnimations];
    
//	[coverView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:animationDelay];
    
}

- (void) dismissSemiModalViewControllerEnded:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	UIView* modalView = (__bridge UIView*)context;
	[modalView removeFromSuperview];
    
}

-(CGPoint) offscreenCenter {
    CGPoint offScreenCenter = CGPointZero;
    
    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    CGSize offSize = UIScreen.mainScreen.bounds.size;
    
	if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
		offScreenCenter = CGPointMake(offSize.height / 2.0, offSize.width * 1.5);
	} else {
		offScreenCenter = CGPointMake(offSize.width / 2.0, offSize.height * 1.5);
	}
    
    return offScreenCenter;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (IBAction)closeModalView:(id)sender {
    
    
}
@end
