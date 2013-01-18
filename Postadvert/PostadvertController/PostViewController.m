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
#import "PostadvertControllerV2.h"
#import "MyUIImagePickerViewController.h"

#define MaxImageCanSave  20
#define marginImage 15.0
#define cLocalImageWidth 65.0
#define cLocalImageHeight 65.0

@interface PostViewController ()
- (void) updatePostBtnState;
-(IBAction)takePhoto:(id)sender ;
-(IBAction)chooseFromLibrary:(id)sender;
- (UIImage *)fixOrientation:(UIImage*)image;
- (void) setActivityLocation;
@end

@implementation PostViewController
@synthesize popoverCtr;
@synthesize wall_id;


- (id)initWithWallID:(NSInteger) wallID
{
    self = [[PostViewController alloc]initWithNibName:@"PostViewController" bundle:nil];
    if (self) {
        self.wall_id = wallID;
    }
    return self;
}
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
    
    //Set up view
    self.titleView.layer.cornerRadius = 5.0;
    self.phTitleTextView.layer.cornerRadius = 5.0;
    [self.phTitleTextView setPlaceholder:@"Enter Title of Post ..."];
    [self.phTextView setPlaceholder:@"Type the Contents of Post ..."];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWilBeShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [(UITextView*)_phTitleTextView becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setTitleView:nil];
    [self setPhTitleTextView:nil];
    [self setBtnTitle:nil];
    [self setTopView:nil];
    [super viewDidUnload];
    imagePicker = nil;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self setModalInPopover:YES];
    [self updateViewAfterRatation];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //delete old file
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *pathToDocuments=[paths objectAtIndex:0];
//    for (int i =1; i <= nextID; i++) {
//        [[NSFileManager defaultManager]removeItemAtPath:[NSString stringWithFormat:@"%@/newPost%d.jpg", pathToDocuments, i] error:nil];
//    }
//    paths = nil;
//    pathToDocuments = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    if (interfaceOrientation==UIInterfaceOrientationPortrait ) {
        return YES;
    } else {
        return NO;
    }
}
-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"Rotated %@", self);
    [self setActivityLocation];
    [self updateViewAfterRatation];
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
    
    //insertEasyPost($user_id, $wall_id, $title, $content, $image, $limit, $base64_image = false)
    id data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    functionName = @"insertEasyPost";
    
    paraNames = [NSArray arrayWithObjects:@"user_id", @"wall_id", @"title", @"content", @"image", @"limit", nil];
    paraValues = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld", [UserPAInfo sharedUserPAInfo].registrationID], [NSString stringWithFormat:@"%d",self.wall_id], _phTitleTextView.text, _phTextView.text, @"", @"1", nil];
    
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName: functionName parametterName:paraNames parametterValue:paraValues];
    
    NSInteger newPostId;
    @try {
        NSDictionary *dict = [data objectAtIndex:0];
        
        newPostId = [[[dict objectForKey:@"post"] objectForKey:@"id"]integerValue];
    }
    @catch (NSException *exception) {
        
    }

    // testing
    //newPostId = 1464;
    if (self.delegate && listImageNeedToPost.count) {
        [self.delegate uploadImagesToPostID:newPostId andListImages:listImageNeedToPost];
    }
    
//    NSData *imageData;
//    NSString *encodedImage;
//    if (listImageNeedToPost.count) {
//        functionName = @"uploadPostImage";
//        
//         paraNames = [NSArray arrayWithObjects:@"imageString", @"post_id", nil];
//        int count = 0;
//        while (count < listImageNeedToPost.count) {
//            imageData =[[NSData alloc]initWithContentsOfFile:[listImageNeedToPost objectAtIndex:count]];
//            encodedImage = [imageData base64EncodedString];
//            count ++;
//            paraValues = [NSArray arrayWithObjects:encodedImage,[NSString stringWithFormat:@"%d", newPostId], nil];
//            //uploadPostImage($imageString, $post_id, $folder = ''
//            
//            data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName: functionName parametterName:paraNames parametterValue:paraValues];
//            
//        }
//    }
    self.navigationController.navigationBarHidden = NO;
    [self dismissModalViewControllerAnimated:YES];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"plusSuccessWithPost" object:nil];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"newPostWithData" object:nil];
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
    //[self SaveAndShowImage:info];
    [NSThread detachNewThreadSelector:@selector(SaveAndShowImage:) toTarget:self withObject: info];
    
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
#pragma mark - Handle Keyboard

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWilBeShown:(NSNotification*)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    CGRect frame = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    frame = [self.view convertRect:frame fromView:nil];
    
    CGRect frameMainView = self.view.bounds;
    
    //frameMainView = [self.view convertRect:frameMainView fromView:nil];
    
    float maxHeigh =  frameMainView.size.height - (self.scrollView.frame.origin.y + self.phTextView.frame.origin.y + frame.size.height);
    if (self.scrollView.frame.size.height < maxHeigh) {
        maxHeigh = self.scrollView.frame.size.height;
    }
    
    frame = self.phTextView.frame;
    frame.size.height = maxHeigh;
    self.phTextView.frame = frame;
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    //    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    //    ((UIScrollView*) self.view).contentInset = contentInsets;
    //    ((UIScrollView*) self.view).scrollIndicatorInsets = contentInsets;
    NSDictionary *userInfo = [aNotification userInfo];
    CGRect frame = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    frame = [self.view convertRect:frame fromView:nil];
    
    
}

- (void) updateViewAfterRatation
{
    CGRect frame;
    CGRect frameBotView = self.botView.frame;
    CGRect frameScrollView = self.scrollView.frame;
    CGRect frameMainView = self.view.bounds;
    
    frameScrollView.size.height = frameMainView.size.height - frameBotView.size.height - frameScrollView.origin.y;
    if (frameScrollView.size.height < 0) {
        frameScrollView.size.height = 0;
    }
    self.scrollView.frame = frameScrollView;
    //Update Photobtn
    frame = self.photoButton.frame;
    frame.origin.y = frameScrollView.size.height - frame.size.height;
    self.photoButton.frame = frame;
    
}
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
    NSString *titleText = [_phTitleTextView.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    titleText = [titleText stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([titleText isEqualToString:@""]) {
        canEnable = NO;
    }
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
    [self.phTitleTextView resignFirstResponder];
}

-(IBAction)takePhoto:(id)sender 
{
    
    MyUIImagePickerViewController *picker = [[MyUIImagePickerViewController alloc]initWithRoot:self];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:^(void)
     {
         NSLog(@"Presented");
         [self setActivityLocation];
         self.activity.hidden = NO;
         [self.activity startAnimating ];
         self.btnPost.enabled = NO;
         self.botView.userInteractionEnabled = NO;
     }];
    
//    // Set source to the camera
//    if ([UIImagePickerController isSourceTypeAvailable:
//         UIImagePickerControllerSourceTypeCamera]) 
//    {
//        // Set source to the Photo Library
//        imagePicker.sourceType =UIImagePickerControllerSourceTypeCamera;
//        
//    }
//	[self presentViewController:imagePicker animated:YES completion:^(void)
//     {
//         NSLog(@"presend completion");
//     }];
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
    UIImage *image = [[UIImage imageWithContentsOfFile:path]resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(cLocalImageWidth, cLocalImageHeight) interpolationQuality:0];
    NSInteger total = listImageNeedToPost.count;
    image = [image croppedImage:CGRectMake(0, 0, cLocalImageWidth, cLocalImageHeight)];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.frame = CGRectMake( 10,10, cLocalImageWidth, cLocalImageHeight);
    
    //Bound
    UIView *boundView = [[UIView alloc]initWithFrame:CGRectMake( ( (cLocalImageWidth + marginImage)* (total - 1)) + CELL_CONTENT_MARGIN_LEFT, 0, cLocalImageWidth + marginImage, cLocalImageHeight + marginImage)];
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
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    //NSData *imageData = UIImagePNGRepresentation(image);
    NSLog(@"Before %f %f %f", image.size.width, image.size.height, imageData.length/(1024*1024.0f));
    float leng = imageData.length / (1024.0f*1024.0f );
    float f = 1;
    while (leng > 4) {
        f -= 0.1;
        if (f < 0) {
            break;
        }
        imageData = UIImageJPEGRepresentation(image, f);
        leng = imageData.length / (1024.0f*1024.0f );
        NSLog(@"Before %f %f %f", image.size.width, image.size.height, leng);
    }
    
   

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
    [self performSelectorOnMainThread:@selector(updatePostBtnState) withObject:nil waitUntilDone:NO];
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
            frame.origin.x = (cLocalImageWidth + marginImage)* index + CELL_CONTENT_MARGIN_LEFT ;
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
    CGSize size = CGSizeMake((total)* (cLocalImageWidth + marginImage) + CELL_CONTENT_MARGIN_LEFT + CELL_CONTENT_MARGIN_RIGHT ,75);
    self.thumbnailView.contentSize = size;
}

#pragma mark - MyUIImagePickerViewController

- (void) didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self setActivityLocation];
    self.activity.hidden = NO;
    [self.activity startAnimating ];
    self.btnPost.enabled = NO;
    self.botView.userInteractionEnabled = NO;
    [self SaveAndShowImage:info];

}

//- (void) didFinishPickingMediaWithImage:(UIImage *)image
//{
//    [self setActivityLocation];
//    self.activity.hidden = NO;
//    [self.activity startAnimating ];
//    self.btnPost.enabled = NO;
//    self.botView.userInteractionEnabled = NO;
//    //save
//    nextID += 1;
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *pathToDocuments=[paths objectAtIndex:0];
//    NSString *filePath = [NSString stringWithFormat:@"%@/newPost%d.jpg", pathToDocuments, nextID];
//    NSLog(@"Before using UIImageJPEGRepresentation ");
//    NSData *imageData = UIImageJPEGRepresentation(image, 01.0f);
//    NSLog(@"After using UIImageJPEGRepresentation ");
//    NSLog(@"Path %@ ", filePath);
//    [imageData writeToFile: filePath atomically:YES];
//    NSLog(@"After Write File");
//    paths = nil;
//    imageData = nil;
//    image = nil;
//    pathToDocuments= nil;
//    NSLog(@"Before show Image");
//    [listImageNeedToPost addObject:filePath];
//    [self showThumbnailWithPath:filePath];
//    [self performSelectorOnMainThread:@selector(updatePostBtnState) withObject:nil waitUntilDone:NO];
//    self.botView.userInteractionEnabled = YES;
//    [self.activity stopAnimating];
//    self.activity.hidden = YES;
//}
- (void) didCancelPickingMedia
{
    [self performSelectorOnMainThread:@selector(updatePostBtnState) withObject:nil waitUntilDone:NO];
    self.botView.userInteractionEnabled = YES;
    [self.activity stopAnimating];
    self.activity.hidden = YES;
}

@end
