//
//  PostViewController.m
//  Postadvert
//
//  Created by Mtk Ray on 6/8/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "PostViewController.h"
#import "UserPAInfo.h"
#import "ImageViewController.h"
#import "PostCellContent.h"
#import "UIPlaceHolderTextView.h"
#import "ImageViewController.h"
#import "UIPostCell.h"
#import "SBJson.h"
#import "AppDelegate.h"
#import "UIImage+Resize.h"
#import "NSData+Base64.h"
#import <QuartzCore/QuartzCore.h>

#define MaxImageCanSave  20
#define marginImage 15.0

@interface PostViewController ()
- (void) updatePostBtnState;
-(IBAction)takePhoto:(id)sender ;
-(IBAction)chooseFromLibrary:(id)sender;
- (UIImage *)fixOrientation:(UIImage*)image;
- (void) setActivityLocation;
@end

@implementation PostViewController
@synthesize activity = _activity, avatarImg = _avatarImg, phTextView = _phTextView, scrollView = _scrollView, btnPost = _btnPost, thumbnailView = _thumbnailView, botView = _botView, photoButton = _photoButton;
@synthesize popoverCtr = _popoverCtr;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib
    self.navigationController.navigationBarHidden = YES;
    self.activity.hidden = YES;
    [self.phTextView becomeFirstResponder];
    self.avatarImg.image = [UserPAInfo sharedUserPAInfo].imgAvatar;
    [self.photoButton setImage:[UIImage imageNamed:@"icon_capture_photo_sel.png"] forState:UIControlStateSelected];
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(makeKeyboardGoAway:)];
    [self.thumbnailView addGestureRecognizer:tapGesture];
    tapGesture = nil;
    
    //
    listImageNeedToPost = [[NSMutableArray alloc]init];
    nextID = 0;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    imagePicker = nil;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self setModalInPopover:YES];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //delete old file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *pathToDocuments=[paths objectAtIndex:0];
    for (int i =1; i <= nextID; i++) {
        [[NSFileManager defaultManager]removeItemAtPath:[NSString stringWithFormat:@"%@/newPost%d.jpg", pathToDocuments, i] error:nil];
    }
    paths = nil;
    pathToDocuments = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"Rotated %@", self);
    [self setActivityLocation];
}

//- (void) dealloc
//{
//    
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - toolbar

-(IBAction)backButtinClicked{
    [self dismissModalViewControllerAnimated:YES];
    self.navigationController.navigationBarHidden = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"plusSuccessNoPost" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newPostWithOutData" object:nil];
    
}

-(IBAction)postButtinClicked{
    
    [[NSUserDefaults standardUserDefaults] setObject:self.phTextView.text forKey:@"_text_NewPost"];
    [[NSUserDefaults standardUserDefaults] setInteger:nextID forKey:@"_nextID_NewPost"];
    self.navigationController.navigationBarHidden = NO;
    [self dismissModalViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"plusSuccessWithPost" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newPostWithData" object:nil];
}


#pragma mark - UIImagePickerControllerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissModalViewControllerAnimated:YES];
    if (self.popoverCtr) {
        [self.popoverCtr dismissPopoverAnimated:YES];
    }
    [self setActivityLocation];
    self.activity.hidden = NO;
    [self.activity startAnimating ];
    self.btnPost.enabled = NO;
    self.botView.userInteractionEnabled = NO;
    //UIImage *image = [self normalizedImage:[info objectForKey:@"UIImagePickerControllerOriginalImage"]];
    //[info setValue:nil forKey:@"UIImagePickerControllerOriginalImage"];
    [NSThread detachNewThreadSelector:@selector(SaveAndShowImage:) toTarget:self withObject: info];
    //picker = nil;
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{ //cancel
	
	[picker dismissModalViewControllerAnimated:YES];
    if (self.popoverCtr) {
        [self.popoverCtr dismissPopoverAnimated:YES];
    }

	
}


#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
//    if ([textView.text isEqualToString:@""]) {
//        self.btnPost.enabled = NO;
//    }else {
//        self.btnPost.enabled = YES;
//    }
    [self updatePostBtnState];
}

#pragma mark - implement
- (void) updatePostBtnState
{
    BOOL canEnable = NO;
    if (listImageNeedToPost.count) {
        canEnable = YES;
    }
    NSString *text = [_phTextView.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if ([_phTextView.text isEqualToString:@""] || [text isEqualToString:@""]) {
        //canEnable = NO;
    }else {
        canEnable = YES;
    }
    text = nil;
    
    //Update post btn
    if (canEnable) {
        _btnPost.enabled = YES;
    }else {
        _btnPost.enabled = NO;
    }
}

- (IBAction)makeKeyboardGoAway:(id)sender
{
    [self.phTextView resignFirstResponder];
}

-(IBAction)takePhoto:(id)sender 
{
    // Set source to the camera
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera]) 
    {
        // Set source to the Photo Library
        imagePicker.sourceType =UIImagePickerControllerSourceTypeCamera;
        
    }
    
    // Show image picker
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *pathToDocuments=[paths objectAtIndex:0];
//    NSError *error;
//    [[NSFileManager defaultManager]removeItemAtPath:[NSString stringWithFormat:@"%@/newPost%d.jpg", pathToDocuments, nextID + 1] error:&error];
//    if (error) {
//        NSLog(@"Error %@", error);
//    }
//    paths = nil;
//    pathToDocuments = nil;
	[self presentModalViewController:imagePicker animated:YES];
}
-(IBAction)chooseFromLibrary:(id)sender 
{
    // Set source to the camera
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypePhotoLibrary]) 
    {
        // Set source to the Photo Library
        imagePicker.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
        
    }
    
    // Show image picker
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (! self.popoverCtr) {
           self.popoverCtr = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        }
        UIButton *btnSender = (UIButton*)sender;
        CGRect rect = [btnSender convertRect:btnSender.bounds toView:self.view];
        [self.popoverCtr presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [self presentModalViewController:imagePicker animated:YES];
    }
	
}

- (UIImage *)fixOrientation:(UIImage*)image
{
    
    // No-op if the orientation is already correct
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    image = nil;
    return img;
}

- (UIImage *)normalizedImage:(UIImage*)image {
    if (image == nil) {
        return nil;
    }
    if (image.imageOrientation == UIImageOrientationUp) return image; 
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:(CGRect){0, 0, image.size}];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void) showThumbnailWithPath:(NSString*) path
{
    UIImage *image = [[UIImage imageWithContentsOfFile:path]resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(cImageWidth, cImageHeight) interpolationQuality:0];
    NSInteger total = listImageNeedToPost.count;
    image = [image croppedImage:CGRectMake(0, 0, cImageWidth, cImageHeight)];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.frame = CGRectMake( 10,10, cImageWidth, cImageHeight);
    
    //Bound
    UIView *boundView = [[UIView alloc]initWithFrame:CGRectMake( ( (cImageWidth + marginImage)* (total - 1)) + CELL_CONTENT_MARGIN_LEFT, 0, cImageWidth + marginImage, cImageHeight + marginImage)];
    UIButton *delete_btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 22, 22)];
    //delete_btn.layer.cornerRadius = 3.0;
    [delete_btn setImage:[UIImage imageNamed:@"remove.png"] forState:UIControlStateNormal];
    [delete_btn setTitle:path forState:UIControlStateNormal];
    [delete_btn addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
    
    [boundView addSubview:imgView];
    [boundView addSubview:delete_btn];
    boundView.tag = total;
    
    [self.thumbnailView addSubview:boundView];
    [self setThumbnailContentSize];
    imgView = nil;
    
}
- (void) SaveAndShowImage:(NSDictionary *)info
{
    NSLog(@"Start My Function");
    //UIImage *image = [self normalizedImage: [info objectForKey:@"UIImagePickerControllerOriginalImage"]];
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    NSLog(@"Getting paths");
    //save
    nextID += 1;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *pathToDocuments=[paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/newPost%d.jpg", pathToDocuments, nextID];
    NSLog(@"Before using UIImageJPEGRepresentation ");
    NSData *imageData = UIImageJPEGRepresentation(image, 01.0f);
    NSLog(@"After using UIImageJPEGRepresentation ");
    NSLog(@"Path %@ ", filePath);
    [imageData writeToFile: filePath atomically:YES];
    NSLog(@"After Write File");
    paths = nil;
    imageData = nil;
    image = nil;
    pathToDocuments= nil;
    NSLog(@"Before show Image");
    [listImageNeedToPost addObject:filePath];
    [self showThumbnailWithPath:filePath];
    
    self.btnPost.enabled = YES;
    self.botView.userInteractionEnabled = YES;
    [self.activity stopAnimating];
    self.activity.hidden = YES;
}

- (void) setActivityLocation
{
    CGRect frame = self.activity.frame;
    frame.origin.x = self.botView.center.x - frame.size.width/2.0;
    self.activity.frame = frame;
}

- (void) deleteImage:(id) sender
{
    UIButton *delete_btn = (UIButton*)sender;
    NSString *path = delete_btn.titleLabel.text;
    NSInteger index = -1;
    //Find out the which is tapped
    for (NSString *str in listImageNeedToPost) {
        if ([str isEqualToString:path]) {
            index = [listImageNeedToPost indexOfObject:str];
            [listImageNeedToPost removeObject:str];
            break;
        }
    }
    if (index >= 0) {
        UIView *view = [self.thumbnailView viewWithTag:index + 1];
        [view removeFromSuperview];
        view = nil;
    }
    
    //Re-locate view
    
    index = 0;
    for (UIView *view in self.thumbnailView.subviews) {
        if (view.tag > 0) {
            CGRect frame = view.frame;
            frame.origin.x = (cImageWidth + marginImage)* index + CELL_CONTENT_MARGIN_LEFT ;
            //
            [UIView setAnimationDuration:0.0];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector( animationDidStop:finished:context: )];
            [UIView beginAnimations:@"PostAdvert11" context:(__bridge void *)view];
            view.frame = frame;
            [UIView commitAnimations];
            index ++;
            view.tag = index;
        }
    }
    [self updatePostBtnState];
    [self setThumbnailContentSize];
}
- (void) setThumbnailContentSize
{
    int total = listImageNeedToPost.count;
    CGSize size = CGSizeMake((total)* (cImageWidth + marginImage) + CELL_CONTENT_MARGIN_LEFT + CELL_CONTENT_MARGIN_RIGHT ,75);
    self.thumbnailView.contentSize = size;
}
@end
