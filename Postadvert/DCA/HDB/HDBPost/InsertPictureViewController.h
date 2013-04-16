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

}
@property (strong, nonatomic) IBOutlet UIButton *btnInsertPicture;
@property (strong, nonatomic) NSMutableArray *dataSoure;
@property (weak, nonatomic) IBOutlet UIView *boundView;

- (IBAction)pickImage:(id)sender;

@end
