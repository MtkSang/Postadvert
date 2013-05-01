//
//  InsertPictureViewController.h
//  Stroff
//
//  Created by Ray on 4/12/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyUIImagePickerViewController.h"
@interface InsertPictureViewController : UIViewController<MyUIImagePickerViewControllerDelegate, UIActionSheetDelegate>
{
    NSInteger nextID;
    id delegate;
}
@property (nonatomic, strong) IBOutlet id delegate;
@property (strong, nonatomic) NSString *keyForTitle;
@property (strong, nonatomic) IBOutlet UIButton *btnInsertPicture;
@property (strong, nonatomic) NSMutableArray *dataSoure;
@property (weak, nonatomic) IBOutlet UIView *boundView;
@property (strong, nonatomic) IBOutlet UIView *actitvityView;

- (IBAction)pickImage:(id)sender;
- (void) updateView;
- (IBAction)finish:(id)sender;

@end

@interface NSObject (InsertPictureViewControllerDelegate)

- (void) InsertPictureDidDisappear;

@end
