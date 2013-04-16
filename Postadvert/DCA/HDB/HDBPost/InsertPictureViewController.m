//
//  InsertPictureViewController.m
//  Stroff
//
//  Created by Ray on 4/12/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import "InsertPictureViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MyUIImagePickerViewController.h"

#define maxNumAllow  8
@interface InsertPictureViewController ()

@end

@implementation InsertPictureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _dataSoure = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.boundView.layer.cornerRadius = 5.0;
    if (!_dataSoure) {
        _dataSoure = [[NSMutableArray alloc]init];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    
    [self setBoundView:nil];
    [self setBtnInsertPicture:nil];
    [super viewDidUnload];
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:NO];
    [self updateView];
    
    
    //            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //            NSString *pathToDocuments=[paths objectAtIndex:0];
    //            NSString *filePath = [NSString stringWithFormat:@"%@/newPost%d.jpg", pathToDocuments, nextID];
    //            NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    //            [imageData writeToFile: filePath atomically:YES];
    
}
- (void) updateView
{
    NSInteger index = 1;
    while (index < _dataSoure.count) {
        UIImageView *imageView = (UIImageView*)[_boundView viewWithTag:index];
        [imageView setUserInteractionEnabled:YES];
        if (imageView) {
            UIImage *image = [UIImage imageWithContentsOfFile:[_dataSoure objectAtIndex:index - 1]];
            if (image) {
                [imageView setImage:image];
            }
        }

        index ++;
    }
    if (index <= maxNumAllow) {
        //[self performSelectorOnMainThread:@selector(showBtnInsertPicAtIndex:) withObject:[NSNumber numberWithInteger:index] waitUntilDone:NO];
        [self showBtnInsertPicAtIndex:[NSNumber numberWithInteger:index]];
        index ++;
    }
    while (index <= maxNumAllow) {
        UIImageView *imageView = (UIImageView*)[_boundView viewWithTag:index];
        //[imageView setUserInteractionEnabled:NO];
        [imageView setImage:[UIImage imageNamed:@"uploadImageBlankIcon.png"]];
    }
}

- (void) showBtnInsertPicAtIndex:(NSNumber*)num
{
    if (num.integerValue > maxNumAllow) {
        [_btnInsertPicture removeFromSuperview];
        return;
    }
    UIImageView *imageView = (UIImageView*)[_boundView viewWithTag:num.integerValue];
    [imageView setUserInteractionEnabled:YES];
    CGRect btnFrame = imageView.frame;
    btnFrame.origin.x = 0;
    btnFrame.origin.y = 0;
    _btnInsertPicture.frame = imageView.frame;
    [_boundView addSubview:_btnInsertPicture];
}
- (IBAction)pickImage:(id)sender
{
    UIView *aView = (UIView*)sender;
    UIActionSheet *actionView = [[UIActionSheet alloc]initWithTitle:@"Select photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose From Library", nil];
    
    [actionView showFromRect:aView.frame inView:self.view animated:YES];
    
}

#pragma mark UIActionSheetDelegate
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    MyUIImagePickerViewController *newPicker = [[MyUIImagePickerViewController alloc]initWithRoot:self];
    newPicker.delegate = self;
    
    if (buttonIndex == 0) {
        newPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    if (buttonIndex == 1) {
        newPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:newPicker animated:YES completion:^(void){
        NSLog(@"presented");
    }];
}
#pragma mark MyUIImagePickerViewControllerDelegate

- (void) didCancelPickingMedia
{
    
}

- (void) didFinishPickingMediaWithImage:(UIImage *)image
{


}
@end
