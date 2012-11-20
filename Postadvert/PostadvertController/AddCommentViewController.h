//
//  AddCommentViewController.h
//  PostAdvert11
//
//  Created by Mtk Ray on 5/21/12.
//  Copyright (c) 2012 ray@futureworkz.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostCellContent.h"
@protocol AddCommentViewControllerDelegate;
@interface AddCommentViewController : UIViewController <UITextViewDelegate>
{
    IBOutlet UIToolbar *toolbar;
    IBOutlet UIBarButtonItem *barButtonPost;
    CGRect defaulfFrame;
    
}
@property ( nonatomic, assign) PostCellContent *content;
@property ( nonatomic, strong) IBOutlet UITextView *comment;
@property (nonatomic, weak) id <AddCommentViewControllerDelegate> delegate;
-(IBAction)backButtinClicked;
-(IBAction)postButtinClicked;

@end

@protocol AddCommentViewControllerDelegate
- (void) postWithText:(NSString *)str;
@end
