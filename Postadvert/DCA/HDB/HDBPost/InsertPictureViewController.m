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
#import "Constants.h"
#define maxNumAllow  8
@interface InsertPictureViewController ()

@end

@implementation InsertPictureViewController

@synthesize delegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _dataSoure = [[NSMutableArray alloc]init];
        _keyForTitle = @"Upload Images";
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
    for (NSInteger i = 1; i <= maxNumAllow; i++) {
        UIButton *btnView = (UIButton*)[_boundView viewWithTag:i];
        [btnView.imageView setContentMode:UIViewContentModeScaleAspectFill];
    }
    nextID = [self loadNextID];
    [self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    
    [self setBoundView:nil];
    [self setBtnInsertPicture:nil];
    [self setActitvityView:nil];
    [super viewDidUnload];
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    nextID = [self loadNextID];
    //[self updateView];
}
- (void) viewDidDisappear:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(InsertPictureDidDisappear)]) {
        [self.delegate InsertPictureDidDisappear];
    }
    NSNumber *numNextID = [NSNumber numberWithInteger:nextID];
    [[NSUserDefaults standardUserDefaults] setValue:numNextID forKey:currentMaxNextIDForLocalImage];
}
- (NSInteger) loadNextID
{
    NSNumber *numNextID = [[NSUserDefaults standardUserDefaults] objectForKey:currentMaxNextIDForLocalImage];
    if (numNextID) {
        return [numNextID integerValue];
    }
    return 0;
}
- (void) updateView
{
    NSInteger index = 1;
    while (index <= _dataSoure.count) {
        UIButton *btnView = (UIButton*)[_boundView viewWithTag:index];
        [btnView setUserInteractionEnabled:YES];
        if (btnView) {
            UIImage *image = [UIImage imageWithContentsOfFile:[_dataSoure objectAtIndex:index - 1]];
            if (image) {
                [btnView setImage:image forState:UIControlStateNormal];
                [btnView.imageView setContentMode:UIViewContentModeScaleAspectFill];
            }
        }
        index ++;
    }
    if (index <= maxNumAllow) {
        //[self performSelectorOnMainThread:@selector(showBtnInsertPicAtIndex:) withObject:[NSNumber numberWithInteger:index] waitUntilDone:NO];
        UIButton *btnView = (UIButton*)[_boundView viewWithTag:index];
        [btnView setUserInteractionEnabled:YES];
        [btnView setImage:[UIImage imageNamed:@"uploadImageIcon.png"] forState:UIControlStateNormal];
        index ++;
    }
    while (index <= maxNumAllow) {
        UIButton *btnView = (UIButton*)[_boundView viewWithTag:index];
        [btnView setUserInteractionEnabled:NO];
        [btnView setImage:[UIImage imageNamed:@"uploadImageBlankIcon.png"] forState:UIControlStateNormal];
        index ++;
    }
    self.actitvityView.hidden = YES;
}

- (IBAction)finish:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) updateLastViewWithImage:(UIImage*)image
{
    NSInteger index = _dataSoure.count + 1;
    UIButton *btnView = (UIButton*)[_boundView viewWithTag:index];
    [btnView setImage:image forState:UIControlStateNormal];
    
    UIButton *btnViewInsertPic = (UIButton*)[_boundView viewWithTag:index + 1];
    if (btnViewInsertPic) {
        [btnViewInsertPic setImage:[UIImage imageNamed:@"uploadImageIcon.png"] forState:UIControlStateNormal];
        self.actitvityView.frame = btnViewInsertPic.frame;
        self.actitvityView.hidden = NO;
    }
    
}
- (void) addDataWithImage:(UIImage*)image
{
    nextID ++;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *pathToDocuments=[paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/newPost%d.jpg", pathToDocuments, nextID];
    [_dataSoure addObject:filePath];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    [imageData writeToFile: filePath atomically:YES];
    [self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:NO];
    NSNumber *numNextID = [NSNumber numberWithInteger:nextID];
    [[NSUserDefaults standardUserDefaults] setValue:numNextID forKey:currentMaxNextIDForLocalImage];
}
//- (void) showBtnInsertPicAtIndex:(NSNumber*)num
//{
//    UIImageView *imageView = (UIImageView*)[_boundView viewWithTag:num.integerValue];
//    [imageView setUserInteractionEnabled:YES];
//    CGRect btnFrame = imageView.frame;
//    btnFrame.origin.x = 0;
//    btnFrame.origin.y = 0;
//    _btnInsertPicture.frame = imageView.frame;
//    [_boundView addSubview:_btnInsertPicture];
//}
- (IBAction)pickImage:(id)sender
{
    UIButton *aView = (UIButton*)sender;
    self.actitvityView.frame = aView.frame;
    if (aView.tag <= _dataSoure.count) {
        [aView setImage:[UIImage imageNamed:@"uploadImageBlankIcon.png"] forState:UIControlStateNormal];
        self.actitvityView.hidden = NO;
        [self performSelectorInBackground:@selector(removePhoto:) withObject:sender];
        return;
    }
    UIActionSheet *actionView = [[UIActionSheet alloc]initWithTitle:@"Select photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose From Library", nil];
    
    [actionView showFromRect:aView.frame inView:self.view animated:YES];
    
}
- (IBAction)removePhoto:(id)sender
{
    UIView *aView = (UIView*)sender;
    if (aView.tag > _dataSoure.count) {
        self.actitvityView.hidden = YES;
        return;
    }
    [_dataSoure removeObjectAtIndex:aView.tag - 1];
    [self updateView];
}
#pragma mark UIActionSheetDelegate
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    MyUIImagePickerViewController *newPicker = [[MyUIImagePickerViewController alloc]initWithRoot:self];
    newPicker.delegate = self;
    [newPicker setMaxSizeImage:2];
    if (buttonIndex == 0) {
        newPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    if (buttonIndex == 1) {
        newPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:newPicker animated:YES completion:^(void){
        self.actitvityView.hidden = NO;
        NSInteger index = _dataSoure.count + 1;
        UIButton *btnView = (UIButton*)[_boundView viewWithTag:index];
        [btnView setImage:[UIImage imageNamed:@"uploadImageBlankIcon.png"] forState:UIControlStateNormal];
    }];
}
#pragma mark MyUIImagePickerViewControllerDelegate

- (void) didCancelPickingMedia
{
    self.actitvityView.hidden = YES;
    UIButton *btnView = (UIButton*)[_boundView viewWithTag:_dataSoure.count + 1];
    if ([btnView isKindOfClass:[UIButton class]]) {
        [btnView setUserInteractionEnabled:YES];
        [btnView setImage:[UIImage imageNamed:@"uploadImageIcon.png"] forState:UIControlStateNormal];
    }
    
}

- (void) didFinishPickingMediaWithImage:(UIImage *)image
{
    [self updateLastViewWithImage:image];
    [self performSelectorInBackground:@selector(addDataWithImage:) withObject:image];
}
@end
