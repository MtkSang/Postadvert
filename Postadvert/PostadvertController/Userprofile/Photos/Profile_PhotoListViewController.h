//
//  Profile_PhotoListViewController.h
//  Stroff
//
//  Created by Ray on 10/17/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
//#import "KTThumbsViewController.h"

//@class SDWebImageDataSource;
@interface Profile_PhotoListViewController : UIViewController<MBProgressHUDDelegate, UIActionSheetDelegate , UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    //SDWebImageDataSource *images_;
//    UIActivityIndicatorView *activityIndicatorView_;
//    UIWindow *window_;
    CGSize thumbSize_;
    NSMutableArray *listContent;
    __weak IBOutlet UIScrollView *scrollView;
    UIImagePickerController *imagePicker;
    UIPopoverController *popoverCtr;
}
@property (nonatomic, weak)  UINavigationController *navigationController;
@property (nonatomic)   NSInteger   photoCount;
@property (nonatomic)   NSInteger   albumID;
@end


