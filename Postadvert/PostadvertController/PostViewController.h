//
//  PostViewController.h
//  Postadvert
//
//  Created by Mtk Ray on 6/8/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyUIImagePickerViewController.h"
@class PostCellContent;
@class UIPlaceHolderTextView;
@class UIPostCell;
@interface PostViewController : UIViewController<UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MyUIImagePickerViewControllerDelegate>
{
    UIImagePickerController *imagePicker;
    NSInteger nextID;
    NSMutableArray *listImageNeedToPost;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnTitle;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *phTitleTextView;
@property (weak, nonatomic) IBOutlet UIView *titleView;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activity;
@property (nonatomic, weak)IBOutlet UIImageView *avatarImg;
@property (nonatomic, weak)IBOutlet UIPlaceHolderTextView *phTextView;
@property (nonatomic, weak)IBOutlet UIScrollView * scrollView;
@property (nonatomic, weak)IBOutlet UIBarButtonItem *btnPost;
@property (nonatomic, weak)IBOutlet UIButton *photoButton;
@property (nonatomic, weak)IBOutlet UIView *botView;
@property (nonatomic, weak)IBOutlet UIScrollView *thumbnailView;
@property (nonatomic, strong) UIPopoverController *popoverCtr;
@property (nonatomic)   NSInteger wall_id;
- (id)initWithWallID:(NSInteger) wallID;
- (IBAction)makeKeyboardGoAway:(id)sender;
@end
