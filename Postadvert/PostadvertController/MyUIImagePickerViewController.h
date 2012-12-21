//
//  MyUIImagePickerViewController.h
//  Stroff
//
//  Created by Ray on 11/23/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol MyUIImagePickerViewControllerDelegate;

@interface MyUIImagePickerViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    UIImagePickerController *imagePicker;
    BOOL isShowed;
    UIViewController *_root;
}
@property (nonatomic, weak) id <MyUIImagePickerViewControllerDelegate> delegate;
@property (nonatomic, strong)   NSMutableArray *photos;
@property (nonatomic)           UIImagePickerControllerSourceType sourceType;
- (id) initWithRoot:(UIViewController*) root;

//+ (ALAssetsLibrary *)defaultAssetsLibrary;

@end

@protocol MyUIImagePickerViewControllerDelegate <NSObject>

@optional
- (void) didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void) didFinishPickingMediaWithImage:(UIImage*)image;
- (void) didCancelPickingMedia;

@end
