//
//  MyUIImagePickerViewController.h
//  Stroff
//
//  Created by Ray on 11/23/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyUIImagePickerViewControllerDelegate;

@interface MyUIImagePickerViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    UIImagePickerController *imagePicker;
    BOOL isShowed;
    UIViewController *_root;
}
@property (nonatomic, weak) id <MyUIImagePickerViewControllerDelegate> delegate;
- (id) initWithRoot:(UIViewController*) root;

@end

@protocol MyUIImagePickerViewControllerDelegate

- (void) didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void) didFinishPickingMediaWithImage:(UIImage*)image;
- (void) didCancelPickingMedia;

@end
