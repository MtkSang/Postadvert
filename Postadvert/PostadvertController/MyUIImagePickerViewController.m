//
//  MyUIImagePickerViewController.m
//  Stroff
//
//  Created by Ray on 11/23/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "MyUIImagePickerViewController.h"

@interface MyUIImagePickerViewController ()

@end

@implementation MyUIImagePickerViewController

- (id) initWithRoot:(UIViewController*) root
{
    self = [super init];
    if (self) {
        _root = root;
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

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(!isShowed)
    {
        isShowed = YES;
        imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.delegate = self;
        // Set source to the camera
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeCamera])
        {
            // Set source to the Photo Library
            imagePicker.sourceType =UIImagePickerControllerSourceTypeCamera;
            
        }

        [self presentViewController:imagePicker animated:YES completion:^(void)
         {
             NSLog(@"presend completion");
         }];
    }else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isShowed = NO;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIImagePickerControllerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [self performSelectorInBackground:@selector(selectedImage:) withObject:image];
    [picker dismissViewControllerAnimated:YES completion:^(void){
        NSLog(@"Finish");
    }];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{ //cancel
	
	[picker dismissViewControllerAnimated:YES completion:nil];
    if (self.delegate) {
        //[self.delegate didCancelPickingMedia];
    }
}

- (void) selectedImage:(UIImage*)image
{
    if (self.delegate) {
        [self.delegate didFinishPickingMediaWithImage:image];
    }
}

@end
