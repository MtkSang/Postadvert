//
//  Profile_PhotoListViewController.m
//  Stroff
//
//  Created by Ray on 10/17/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "Profile_PhotoListViewController.h"
#import "PostadvertControllerV2.h"
#import "NSData+Base64.h"
#import "UIImageView+URL.h"
#import "UIImageView+URL.h"
#import "UserPAInfo.h"
#import "Constants.h"
#import "SDWebImageRootViewController.h"
#import "SDWebImageDataSource.h"
#import <QuartzCore/QuartzCore.h>
#import "KTPhotoScrollViewController.h"
#import "SDWebImageDataSource.h"

@interface Profile_PhotoListViewController ()
- (void) sendAndShowImage:(NSDictionary *)info;
- (IBAction)didTapOnImageView:(UITapGestureRecognizer*)tapGesture;
@end

@implementation Profile_PhotoListViewController

@synthesize albumID;
@synthesize photoCount;
@synthesize navigationController;
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
    thumbSize_ = CGSizeMake(75, 75);
    scrollView.scrollEnabled = YES;
    listContent = [[NSMutableArray alloc]init];
    // Do any additional setup after loading the view from its nib.
    
    [self loadImage];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    UIButton *addButton = [[UIButton alloc]init];
    addButton.titleLabel.text = @"+";
    addButton.imageView.image = [UIImage imageNamed:@"iPad.png"];
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc]initWithCustomView:addButton];
    barBtnItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPicture:)];
    self.navigationItem.rightBarButtonItem = barBtnItem;
    //addButton = nil;
    //barBtnItem = nil;
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    scrollView = nil;
    [super viewDidUnload];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self performSelectorOnMainThread:@selector(updateViewForRotate) withObject:nil waitUntilDone:NO];
}
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}

#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[hud removeFromSuperview];
    hud = nil;
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)uias clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // user pressed "Cancel"
    if(buttonIndex == [uias cancelButtonIndex]) return;
    if([[uias buttonTitleAtIndex:buttonIndex] compare:@"Take Photo"] == NSOrderedSame)
    {
        [self takePhoto:nil];
    }
    if([[uias buttonTitleAtIndex:buttonIndex] compare:@"Choose From Library"] == NSOrderedSame)
    {
        [self chooseFromLibrary:nil];
    }
    
}
#pragma mark - UIImagePickerControllerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissModalViewControllerAnimated:YES];
    if (popoverCtr) {
        [popoverCtr dismissPopoverAnimated:YES];
    }
    
    [NSThread detachNewThreadSelector:@selector(sendAndShowImage:) toTarget:self withObject: info];
    //picker = nil;
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{ //cancel
	
	[picker dismissModalViewControllerAnimated:YES];
    if (popoverCtr) {
        [popoverCtr dismissPopoverAnimated:YES];
    }
    
	
}

#pragma mark -

- (void)loadImage
{
    //LOAD DATA
    MBProgressHUD *HUD;
    if (self.view.superview) {
        HUD = [[MBProgressHUD alloc]initWithView:self.view.superview];
        [self.view.superview addSubview:HUD];
    }else {
        HUD = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:HUD];
    }
    HUD.delegate = self;
    HUD.userInteractionEnabled = NO;
    [HUD setLabelText:@"Loading..."];
    [HUD showWhileExecuting:@selector(loadCellsInBackground) onTarget:self withObject:nil animated:YES];
}

- (void) loadCellsInBackground
{
    id data = [[PostadvertControllerV2 sharedPostadvertController] getPhotoOfAlbumWithAlbumID:[NSString stringWithFormat:@"%d", self.albumID]];
    if (data) {
        [listContent removeAllObjects];
        for (NSDictionary *dict in data) {
            if ([dict isKindOfClass:[NSDictionary class]]) {
                NSString *thumbnail, *fullImageLink, *num;
                thumbnail = [NSData stringDecodeFromBase64String:[dict objectForKey:@"thumbnail"]];
                fullImageLink = [NSData stringDecodeFromBase64String:[dict objectForKey:@"image"]];
                num = [dict objectForKey:@"photo_id"];
                NSArray *aImageInfo = [NSArray arrayWithObjects:fullImageLink, thumbnail, num, nil];
                [listContent addObject:aImageInfo];
            }
            
            
        }
    }
    for (UIImageView *imageView in scrollView.subviews) {
        if ([imageView isKindOfClass:[UIImageView class]] && imageView.tag > 0) {
            [imageView removeFromSuperview];
        }
    }
    [self performSelectorOnMainThread:@selector(drawView) withObject:nil waitUntilDone:NO];
    data = nil;
    
}

-(IBAction)takePhoto:(id)sender
{
    // Set source to the camera
    if (!imagePicker) {
        imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = NO;
    }
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        // Set source to the Photo Library
        imagePicker.sourceType =UIImagePickerControllerSourceTypeCamera;
        
    }
	[self presentModalViewController:imagePicker animated:YES];
}
-(IBAction)chooseFromLibrary:(id)sender
{
    // Set source to the camera
    if (!imagePicker) {
        imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = NO;
    }
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypePhotoLibrary])
    {
        // Set source to the Photo Library
        imagePicker.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
        
    }
    
    // Show image picker
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (!popoverCtr) {
            popoverCtr = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        }
        UIButton *btnSender = (UIButton*)sender;
        CGRect rect = [btnSender convertRect:btnSender.bounds toView:self.view];
        [popoverCtr presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [self presentModalViewController:imagePicker animated:YES];
    }
	
}

- (void) drawView
{
    CGRect visibleBounds = [self.view bounds];
    int visibleWidth = visibleBounds.size.width;
    // Do a bunch of math to determine which rows and colums
    // are visible.
    
    int itemsPerRow = floor(visibleWidth / thumbSize_.width);
    // Ensure a minimum of space between images.
    int minimumSpace = 5;
    if (visibleWidth - itemsPerRow * thumbSize_.width < minimumSpace) {
        itemsPerRow--;
    }
    
    if (itemsPerRow < 1) itemsPerRow = 1;  // Ensure at least one per row.
    
    int spaceWidth = round((visibleWidth - thumbSize_.width * itemsPerRow) / (itemsPerRow + 1));
    int spaceHeight = spaceWidth;
    
    // Calculate content size.
    int thumbCount = listContent.count;
    int rowCount = ceil(thumbCount / (float)itemsPerRow);
    int rowHeight = thumbSize_.height + spaceHeight;
    CGSize contentSize = CGSizeMake(visibleWidth, (rowHeight * rowCount + spaceHeight));
    [scrollView setContentSize:contentSize];
    // Set our initial origin.
    int x = spaceWidth;
    int y = spaceHeight;
    int index = 0;
    
    for (NSArray *aImageInfor in listContent) {

        UIImageView *imageView = [[UIImageView alloc]init];
        [imageView setImageWithURL:[NSURL URLWithString:[aImageInfor objectAtIndex:1] ] placeholderImage:[UIImage imageNamed:@"photoDefault.png"]];
        imageView.tag = index + 1;
        imageView.frame = CGRectMake(x, y, thumbSize_.width, thumbSize_.height);
        imageView.layer.borderColor = [UIColor colorWithWhite:0.85 alpha:1.0].CGColor;
        imageView.layer.borderWidth = 1;
        // Adjust the position.
        if ( (index+1) % itemsPerRow == 0) {
            // Start new row.
            x = spaceWidth;
            y += thumbSize_.height + spaceHeight;
        } else {
            x += thumbSize_.width + spaceWidth;
        }
        //add gesture to catch & show Enlagre Image
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapOnImageView:)];
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:tapGesture];
        [scrollView addSubview:imageView];
        index += 1;
        //destroy
        
    }
    
    
}

- (void) updateViewForRotate
{
    CGRect visibleBounds = [self.view bounds];
    int visibleWidth = visibleBounds.size.width;
    // Do a bunch of math to determine which rows and colums
    // are visible.
    
    int itemsPerRow = floor(visibleWidth / thumbSize_.width);
    // Ensure a minimum of space between images.
    int minimumSpace = 5;
    if (visibleWidth - itemsPerRow * thumbSize_.width < minimumSpace) {
        itemsPerRow--;
    }
    
    if (itemsPerRow < 1) itemsPerRow = 1;  // Ensure at least one per row.
    
    int spaceWidth = round((visibleWidth - thumbSize_.width * itemsPerRow) / (itemsPerRow + 1));
    int spaceHeight = spaceWidth;
    
    // Calculate content size.
    int thumbCount = listContent.count;
    int rowCount = ceil(thumbCount / (float)itemsPerRow);
    int rowHeight = thumbSize_.height + spaceHeight;
    CGSize contentSize = CGSizeMake(visibleWidth, (rowHeight * rowCount + spaceHeight));
    [scrollView setContentSize:contentSize];
    // Set our initial origin.
    int x = spaceWidth;
    int y = spaceHeight;
    int index = 0;
    
    for (UIImageView *imageView in scrollView.subviews) {
        if (imageView.tag <1 || ![imageView isKindOfClass:[UIImageView class]]) {
            continue;
        }
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        imageView.frame = CGRectMake(x, y, thumbSize_.width, thumbSize_.height);        
        [UIView commitAnimations];

        // Adjust the position.
        if ( (index+1) % itemsPerRow == 0) {
            // Start new row.
            x = spaceWidth;
            y += thumbSize_.height + spaceHeight;
        } else {
            x += thumbSize_.width + spaceWidth;
        }
        
        index += 1;
    }
}

- (IBAction)didTapOnImageView:(UITapGestureRecognizer*)tapGesture
{
    if ([tapGesture isKindOfClass:[UITapGestureRecognizer class]]) {
        
        UIView *imageView = tapGesture.view;
        NSInteger index = imageView.tag - 1;
    
        SDWebImageDataSource *dataSource_ = [[SDWebImageDataSource alloc]initWithArray:listContent];
        KTPhotoScrollViewController *newController = [[KTPhotoScrollViewController alloc]
                                                      initWithDataSource:dataSource_
                                                      andStartWithPhotoAtIndex:index];
        //EnlargeImageViewControllerV2 *newController = [[EnlargeImageViewControllerV2 alloc]initWithDataSource:dataSource_ andStartWithPhotoAtIndex:index];
        //[self addChildViewController:newController];
        //[[self navigationController] pushViewController:newController animated:YES];
        [[self navigationController] presentModalViewController:newController animated:YES];
        dataSource_ = nil;
        newController = nil;
    }
    
}

- (IBAction)addPicture:(id)sender
{
    UIActionSheet *uias = [[UIActionSheet alloc] initWithTitle:nil
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:@"Take Photo", @"Choose From Library",  nil];
    
    [uias showInView:self.view];
    uias = nil;
}

- (void) sendAndShowImage:(NSDictionary *)info
{
    //send to server
    
    //refresh 
    [self performSelectorOnMainThread:@selector(loadImage) withObject:nil waitUntilDone:NO];
}
@end
