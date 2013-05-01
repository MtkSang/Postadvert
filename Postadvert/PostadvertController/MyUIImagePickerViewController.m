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

+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}



- (id) initWithRoot:(UIViewController*) root
{
    self = [super init];
    if (self) {
        _root = root;
        maxSize = 4;
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        maxSize = 4;
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated  {
    
    [super viewWillAppear:animated];
    return;
    // collect the photos
    NSMutableArray *collector = [[NSMutableArray alloc] initWithCapacity:0];
    ALAssetsLibrary *al = [MyUIImagePickerViewController defaultAssetsLibrary];
    
    [al enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                      usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop)
          {
              if (asset) {
                  [collector addObject:asset];
              }
          }];
         
         self.photos = collector;
         [(UICollectionView*)self.view reloadData];
     }
                    failureBlock:^(NSError *error) { NSLog(@"Boom!!!");}
     ];
    
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
        if ( (![UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeCamera] ) && self.sourceType == UIImagePickerControllerSourceTypeCamera)
        {
            // Set source to the Photo Library
            self.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            
        }
        imagePicker.sourceType = self.sourceType;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}
#pragma mark - UIImagePickerControllerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [self performSelectorInBackground:@selector(selectedInfo:) withObject:info];
    //[self.delegate didFinishPickingMediaWithInfo:info];
    [picker dismissViewControllerAnimated:YES completion:^(void){
        NSLog(@"Finish");
    }];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{ //cancel
	
	[picker dismissViewControllerAnimated:YES completion:nil];
    if ([self.delegate respondsToSelector:@selector(didCancelPickingMedia)]) {
        [self.delegate didCancelPickingMedia];
    }
}

- (void) selectedInfo:(NSDictionary*)info
{
    if ([self.delegate respondsToSelector:@selector(didFinishPickingMediaWithInfo:)]) {
        [self.delegate didFinishPickingMediaWithInfo:info];
    }
    
    if ([self.delegate respondsToSelector:@selector(didFinishPickingMediaWithImage:)]) {
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        if (isScale) {
            image = [self selectedImage:image];
        }
        [self.delegate didFinishPickingMediaWithImage:image];
    }
}
- (UIImage*) selectedImage:(UIImage*)image
{
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    //NSData *imageData = UIImagePNGRepresentation(image);
    NSLog(@"Before %f %f %f", image.size.width, image.size.height, imageData.length/(1024*1024.0f));
    float leng = imageData.length / (1024.0f*1024.0f );
    float f = 1;
    if (leng > maxSize) {
        while (leng > maxSize) {
            f -= 0.1;
            if (f < 0) {
                break;
            }
            imageData = UIImageJPEGRepresentation(image, f);
            leng = imageData.length / (1024.0f*1024.0f );
            NSLog(@"Before %f %f %f", image.size.width, image.size.height, leng);
        }
        image = [UIImage imageWithData:imageData];
    }
//    if ([self.delegate respondsToSelector:@selector(didFinishPickingMediaWithImage:)]) {
//        [self.delegate didFinishPickingMediaWithImage:image];
//    }
    return image;
}

- (void) setMaxSizeImage:(NSInteger)maxSize_
{
    isScale = YES;
    maxSize = maxSize_;
}

//
//#pragma mark - UICollectionView Datasource
//- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
//{
//    return self.photos.count;
//}
//
//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
//{
//    return 1;
//}
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"FlickrCell" forIndexPath:indexPath];
//    if (!cell) {
//        cell = [[UICollectionViewCell alloc]init];
//        UIImageView *imagView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"defaultPhoto.png"]];
//        imagView.tag = 1;
//        [cell addSubview:imagView];
//    }
//    ALAsset *asset = [self.photos objectAtIndex:indexPath.row];
//    
//    UIImageView *imgView = (UIImageView*)[cell viewWithTag:1];
//    
//    [imgView setImage:[UIImage imageWithCGImage:[asset thumbnail]]];
//    
//    return cell;
//}
//
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"FlickPhotoHeaderView" forIndexPath:indexPath];
//
//    return headerView;
//}
//
//#pragma mark - UICollectionViewDelegate
//
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    if(!YES) // single
//    {
//
//    }
//    else //multilSelection
//    {
//
//    }
//    
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//   
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    ALAsset *asset = [self.photos objectAtIndex:indexPath.row];
//    UIImageView *imgView = [[UIImageView alloc]init];
//    [imgView setImage:[UIImage imageWithCGImage:[asset thumbnail]]];
//    CGSize retval = imgView.image.size.width > 0 ? imgView.image.size : CGSizeMake(100, 100);
//    retval.height += 35;
//    retval.width += 35;
//    return retval;
//}
//
//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
//{
//    return UIEdgeInsetsMake(50, 20, 50, 20);
//}



@end
